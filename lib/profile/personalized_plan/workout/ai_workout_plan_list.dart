import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/profile/personalized_plan/workout/ai_workout_details.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../workout/exercise_detailed_screen.dart';

class AiWorkoutPlan extends StatefulWidget {
  const AiWorkoutPlan({super.key});

  @override
  State<AiWorkoutPlan> createState() => _AiWorkoutPlanState();
}

class _AiWorkoutPlanState extends State<AiWorkoutPlan>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _workoutsFuture;
  late AnimationController _shimmerController;
  late AnimationController _headerFloatController;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = UserApiService.getAiWorkoutDetails();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _headerFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      lowerBound: -4,
      upperBound: 4,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _headerFloatController.dispose();
    super.dispose();
  }

  IconData _focusIcon(String area) {
    switch (area.toLowerCase()) {
      case 'abs':
        return Icons.sports_gymnastics;
      case 'chest':
        return Icons.fitness_center;
      case 'legs':
        return Icons.directions_run;
      case 'back':
        return Icons.accessibility_new;
      case 'arms':
        return Icons.sports_handball;
      case 'shoulders':
        return Icons.sports_martial_arts;
      default:
        return Icons.bolt;
    }
  }

  Color _goalColor(String goal) {
    switch (goal.toLowerCase()) {
      case 'muscle gain':
        return const Color(0xFFE65100);
      case 'weight loss':
        return const Color(0xFF0277BD);
      case 'endurance':
        return const Color(0xFF2E7D32);
      case 'flexibility':
        return const Color(0xFF6A1B9A);
      default:
        return AppColors.primary;
    }
  }

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF2E7D32);
      case 'intermediate':
        return const Color(0xFFE65100);
      case 'advanced':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("AI Generated Workouts"),
      backgroundColor: AppColors.scaffoldBackground,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoader();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return _buildEmpty();
          }
          return _buildContent(workouts);
        },
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> workouts) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(workouts),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSummaryStrip(workouts),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Your Plans',
                  style: TextStyle(
                    color: const Color(0xFF0D1B3E),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${workouts.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(workouts.length, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + i * 100),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) => Transform.translate(
                offset: Offset(0, 24 * (1 - val)),
                child: Opacity(opacity: val, child: child),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildWorkoutCard(workouts[i]),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // HERO HEADER with Stack depth
  // ──────────────────────────────────────────────
  Widget _buildHeroHeader(List<Map<String, dynamic>> workouts) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base gradient block
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF1565C0), Color(0xFF0D47A1)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
        ),

        // Decorative circles (depth layer)
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -24,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),

        // Dot grid texture
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            child: CustomPaint(painter: _DotGridPainter()),
          ),
        ),

        // Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (_, child) => ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: const [Colors.white70, Colors.white, Colors.white70],
                            stops: [
                              (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                              _shimmerController.value.clamp(0.0, 1.0),
                              (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                            ],
                          ).createShader(bounds),
                          child: child!,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'AI-Powered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your Personalized\nWorkout Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crafted by AI based on your body & goals',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating card that overlaps the header bottom
        Positioned(
          bottom: -28,
          left: 20,
          right: 20,
          child: _buildFloatingActiveCard(workouts),
        ),
      ],
    );
  }

  Widget _buildFloatingActiveCard(List<Map<String, dynamic>> workouts) {
    final totalMins = workouts.fold<int>(
        0, (sum, w) => sum + (w['workout_duration'] as int? ?? 0));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${workouts.length} Active Plans • ${totalMins}m Total',
                  style: const TextStyle(
                    color: Color(0xFF0D1B3E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap any plan to start your session',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // SUMMARY STRIP
  // ──────────────────────────────────────────────
  Widget _buildSummaryStrip(List<Map<String, dynamic>> workouts) {
    final totalMins = workouts.fold<int>(
        0, (sum, w) => sum + (w['workout_duration'] as int? ?? 0));
    final focuses = workouts
        .map((w) => w['workout_focus_area'] as String? ?? '')
        .toSet()
        .length;
    final goals =
        workouts.map((w) => w['workout_goal'] as String? ?? '').toSet().length;

    // Extra top spacing to clear the floating card
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        children: [
          _summaryTile(
              value: '${totalMins}m',
              label: 'Total Time',
              icon: Icons.timer_rounded,
              accent: AppColors.primary),
          const SizedBox(width: 12),
          _summaryTile(
              value: '$focuses',
              label: 'Focus Areas',
              icon: Icons.grid_view_rounded,
              accent: const Color(0xFF6A1B9A)),
          const SizedBox(width: 12),
          _summaryTile(
              value: '$goals',
              label: 'Goals',
              icon: Icons.track_changes_rounded,
              accent: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF0D1B3E),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // WORKOUT CARD with Stack layering
  // ──────────────────────────────────────────────
  Widget _buildWorkoutCard(Map<String, dynamic> w) {
    final workoutId = w["ai_workout_id"];
    final name = w['workout_name'] ?? 'Workout';
    final goal = w['workout_goal'] ?? '';
    final focus = w['workout_focus_area'] ?? '';
    final duration = w['workout_duration'] as int? ?? 0;
    final difficulty = w['workout_difficulty'] ?? '';
    final bodyType = w['body_type'] ?? '';
    final createdAt = w['created_at'] ?? '';
    final accentColor = _goalColor(goal);
    final diffColor = _difficultyColor(difficulty);
    final focusIcon = _focusIcon(focus);
    final progress = (duration / 60).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiWorkoutDetails(
              workoutId:  workoutId,       // w['ai_workout_id']
              name:       name,            // w['workout_name']
              goal:       goal,            // w['workout_goal']
              focus:      focus,           // w['workout_focus_area']
              duration:   duration,        // w['workout_duration']
              difficulty: difficulty,      // w['workout_difficulty']
              bodyType:   bodyType,        // w['body_type']
              createdAt:  createdAt,       // w['created_at']
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card base
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored top band
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon circle with depth
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(focusIcon, color: accentColor, size: 26),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF0D1B3E),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _chip(focus.toUpperCase(), accentColor),
                                _chip(difficulty, diffColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Thin divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.grey.shade100, height: 1),
                ),

                // Meta row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _metaChip(
                        icon: Icons.timer_rounded,
                        label: '$duration min',
                        bgColor: AppColors.primary.withOpacity(0.07),
                        textColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _metaChip(
                        icon: Icons.person_outline_rounded,
                        label: _capitalize(bodyType),
                        bgColor: const Color(0xFF6A1B9A).withOpacity(0.07),
                        textColor: const Color(0xFF6A1B9A),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Goal bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Goal: ${_capitalize(goal)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [accentColor, accentColor.withOpacity(0.6)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating duration badge (top-right overlap)
          Positioned(
            top: -1,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '$duration MIN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STATES
  // ──────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.withOpacity(0.2)),
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Building your AI plans...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: Color(0xFFC62828), size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not load plans',
              style: TextStyle(
                color: Color(0xFF0D1B3E),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => setState(
                      () => _workoutsFuture = UserApiService.getAiWorkoutDetails()),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, const Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Plans Yet',
              style: TextStyle(
                color: Color(0xFF0D1B3E),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Generate your first AI workout plan\nto get started on your journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ──────────────────────────────────────────────
// Dot grid background painter
// ──────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}