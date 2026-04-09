import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

import '../api/api_service.dart';
import 'injury/injury_detailed_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final int exeId;

  const ExerciseDetailScreen({super.key, required this.exeId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  Map<String, dynamic>? exercise;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercise();
  }

  Future<void> fetchExercise() async {
    final data = await UserApiService.getExerciseDetails(widget.exeId);

    setState(() {
      exercise = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Exercise Details",
        actions: [
          if (exercise?["injury_id"] != null)
            IconButton(
              icon: const Icon(Icons.shield_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InjuryDetailedScreen(
                      injuryid: exercise!["injury_id"],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? Center(child: buildLoader())
          : exercise == null
          ? const Center(child: Text("Exercise not found"))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// GIF IMAGE (FULLY VISIBLE)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  child: Image.network(
                    exercise!["exercise_gif_full_url"],
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: 320,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// EXERCISE TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    exercise!["exercise_name"],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: const [
                      _FocusChip(label: "WORKOUT"),
                      SizedBox(width: 8),
                      _FocusChip(label: "FITNESS"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(
                    icon: Icons.timer,
                    title: "Duration",
                    value:
                    "${exercise!["exercise_duration_second"]} sec",
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.repeat,
                    title: "Sets",
                    value: "${exercise!["exercise_sets"]}",
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.fitness_center,
                    title: "Reps",
                    value: "${exercise!["exercise_reps"]}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// CALORIES
            _SectionCard(
              title: "Calories Burn",
              value: "${exercise!["exercise_calories_burn"]} kcal",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              description:
              "Calories burned may vary depending on intensity and body weight.",
            ),

            /// DESCRIPTION
            _SectionCard(
              title: "Exercise Guide",
              icon: Icons.menu_book,
              color: Colors.blue,
              description: exercise!["exercise_description"],
            ),

            /// XP REWARD
            _SectionCard(
              title: "XP Reward",
              value: "${exercise!["exercise_xp"]} XP",
              icon: Icons.workspace_premium,
              color: Colors.green,
              description:
              "Complete this exercise to earn experience points.",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// FOCUS CHIP
class _FocusChip extends StatelessWidget {
  final String label;

  const _FocusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// STAT CARD
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// SECTION CARD
class _SectionCard extends StatelessWidget {
  final String title;
  final String? value;
  final String description;
  final IconData icon;
  final Color color;

  const _SectionCard({
    required this.title,
    this.value,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color),
                ),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.6,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }
}