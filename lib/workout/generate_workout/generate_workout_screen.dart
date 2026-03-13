import 'package:fitnessai/workout/generate_workout/workout_plan_details.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';


class GenerateWorkoutScreen extends StatefulWidget {
  const GenerateWorkoutScreen({super.key});

  @override
  State<GenerateWorkoutScreen> createState() => _GenerateWorkoutScreenState();
}

class _GenerateWorkoutScreenState extends State<GenerateWorkoutScreen> {
  // State variables (unchanged)
  String workoutTime = "Morning";
  String restDay = "Sunday";
  String selectedGoal = 'Weight Loss';
  String selectedBodyType = 'Ectomorph';
  final TextEditingController _durationController = TextEditingController(text: '45'); // Added controller for duration

  final List<String> goals = [
    'Weight Gain',
    'Weight Loss',
  ];

  final List<String> focusList = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Abs / Core',
    'Full Body',
    'Cardio / Fat Loss',
    'Strength',
    'Flexibility / Mobility',
  ];

  final List<String> selectedFocus = ['Full Body']; // Default selected focus for better UX

  final Map<String, Map<String, String>> bodyTypes = {
    'Ectomorph': {
      'desc': 'Naturally thin, fast metabolism, hard to gain weight',
      'img': 'assets/images/ecto.jpg',
    },
    'Mesomorph': {
      'desc': 'Naturally athletic, gains muscle easily',
      'img': 'assets/images/meso.jpg',
    },
    'Endomorph': {
      'desc': 'Higher body fat, gains weight easily',
      'img': 'assets/images/endo.jpg',
    },
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Generate Workout Plan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [

            /// ---------------- USER INFO ----------------
            _sectionCard(
              title: "Your Profile",
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _infoRow("Age", "21"),
                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                  _infoRow("Height", "160 cm"),
                  Divider(height: 1, color: Color(0xFFE0E0E0)),
                  _infoRow("Weight", "62 kg"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ---------------- WORKOUT PREFERENCES ----------------
            _sectionCard(
              title: "Workout Preferences",
              icon: Icons.settings_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- Goal Dropdown ---
                  _labeledDropdown(
                    label: "Primary Goal",
                    value: selectedGoal,
                    items: goals,
                    onChanged: (v) => setState(() => selectedGoal = v!),
                  ),

                  const SizedBox(height: 20),

                  // --- Focus Area Chips ---
                  _sectionTitle("Focus Area"),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: focusList.map((focus) {
                      final isSelected = selectedFocus.contains(focus);
                      return FilterChip(
                        label: Text(focus, style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )),
                        selected: isSelected,
                        checkmarkColor: Colors.white,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected ? AppColors.primary :  Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                        ),
                        onSelected: (value) {
                          setState(() {
                            // Enforce at least one focus area is selected
                            if (value || selectedFocus.length > 1) {
                              value
                                  ? selectedFocus.add(focus)
                                  : selectedFocus.remove(focus);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- Body Type Selection ---
                  _sectionTitle("Your Body Type"),
                  const SizedBox(height: 12),

                  Column(
                    children: bodyTypes.entries.map((entry) {
                      return _bodyTypeCard(entry);
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // --- Duration Input ---
                  _sectionTitle("Preferred Duration (in Minutes)"),
                  const SizedBox(height: 8),
                  _modernTextField(
                    controller: _durationController,
                    hint: "e.g., 45",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  // --- Time and Rest Day Dropdowns ---
                  Row(
                    children: [
                      Expanded(
                        child: _labeledDropdown(
                          label: "Workout Time",
                          value: workoutTime,
                          items: const ["Morning", "Afternoon", "Evening"],
                          onChanged: (v) => setState(() => workoutTime = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _labeledDropdown(
                          label: "Rest Day",
                          value: restDay,
                          items: const [
                            "Sunday", "Monday", "Tuesday", "Wednesday",
                            "Thursday", "Friday", "Saturday"
                          ],
                          onChanged: (v) => setState(() => restDay = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// ---------------- BUTTONS ----------------
            SizedBox(
              width: double.infinity,
              height: 54, // Slightly taller button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // More rounded
                  ),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutPlanDetails(),));
                },
                child: const Text(
                  "Generate Personalized Plan",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

             SizedBox(height: 10),

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
                  "View All My Plans",
                  style: TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- NEW UI HELPER WIDGETS ---

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black, // Use a secondary color for label
      ),
    );
  }

  /// ---------------- REPLACED _sectionContainer with a Card-like _sectionCard ----------------
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

      margin: EdgeInsets.zero,
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
                    fontWeight: FontWeight.bold, // Bolder title
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

  Widget _bodyTypeCard(MapEntry<String, Map<String, String>> entry) {
    final isSelected = selectedBodyType == entry.key;

    return GestureDetector(
      onTap: () {
        setState(() => selectedBodyType = entry.key);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                entry.value['img']!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                color: isSelected ? null : Colors.grey.withOpacity(0.1),
                colorBlendMode: BlendMode.color,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value['desc']!,
                    style: TextStyle(fontSize: 13, color: AppColors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }


  /// ---------------- IMPROVED INPUT FIELDS ----------------
  Widget _modernTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center, // Center text for numerical input
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textStyle(AppColors.grey, 18, AppColors.normal),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Removed default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        isDense: true,
      ),
    );
  }

  // Renamed _simpleDropdown to _labeledDropdown for clarity and improved styling
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
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.black),
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// ---------------- INFO ROW (Slightly improved style) ----------------
class _infoRow extends StatelessWidget {
  final String title;
  final String value;

  const _infoRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Increased vertical padding
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: AppColors.black, fontSize: 15))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
