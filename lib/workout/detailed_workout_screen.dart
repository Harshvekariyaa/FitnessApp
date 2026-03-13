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
              child: Column(
                children: [
                  _workoutHeader(),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statsRow(),

                        const SizedBox(height: 24),

                        const Text(
                          "Exercises",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];

                            return _exerciseTile(
                              image: exercise["exercise_gif_full_url"],
                              title: exercise["exercise_name"],
                              subtitle:
                                  "${exercise["exercise_duration_second"]} sec",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exeId: exercise['exercise_id'],),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: elevetedbtn("Start Workout", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseScreen()),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _workoutHeader() {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(workoutData?["workout_image_url"] ?? ""),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Text(
            workoutData?["workout_name"] ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- STATS ----------------

  Widget _statsRow() {
    final exercises = workoutData?["exercises"] ?? [];

    return Row(
      children: [
        _statCard(
          Icons.timer,
          "${workoutData?["workout_duration_minute"] ?? 0} min",
          "Duration",
        ),
        const SizedBox(width: 12),
        _statCard(Icons.fitness_center, "${exercises.length}", "Exercises"),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ---------------- EXERCISE TILE ----------------

  Widget _exerciseTile({
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
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
                      height: 60,
                      width: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
