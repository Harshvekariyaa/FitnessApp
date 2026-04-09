import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/workout/workout_history_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../api/api_service.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with TickerProviderStateMixin {

  // ─── Data ─────────────────────────────────────────────────────
  int totalWorkouts = 0;
  double totalCalories = 0;
  int currentStreak = 0;
  int totalXp = 0;
  Map<String, dynamic>? weeklyReport;
  List<Map<String, dynamic>> weeklyGraphData = [];
  String? aiFeedback;
  bool aiLoading = true;
  bool isLoading = true;

  // ─── Animation Controllers ────────────────────────────────────
  late AnimationController _masterController;
  late AnimationController _chartController;
  late AnimationController _aiController;
  late AnimationController _ringController;

  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _chartAnim;
  late Animation<double> _aiFade;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _chartController = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _aiController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _ringController = AnimationController(
        duration: const Duration(milliseconds: 1600), vsync: this);

    _fadeIn = CurvedAnimation(
        parent: _masterController, curve: Curves.easeOut);
    _slideUp = CurvedAnimation(
        parent: _masterController, curve: Curves.easeOutCubic);
    _chartAnim = CurvedAnimation(
        parent: _chartController, curve: Curves.easeOutCubic);
    _aiFade = CurvedAnimation(
        parent: _aiController, curve: Curves.easeOut);
    _ringAnim = CurvedAnimation(
        parent: _ringController, curve: Curves.easeOutCubic);

    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      getUserProgress(),
      fetchWeeklyReport(),
      fetchWeeklyGraph(),
    ]);
    _masterController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _chartController.forward();
    _ringController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    fetchAiReport();
  }

  Future<void> getUserProgress() async {
    try {
      final response = await UserApiService.fetchUserProgress();
      if (response["success"] == true) {
        final data = response["data"];
        setState(() {
          totalWorkouts = data["total_workouts"] ?? 0;
          totalCalories =
              double.tryParse(data["total_calories"].toString()) ?? 0.0;
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

  Future<void> fetchWeeklyReport() async {
    try {
      final data = await UserApiService.getWeeklyReport();
      setState(() => weeklyReport = data);
    } catch (e) {
      debugPrint("Weekly Report Error: $e");
    }
  }

  Future<void> fetchWeeklyGraph() async {
    try {
      final data = await UserApiService.getWeeklyGraph();
      setState(() => weeklyGraphData = data);
    } catch (e) {
      debugPrint("Weekly Graph Error: $e");
    }
  }

  Future<void> fetchAiReport() async {
    try {
      final feedback = await UserApiService.getAiReport();
      setState(() {
        aiFeedback = feedback;
        aiLoading = false;
      });
      _aiController.forward();
    } catch (e) {
      debugPrint("AI Report Error: $e");
      setState(() => aiLoading = false);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _chartController.dispose();
    _aiController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _formatCalories(double cal) =>
      cal % 1 == 0 ? cal.toInt().toString() : cal.toStringAsFixed(1);

  double get _maxGraphCalories {
    if (weeklyGraphData.isEmpty) return 1;
    return weeklyGraphData
        .map((e) => double.tryParse(e["calories"].toString()) ?? 0)
        .fold(0.0, (a, b) => a > b ? a : b);
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    if (m < 60) return "${m}m";
    return "${m ~/ 60}h ${m % 60}m";
  }

  String _formatDouble(dynamic val, {int decimals = 1}) {
    final d = double.tryParse(val.toString()) ?? 0.0;
    return d % 1 == 0 ? d.toInt().toString() : d.toStringAsFixed(decimals);
  }

  int get _xpLevel => (totalXp / 500).floor() + 1;
  double get _xpProgress => (totalXp % 500) / 500;

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Track Your Progress"),
      body: isLoading
          ? Center(child: buildLoader())
          : FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Summary Banner ───────────────────
              _buildTopSummaryBanner(),
              const SizedBox(height: 20),

              // ── 4-Stat Grid ──────────────────────────
              _buildSectionTitle("Overview", Icons.bar_chart_rounded),
              const SizedBox(height: 12),
              _buildStatGrid(),
              const SizedBox(height: 20),

              // ── XP Progress Ring ─────────────────────
              _buildSectionTitle("Level & XP", Icons.star_rounded),
              const SizedBox(height: 12),
              _buildXpProgressCard(),
              const SizedBox(height: 20),

              // ── Weekly Calorie Bar Chart ─────────────
              if (weeklyGraphData.isNotEmpty) ...[
                _buildSectionTitle(
                    "Calories This Week", Icons.local_fire_department_rounded),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _chartAnim,
                  builder: (_, __) => _buildBarChart(_chartAnim.value),
                ),
                const SizedBox(height: 20),
              ],

              // ── Weekly Comparison ────────────────────
              if (weeklyReport != null) ...[
                _buildSectionTitle(
                    "Week vs Last Week", Icons.compare_arrows_rounded),
                const SizedBox(height: 12),
                _buildWeeklyComparisonSection(),
                const SizedBox(height: 20),
              ],

              // ── Fitness Score Radial ─────────────────
              if (weeklyReport != null) ...[
                _buildSectionTitle(
                    "Fitness Score", Icons.emoji_events_rounded),
                const SizedBox(height: 12),
                _buildFitnessScoreRadial(),
                const SizedBox(height: 20),
              ],

              // ── AI Coach ─────────────────────────────
              _buildSectionTitle("AI Coach Feedback", Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
              aiLoading ? _buildAiShimmer() : _buildAiCard(),
              const SizedBox(height: 20),

              // ── History Button ───────────────────────
              _buildHistoryButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Title ────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2340),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── Top Summary Banner ───────────────────────────────────────

  Widget _buildTopSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.82),
            AppColors.primary.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on_rounded,
                                    color: Colors.amber, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  "ACTIVE STREAK",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$currentStreak",
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -2,
                              ),
                            ),
                            TextSpan(
                              text: "  days",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentStreak >= 7
                            ? "🔥 You're on fire! Keep pushing!"
                            : currentStreak >= 3
                            ? "💪 Great momentum — don't stop!"
                            : "Start building your streak today!",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStreakBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Colors.amber, size: 32),
          const SizedBox(height: 6),
          Text(
            "Best",
            style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600),
          ),
          Text(
            "${math.max(currentStreak, 1)}🔥",
            style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ─── Stat Grid ────────────────────────────────────────────────

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _statTile(
          icon: Icons.fitness_center_rounded,
          label: "Workouts",
          value: "$totalWorkouts",
          sub: "total sessions",
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        ),
        _statTile(
          icon: Icons.local_fire_department_rounded,
          label: "Calories",
          value: _formatCalories(totalCalories),
          sub: "kcal burned",
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFFF1F0),
        ),
        _statTile(
          icon: Icons.bolt_rounded,
          label: "Streak",
          value: "$currentStreak",
          sub: "day streak",
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
        ),
        _statTile(
          icon: Icons.star_rounded,
          label: "Total XP",
          value: "$totalXp",
          sub: "points earned",
          color: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF5F3FF),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── XP Progress Ring Card ────────────────────────────────────

  Widget _buildXpProgressCard() {
    final nextLevelXp = _xpLevel * 500;
    final currLevelXp = (_xpLevel - 1) * 500;
    final progressInLevel = totalXp - currLevelXp;
    final neededForLevel = 500;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring
          AnimatedBuilder(
            animation: _ringAnim,
            builder: (_, __) => SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _xpProgress * _ringAnim.value,
                  color: AppColors.primary,
                  trackColor: AppColors.primary.withOpacity(0.10),
                  strokeWidth: 10,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "LVL",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withOpacity(0.5),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "$_xpLevel",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Level $_xpLevel",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$totalXp XP total",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 14),
                // Linear progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _xpProgress * _ringAnim.value,
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$progressInLevel / $neededForLevel XP",
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                    Text(
                      "${neededForLevel - progressInLevel} to LVL ${_xpLevel + 1}",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bar Chart ────────────────────────────────────────────────

  Widget _buildBarChart(double progress) {
    final maxCal = _maxGraphCalories;
    const barMaxH = 100.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Calories",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2340).withOpacity(0.85),
                    ),
                  ),
                  Text(
                    "This week · kcal",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Peak: ${maxCal.toInt()} kcal",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final count = weeklyGraphData.length;
            if (count == 0) return const SizedBox.shrink();
            const gap = 8.0;
            final barW =
                (constraints.maxWidth - gap * (count - 1)) / count;

            return SizedBox(
              height: 145,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyGraphData.asMap().entries.map((e) {
                  final idx = e.key;
                  final item = e.value;
                  final cal =
                      double.tryParse(item["calories"].toString()) ?? 0;
                  final ratio = maxCal > 0 ? (cal / maxCal) : 0.0;
                  final barH = (barMaxH * ratio * progress).clamp(0.0, barMaxH);
                  final isMax = cal == maxCal && cal > 0;

                  String dayLabel = "";
                  try {
                    final d =
                    DateTime.parse(item["workout_date"].toString());
                    const days = [
                      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                    ];
                    dayLabel = days[d.weekday - 1];
                  } catch (_) {}

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: barW,
                        height: 145,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cal label
                            SizedBox(
                              height: 16,
                              child: AnimatedOpacity(
                                opacity: progress > 0.85 && cal > 0 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  "${cal.toInt()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isMax
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Bar with track
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: barW,
                                  height: barMaxH,
                                  decoration: BoxDecoration(
                                    color: isMax
                                        ? AppColors.primary.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                if (barH > 0)
                                  Container(
                                    width: barW,
                                    height: barH,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isMax
                                            ? [
                                          AppColors.primary,
                                          AppColors.primary
                                              .withOpacity(0.6),
                                        ]
                                            : [
                                          AppColors.primary
                                              .withOpacity(0.55),
                                          AppColors.primary
                                              .withOpacity(0.25),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: isMax
                                          ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.28),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Day label
                            Text(
                              dayLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isMax
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isMax
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (idx < count - 1) const SizedBox(width: gap),
                    ],
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Weekly Comparison ────────────────────────────────────────

  Widget _buildWeeklyComparisonSection() {
    final curr = weeklyReport?["current_week"];
    final prev = weeklyReport?["previous_week"];
    final comp = weeklyReport?["comparison"];
    if (curr == null || prev == null) return const SizedBox.shrink();

    final currCal = double.tryParse(curr["calories"].toString()) ?? 0.0;
    final prevCal = double.tryParse(prev["calories"].toString()) ?? 0.0;
    final currXp = int.tryParse(curr["xp"].toString()) ?? 0;
    final prevXp = int.tryParse(prev["xp"].toString()) ?? 0;
    final currWorkouts = int.tryParse(curr["workouts"].toString()) ?? 0;
    final prevWorkouts = int.tryParse(prev["workouts"].toString()) ?? 0;
    final currDurSec = int.tryParse(curr["duration_sec"].toString()) ?? 0;
    final prevDurSec = int.tryParse(prev["duration_sec"].toString()) ?? 0;
    final currConsist =
        double.tryParse(curr["consistency"].toString()) ?? 0.0;
    final prevConsist =
        double.tryParse(prev["consistency"].toString()) ?? 0.0;
    final fatLoss =
        double.tryParse(curr["estimated_fat_loss_kg"].toString()) ?? 0.0;

    final calChange =
        double.tryParse(comp?["calorie_change"].toString() ?? "0") ?? 0.0;
    final durChange =
        int.tryParse(comp?["duration_change_sec"].toString() ?? "0") ?? 0;
    final xpChange =
        int.tryParse(comp?["xp_change"].toString() ?? "0") ?? 0;
    final workoutChange =
        int.tryParse(comp?["workout_change"].toString() ?? "0") ?? 0;
    final consistChange =
        double.tryParse(comp?["consistency_change"].toString() ?? "0") ?? 0.0;
    final compMessage = comp?["message"]?.toString() ?? "";

    return Column(
      children: [
        // Message banner
        if (compMessage.isNotEmpty) ...[
          _buildMessageBanner(compMessage),
          const SizedBox(height: 12),
        ],
        // 2x2 comparison grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _compTile(
              icon: Icons.local_fire_department_rounded,
              label: "Calories",
              curr: _formatCalories(currCal),
              prev: _formatCalories(prevCal),
              change: calChange,
              unit: "kcal",
              iconColor: const Color(0xFFEF4444),
            ),
            _compTile(
              icon: Icons.fitness_center_rounded,
              label: "Workouts",
              curr: "$currWorkouts",
              prev: "$prevWorkouts",
              change: workoutChange.toDouble(),
              unit: "sessions",
              iconColor: AppColors.primary,
            ),
            _compTile(
              icon: Icons.timer_outlined,
              label: "Duration",
              curr: _formatDuration(currDurSec),
              prev: _formatDuration(prevDurSec),
              change: durChange.toDouble(),
              unit: "total time",
              iconColor: const Color(0xFF10B981),
              customChange: durChange >= 0
                  ? "+${_formatDuration(durChange.abs())}"
                  : "-${_formatDuration(durChange.abs())}",
            ),
            _compTile(
              icon: Icons.bolt_rounded,
              label: "XP Earned",
              curr: "$currXp",
              prev: "$prevXp",
              change: xpChange.toDouble(),
              unit: "points",
              iconColor: const Color(0xFF8B5CF6),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _compTile(
                icon: Icons.calendar_today_outlined,
                label: "Consistency",
                curr: "${currConsist.toStringAsFixed(1)}%",
                prev: "${prevConsist.toStringAsFixed(1)}%",
                change: consistChange,
                unit: "of week",
                iconColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _fatLossTile(fatLoss)),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.teal.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Icon(Icons.trending_up_rounded, color: Colors.green.shade600, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compTile({
    required IconData icon,
    required String label,
    required String curr,
    required String prev,
    required double change,
    required String unit,
    required Color iconColor,
    String? customChange,
  }) {
    final bool isGood = change >= 0;
    final Color changeColor = change == 0
        ? Colors.grey.shade400
        : (isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    final IconData changeIcon = change > 0
        ? Icons.arrow_upward_rounded
        : change < 0
        ? Icons.arrow_downward_rounded
        : Icons.remove_rounded;

    final String changeLabel = customChange ??
        (change >= 0
            ? "+${_formatDouble(change.abs(), decimals: change.abs() < 10 ? 1 : 0)}"
            : "-${_formatDouble(change.abs(), decimals: change.abs() < 10 ? 1 : 0)}");

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(changeIcon, size: 8, color: changeColor),
                    const SizedBox(width: 2),
                    Text(
                      changeLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                curr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2340),
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "vs $prev  ·  $unit",
                style:
                TextStyle(fontSize: 9, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fatLossTile(double fatLoss) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_outlined,
                  size: 14, color: Colors.orange.shade500),
              const SizedBox(width: 5),
              Text(
                "Fat Loss",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "est.",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade500,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${fatLoss.toStringAsFixed(3)} kg",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange.shade600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "estimated this week",
                style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Fitness Score Radial ─────────────────────────────────────

  Widget _buildFitnessScoreRadial() {
    final curr = weeklyReport?["current_week"];
    final prev = weeklyReport?["previous_week"];
    final comp = weeklyReport?["comparison"];
    final scoreInfo =
        weeklyReport?["info"]?["fitness_score_meaning"]?.toString() ?? "";
    if (curr == null) return const SizedBox.shrink();

    final currScore =
        double.tryParse(curr["fitness_score"].toString()) ?? 0.0;
    final prevScore =
        double.tryParse(prev?["fitness_score"].toString() ?? "0") ?? 0.0;
    final scoreChange =
        double.tryParse(comp?["score_change"].toString() ?? "0") ?? 0.0;
    final currLevel = curr["fitness_level"]?.toString() ?? "";
    final normalised = (currScore / 100).clamp(0.0, 1.0);
    final bool improved = scoreChange >= 0;
    final changeColor = improved
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _ringAnim,
            builder: (_, __) => SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: normalised * _ringAnim.value,
                  color: AppColors.primary,
                  trackColor: AppColors.primary.withOpacity(0.09),
                  strokeWidth: 11,
                  startAngle: -math.pi * 0.75,
                  sweepAngle: math.pi * 1.5,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      Text(
                        "/ 100",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Fitness Score",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                    ),
                    if (currLevel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currLevel.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        improved
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${improved ? '+' : ''}${scoreChange.toStringAsFixed(1)} vs last week",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (scoreInfo.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    scoreInfo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI Card ──────────────────────────────────────────────────

  Widget _buildAiShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.10), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Coach",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "Analyzing your week...",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const Spacer(),
              _buildPulsingDot(),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBar(double.infinity),
          const SizedBox(height: 8),
          _shimmerBar(double.infinity),
          const SizedBox(height: 8),
          _shimmerBar(180),
        ],
      ),
    );
  }

  Widget _shimmerBar(double w) => Container(
    width: w,
    height: 11,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (_, val, __) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(val),
        ),
      ),
      onEnd: () => setState(() {}),
    );
  }

  Widget _buildAiCard() {
    if (aiFeedback == null) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _aiFade,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.09),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Coach",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      "Personalized feedback",
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "✦ AI",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: AppColors.primary.withOpacity(0.07),
            ),
            const SizedBox(height: 16),
            Text(
              aiFeedback!,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF374151),
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── History Button ───────────────────────────────────────────

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.primary.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.18), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.history_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Workout History",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "View all past sessions & details",
                  style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ring Painter ──────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    this.startAngle = -math.pi / 2,
    this.sweepAngle = 2 * math.pi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle * progress, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}