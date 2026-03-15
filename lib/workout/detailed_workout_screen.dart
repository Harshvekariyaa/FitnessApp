import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/workout/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'exercise_detailed_screen.dart';

class DetailedWorkoutScreen extends StatefulWidget {
  final int workout_id;

  const DetailedWorkoutScreen({super.key, required this.workout_id});

  @override
  State<DetailedWorkoutScreen> createState() => _DetailedWorkoutScreenState();
}

class _DetailedWorkoutScreenState extends State<DetailedWorkoutScreen> {
  Map<String, dynamic>? workoutData;
  bool isLoading = true;
  bool isStartingWorkout = false;

  @override
  void initState() {
    super.initState();
    fetchWorkout();
  }

  Future<void> fetchWorkout() async {
    final data = await UserApiService.getWorkoutDetails(widget.workout_id);
    setState(() {
      workoutData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: commonAppBar("Workout Details"),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final exercises = workoutData?["exercises"] ?? [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Workout Details"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _workoutHeader(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statsRow(),
                        const SizedBox(height: 28),
                        _sectionLabel("Exercises", "${exercises.length} total"),
                        const SizedBox(height: 14),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return _exerciseTile(
                              index: index + 1,
                              image: exercise["exercise_gif_full_url"],
                              title: exercise["exercise_name"],
                              subtitle:
                              "${exercise["exercise_duration_second"]} sec",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExerciseDetailScreen(
                                      exeId: exercise['exercise_id'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _startWorkoutButton(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────

  Widget _workoutHeader() {
    return Stack(
      children: [
        // Hero image
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(workoutData?["workout_image_url"] ?? ""),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay — deeper, richer
        Container(
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 0.75],
            ),
          ),
        ),

        // Badge + Title
        Positioned(
          bottom: 22,
          left: 18,
          right: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: const Text(
                  "WORKOUT PLAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                workoutData?["workout_name"] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────

  Widget _statsRow() {
    final exercises = workoutData?["exercises"] ?? [];

    return Row(
      children: [
        _statCard(
          icon: Icons.timer_outlined,
          value: "${workoutData?["workout_duration_minute"] ?? 0}",
          unit: "min",
          label: "Duration",
          iconColor: const Color(0xFF4A90E2),
          bgColor: const Color(0xFFEEF4FF),
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.fitness_center_rounded,
          value: "${exercises.length}",
          unit: "",
          label: "Exercises",
          iconColor: const Color(0xFF34C759),
          bgColor: const Color(0xFFEEFAF1),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        height: 1,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────

  Widget _sectionLabel(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // EXERCISE TILE
  // ─────────────────────────────────────────

  Widget _exerciseTile({
    required int index,
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    "$index",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // GIF / Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 64,
                        width: 64,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // START WORKOUT BUTTON
  // ─────────────────────────────────────────

  Widget _startWorkoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: isStartingWorkout
            ? _loadingButton()
            : elevetedbtn("Start Workout", () async {
          setState(() => isStartingWorkout = true);
          try {
            final sessionResponse =
            await UserApiService.startWorkout(widget.workout_id);
            final sessionId =
            sessionResponse['data']['session_id'] as String;

            final exercisesData = await UserApiService
                .fetchWorkoutExercises(widget.workout_id);

            final exercises = (exercisesData['data'] as List<dynamic>)
                .map((e) {
              final item = Map<String, dynamic>.from(e as Map);
              item['is_completed'] = 0;
              item['sets_completed'] = 0;
              item['reps_completed'] = 0;
              item['exercise_duration_sec'] = 0;
              return item;
            })
                .toList();

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseScreen(
                  sessionId: sessionId,
                  workoutId: widget.workout_id,
                  exercises: exercises,
                  startIndex: 0,
                ),
              ),
            ).then((_) {
              if (mounted) setState(() => isStartingWorkout = false);
            });
          } catch (e) {
            if (mounted) {
              setState(() => isStartingWorkout = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to start workout: $e")),
              );
            }
          }
        }),
      ),
    );
  }

  Widget _loadingButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF2F6FD6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Setting up your workout...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
