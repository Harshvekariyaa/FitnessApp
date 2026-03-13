import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/profile/personalized_plan/diet_plans.dart';
import 'package:fitnessai/profile/personalized_plan/workout_plans.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class WorkoutAndDietPlanScreen extends StatefulWidget {
  const WorkoutAndDietPlanScreen({super.key});

  @override
  State<WorkoutAndDietPlanScreen> createState() => _WorkoutAndDietPlanScreenState();
}

class _WorkoutAndDietPlanScreenState extends State<WorkoutAndDietPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Workout & Diet Plan"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _plancard(
                      context: context,
                      image: "assets/images/stretch.jpeg",
                      name: "Workout Plans",
                      plan: 4, ontap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutPlans(),));
                    }
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _plancard(
                        context: context,
                        image: "assets/images/f1.jpeg",
                        name: "Diet Plans",
                        plan: 7, ontap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DietPlans(),));

                    }
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plancard  ({
    required BuildContext context,
    required String name,
    required int plan,
    required String image,
    required VoidCallback ontap
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(image.toString()),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.2),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [



              const SizedBox(height: 8),

              /// Injury Name
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              /// Description
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    plan.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
