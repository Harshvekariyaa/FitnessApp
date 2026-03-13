import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';

class Page2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  // 🔹 Data from RegisterScreen
  String selectedGender;
  int height;
  int weight;
  DateTime? birthDate;

  // 🔹 Callback to update RegisterScreen values
  final Function(
      String gender,
      int height,
      int weight,
      DateTime? birthDate,
      ) onChanged;

  Page2({
    super.key,
    required this.formKey,
    required this.selectedGender,
    required this.height,
    required this.weight,
    required this.onChanged,
    this.birthDate,
  });

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Form(
        key: widget.formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header("Personal Details", "Tell us about your body"),
                const SizedBox(height: 24),

                Text(
                  "Gender",
                  style: textStyle(AppColors.black, 18, AppColors.bold),
                ),
                const SizedBox(height: 5),

                _genderSelector(),

                const SizedBox(height: 20),

                Text(
                  "Physical Stats",
                  style: textStyle(AppColors.black, 18, AppColors.bold),
                ),
                const SizedBox(height: 5),

                // 🎂 Birthdate
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey.shade300),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Birth Date",
                          style:
                          textStyle(AppColors.black, 14, AppColors.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.birthDate == null
                              ? "Select your birth date"
                              : "${widget.birthDate!.day}/${widget.birthDate!.month}/${widget.birthDate!.year}",
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.birthDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: numberCard(
                        title: "Height",
                        unit: "cm",
                        value: widget.height,
                        min: 100,
                        max: 220,
                        onChanged: (v) {
                          setState(() => widget.height = v);
                          _updateParent();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: numberCard(
                        title: "Weight",
                        unit: "kg",
                        value: widget.weight,
                        min: 30,
                        max: 150,
                        onChanged: (v) {
                          setState(() => widget.weight = v);
                          _updateParent();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧍 Gender Selector
  Widget _genderSelector() {
    return Row(
      children: [
        _genderCard("Male", Icons.male),
        const SizedBox(width: 12),
        _genderCard("Female", Icons.female),
      ],
    );
  }

  Widget _genderCard(String gender, IconData icon) {
    final bool isSelected = widget.selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => widget.selectedGender = gender);
          _updateParent();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => widget.birthDate = picked);
      _updateParent();
    }
  }

  void _updateParent() {
    widget.onChanged(
      widget.selectedGender,
      widget.height,
      widget.weight,
      widget.birthDate,
    );
  }
}
