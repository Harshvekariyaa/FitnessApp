import 'package:flutter/material.dart';
import '../../Themes_and_color/app_colors.dart';
import '../../api/api_service.dart';
import '../../ui_helper/common_widgets.dart';
import '../../workout/exercise_screen.dart';
class WorkoutPlans extends StatefulWidget {
  const WorkoutPlans({super.key});

  @override
  State<WorkoutPlans> createState() => _WorkoutPlansState();
}

class _WorkoutPlansState extends State<WorkoutPlans> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _workouts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodayWorkouts();
  }

  // ─── Fetch today's workout list ────────────────────────────────────────────
  Future<void> _fetchTodayWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await UserApiService.getTodayWorkouts();
      if (response['success'] == true) {
        final List data = response['data'] ?? [];
        setState(() => _workouts = data.cast<Map<String, dynamic>>());
      } else {
        setState(() => _errorMessage = 'Failed to load workouts.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Start or Resume a workout ─────────────────────────────────────────────
  //
  // Flow:
  //   A) Fresh start  (resume_available == false)
  //      1. POST startWorkout(workoutId)     → { session_id }
  //      2. GET  fetchWorkoutExercises(workoutId) → exercises[]
  //      3. Open ExerciseScreen at index 0
  //
  //   B) Resume  (resume_available == true)
  //      1. GET  resumeWorkoutApi(sessionId) → { resume_from_order, progress[] }
  //      2. GET  fetchWorkoutExercises(workoutId) → exercises[]
  //      3. Merge exercises with progress by exercise_order
  //      4. Open ExerciseScreen at the index that matches resume_from_order
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _openExerciseScreen(Map<String, dynamic> workout) async {
    final bool isCompleted    = (workout['status'] ?? '') == 'completed';
    if (isCompleted) return;

    final bool resumeAvail    = workout['resume_available'] ?? false;
    final int  workoutId      = workout['workout_id'];
    final String existingSession = workout['session_id'] ?? '';

    setState(() => _isLoading = true);
    try {
      String sessionId;
      int    startIndex = 0;
      List<Map<String, dynamic>> mergedExercises;

      // ── STEP 1: get exercise details (needed in both paths) ────────────────
      final exerciseResponse =
      await UserApiService.fetchWorkoutExercises(workoutId);
      if (exerciseResponse['success'] != true) {
        _showError('Failed to load exercises.');
        return;
      }
      // exercises[] shape from fetchWorkoutExercises:
      // [ { exercise_order: 1, exercise: { exercise_id, exercise_name,
      //     exercise_gif_full_url, exercise_description,
      //     exercise_sets, exercise_reps, exercise_duration_second } }, … ]
      final List<dynamic> exerciseDetails =
      List<dynamic>.from(exerciseResponse['data'] ?? []);

      if (resumeAvail && existingSession.isNotEmpty) {
        // ── PATH B: Resume ───────────────────────────────────────────────────
        final resumeResponse =
        await UserApiService.resumeWorkoutApi(sessionId: existingSession);
        if (resumeResponse['success'] != true) {
          _showError('Failed to resume workout.');
          return;
        }

        // resumeWorkoutApi response:
        // {
        //   "success": true,
        //   "data": {
        //     "resume_from_order": 2,        ← 1-based order to jump to
        //     "progress": [
        //       {
        //         "exercise_id"          : 19,
        //         "exercise_order"       : 1,
        //         "session_id"           : "session_xxx",
        //         "is_completed"         : 1,
        //         "sets_completed"       : 3,
        //         "reps_completed"       : 20,
        //         "exercise_duration_sec": 40,
        //         …
        //       }, …
        //     ]
        //   }
        // }
        final Map<String, dynamic> resumeData =
        Map<String, dynamic>.from(resumeResponse['data']);

        final int resumeFromOrder =
        (resumeData['resume_from_order'] ?? 1) as int;
        final List<dynamic> progressList =
        List<dynamic>.from(resumeData['progress'] ?? []);

        // session_id is identical across all progress rows
        sessionId = progressList.isNotEmpty
            ? (progressList[0]['session_id'] ?? existingSession).toString()
            : existingSession;

        // Build lookup: exercise_order → progress entry
        final Map<int, Map<String, dynamic>> progressByOrder = {
          for (final p in progressList)
            (p['exercise_order'] as int): Map<String, dynamic>.from(p as Map),
        };

        // Merge exercise details with their progress
        mergedExercises = exerciseDetails.map<Map<String, dynamic>>((detail) {
          final int order = (detail['exercise_order'] ?? 0) as int;
          final Map<String, dynamic> prog = progressByOrder[order] ?? {};
          return {
            ...Map<String, dynamic>.from(detail as Map),
            'is_completed'          : prog['is_completed']           ?? 0,
            'sets_completed'        : prog['sets_completed']         ?? 0,
            'reps_completed'        : prog['reps_completed']         ?? 0,
            'exercise_duration_sec' : prog['exercise_duration_sec']  ?? 0,
          };
        }).toList()
          ..sort((a, b) => (a['exercise_order'] as int)
              .compareTo(b['exercise_order'] as int));

        // Convert 1-based resume_from_order → 0-based list index
        startIndex = mergedExercises.indexWhere(
              (e) => (e['exercise_order'] as int) == resumeFromOrder,
        );
        if (startIndex == -1) startIndex = 0;
      } else {
        // ── PATH A: Fresh start ──────────────────────────────────────────────
        final startResponse =
        await UserApiService.startWorkout(workoutId);
        if (startResponse['success'] != true) {
          _showError('Failed to start workout.');
          return;
        }

        // startWorkout response: { "success": true, "data": { "session_id": "…" } }
        final Map<String, dynamic> startData =
        Map<String, dynamic>.from(startResponse['data'] ?? {});
        sessionId = (startData['session_id'] ?? '').toString();

        // All exercises start as not completed
        mergedExercises = exerciseDetails.map<Map<String, dynamic>>((detail) {
          return {
            ...Map<String, dynamic>.from(detail as Map),
            'is_completed'          : 0,
            'sets_completed'        : 0,
            'reps_completed'        : 0,
            'exercise_duration_sec' : 0,
          };
        }).toList()
          ..sort((a, b) => (a['exercise_order'] as int)
              .compareTo(b['exercise_order'] as int));

        startIndex = 0;
      }

      if (!mounted) return;

      // ── Navigate ───────────────────────────────────────────────────────────
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseScreen(
            sessionId  : sessionId,
            workoutId  : workoutId,
            exercises  : mergedExercises,
            startIndex : startIndex,
          ),
        ),
      );

      // Refresh list after returning so progress chips update
      if (result == true || result == null) _fetchTodayWorkouts();
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Today's Workouts"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _workouts.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _fetchTodayWorkouts,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _workouts.length,
                itemBuilder: (context, index) =>
                    _workoutPlanCard(workout: _workouts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────────────────
  Widget _buildSummaryHeader() {
    final total     = _workouts.length;
    final completed = _workouts.where((w) => w['status'] == 'completed').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          _summaryChip(icon: Icons.list_alt_rounded,         label: '$total Total',               color: Colors.blueGrey),
          const SizedBox(width: 10),
          _summaryChip(icon: Icons.check_circle_outline_rounded, label: '$completed Completed',   color: Colors.green),
          const SizedBox(width: 10),
          _summaryChip(icon: Icons.pending_actions_rounded,  label: '${total - completed} Pending', color: Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _workoutPlanCard({required Map<String, dynamic> workout}) {
    final String name         = workout['workout_name'] ?? '';
    final String imageUrl     = workout['workout_image_url'] ?? '';
    final int totalExercise   = workout['total_exercises'] ?? 0;
    final int completed       = workout['completed_exercises'] ?? 0;
    final String status       = workout['status'] ?? '';
    final bool resumeAvail    = workout['resume_available'] ?? false;
    final bool isCompleted    = status == 'completed';
    final double progress     = totalExercise > 0 ? completed / totalExercise : 0.0;

    return GestureDetector(
      onTap: isCompleted ? null : () => _openExerciseScreen(workout),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          image: imageUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover, onError: (_, __) {})
              : null,
          color: Colors.grey.shade800,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.80), Colors.black.withOpacity(0.30), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: 0, right: 0, child: _statusBadge(isCompleted: isCompleted)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _progressBar(progress: progress, completed: completed, total: totalExercise),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoChip(icon: Icons.fitness_center, text: '$totalExercise Exercises'),
                      const SizedBox(width: 10),
                      if (!isCompleted && resumeAvail)
                        _actionChip(
                          icon: Icons.play_arrow_rounded,
                          text: 'Resume',
                          color: Colors.blueAccent,
                          onTap: () => _openExerciseScreen(workout),
                        )
                      else if (!isCompleted)
                        _actionChip(
                          icon: Icons.play_circle_outline_rounded,
                          text: 'Start',
                          color: Colors.blueAccent,
                          onTap: () => _openExerciseScreen(workout),
                        )
                      else
                        _infoChip(icon: Icons.check_circle_outline, text: 'Done', color: Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge({required bool isCompleted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.85) : Colors.orange.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCompleted ? Icons.check_circle : Icons.pending_actions, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(isCompleted ? 'Completed' : 'Incomplete',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _progressBar({required double progress, required int completed, required int total}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$completed / $total exercises',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.greenAccent : Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _actionChip({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String text, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.white),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
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
            const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchTodayWorkouts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('No workouts scheduled for today.',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}