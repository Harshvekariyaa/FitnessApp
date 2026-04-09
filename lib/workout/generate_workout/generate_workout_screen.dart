
import 'package:fitnessai/profile/personalized_plan/workout/ai_workout_plan_list.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import '../../api/api_service.dart';
import '../../profile/personalized_plan/workout/ai_workout_details.dart';

class GenerateWorkoutScreen extends StatefulWidget {
  const GenerateWorkoutScreen({super.key});

  @override
  State<GenerateWorkoutScreen> createState() => _GenerateWorkoutScreenState();
}

class _GenerateWorkoutScreenState extends State<GenerateWorkoutScreen> {

  String selectedDifficulty = 'beginner';
  final List<Map<String, dynamic>> difficultyLevels = [
    {'key': 'beginner',     'label': 'Beginner',     'icon': Icons.signal_cellular_alt_1_bar, 'desc': 'New to working out'},
    {'key': 'intermediate', 'label': 'Intermediate', 'icon': Icons.signal_cellular_alt_2_bar, 'desc': 'Some experience'},
    {'key': 'advanced',     'label': 'Advanced',     'icon': Icons.signal_cellular_alt,       'desc': 'Highly experienced'},
  ];

  // ── User Profile ──────────────────────────────────────────────
  Map<String, dynamic>? _userProfile;

  // ── Focus Areas ───────────────────────────────────────────────
  List<Map<String, dynamic>> focusAreas = [];

  // ── Goals (dynamic) ──────────────────────────────────────────
  List<Map<String, dynamic>> goals = [];

  // ── Loading ───────────────────────────────────────────────────
  bool _isLoading = true;

  // ── Form State ────────────────────────────────────────────────
  String selectedGoal = '';
  String selectedBodyType = 'ectomorph';
  String selectedFocusArea = '';
  final TextEditingController _durationController =
  TextEditingController(text: '45');

  bool _isGenerating = false;

  // ── Goal Icons Map ────────────────────────────────────────────
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

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  // ── API Calls ─────────────────────────────────────────────────
  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _fetchUserProfile(),
      _fetchFocusAreas(),
      _fetchGoals(),
    ]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchUserProfile() async {
    final profile = await UserApiService.getUserProfile();
    if (mounted) {
      _userProfile = profile;
    }
  }

  Future<void> _fetchFocusAreas() async {
    final areas = await UserApiService.getFocusAreas();
    if (mounted) {
      focusAreas = List<Map<String, dynamic>>.from(areas);
      if (focusAreas.isNotEmpty) {
        selectedFocusArea = focusAreas.first['focus_areas_name'];
      }
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

  Future<void> _generateWorkout() async {
    final durationText = _durationController.text.trim();
    if (durationText.isEmpty) {
      _showSnackBar('Please enter a workout duration.');
      return;
    }
    final duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      _showSnackBar('Please enter a valid duration in minutes.');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final result = await UserApiService.generateAIWorkout(
        goal: selectedGoal,
        focusArea: selectedFocusArea,
        duration: duration,
        bodyType: selectedBodyType,
        difficulty: selectedDifficulty,
      );

      if (!mounted) return;

      final int aiWorkoutId = result['ai_workout_id'];  // ← extract id

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiWorkoutDetails(
            workoutId: result['ai_workout_id'] is int
                ? result['ai_workout_id']
                : int.tryParse(result['ai_workout_id'].toString()) ?? 0,

            duration: result['workout_duration'] is int
                ? result['workout_duration']
                : int.tryParse(result['workout_duration'].toString()) ?? 0,

            name: result['workout_name']?.toString() ?? '',
            goal: result['workout_goal']?.toString() ?? '',
            focus: result['workout_focus_area']?.toString() ?? '',
            difficulty: result['workout_difficulty']?.toString() ?? '',
            bodyType: result['body_type']?.toString() ?? '',
            createdAt: result['created_at']?.toString() ?? '',
          ),
        ),
      );

    } catch (e) {
      if (mounted) _showSnackBar('Failed to generate workout. Try again.');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
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

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Generate Workout Plan"),
      body: _isLoading
          ? Center(child: buildLoader())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ── Profile Card ──────────────────────────────────
            _sectionCard(
              title: "Your Profile",
              icon: Icons.person_outline,
              child: _userProfile == null
                  ? _emptyProfile()
                  : _profileContent(),
            ),

            const SizedBox(height: 12),

            // ── Preferences Card ──────────────────────────────
            _sectionCard(
              title: "Workout Preferences",
              icon: Icons.tune_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Difficulty Level"),

                  const SizedBox(height: 10),
                  _difficultySelector(),

                  const SizedBox(height: 22),

                  // Goal
                  _sectionLabel("Primary Goal"),
                  const SizedBox(height: 10),
                  _goalGrid(),


                  const SizedBox(height: 22),

                  // Focus Area
                  _sectionLabel("Focus Area"),
                  const SizedBox(height: 10),
                  _focusAreaChips(),

                  const SizedBox(height: 22),

                  // Body Type
                  _sectionLabel("Body Type"),
                  const SizedBox(height: 10),
                  _bodyTypeCards(),

                  const SizedBox(height: 22),

                  // Duration
                  _sectionLabel("Duration (minutes)"),
                  const SizedBox(height: 8),
                  _durationField(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Generate Button ───────────────────────────────
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
                onPressed: _isGenerating ? null : _generateWorkout,
                child: _isGenerating
                    ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "Generate My Workout Plan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── View Plans Button ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AiWorkoutPlan(),));
                },
                child: Text(
                  "View All My Plans",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
      final birthDate = DateTime.parse(_userProfile!['user_birthdate']);
      final today = DateTime.now();
      int calculatedAge = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        calculatedAge--;
      }
      age = calculatedAge.toString();
    }

    final height = _userProfile!['user_height'] != null
        ? '${_userProfile!['user_height']} cm'
        : '—';
    final weight = _userProfile!['user_weight'] != null
        ? '${_userProfile!['user_weight']} kg'
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

  // ── Goal Grid ─────────────────────────────────────────────────

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
                color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
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

  // ── Focus Area Chips ──────────────────────────────────────────

  Widget _focusAreaChips() {
    if (focusAreas.isEmpty) {
      return Text(
        "No focus areas available.",
        style: TextStyle(color: AppColors.grey, fontSize: 14),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: focusAreas.map((area) {
        final label = area['focus_areas_name'] as String;
        final isSelected = selectedFocusArea == label;
        return GestureDetector(
          onTap: () => setState(() => selectedFocusArea = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                width: 1.2,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Body Type Cards ───────────────────────────────────────────

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
                color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
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
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.black,
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

  // ── Duration Field ────────────────────────────────────────────

  Widget _durationField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: "e.g. 45",
              hintStyle: TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon:
              Icon(Icons.timer_outlined, color: AppColors.primary),
              suffixText: "min",
              suffixStyle: TextStyle(color: AppColors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
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
        _durationPreset("20"),
        const SizedBox(width: 6),
        _durationPreset("45"),
        const SizedBox(width: 6),
        _durationPreset("60"),
      ],
    );
  }

  Widget _durationPreset(String val) {
    final isActive = _durationController.text == val;
    return GestureDetector(
      onTap: () => setState(() => _durationController.text = val),
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

  Widget _difficultySelector() {
    return Row(
      children: difficultyLevels.map((level) {
        final isSelected = selectedDifficulty == level['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedDifficulty = level['key']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: level['key'] != 'advanced' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    level['icon'] as IconData,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.grey,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    level['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level['desc'],
                    style: TextStyle(fontSize: 10, color: AppColors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}