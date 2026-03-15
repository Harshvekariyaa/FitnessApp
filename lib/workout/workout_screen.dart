import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/workout/injury/injuries_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import '../Themes_and_color/app_colors.dart';
import 'detailed_workout_screen.dart';
import 'generate_workout/generate_workout_screen.dart';
import 'workout_history_screen.dart';

// ─── Shimmer primitive ────────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final bool circle;

  const _Shimmer({
    required this.width,
    required this.height,
    this.radius = 10,
    this.circle = false,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
          widget.circle ? null : BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _anim.value * 3, 0),
            end: Alignment(-0.5 + _anim.value * 3, 0),
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick-workout horizontal list skeleton ───────────────────────────────────
class _QuickWorkoutsSkeleton extends StatelessWidget {
  const _QuickWorkoutsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => const _Shimmer(width: 160, height: 170, radius: 18),
    );
  }
}

// ─── Workout grid skeleton ────────────────────────────────────────────────────
class _WorkoutGridSkeleton extends StatelessWidget {
  const _WorkoutGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _Shimmer(
        width: double.infinity,
        height: double.infinity,
        radius: 20,
      ),
    );
  }
}

// ─── WorkoutScreen ────────────────────────────────────────────────────────────
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool isLoading = false;
  List<dynamic> quickWorkouts = [];

  bool isLoadingWorkout = false;
  List<dynamic> workoutList = [];

  // 🔍 Search & Filter
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedGoal = 'All';

  final List<String> _difficultyFilters = ['All', 'Easy', 'Medium', 'Hard'];

  final List<Map<String, dynamic>> _goalFilters = [
    {'label': 'All Goals',   'key': 'All',         'icon': Icons.flag_outlined},
    {'label': 'Weight Loss', 'key': 'weight_loss', 'icon': Icons.local_fire_department_outlined},
    {'label': 'Weight Gain', 'key': 'weight_gain', 'icon': Icons.trending_up_rounded},
    {'label': 'Muscle Gain', 'key': 'Muscle_gain', 'icon': Icons.fitness_center_rounded},
    {'label': 'Maintenance', 'key': 'maintenance', 'icon': Icons.balance_outlined},
  ];

  @override
  void initState() {
    super.initState();
    fetchQuickWorkouts();
    fetchWorkouts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredWorkouts {
    return workoutList.where((workout) {
      final name       = (workout['workout_name']       ?? '').toString().toLowerCase();
      final difficulty = (workout['workout_difficulty'] ?? '').toString();
      final goals      = (workout['goals'] as List<dynamic>?) ?? [];

      final matchesSearch     = _searchQuery.isEmpty || name.contains(_searchQuery);
      final matchesDifficulty = _selectedDifficulty == 'All' || difficulty == _selectedDifficulty;
      final matchesGoal       = _selectedGoal == 'All' ||
          goals.any((g) => g['goal_name'] == _selectedGoal);

      return matchesSearch && matchesDifficulty && matchesGoal;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedDifficulty != 'All' || _selectedGoal != 'All';

  Future<void> fetchQuickWorkouts() async {
    setState(() => isLoading = true);
    final data = await UserApiService.getQuickWorkouts();
    if (!mounted) return;
    setState(() { quickWorkouts = data; isLoading = false; });
  }

  Future<void> fetchWorkouts() async {
    setState(() => isLoadingWorkout = true);
    final data = await UserApiService.getWorkoutList();
    if (!mounted) return;
    setState(() { workoutList = data; isLoadingWorkout = false; });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() { _selectedDifficulty = 'All'; _selectedGoal = 'All'; });
    _searchFocusNode.unfocus();
  }

  // ── Colors / Labels ──────────────────────────────────────────────

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Hard':   return Colors.redAccent;
      case 'Medium': return Colors.orange;
      case 'Easy':   return Colors.green;
      default:       return Colors.grey;
    }
  }

  Color _goalColor(String g) {
    switch (g) {
      case 'weight_loss': return Colors.deepOrange;
      case 'weight_gain': return Colors.blue.shade500;
      case 'Muscle_gain': return Colors.purple.shade400;
      case 'maintenance': return Colors.teal;
      default:            return Colors.grey;
    }
  }

  String _goalDisplayName(String g) {
    switch (g) {
      case 'weight_loss': return 'Weight Loss';
      case 'weight_gain': return 'Weight Gain';
      case 'Muscle_gain': return 'Muscle Gain';
      case 'maintenance': return 'Maintenance';
      default:            return g;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWorkouts;

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: commonAppBar(
          "Workout",
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WorkoutHistoryScreen())),
              icon: const Icon(Icons.date_range_outlined),
            ),
            IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => InjuriesScreen())),
              icon: const Icon(Icons.personal_injury_outlined),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 AI Card
              _buildAICard(),
              const SizedBox(height: 24),

              // ⚡ Quick Workouts
              Text("Quick Workouts",
                  style: textStyle(AppColors.black, 20, AppColors.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: isLoading
                    ? const _QuickWorkoutsSkeleton()   // ← was CircularProgressIndicator
                    : quickWorkouts.isEmpty
                    ? Center(
                  child: Text(
                    "No quick workouts available",
                    style: textStyle(AppColors.grey, 14, AppColors.normal),
                  ),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: quickWorkouts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final w = quickWorkouts[index];
                    return SizedBox(
                      width: 160,
                      child: _quickWorkoutCard(
                        title: w['workout_name'] ?? '',
                        image: w['workout_image_url'] ?? '',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailedWorkoutScreen(
                                workout_id: w["workout_id"]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── All Workouts Header ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text("All Workouts",
                        style: textStyle(AppColors.black, 20, AppColors.w600)),
                  ),
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.energyRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 13, color: AppColors.energyRed),
                            const SizedBox(width: 4),
                            Text("Clear",
                                style: TextStyle(
                                    color: AppColors.energyRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔍 Search
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                style: textStyle(AppColors.black, 14, AppColors.normal),
                decoration: InputDecoration(
                  hintText: "Search workouts...",
                  hintStyle: textStyle(AppColors.grey, 14, AppColors.normal),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.grey, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.grey, size: 20),
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: AppColors.primaryDark, width: 1.5)),
                ),
              ),

              const SizedBox(height: 16),

              // 🎯 Goal Filter
              _filterLabel("Goal"),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _goalFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _goalFilters[i];
                    final selected = _selectedGoal == f['key'];
                    return _goalChip(
                      label: f['label'],
                      icon: f['icon'],
                      isSelected: selected,
                      onTap: () {
                        setState(() => _selectedGoal = f['key']);
                        _searchFocusNode.unfocus();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 💪 Difficulty Filter
              _filterLabel("Difficulty"),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _difficultyFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _difficultyFilters[i];
                    final selected = _selectedDifficulty == f;
                    return _difficultyChip(
                      label: f,
                      isSelected: selected,
                      onTap: () {
                        setState(() => _selectedDifficulty = f);
                        _searchFocusNode.unfocus();
                      },
                    );
                  },
                ),
              ),

              // Results count
              if (_hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view_rounded,
                          size: 14, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "${filtered.length} workout${filtered.length != 1 ? 's' : ''} found",
                        style:
                        textStyle(AppColors.grey, 13, AppColors.normal),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // 🏋️ Grid
              isLoadingWorkout
                  ? const _WorkoutGridSkeleton()   // ← was CircularProgressIndicator
                  : filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final workout = filtered[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailedWorkoutScreen(
                            workout_id: workout["workout_id"]),
                      ),
                    ),
                    child: _bodyFocusCard(
                      title: workout['workout_name'] ?? '',
                      image: workout['workout_image_url'] ?? '',
                      duration: workout['workout_duration_minute']
                          ?.toString() ??
                          '',
                      difficulty:
                      workout['workout_difficulty'] ?? '',
                      goals: (workout['goals'] as List<dynamic>?) ??
                          [],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────

  Widget _filterLabel(String label) => Text(
    label,
    style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9),
  );

  Widget _goalChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryDark
                  : Colors.grey.shade300,
              width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.grey,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _difficultyChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryDark
                  : Colors.grey.shade300,
              width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All') ...[
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : _difficultyColor(label))),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.grey,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAICard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.generating_tokens_outlined,
                    color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text("AI Workout Plan",
                      style:
                      textStyle(AppColors.white, 18, AppColors.w600))),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.energyRed,
                    borderRadius: BorderRadius.circular(20)),
                child: Text("NEW",
                    style:
                    textStyle(AppColors.white, 10, AppColors.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Generate a personalized workout plan based on your body, goal, and fitness level.",
            style: textStyle(
                AppColors.white.withOpacity(0.88), 13, AppColors.normal),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => GenerateWorkoutScreen())),
              icon: Icon(Icons.auto_awesome_rounded,
                  size: 17, color: AppColors.primaryDark),
              label: Text("Generate Workout",
                  style: textStyle(
                      AppColors.primaryDark, 14, AppColors.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.fitness_center_rounded,
                  size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text("No workouts found",
                style: textStyle(AppColors.black, 16, AppColors.w600)),
            const SizedBox(height: 6),
            Text("Try a different search or filter",
                style: textStyle(AppColors.grey, 13, AppColors.normal)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Clear all filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickWorkoutCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              image.isNotEmpty
                  ? Image.network(image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/begginer.jpeg",
                      fit: BoxFit.cover))
                  : Image.asset("assets/images/begginer.jpeg",
                  fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle(AppColors.white, 14, AppColors.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bodyFocusCard({
    required String title,
    required String image,
    String duration = "",
    String difficulty = "",
    List<dynamic> goals = const [],
  }) {
    final firstGoal =
    goals.isNotEmpty ? (goals[0]['goal_name'] ?? '') as String : '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: image.isNotEmpty
                  ? Image.network(image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/begginer.jpeg",
                      fit: BoxFit.cover))
                  : Image.asset("assets/images/begginer.jpeg",
                  fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.82),
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (firstGoal.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                            color: _goalColor(firstGoal).withOpacity(0.88),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(_goalDisplayName(firstGoal),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  else
                    const SizedBox(),
                  if (difficulty.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                          color: _difficultyColor(difficulty).withOpacity(0.88),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(difficulty,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                  if (duration.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Text("$duration min",
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}