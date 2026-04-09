import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

import '../../api/api_service.dart';
import '../../profile/personalized_plan/diet/ai_diet_plan_details.dart';


class GenerateDietScreen extends StatefulWidget {
  const GenerateDietScreen({super.key});

  @override
  State<GenerateDietScreen> createState() => _GenerateDietScreenState();
}

class _GenerateDietScreenState extends State<GenerateDietScreen> {
  Map<String, dynamic>? _userProfile;
  bool isLoading = false;
  bool _isLoadingData = true;

  List<Map<String, dynamic>> goals = [];
  String selectedGoal = '';
  String selectedBodyType = 'ectomorph';

  final TextEditingController _caloriesController =
  TextEditingController(text: '1800');

  // ── Goal Icons & Labels (same as GenerateWorkoutScreen) ───────
  final Map<String, String> goalIcons = {
    'weight_loss': '🔥',
    'weight_gain': '⚖️',
    'muscle_gain': '💪',
    'endurance': '🏃',
    'flexibility': '🧘',
  };

  final Map<String, String> goalLabels = {
    'weight_loss': 'Weight Loss',
    'weight_gain': 'Weight Gain',
    'muscle_gain': 'Muscle Gain',
    'endurance': 'Endurance',
    'flexibility': 'Flexibility',
  };

