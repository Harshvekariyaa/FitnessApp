import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/profile/personalized_plan/diet/ai_diet_plan_details.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../api/api_service.dart' show UserApiService;

class AiDietPlans extends StatefulWidget {
  const AiDietPlans({super.key});

  @override
  State<AiDietPlans> createState() => _AiDietPlansState();
}

class _AiDietPlansState extends State<AiDietPlans> {
  List<Map<String, dynamic>> _dietPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDietPlans();
  }

  // ─── Fetch ───────────────────────────────────────────────────────────────
  Future<void> _fetchDietPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plans = await UserApiService.getAiDietPlans();
      setState(() {
        _dietPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  _PlanStyle _styleForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'muscle gain':
        return _PlanStyle(
          accentColor: AppColors.primary,
          lightAccent: AppColors.primaryLight.withOpacity(0.12),
          borderColor: AppColors.primaryLight.withOpacity(0.3),
          icon: Icons.fitness_center_rounded,
          label: 'Muscle Gain',
          tagColor: AppColors.primaryLight,
        );
      case 'weight loss':
        return _PlanStyle(
          accentColor: AppColors.energyRed,
          lightAccent: AppColors.energyRed.withOpacity(0.08),
          borderColor: AppColors.energyRed.withOpacity(0.2),
          icon: Icons.trending_down_rounded,
          label: 'Weight Loss',
          tagColor: AppColors.energyRed,
        );
      case 'maintenance':
        return _PlanStyle(
          accentColor: AppColors.secondary,
          lightAccent: AppColors.secondary.withOpacity(0.08),
          borderColor: AppColors.secondary.withOpacity(0.25),
          icon: Icons.balance_rounded,
          label: 'Maintenance',
          tagColor: AppColors.secondaryDark,
        );
      default:
        return _PlanStyle(
          accentColor: AppColors.progressPurple,
          lightAccent: AppColors.progressPurple.withOpacity(0.08),
          borderColor: AppColors.progressPurple.withOpacity(0.2),
          icon: Icons.restaurant_menu_rounded,
          label: goal,
          tagColor: AppColors.progressPurple,
        );
    }
  }

  String _bodyTypeLabel(String bodyType) {
    switch (bodyType.toLowerCase()) {
      case 'ectomorph':
        return 'Ectomorph — Lean Frame';
      case 'mesomorph':
        return 'Mesomorph — Athletic';
      case 'endomorph':
        return 'Endomorph — Solid Build';
      default:
        return bodyType;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May',
        'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return rawDate;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Diet Plans"),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    /// 🔄 Loading
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLoader(),
          ],
        ),
      );
    }

    /// ❌ Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Something went wrong",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: AppColors.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchDietPlans,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    /// 📭 Empty
    if (_dietPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_food_rounded,
                color: AppColors.primaryLight,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Diet Plans Yet",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: AppColors.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Generate your first AI diet plan to get started",
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
    }

    /// ✅ Success
    return RefreshIndicator(
      onRefresh: _fetchDietPlans,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _dietPlans.length,
        itemBuilder: (context, index) {
          final plan = _dietPlans[index];
          final style = _styleForGoal(plan['plan_goal'] ?? '');

          return _DietPlanCard(
            planName: plan['plan_name'] ?? '',
            bodyType: _bodyTypeLabel(plan['body_type'] ?? ''),
            dailyCalories: plan['daily_calories'] ?? 0,
            durationDays: plan['duration_days'] ?? 0,
            createdAt: _formatDate(plan['created_at'] ?? ''),
            style: style,

            // In _buildBody() → ListView.builder → _DietPlanCard onTap:
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiDietPlanDetails(
                  dietPlanId: plan['ai_diet_plan_id'] ?? 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Style Model
// ─────────────────────────────────────────────────────────────────────────────
class _PlanStyle {
  final Color accentColor;
  final Color lightAccent;
  final Color borderColor;
  final Color tagColor;
  final IconData icon;
  final String label;

  const _PlanStyle({
    required this.accentColor,
    required this.lightAccent,
    required this.borderColor,
    required this.tagColor,
    required this.icon,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _DietPlanCard extends StatelessWidget {
  final String planName;
  final String bodyType;
  final int dailyCalories;
  final int durationDays;
  final String createdAt;
  final _PlanStyle style;
  final VoidCallback? onTap;

  const _DietPlanCard({
    required this.planName,
    required this.bodyType,
    required this.dailyCalories,
    required this.durationDays,
    required this.createdAt,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top accent strip ─────────────────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: style.accentColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: style.lightAccent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: style.borderColor, width: 1.2),
                        ),
                        child: Icon(
                          style.icon,
                          color: style.accentColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Name + body type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: AppColors.w700,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bodyType,
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                                fontWeight: AppColors.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Arrow button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: style.lightAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: style.borderColor),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: style.accentColor,
                          size: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Goal Tag ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: style.lightAccent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: style.borderColor),
                    ),
                    child: Text(
                      style.label.toUpperCase(),
                      style: TextStyle(
                        color: style.tagColor,
                        fontSize: 10,
                        fontWeight: AppColors.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Divider ───────────────────────────────────────────
                  const Divider(color: AppColors.border, height: 1),

                  const SizedBox(height: 16),

                  // ── Stats Row ─────────────────────────────────────────
                  Row(
                    children: [
                      _statChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '$dailyCalories kcal',
                        label: 'Daily Calories',
                        accent: style.accentColor,
                        bg: style.lightAccent,
                        border: style.borderColor,
                      ),
                      const SizedBox(width: 10),
                      _statChip(
                        icon: Icons.calendar_month_rounded,
                        value: '$durationDays Days',
                        label: 'Duration',
                        accent: style.accentColor,
                        bg: style.lightAccent,
                        border: style.borderColor,
                      ),
                      const SizedBox(width: 10),
                      _statChip(
                        icon: Icons.access_time_filled_rounded,
                        value: createdAt,
                        label: 'Created',
                        accent: style.accentColor,
                        bg: style.lightAccent,
                        border: style.borderColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
    required Color bg,
    required Color border,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: AppColors.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 10,
                fontWeight: AppColors.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}