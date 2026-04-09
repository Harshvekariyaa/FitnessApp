import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:table_calendar/table_calendar.dart';

import '../api/api_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool isLoading = true;
  String _searchQuery = "";
  _StatsPeriod _statsPeriod = _StatsPeriod.weekly;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List historyList = [];
  Map<DateTime, List<dynamic>> workoutEvents = {};

  @override
  void initState() {
    super.initState();
    getWorkoutHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> getWorkoutHistory() async {
    try {
      final response = await UserApiService.fetchWorkoutHistory();

      if (response["success"] == true) {
        List data = response["data"];
        print(data);

        Map<DateTime, List<dynamic>> events = {};

        for (var item in data) {
          DateTime date = DateTime.parse(item["workout_date"]);
          DateTime cleanDate = DateTime(date.year, date.month, date.day);
          events[cleanDate] ??= [];
          events[cleanDate]!.add(item);
        }

        setState(() {
          historyList = data;
          workoutEvents = events;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("History API Error: $e");
      setState(() => isLoading = false);
    }
  }

  List getSelectedDayWorkouts() {
    if (_selectedDay == null) return [];
    return workoutEvents[DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    )] ??
        [];
  }

  List get filteredWorkouts {
    final base = _selectedDay == null ? historyList : getSelectedDayWorkouts();
    if (_searchQuery.isEmpty) return base;
    return base.where((w) {
      final name =
      (w["workout"]?["workout_name"] ?? "").toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, int> getAllTimeStats() {
    int totalCalories = 0, totalXp = 0, totalExercises = 0;
    for (var w in historyList) {
      totalCalories += ((w["total_calories"] ?? 0) as num).toInt();
      totalXp += int.tryParse(w["total_xp"].toString()) ?? 0;
      totalExercises += ((w["total_exercises"] ?? 0) as num).toInt();
    }
    return {
      "workouts": historyList.length,
      "calories": totalCalories,
      "xp": totalXp,
      "exercises": totalExercises,
    };
  }

  Map<String, int> getDaySummary() {
    List workouts = getSelectedDayWorkouts();
    int calories = 0, xp = 0, exercises = 0;
    for (var w in workouts) {
      calories += ((w["total_calories"] ?? 0) as num).toInt();
      xp += int.tryParse(w["total_xp"].toString()) ?? 0;
      exercises += ((w["total_exercises"] ?? 0) as num).toInt();
    }
    return {
      "workouts": workouts.length,
      "calories": calories,
      "xp": xp,
      "exercises": exercises,
    };
  }

  Map<String, int> getPeriodStats() {
    final now = DateTime.now();
    DateTime startDate;

    if (_statsPeriod == _StatsPeriod.weekly) {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else {
      startDate = DateTime(now.year, now.month, 1);
    }

    int calories = 0, xp = 0, exercises = 0, workouts = 0;
    for (var w in historyList) {
      DateTime date = DateTime.parse(w["workout_date"]);
      DateTime cleanDate = DateTime(date.year, date.month, date.day);
      if (!cleanDate.isBefore(startDate)) {
        workouts++;
        calories += ((w["total_calories"] ?? 0) as num).toInt();
        xp += int.tryParse(w["total_xp"].toString()) ?? 0;
        exercises += ((w["total_exercises"] ?? 0) as num).toInt();
      }
    }

    return {
      "workouts": workouts,
      "calories": calories,
      "xp": xp,
      "exercises": exercises,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar(
          "Workout History",
        actions: [
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = null;
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                  _searchQuery = "";
                }),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.close, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],

      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (!isLoading) _allTimeBanner(),
            const SizedBox(height: 16),
            if (!isLoading) _periodStatsCard(),
            const SizedBox(height: 16),
            _calendarCard(),
            const SizedBox(height: 16),
            if (_selectedDay != null) ...[
              _daySummaryCard(),
              const SizedBox(height: 16),
            ],
            _searchBar(),
            const SizedBox(height: 12),
            _sectionHeader(),
            const SizedBox(height: 10),
            isLoading
                ? Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: buildLoader()),
            )
                : _workoutList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── AppBar with Clear action ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Workout History",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,

    );
  }

  // ─── All-time Stats Banner ────────────────────────────────────────────────

  Widget _allTimeBanner() {
    final stats = getAllTimeStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text(
                "All-Time Stats",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _bannerStat("${stats["workouts"]}", "Workouts",
                  Icons.fitness_center),
              _bannerDivider(),
              _bannerStat("${stats["calories"]}", "Calories",
                  Icons.local_fire_department),
              _bannerDivider(),
              _bannerStat("${stats["xp"]}", "XP", Icons.bolt),
              _bannerDivider(),
              _bannerStat("${stats["exercises"]}", "Exercises",
                  Icons.format_list_bulleted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _bannerDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ─── Weekly / Monthly Stats Card ─────────────────────────────────────────

  Widget _periodStatsCard() {
    final stats = getPeriodStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: Colors.blue, size: 20),
                const SizedBox(width: 6),
                const Text("Performance",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _periodTab("Weekly", _StatsPeriod.weekly),
                      _periodTab("Monthly", _StatsPeriod.monthly),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Row(
              children: [
                _periodStatItem("${stats["workouts"]}", "Sessions",
                    Icons.fitness_center, Colors.blue),
                _periodStatItem("${stats["calories"]}", "Calories",
                    Icons.local_fire_department, Colors.orange),
                _periodStatItem(
                    "+${stats["xp"]}", "XP", Icons.bolt, Colors.amber),
                _periodStatItem("${stats["exercises"]}", "Exercises",
                    Icons.format_list_bulleted, Colors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodTab(String label, _StatsPeriod period) {
    final isActive = _statsPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _statsPeriod = period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _periodStatItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 7),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style:
              TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── Calendar Card ────────────────────────────────────────────────────────

  Widget _calendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _navButton(Icons.chevron_left, () {
                  setState(() {
                    _focusedDay = DateTime(
                        _focusedDay.year, _focusedDay.month - 1);
                  });
                }),
                Expanded(
                  child: Center(
                    child: Text(
                      "${_getMonthName(_focusedDay.month)} ${_focusedDay.year}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                _navButton(Icons.chevron_right, () {
                  setState(() {
                    _focusedDay = DateTime(
                        _focusedDay.year, _focusedDay.month + 1);
                  });
                }),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return workoutEvents[
              DateTime(day.year, day.month, day.day)] ??
                  [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _searchQuery = "";
                _searchController.clear();
                _searchFocusNode.unfocus();
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              markerDecoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 5,
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red.shade300),
              defaultTextStyle: const TextStyle(fontSize: 13.5),
              cellMargin: const EdgeInsets.all(4),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              weekendStyle: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            headerVisible: false,
            rowHeight: 44,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
    );
  }

  // ─── Day Summary Card ─────────────────────────────────────────────────────

  Widget _daySummaryCard() {
    final summary = getDaySummary();
    final items = [
      _SummaryData("Workouts", summary["workouts"].toString(),
          Icons.fitness_center, Colors.blue),
      _SummaryData("Calories", "${summary["calories"]}",
          Icons.local_fire_department, Colors.orange),
      _SummaryData(
          "XP Earned", "+${summary["xp"]}", Icons.bolt, Colors.amber),
      _SummaryData("Exercises", summary["exercises"].toString(),
          Icons.list, Colors.teal),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: items
            .map((item) => Expanded(child: _summaryItem(item)))
            .toList(),
      ),
    );
  }

  Widget _summaryItem(_SummaryData data) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, color: data.color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(data.value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 3),
        Text(data.label,
            style:
            TextStyle(color: Colors.grey.shade500, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (val) => setState(() => _searchQuery = val),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchFocusNode.unfocus(),
          decoration: InputDecoration(
            hintText: "Search workouts...",
            hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon:
            Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                setState(() => _searchQuery = "");
              },
              child: Icon(Icons.close,
                  color: Colors.grey.shade400, size: 18),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _sectionHeader() {
    final label = _selectedDay == null
        ? "All Workouts"
        : "${_getMonthName(_selectedDay!.month)} ${_selectedDay!.day}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2)),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${filteredWorkouts.length}",
              style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text("· filtered",
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  // ─── Workout List ─────────────────────────────────────────────────────────

  Widget _workoutList() {
    final workouts = filteredWorkouts;

    if (workouts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.fitness_center_outlined,
                  size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isNotEmpty
                    ? "No workouts match \"$_searchQuery\""
                    : "No workouts found",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: workouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final workout = workouts[index];

        // ✅ Use correct key: workout_details
        final workoutData = workout["workout_details"];
        final isAI = workout["ai_workout_id"] != null;
        final imageUrl = workoutData?["workout_image_url"];
        final workoutName = workoutData?["workout_name"] ?? "Unknown Workout";
        final difficulty = workoutData?["workout_difficulty"] ?? "";
        final durationMin = workoutData?["workout_duration_minute"];

        // ✅ Format calories (handle double)
        final rawCalories = workout["total_calories"] ?? 0;
        final calories = rawCalories is double
            ? rawCalories.toStringAsFixed(1)
            : rawCalories.toString();

        // ✅ Format time (trim seconds if needed — "11:14:00" → "11:14")
        final rawTime = workout["workout_time"]?.toString() ?? "";
        final timeParts = rawTime.split(":");
        final formattedTime = timeParts.length >= 2
            ? "${timeParts[0]}:${timeParts[1]}"
            : rawTime;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ Image with fallback placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: (imageUrl != null && imageUrl.toString().isNotEmpty)
                    ? Image.network(
                  imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _workoutImagePlaceholder(workoutName),
                )
                    : _workoutImagePlaceholder(workoutName),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workoutName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ AI badge
                        if (isAI)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "AI",
                              style: TextStyle(
                                  color: Colors.purple.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (difficulty.isNotEmpty)
                          _difficultyChip(difficulty),
                        if (difficulty.isNotEmpty)
                          const SizedBox(width: 8),
                        Icon(Icons.access_time,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          formattedTime,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statChip(
                            Icons.local_fire_department,
                            "$calories kcal",
                            Colors.orange),
                        const SizedBox(width: 8),
                        if (durationMin != null)
                          _statChip(
                              Icons.timer_outlined,
                              "$durationMin min",
                              Colors.blue),
                        const SizedBox(width: 8),
                        _statChip(
                            Icons.bolt,
                            "+${workout["total_xp"]} XP",
                            Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ✅ NEW: Styled placeholder when image is missing
  Widget _workoutImagePlaceholder(String workoutName) {
    // Pick a color based on first letter
    final colors = [
      Colors.blue, Colors.teal, Colors.orange,
      Colors.purple, Colors.green, Colors.red,
    ];
    final colorIndex = workoutName.isNotEmpty
        ? workoutName.codeUnitAt(0) % colors.length
        : 0;
    final color = colors[colorIndex];

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, color: color, size: 26),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              workoutName.split(" ").first,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _difficultyChip(String label) {
    Color color = Colors.blue;
    if (label.toLowerCase() == "hard") color = Colors.red;
    if (label.toLowerCase() == "medium") color = Colors.orange;

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

enum _StatsPeriod { weekly, monthly }

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryData(this.label, this.value, this.icon, this.color);
}