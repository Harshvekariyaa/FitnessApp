import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/profile/personalized_plan/diet/MealDetailScreen.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class AiDietPlanDetails extends StatefulWidget {
  /// Pass [dietPlanId] when navigating from the plans list (fetches from API).
  /// Pass [data] when navigating from the generate screen (already loaded).
  final int? dietPlanId;
  final Map<String, dynamic>? data;

  const AiDietPlanDetails({
    super.key,
    this.dietPlanId,
    this.data,
  }) : assert(
  dietPlanId != null || data != null,
  'Provide either dietPlanId or data',
  );

  @override
  State<AiDietPlanDetails> createState() => _AiDietPlanDetailsState();
}

class _AiDietPlanDetailsState extends State<AiDietPlanDetails> {
  Map<String, dynamic>? dietPlan;
  bool isLoading = true;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      // Data already available — no need to fetch
      dietPlan = widget.data;
      isLoading = false;
    } else {
      fetchDietPlan();
    }
  }

  Future<void> fetchDietPlan() async {
    setState(() => isLoading = true);
    try {
      final data = await UserApiService.getAiDietPlanFullDetails(
          widget.dietPlanId!);
      setState(() {
        dietPlan = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ── Meal styling ──────────────────────────────────────────────
  _MealMeta _metaFor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return _MealMeta(
          icon: Icons.wb_sunny_rounded,
          gradient: const LinearGradient(
              colors: [Color(0xFFFB923C), Color(0xFFFBBF24)]),
          tag: 'Breakfast',
          tagColor: AppColors.powerOrange,
        );
      case 'lunch':
        return _MealMeta(
          icon: Icons.restaurant_rounded,
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight]),
          tag: 'Lunch',
          tagColor: AppColors.primary,
        );
      case 'snack':
        return _MealMeta(
          icon: Icons.apple_rounded,
          gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryLight]),
          tag: 'Snack',
          tagColor: AppColors.secondary,
        );
      case 'dinner':
        return _MealMeta(
          icon: Icons.nightlight_round,
          gradient: const LinearGradient(
              colors: [AppColors.progressPurple, Color(0xFFA78BFA)]),
          tag: 'Dinner',
          tagColor: AppColors.progressPurple,
        );
      default:
        return _MealMeta(
          icon: Icons.fastfood_rounded,
          gradient: const LinearGradient(
              colors: [AppColors.calmBlue, AppColors.primaryLight]),
          tag: type,
          tagColor: AppColors.calmBlue,
        );
    }
  }

  int _dayCalories(Map<String, dynamic> day) {
    final meals = day['meals'] as List;
    return meals.fold(0, (sum, m) => sum + (m['calories'] as int));
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: isLoading
          ? _buildLoading()
          : dietPlan == null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLoader(),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 30),
            ),
            const SizedBox(height: 20),
            const Text('Could not load plan',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: AppColors.w700)),
            const SizedBox(height: 8),
            const Text('Please check your connection and try again.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: fetchDietPlan,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: AppColors.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final days = dietPlan!['days'] as List;
    final selectedDay = days[_selectedDayIndex] as Map<String, dynamic>;
    final meals = selectedDay['meals'] as List;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          elevation: 0,
          backgroundColor: AppColors.appBarColor,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white, size: 16),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _buildHero(),
          ),
        ),

        // ── Day Selector ───────────────────────────────────────────
        SliverToBoxAdapter(child: _buildDaySelector(days)),

        // ── Summary Card ───────────────────────────────────────────
        SliverToBoxAdapter(child: _buildDaySummaryCard(selectedDay)),

        // ── Meals Section Title ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Meals for Day ${selectedDay['day_number']}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: AppColors.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${meals.length} meals',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        // ── Meal Cards ─────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final meal = meals[i] as Map<String, dynamic>;
                final meta = _metaFor(meal['meal_type'] ?? '');
                return _MealCard(
                  meal: meal,
                  meta: meta,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(meal: meal),
                    ),
                  ),
                );
              },
              childCount: meals.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.white.withOpacity(0.12),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.secondary.withOpacity(0.2),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppColors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_cap(dietPlan!['body_type'] ?? '')}  ·  ${_cap(dietPlan!['plan_goal'] ?? '')}'
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: AppColors.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  dietPlan!['plan_name'] ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: AppColors.bold,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _statPill(
                        Icons.local_fire_department_rounded,
                        '${dietPlan!['daily_calories']} kcal',
                        AppColors.powerOrange),
                    const SizedBox(width: 10),
                    _statPill(
                        Icons.calendar_month_rounded,
                        '${dietPlan!['duration_days']} days',
                        AppColors.white),
                    const SizedBox(width: 10),
                    _statPill(
                        Icons.restaurant_menu_rounded,
                        '${(dietPlan!['days'] as List)[0]['meals'].length} meals/day',
                        AppColors.secondaryLight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: AppColors.w600)),
        ],
      ),
    );
  }

  Widget _buildDaySelector(List days) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'CHOOSE DAY',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 10,
                fontWeight: AppColors.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index] as Map<String, dynamic>;
                final isSelected = _selectedDayIndex == index;
                final cals = _dayCalories(day);

                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 64,
                    decoration: BoxDecoration(
                      gradient:
                      isSelected ? AppColors.primaryGradient : null,
                      color:
                      isSelected ? null : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color:
                          AppColors.primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ]
                          : const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'D${day['day_number']}',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: AppColors.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$cals',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white70
                                : AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: AppColors.w500,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white54
                                : AppColors.textHint,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummaryCard(Map<String, dynamic> day) {
    final meals = day['meals'] as List;
    final totalCal = _dayCalories(day);
    final totalProtein =
    meals.fold(0, (sum, m) => sum + (m['protein'] as int));
    final totalCarbs =
    meals.fold(0, (sum, m) => sum + (m['carbs'] as int));
    final totalFats =
    meals.fold(0, (sum, m) => sum + (m['fats'] as int));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Daily Totals',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: AppColors.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.powerOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.powerOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppColors.powerOrange, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCal kcal',
                        style: const TextStyle(
                          color: AppColors.powerOrange,
                          fontSize: 12,
                          fontWeight: AppColors.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _macroBar('Protein', totalProtein, 150, AppColors.primary),
                const SizedBox(width: 10),
                _macroBar(
                    'Carbs', totalCarbs, 250, AppColors.powerOrange),
                const SizedBox(width: 10),
                _macroBar(
                    'Fats', totalFats, 80, AppColors.progressPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroBar(String label, int value, int max, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 10)),
              Text('${value}g',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: AppColors.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              widthFactor: pct,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Meal Meta Model
// ─────────────────────────────────────────────────────────────────
class _MealMeta {
  final IconData icon;
  final LinearGradient gradient;
  final String tag;
  final Color tagColor;

  const _MealMeta({
    required this.icon,
    required this.gradient,
    required this.tag,
    required this.tagColor,
  });
}

// ─────────────────────────────────────────────────────────────────
// Meal Card
// ─────────────────────────────────────────────────────────────────
class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final _MealMeta meta;
  final VoidCallback onTap;

  const _MealCard({
    required this.meal,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: meta.gradient,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: meta.gradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(meta.icon,
                            color: AppColors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: meta.tagColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color:
                                    meta.tagColor.withOpacity(0.2)),
                              ),
                              child: Text(
                                meta.tag.toUpperCase(),
                                style: TextStyle(
                                  color: meta.tagColor,
                                  fontSize: 9,
                                  fontWeight: AppColors.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              meal['meal_name'] ?? '',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: AppColors.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meal['meal_description'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _macro('${meal['calories']}', 'kcal',
                            AppColors.powerOrange),
                        _divider(),
                        _macro('${meal['protein']}g', 'Protein',
                            AppColors.primary),
                        _divider(),
                        _macro('${meal['carbs']}g', 'Carbs',
                            AppColors.calmBlue),
                        _divider(),
                        _macro('${meal['fats']}g', 'Fats',
                            AppColors.progressPurple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macro(String val, String lbl, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: AppColors.w700)),
          const SizedBox(height: 2),
          Text(lbl,
              style: const TextStyle(
                  color: AppColors.textHint, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 28, color: AppColors.border);
}