import 'package:flutter/material.dart';
import '../../Themes_and_color/app_colors.dart';
import '../../ui_helper/common_widgets.dart';

class DietPlanDetails extends StatefulWidget {
  const DietPlanDetails({super.key});

  @override
  State<DietPlanDetails> createState() => _DietPlanDetailsState();
}

class _DietPlanDetailsState extends State<DietPlanDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("View Your Plan"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------------- PLAN HEADER ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Weight Gain Plan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InfoItem(title: "Duration", value: "30 Days"),
                            _InfoItem(title: "Total Meals", value: "90"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ---------------- DIET DAYS ----------------
                  _dayDietCard(
                    day: "Day 1 - Green Super Drink",
                    morning: "Milk, Bread",
                    lunch: "Rice, Chapati",
                    dinner: "Paneer, Palak",
                  ),

                  _dayDietCard(
                    day: "Day 2 - Green Super Drink",
                    morning: "Milk, Bread",
                    lunch: "Rice, Chapati",
                    dinner: "Paneer, Palak",
                  ),

                  _dayDietCard(
                    day: "Day 3 - Green Super Drink",
                    morning: "Milk, Bread",
                    lunch: "Rice, Chapati",
                    dinner: "Paneer, Palak",
                  ),
                ],
              ),
            ),
          ),

          /// ---------------- START PLAN BUTTON ----------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Start Diet Plan
                },
                child: const Text(
                  "Start Plan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- DAY DIET CARD ----------------
  Widget _dayDietCard({
    required String day,
    required String morning,
    required String lunch,
    required String dinner,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          _mealRow("Morning", morning),
          _mealRow("Lunch", lunch),
          _mealRow("Dinner", dinner),
        ],
      ),
    );
  }

  Widget _mealRow(String time, String meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            meal,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- INFO ITEM (HEADER CARD) ----------------
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
