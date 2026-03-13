import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

import 'diet_plan_details.dart';

class GenerateDietScreen extends StatefulWidget {
  const GenerateDietScreen({super.key});

  @override
  State<GenerateDietScreen> createState() => _GenerateDietScreenState();
}

class _GenerateDietScreenState extends State<GenerateDietScreen> {
  String dietType = "Heavy";
  String calories = "2000 Cal";
  String mealFrequency = "3 Meals / Day";

  final List<String> dietTypes = ["Light", "Medium", "Heavy"];
  final List<String> caloriesList = [
    "1500 Cal",
    "1800 Cal",
    "2000 Cal",
    "2500 Cal"
  ];
  final List<String> mealList = [
    "2 Meals / Day",
    "3 Meals / Day",
    "4 Meals / Day",
    "5 Meals / Day",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Generate Diet Plan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [

            /// ---------------- USER INFO ----------------
            _sectionCard(
              title: "Your Information",
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _infoRow("Age", "21"),
                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                  _infoRow("Height", "160 cm"),
                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                  _infoRow("Weight", "62 kg"),
                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                  _infoRow("Target Weight", "75 kg"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ---------------- DIET PREFERENCES ----------------
            _sectionCard(
              title: "Dietary Preferences",
              icon: Icons.restaurant_menu_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _labeledDropdown(
                    label: "Diet Type",
                    value: dietType,
                    items: dietTypes,
                    onChanged: (v) => setState(() => dietType = v!),
                  ),

                  const SizedBox(height: 20),

                  _labeledDropdown(
                    label: "Calories Intake",
                    value: calories,
                    items: caloriesList,
                    onChanged: (v) => setState(() => calories = v!),
                  ),

                  const SizedBox(height: 20),

                  _labeledDropdown(
                    label: "Meal Frequency",
                    value: mealFrequency,
                    items: mealList,
                    onChanged: (v) => setState(() => mealFrequency = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ---------------- BUTTONS ----------------
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DietPlanDetails(),));
                },
                child: const Text(
                  "Generate Personalized Plan",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "All My Personalized Plans",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ---------------- SECTION CARD ----------------
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: AppColors.black),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  /// ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  /// ---------------- DROPDOWN ----------------
  Widget _labeledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.black),
          items: items
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// ---------------- INFO ROW ----------------
class _infoRow extends StatelessWidget {
  final String title;
  final String value;

  const _infoRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: AppColors.black, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
