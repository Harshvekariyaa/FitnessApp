import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Meal Meta ─────────────────────────────────────────────────────────────
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

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final meta = _metaFor(meal['meal_type'] ?? '');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero App Bar ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
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
                  background: _buildHero(meal, meta),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Macro Rows
                      _buildMacroList(meal),
                      const SizedBox(height: 24),

                      // Description Section
                      _sectionTitle('About This Meal'),
                      const SizedBox(height: 12),
                      _buildDescriptionCard(meal),
                      const SizedBox(height: 24),

                      // Nutrition Breakdown
                      _sectionTitle('Nutrition Breakdown'),
                      const SizedBox(height: 12),
                      _buildNutritionBreakdown(meal),
                      const SizedBox(height: 24),

                      // Meal Info Chips
                      _sectionTitle('Meal Info'),
                      const SizedBox(height: 12),
                      _buildInfoChips(meal, meta),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero(Map<String, dynamic> meal, _MealMeta meta) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                meta.tagColor.withOpacity(0.8),
              ],
            ),
          ),
        ),

        // Decorative orb top-right
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.white.withOpacity(0.1),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        // Decorative orb bottom-left
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                meta.tagColor.withOpacity(0.25),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        // Meal icon watermark
        Positioned(
          right: 24,
          bottom: 60,
          child: Opacity(
            opacity: 0.08,
            child: Icon(meta.icon, size: 120, color: AppColors.white),
          ),
        ),

        // Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppColors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(meta.icon, color: AppColors.white, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        meta.tag.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: AppColors.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Meal name
                Text(
                  meal['meal_name'] ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: AppColors.bold,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Stat pills row
                Row(
                  children: [
                    _heroPill(Icons.local_fire_department_rounded,
                        '${meal['calories']} kcal', AppColors.powerOrange),
                    const SizedBox(width: 8),
                    _heroPill(Icons.fitness_center_rounded,
                        '${meal['protein']}g protein', AppColors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroPill(IconData icon, String label, Color color) {
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

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Row(
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
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: AppColors.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Macro List ────────────────────────────────────────────────────────────
  Widget _buildMacroList(Map<String, dynamic> meal) {
    final macros = [
      _MacroItem(
        label: 'Calories',
        value: '${meal['calories']}',
        unit: 'kcal',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.powerOrange,
        bgColor: AppColors.powerOrange.withOpacity(0.1),
      ),
      _MacroItem(
        label: 'Protein',
        value: '${meal['protein']}',
        unit: 'g',
        icon: Icons.fitness_center_rounded,
        color: AppColors.primary,
        bgColor: AppColors.primary.withOpacity(0.1),
      ),
      _MacroItem(
        label: 'Carbs',
        value: '${meal['carbs']}',
        unit: 'g',
        icon: Icons.grain_rounded,
        color: AppColors.calmBlue,
        bgColor: AppColors.calmBlue.withOpacity(0.1),
      ),
      _MacroItem(
        label: 'Fats',
        value: '${meal['fats']}',
        unit: 'g',
        icon: Icons.water_drop_rounded,
        color: AppColors.progressPurple,
        bgColor: AppColors.progressPurple.withOpacity(0.1),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(macros.length, (i) {
          final m = macros[i];
          final isLast = i == macros.length - 1;
          return Column(
            children: [
              _MacroRow(item: m),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Description Card ──────────────────────────────────────────────────────
  Widget _buildDescriptionCard(Map<String, dynamic> meal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              meal['meal_description'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.7,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nutrition Breakdown ───────────────────────────────────────────────────
  Widget _buildNutritionBreakdown(Map<String, dynamic> meal) {
    final totalCals = (meal['calories'] as int).toDouble();
    final proteinCal = (meal['protein'] as int) * 4.0;
    final carbsCal = (meal['carbs'] as int) * 4.0;
    final fatsCal = (meal['fats'] as int) * 9.0;

    final items = [
      _NutritionBarItem(
          label: 'Protein',
          value: '${meal['protein']}g',
          calories: '${proteinCal.round()} kcal',
          fraction: totalCals > 0 ? proteinCal / totalCals : 0,
          color: AppColors.primary),
      _NutritionBarItem(
          label: 'Carbohydrates',
          value: '${meal['carbs']}g',
          calories: '${carbsCal.round()} kcal',
          fraction: totalCals > 0 ? carbsCal / totalCals : 0,
          color: AppColors.calmBlue),
      _NutritionBarItem(
          label: 'Fats',
          value: '${meal['fats']}g',
          calories: '${fatsCal.round()} kcal',
          fraction: totalCals > 0 ? fatsCal / totalCals : 0,
          color: AppColors.progressPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: items
            .map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _NutritionBar(item: item),
        ))
            .toList(),
      ),
    );
  }

  // ── Info Chips ────────────────────────────────────────────────────────────
  Widget _buildInfoChips(Map<String, dynamic> meal, _MealMeta meta) {
    final mealOrder = meal['meal_order'] as int? ?? 1;
    final chips = [
      _InfoChip(
        icon: Icons.sort_rounded,
        label: 'Meal #$mealOrder of the day',
        color: AppColors.calmBlue,
      ),
      _InfoChip(
        icon: meta.icon,
        label: '${_cap(meal['meal_type'] ?? '')} meal',
        color: meta.tagColor,
      ),
      _InfoChip(
        icon: Icons.local_fire_department_rounded,
        label: '${meal['calories']} total calories',
        color: AppColors.powerOrange,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips
          .map((c) => Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: c.color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(c.icon, color: c.color, size: 14),
            const SizedBox(width: 8),
            Text(
              c.label,
              style: TextStyle(
                color: c.color,
                fontSize: 12,
                fontWeight: AppColors.w600,
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

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

class _MacroItem {
  final String label, value, unit;
  final IconData icon;
  final Color color, bgColor;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _NutritionBarItem {
  final String label, value, calories;
  final double fraction;
  final Color color;

  const _NutritionBarItem({
    required this.label,
    required this.value,
    required this.calories,
    required this.fraction,
    required this.color,
  });
}

class _InfoChip {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});
}

// ─────────────────────────────────────────────────────────────────────────────
// Macro Row Widget
// ─────────────────────────────────────────────────────────────────────────────

class _MacroRow extends StatelessWidget {
  final _MacroItem item;

  const _MacroRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Accent bar
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Icon bubble
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 16),
          ),
          const SizedBox(width: 14),

          // Label
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: AppColors.w500,
              ),
            ),
          ),

          // Value + unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  color: item.color,
                  fontSize: 20,
                  fontWeight: AppColors.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  item.unit,
                  style: TextStyle(
                    color: item.color.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: AppColors.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Bar Widget
// ─────────────────────────────────────────────────────────────────────────────

class _NutritionBar extends StatelessWidget {
  final _NutritionBarItem item;

  const _NutritionBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: AppColors.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 13,
                    fontWeight: AppColors.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.calories,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: item.fraction.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(item.fraction * 100).round()}% of total calories',
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}