import 'package:flutter/material.dart';

import '../../Themes_and_color/app_colors.dart';
import '../../ui_helper/common_widgets.dart';

class WorkoutPlans extends StatefulWidget {
  const WorkoutPlans({super.key});

  @override
  State<WorkoutPlans> createState() => _WorkoutPlansState();
}

class _WorkoutPlansState extends State<WorkoutPlans> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Workout Plans"),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) {
                // final injury = injuriesList[index];
                return workoutPlanCard(
                  context: context,
                  image: 'assets/images/stretch.jpeg',
                  name: 'Stretch',
                  totalExercise: 12,
                  totalDuration: 20,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget workoutPlanCard({
    required BuildContext context,
    required String image,
    required String name,
    required int totalExercise,
    required int totalDuration,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.75),
                Colors.black.withOpacity(0.25),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /// Workout name
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              /// Info row
              Row(
                children: [
                  _infoChip(
                    icon: Icons.fitness_center,
                    text: "$totalExercise Exercises",
                  ),
                  const SizedBox(width: 10),
                  _infoChip(
                    icon: Icons.timer,
                    text: "$totalDuration Min",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Small reusable chip widget
  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}
