import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class Page3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  int targetWeight;
  String selectedGoal;
  String selectedBodyType;

  final Function(
      int targetWeight,
      String goal,
      String bodyType,
      ) onChanged;

  Page3({
    super.key,
    required this.formKey,
    required this.targetWeight,
    required this.selectedGoal,
    required this.selectedBodyType,
    required this.onChanged,
  });

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final List<String> goals = [
    'Weight Gain',
    'Weight Loss',
    'Muscle Gain',
  ];

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
      body: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              header(
                "Personal Fitness Profile",
                "Track your body type, goal, and target weight",
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 207,
                      child: numberCard(
                        title: 'Target Weight',
                        unit: 'kg',
                        value: widget.targetWeight,
                        min: 30,
                        max: 200,
                        onChanged: (value) {
                          setState(() => widget.targetWeight = value);
                          _updateParent();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Goal'),
                        Column(
                          children: goals
                              .map(
                                (goal) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 8),
                              child: _goalTile(goal),
                            ),
                          )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "Body Type",
                style: textStyle(AppColors.black, 18, AppColors.bold),
              ),
              const SizedBox(height: 8),

              Column(
                children: bodyTypes.entries.map((entry) {
                  return _bodyTypeTile(
                    entry.key,
                    entry.value['desc']!,
                    entry.value['img']!,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalTile(String goal) {
    final bool isSelected = widget.selectedGoal == goal;
    return GestureDetector(
      onTap: () {
        setState(() => widget.selectedGoal = goal);
        _updateParent();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isSelected ? AppColors.primary : AppColors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            goal,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color:
              isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyTypeTile(
      String type,
      String description,
      String imagePath,
      ) {
    final bool isSelected = widget.selectedBodyType == type;
    return GestureDetector(
      onTap: () {
        setState(() => widget.selectedBodyType = type);
        _updateParent();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateParent() {
    widget.onChanged(
      widget.targetWeight,
      widget.selectedGoal,
      widget.selectedBodyType,
    );
  }
}