  // ── Body Types (same as GenerateWorkoutScreen) ────────────────
  final Map<String, Map<String, String>> bodyTypes = {
    'ectomorph': {
      'label': 'Ectomorph',
      'desc': 'Naturally thin · Fast metabolism · Hard to gain weight',
      'img': 'assets/images/ecto.jpg',
    },
    'mesomorph': {
      'label': 'Mesomorph',
      'desc': 'Naturally athletic · Gains muscle easily',
      'img': 'assets/images/meso.jpg',
    },
    'endomorph': {
      'label': 'Endomorph',
      'desc': 'Higher body fat · Gains weight easily',
      'img': 'assets/images/endo.jpg',
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  // ── API Calls ─────────────────────────────────────────────────
  Future<void> _fetchAllData() async {
    setState(() => _isLoadingData = true);

    await Future.wait([
      _fetchUserProfile(),
      _fetchGoals(),
    ]);

    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _fetchUserProfile() async {
    final profile = await UserApiService.getUserProfile();
    if (mounted) {
      _userProfile = profile;
    }
  }

  Future<void> _fetchGoals() async {
    try {
      final fetchedGoals = await UserApiService.getGoals();
      if (mounted) {
        goals = fetchedGoals;
        if (goals.isNotEmpty) {
          selectedGoal = goals.first['goal_name'];
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to load goals.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  int _calculateAge(String birthdate) {
    DateTime dob = DateTime.parse(birthdate);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  int _calculateCalories() {
    int weight = _userProfile!['user_weight'];
    int target = _userProfile!['user_target_weight'];
    if (target < weight) return 1500;
    if (target > weight) return 2200;
    return 1800;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Generate Diet ─────────────────────────────────────────────
  Future<void> _generateDiet() async {
    if (_userProfile == null) return;

    final caloriesText = _caloriesController.text.trim();
    if (caloriesText.isEmpty) {
      _showSnackBar('Please enter a daily calorie target.');
      return;
    }
    final calories = int.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      _showSnackBar('Please enter a valid calorie amount.');
      return;
    }

    setState(() => isLoading = true);

    final result = await UserApiService.generateDiet(
      goal: selectedGoal,
      bodyType: selectedBodyType,
      calories: calories,
    );

    setState(() => isLoading = false);

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AiDietPlanDetails(data: result),
        ),
      );
    } else {
      _showSnackBar("Failed to generate diet. Try again.");
    }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Generate Diet Plan"),
      body: _isLoadingData
          ? Center(child: buildLoader())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ── Profile Card ────────────────────────────
            _sectionCard(
              title: "Your Information",
              icon: Icons.person_outline,
              child: _userProfile == null
                  ? _emptyProfile()
                  : _profileContent(),
            ),

            const SizedBox(height: 12),

            // ── Preferences Card ─────────────────────────
            _sectionCard(
              title: "Diet Preferences",
              icon: Icons.tune_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Goal
                  _sectionLabel("Primary Goal"),
                  const SizedBox(height: 10),
                  _goalGrid(),

                  const SizedBox(height: 22),

                  // Body Type
                  _sectionLabel("Body Type"),
                  const SizedBox(height: 10),
                  _bodyTypeCards(),

                  const SizedBox(height: 22),

                  // Calories
                  _sectionLabel("Daily Calorie Target"),
                  const SizedBox(height: 8),
                  _caloriesField(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Generate Button ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : _generateDiet,
                child: isLoading
                    ? SizedBox(
                  width: 22,
                  height: 22,
                  child: buildLoader(),
                )
                    : const Text(
                  "Generate AI Diet Plan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Profile Widgets ───────────────────────────────────────────

  Widget _profileContent() {
    String age = '—';
    if (_userProfile!['user_birthdate'] != null) {
      age = _calculateAge(_userProfile!['user_birthdate'].toString()).toString();
    }
    final height = _userProfile!['user_height'] != null
        ? '${_userProfile!['user_height']} cm'
        : '—';
    final weight = _userProfile!['user_weight'] != null
        ? '${_userProfile!['user_weight']} kg'
        : '—';
    final targetWeight = _userProfile!['user_target_weight'] != null
        ? '${_userProfile!['user_target_weight']} kg'
        : '—';

    return Column(
      children: [
        _infoTile(icon: Icons.cake_outlined, label: "Age", value: age),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        _infoTile(
            icon: Icons.straighten_outlined, label: "Height", value: height),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        _infoTile(
            icon: Icons.monitor_weight_outlined,
            label: "Weight",
            value: weight),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        _infoTile(
            icon: Icons.flag_outlined,
            label: "Target Weight",
            value: targetWeight),
      ],
    );
  }

  Widget _emptyProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.grey),
          const SizedBox(width: 8),
          Text(
            "Could not load profile.",
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 14, color: AppColors.black54)),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── Goal Grid (identical to GenerateWorkoutScreen) ────────────

  Widget _goalGrid() {
    if (goals.isEmpty) {
      return Text(
        "No goals available.",
        style: TextStyle(color: AppColors.grey, fontSize: 14),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: goals.map((goal) {
        final goalName = goal['goal_name'] as String;
        final isSelected = selectedGoal == goalName;
        final icon = goalIcons[goalName] ?? '🏋️';
        final label = goalLabels[goalName] ??
            goalName
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' ');

        return GestureDetector(
          onTap: () => setState(() => selectedGoal = goalName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Body Type Cards (identical to GenerateWorkoutScreen) ──────

  Widget _bodyTypeCards() {
    return Column(
      children: bodyTypes.entries.map((entry) {
        final isSelected = selectedBodyType == entry.key;
        return GestureDetector(
          onTap: () => setState(() => selectedBodyType = entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.07)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    entry.value['img']!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    color: isSelected ? null : Colors.grey.withOpacity(0.15),
                    colorBlendMode: BlendMode.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color:
                          isSelected ? AppColors.primary : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value['desc']!,
                        style:
                        TextStyle(fontSize: 12, color: AppColors.black54),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey(true),
                      color: AppColors.primary,
                      size: 26)
                      : Icon(Icons.radio_button_unchecked,
                      key: const ValueKey(false),
                      color: const Color(0xFFE0E0E0),
                      size: 26),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Calories Field ────────────────────────────────────────────

  Widget _caloriesField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: "e.g. 1800",
              hintStyle: TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon:
              Icon(Icons.local_fire_department_outlined, color: AppColors.primary),
              suffixText: "kcal",
              suffixStyle: TextStyle(color: AppColors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary, width: 2.0),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _caloriesPreset("1500"),
        const SizedBox(width: 6),
        _caloriesPreset("2200"),
      ],
    );
  }

  Widget _caloriesPreset(String val) {
    final isActive = _caloriesController.text == val;
    return GestureDetector(
      onTap: () => setState(() => _caloriesController.text = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE0E0E0),
            width: 1.2,
          ),
        ),
        child: Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.black54,
          ),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: AppColors.black),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 22, color: Color(0xFFEEEEEE)),
            child,
          ],
        ),
      ),
    );
  }
}