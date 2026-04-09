import 'package:flutter/material.dart';
import '../../Themes_and_color/app_colors.dart';
import '../../api/api_service.dart';
import '../../ui_helper/common_widgets.dart';
import '../../workout/exercise_screen.dart';
import '../../workout/ai_exercise_screen.dart';

class WorkoutPlans extends StatefulWidget {
  const WorkoutPlans({super.key});

  @override
  State<WorkoutPlans> createState() => _WorkoutPlansState();
}

class _WorkoutPlansState extends State<WorkoutPlans>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _regularWorkouts = [];
  List<Map<String, dynamic>> _aiWorkouts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTodayWorkouts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTodayWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await UserApiService.getTodayWorkouts();
      if (response['success'] == true) {
        final List<Map<String, dynamic>> all =
        (response['data'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _regularWorkouts = all
              .where((w) => w['workout_id'] != null && w['ai_workout_id'] == null)
              .toList();
          _aiWorkouts = all
              .where((w) => w['ai_workout_id'] != null && w['workout_id'] == null)
              .toList();
        });
      } else {
        setState(() => _errorMessage = 'Failed to load workouts.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openExerciseScreen(Map<String, dynamic> workout) async {
    debugPrint('🔍 workout map: $workout');

    final bool isCompleted = (workout['status'] ?? '') == 'completed';
    if (isCompleted) return;

    final bool resumeAvail = workout['resume_available'] ?? false;
    final String existingSession = workout['session_id'] ?? '';

    final int? workoutId = workout['workout_id'] != null
        ? int.tryParse(workout['workout_id'].toString())
        : null;
    final int? aiWorkoutId = workout['ai_workout_id'] != null
        ? int.tryParse(workout['ai_workout_id'].toString())
        : null;

    final bool isAiWorkout = aiWorkoutId != null && workoutId == null;
    final int? activeId = aiWorkoutId ?? workoutId;

    if (activeId == null) {
      _showError('Workout ID is missing.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      String sessionId;
      int startIndex = 0;
      List<Map<String, dynamic>> mergedExercises;

      if (resumeAvail && existingSession.isNotEmpty) {
        final resumeResponse =
        await UserApiService.resumeWorkoutApi(sessionId: existingSession);
        if (resumeResponse['success'] != true) {
          _showError('Failed to resume workout.');
          return;
        }

        final Map<String, dynamic> resumeData =
        Map<String, dynamic>.from(resumeResponse['data']);
        final int resumeFromOrder = (resumeData['resume_from_order'] ?? 1) as int;
        final List<dynamic> progressList =
        List<dynamic>.from(resumeData['progress'] ?? []);

        sessionId = progressList.isNotEmpty
            ? (progressList[0]['session_id'] ?? existingSession).toString()
            : existingSession;

        List<dynamic> exerciseDetails;
        if (isAiWorkout) {
          exerciseDetails = await UserApiService.fetchAiWorkoutExercises(activeId);
        } else {
          final exerciseResponse =
          await UserApiService.fetchWorkoutExercises(activeId);
          if (exerciseResponse['success'] != true) {
            _showError('Failed to load exercises.');
            return;
          }
          exerciseDetails = List<dynamic>.from(exerciseResponse['data'] ?? []);
        }

        final Map<int, Map<String, dynamic>> progressByOrder = {
          for (final p in progressList)
            (p['exercise_order'] as int): Map<String, dynamic>.from(p as Map),
        };

        mergedExercises = exerciseDetails.map<Map<String, dynamic>>((detail) {
          final int order = (detail['exercise_order'] ?? 0) as int;
          final Map<String, dynamic> prog = progressByOrder[order] ?? {};
          return {
            ...Map<String, dynamic>.from(detail as Map),
            'is_completed': prog['is_completed'] ?? 0,
            'sets_completed': prog['sets_completed'] ?? 0,
            'reps_completed': prog['reps_completed'] ?? 0,
            'exercise_duration_sec': prog['exercise_duration_sec'] ?? 0,
          };
        }).toList()
          ..sort((a, b) =>
              (a['exercise_order'] as int).compareTo(b['exercise_order'] as int));

        startIndex = mergedExercises
            .indexWhere((e) => (e['exercise_order'] as int) == resumeFromOrder);
        if (startIndex == -1) startIndex = 0;
      } else {
        List<dynamic> exerciseDetails;
        if (isAiWorkout) {
          exerciseDetails = await UserApiService.fetchAiWorkoutExercises(activeId);
        } else {
          final exerciseResponse =
          await UserApiService.fetchWorkoutExercises(activeId);
          if (exerciseResponse['success'] != true) {
            _showError('Failed to load exercises.');
            return;
          }
          exerciseDetails = List<dynamic>.from(exerciseResponse['data'] ?? []);
        }

        final startResponse = await UserApiService.startWorkout(activeId);
        if (startResponse['success'] != true) {
          _showError('Failed to start workout.');
          return;
        }

        final Map<String, dynamic> startData =
        Map<String, dynamic>.from(startResponse['data'] ?? {});
        sessionId = (startData['session_id'] ?? '').toString();

        mergedExercises = exerciseDetails.map<Map<String, dynamic>>((detail) {
          return {
            ...Map<String, dynamic>.from(detail as Map),
            'is_completed': 0,
            'sets_completed': 0,
            'reps_completed': 0,
            'exercise_duration_sec': 0,
          };
        }).toList()
          ..sort((a, b) =>
              (a['exercise_order'] as int).compareTo(b['exercise_order'] as int));

        startIndex = 0;
      }

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isAiWorkout
              ? AiExerciseScreen(
            sessionId: sessionId,
            aiWorkoutId: aiWorkoutId,
            exercises: mergedExercises,
            startIndex: startIndex,
          )
              : ExerciseScreen(
            sessionId: sessionId,
            workoutId: workoutId,
            exercises: mergedExercises,
            startIndex: startIndex,
          ),
        ),
      );

      if (result == true || result == null) _fetchTodayWorkouts();
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "Today's Workout",
          style: textStyle(AppColors.white, 20, AppColors.w500),
        ),
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade600.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(3),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('My Workouts'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 15),
                      SizedBox(width: 6),
                      Text('AI Workouts'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? buildLoader()
          : _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutList(
            workouts: _regularWorkouts,
            emptyMsg: 'No workouts scheduled for today.',
            emptyIcon: Icons.fitness_center,
            isAiTab: false,
          ),
          _buildWorkoutList(
            workouts: _aiWorkouts,
            emptyMsg: 'No AI workouts scheduled for today.',
            emptyIcon: Icons.auto_awesome_rounded,
            isAiTab: true,
          ),
        ],
      ),
    );
  }

  // ─── Loading State ───────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading workouts...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Per-tab list ─────────────────────────────────────────────────────────
  Widget _buildWorkoutList({
    required List<Map<String, dynamic>> workouts,
    required String emptyMsg,
    required IconData emptyIcon,
    required bool isAiTab,
  }) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Icon(emptyIcon, size: 38, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            Text(
              emptyMsg,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back tomorrow!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final total = workouts.length;
    final completed = workouts.where((w) => w['status'] == 'completed').length;
    final pending = total - completed;

    return RefreshIndicator(
      onRefresh: _fetchTodayWorkouts,
      color: Colors.blue.shade600,
      backgroundColor: const Color(0xFF1A1A2E),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: _buildStatsRow(
                total: total,
                completed: completed,
                pending: pending,
                isAiTab: isAiTab,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _workoutPlanCard(
                  workout: workouts[i],
                  isAiTab: isAiTab,
                  index: i,
                ),
                childCount: workouts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow({
    required int total,
    required int completed,
    required int pending,
    required bool isAiTab,
  }) {
    final Color accent = isAiTab ? Colors.deepPurpleAccent : Colors.blue.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _statItem(
            value: '$total',
            label: 'Total',
            icon: Icons.grid_view_rounded,
            color: Colors.blueGrey.shade300,
          ),
          _statDivider(),
          _statItem(
            value: '$completed',
            label: 'Done',
            icon: Icons.check_circle_rounded,
            color: Colors.greenAccent.shade400,
          ),
          _statDivider(),
          _statItem(
            value: '$pending',
            label: 'Pending',
            icon: Icons.timer_outlined,
            color: Colors.orangeAccent.shade200,
          ),
          const Spacer(),
          // Circular progress indicator
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0.0,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed == total && total > 0
                        ? Colors.greenAccent.shade400
                        : accent,
                  ),
                ),
                Text(
                  '${total > 0 ? ((completed / total) * 100).toInt() : 0}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.08),
    );
  }

  // ─── Card ─────────────────────────────────────────────────────────────────
  Widget _workoutPlanCard({
    required Map<String, dynamic> workout,
    required bool isAiTab,
    required int index,
  }) {
    final String name = isAiTab
        ? (workout['ai_workout_name'] ?? workout['workout_name'] ?? 'AI Workout')
        : (workout['workout_name'] ?? '');
    final String imageUrl = isAiTab
        ? (workout['ai_workout_image_url'] ?? workout['workout_image_url'] ?? '')
        : (workout['workout_image_url'] ?? '');

    final int totalExercise = workout['total_exercises'] ?? 0;
    final int completedEx = workout['completed_exercises'] ?? 0;
    final String status = workout['status'] ?? '';
    final bool resumeAvail = workout['resume_available'] ?? false;
    final bool isCompleted = status == 'completed';
    final double progress = totalExercise > 0 ? completedEx / totalExercise : 0.0;

    final Color accentColor =
    isAiTab ? Colors.deepPurpleAccent : Colors.blue.shade600;
    final Color accentGlow =
    isAiTab ? Colors.deepPurple : Colors.blue.shade900;

    return GestureDetector(
      onTap: isCompleted ? null : () => _openExerciseScreen(workout),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? Colors.green.withOpacity(0.12)
                  : accentGlow.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // ── Background image or gradient ──────────────────────────
              if (imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _cardFallbackBg(
                        isAiTab: isAiTab, isCompleted: isCompleted),
                  ),
                )
              else
                Positioned.fill(
                  child: _cardFallbackBg(
                      isAiTab: isAiTab, isCompleted: isCompleted),
                ),

              // ── Gradient overlay ──────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.88),
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.15),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              SizedBox(
                height: 210,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: AI badge + Status badge
                      Row(
                        children: [
                          if (isAiTab) _aiBadge(),
                          if (isAiTab) const SizedBox(width: 8),
                          _statusBadge(isCompleted: isCompleted),
                          const Spacer(),
                          // Exercise count pill
                          _glassChip(
                            icon: Icons.bolt_rounded,
                            text: '$totalExercise exercises',
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Workout name
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      _progressBar(
                        progress: progress,
                        completed: completedEx,
                        total: totalExercise,
                        color: isCompleted
                            ? Colors.greenAccent.shade400
                            : accentColor,
                      ),
                      const SizedBox(height: 14),
                      // Action button
                      if (!isCompleted)
                        _actionButton(
                          isResume: resumeAvail,
                          accentColor: accentColor,
                          onTap: () => _openExerciseScreen(workout),
                        )
                      else
                        _completedRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardFallbackBg({required bool isAiTab, required bool isCompleted}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAiTab
              ? [const Color(0xFF1A0533), const Color(0xFF2D1B69)]
              : [const Color(0xFF0A1628), const Color(0xFF0D2744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _aiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FBE), Color(0xFFAB57F7)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'AI Powered',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({required bool isCompleted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isCompleted
              ? Colors.greenAccent.withOpacity(0.5)
              : Colors.orangeAccent.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'Completed' : 'Pending',
            style: TextStyle(
              color: isCompleted ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar({
    required double progress,
    required int completed,
    required int total,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total done',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required bool isResume,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withOpacity(0.75)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isResume
                  ? Icons.play_arrow_rounded
                  : Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isResume ? 'Resume Workout' : 'Start Workout',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedRow() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded,
              color: Colors.greenAccent.shade400, size: 18),
          const SizedBox(width: 8),
          Text(
            'Workout Completed',
            style: TextStyle(
              color: Colors.greenAccent.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 36, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh or tap Retry',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _fetchTodayWorkouts,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade800.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
