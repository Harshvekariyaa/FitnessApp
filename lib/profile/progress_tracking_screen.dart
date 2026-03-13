import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/workout/workout_history_screen.dart';
import 'package:flutter/material.dart';

import '../api/api_service.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {

  int totalWorkouts = 0;
  int totalCalories = 0;
  int currentStreak = 0;
  int totalXp = 0;

  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    getUserProgress();
  }

  Future<void> getUserProgress() async {
    try {
      final response = await UserApiService.fetchUserProgress();
      if (response["success"] == true) {
        final data = response["data"];
        setState(() {
          totalWorkouts = data["total_workouts"] ?? 0;
          totalCalories = data["total_calories"] ?? 0;
          currentStreak = data["current_streak"] ?? 0;
          totalXp = int.tryParse(data["total_xp"].toString()) ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Progress API Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Track Your Progress"),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel("THIS WEEK"),
                const SizedBox(height: 12),
                _buildHeroStreakCard(),
                const SizedBox(height: 24),
                _buildSectionLabel("YOUR STATS"),
                const SizedBox(height: 12),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildSectionLabel("ACHIEVEMENT"),
                const SizedBox(height: 12),
                _buildXpCard(),
                const SizedBox(height: 24),
                _buildWorkoutHistoryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.5,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  // ─── Hero Streak Card ─────────────────────────────────────────

  Widget _buildHeroStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CURRENT STREAK",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$currentStreak",
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 6),
                    child: Text(
                      "DAYS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                "Keep it up — don't break the chain!",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.flash_on, color: Colors.white, size: 52),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: "WORKOUTS",
            value: "$totalWorkouts",
            unit: "sessions",
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: "CALORIES",
            value: "$totalCalories",
            unit: "kcal burned",
            icon: Icons.local_fire_department,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── XP Card ─────────────────────────────────────────────────

  Widget _buildXpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.star, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "XP",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
              Text(
                "$totalXp",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
              Text(
                "total points earned",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Workout History Button ───────────────────────────────────

  Widget _buildWorkoutHistoryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutHistoryScreen(),));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Workout History",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "View all past sessions & details",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}