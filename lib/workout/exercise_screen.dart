import 'package:fitnessai/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/workout/injury/injury_detailed_screen.dart';

/// ExerciseScreen
///
/// Receives [exercises] — a merged list built by WorkoutPlans.
/// Each item shape:
/// {
///   "exercise_order"       : int,
///   "is_completed"         : int,    ← 0 / 1
///   "sets_completed"       : int,
///   "reps_completed"       : int,
///   "exercise_duration_sec": int,
///   "exercise": {
///     "exercise_id"             : int,
///     "exercise_name"           : String,
///     "exercise_gif_full_url"   : String,
///     "exercise_description"    : String,
///     "exercise_sets"           : int,
///     "exercise_reps"           : int,
///     "exercise_duration_second": int
///   }
/// }
///
/// [startIndex] is the 0-based index WorkoutPlans resolved from
/// resume_from_order, so the user lands directly on their next exercise.
class ExerciseScreen extends StatefulWidget {
  final String sessionId;
  final int workoutId;
  final List<Map<String, dynamic>> exercises;
  final int startIndex;

  const ExerciseScreen({
    super.key,
    required this.sessionId,
    required this.workoutId,
    required this.exercises,
    this.startIndex = 0,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  late int currentIndex;
  bool isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _animateTransition(VoidCallback onChange) {
    _fadeController.reverse().then((_) {
      onChange();
      _fadeController.forward();
    });
  }

  // ─── Convenience getters ──────────────────────────────────────────────────
  Map<String, dynamic> get currentItem =>
      widget.exercises[currentIndex];
  Map<String, dynamic> get currentExercise =>
      Map<String, dynamic>.from(currentItem['exercise'] as Map);
  bool get alreadyCompleted => (currentItem['is_completed'] ?? 0) == 1;
  bool get isLastExercise =>
      currentIndex >= widget.exercises.length - 1;

  // ─── Mark Done ────────────────────────────────────────────────────────────
  Future<void> _onMarkDone() async {
    setState(() => isLoading = true);
    try {
      await UserApiService.updateExerciseProgress(
        sessionId: widget.sessionId,
        workoutId: widget.workoutId,
        exerciseId: currentExercise['exercise_id'],
        exerciseOrder: currentItem['exercise_order'],
        setsCompleted: currentExercise['exercise_sets'],
        repsCompleted: currentExercise['exercise_reps'],
        exerciseDurationSec: currentExercise['exercise_duration_second'],
        isCompleted: 1,
      );
      widget.exercises[currentIndex]['is_completed'] = 1;
      isLastExercise ? await _finishWorkout() : _goNext();
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─── Skip ─────────────────────────────────────────────────────────────────
  Future<void> _onSkip() async {
    setState(() => isLoading = true);
    try {
      await UserApiService.updateExerciseProgress(
        sessionId: widget.sessionId,
        workoutId: widget.workoutId,
        exerciseId: currentExercise['exercise_id'],
        exerciseOrder: currentItem['exercise_order'],
        isCompleted: 0,
      );
      widget.exercises[currentIndex]['is_completed'] = 0;
      isLastExercise ? await _finishWorkout() : _goNext();
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─── Finish Workout ───────────────────────────────────────────────────────
  Future<void> _finishWorkout() async {
    try {
      final result =
      await UserApiService.finishWorkout(sessionId: widget.sessionId);
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(result['data'] ?? {});
      final double calories =
      (data['total_calories'] ?? 0).toDouble();
      final int xp = (data['total_xp'] ?? 0).toInt();
      final int exercises =
      (data['total_exercises'] ?? 0).toInt();

      if (!mounted) return;
      _showCompleteDialog(
          calories: calories, xp: xp, exercises: exercises);
    } catch (e) {
      _showSnack('Error finishing workout: $e');
      if (mounted) Navigator.pop(context, true);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void _goNext() {
    if (currentIndex < widget.exercises.length - 1) {
      _animateTransition(() => setState(() => currentIndex++));
    } else {
      Navigator.pop(context, true);
    }
  }

  void _goPrevious() {
    if (currentIndex > 0) {
      _animateTransition(() => setState(() => currentIndex--));
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Workout Complete Dialog ──────────────────────────────────────────────
  void _showCompleteDialog({
    required double calories,
    required int xp,
    required int exercises,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle),
                child: const Center(
                    child: Text('🏆',
                        style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 16),
              const Text('Workout Complete!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff1c1c1e))),
              const SizedBox(height: 6),
              Text("Great job! Here's your summary",
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard(
                      icon: '🔥',
                      value: '$calories',
                      label: 'Calories',
                      color: Colors.orange.shade50),
                  _statCard(
                      icon: '⚡',
                      value: '$xp XP',
                      label: 'Earned',
                      color: Colors.blue.shade50),
                  _statCard(
                      icon: '💪',
                      value: '$exercises',
                      label: 'Exercises',
                      color: Colors.green.shade50),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1c1c1e))),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final exercise = currentExercise;
    final total = widget.exercises.length;
    final progress = (currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fc),
      appBar: commonAppBar(
        'Exercise ${currentIndex + 1}/$total',
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      InjuryDetailedScreen(injuryid: 12)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress bar ──
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ── Scrollable content ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise GIF card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              exercise['exercise_gif_full_url'] ?? '',
                              height: 260,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                  BorderRadius.circular(24),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.fitness_center_rounded,
                                        size: 52,
                                        color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('No preview available',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Completed badge overlay
                          if (alreadyCompleted)
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check_circle,
                                        size: 13,
                                        color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Done',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          // Exercise index chip
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${currentIndex + 1} / $total',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Name + description
                    Text(
                      exercise['exercise_name'] ?? '',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1c1c1e),
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exercise['exercise_description'] ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5),
                    ),

                    const SizedBox(height: 20),

                    // Duration / Sets / Reps — styled tiles
                    Row(
                      children: [
                        _metricTile(
                          icon: Icons.timer_outlined,
                          value:
                          '${exercise['exercise_duration_second']}s',
                          label: 'Duration',
                          iconColor: Colors.blue.shade400,
                          bgColor: Colors.blue.shade50,
                        ),
                        const SizedBox(width: 12),
                        _metricTile(
                          icon: Icons.repeat_rounded,
                          value: '${exercise['exercise_sets']}',
                          label: 'Sets',
                          iconColor: Colors.purple.shade400,
                          bgColor: Colors.purple.shade50,
                        ),
                        const SizedBox(width: 12),
                        _metricTile(
                          icon: Icons.fitness_center_rounded,
                          value: '${exercise['exercise_reps']}',
                          label: 'Reps',
                          iconColor: Colors.orange.shade400,
                          bgColor: Colors.orange.shade50,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Primary CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onMarkDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: alreadyCompleted
                              ? Colors.green.shade500
                              : Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5))
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              alreadyCompleted
                                  ? Icons.check_circle_rounded
                                  : isLastExercise
                                  ? Icons.flag_rounded
                                  : Icons
                                  .arrow_circle_right_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alreadyCompleted
                                  ? 'Already Done — Next'
                                  : isLastExercise
                                  ? 'Finish Workout'
                                  : 'Mark as Done',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Previous / Skip row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: (currentIndex > 0 && !isLoading)
                                ? _goPrevious
                                : null,
                            icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              side: BorderSide(
                                  color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14)),
                              textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _onSkip,
                            icon: Icon(
                              isLastExercise
                                  ? Icons.flag_outlined
                                  : Icons.skip_next_rounded,
                              size: 18,
                            ),
                            label: Text(isLastExercise
                                ? 'Skip & Finish'
                                : 'Skip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1c1c1e),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14)),
                              textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Metric tile (replaces old _infoTile) ─────────────────────────────────
  Widget _metricTile({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1c1c1e)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}