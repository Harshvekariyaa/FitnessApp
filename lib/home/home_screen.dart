import 'dart:math';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/profile/personalized_plan/diet_plans.dart';
import 'package:fitnessai/profile/personalized_plan/workout_plans.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/workout/detailed_workout_screen.dart';
import 'package:flutter/material.dart';

import '../api/api_service.dart';

// ─── Shimmer helper ───────────────────────────────────────────────────────────
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

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
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
      builder: (_, __) {
        return Container(
          width: widget.circle ? widget.width : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
            widget.circle ? null : BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _anim.value * 3, 0),
              end: Alignment(-0.5 + _anim.value * 3, 0),
              colors: [
                AppColors.grey.shade200,
                AppColors.grey.shade100,
                AppColors.grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Full-screen skeleton matching the home screen layout ────────────────────
class _HomeScreenSkeleton extends StatelessWidget {
  const _HomeScreenSkeleton();

  Widget _gap([double h = 14]) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Shimmer(width: 120, height: 12, radius: 6),
            const SizedBox(height: 6),
            const _Shimmer(width: 160, height: 18, radius: 6),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote card
            const _Shimmer(width: double.infinity, height: 100, radius: 18),
            _gap(),

            // Weekly Goal card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _Shimmer(width: 110, height: 14, radius: 6),
                      const Spacer(),
                      const _Shimmer(width: 70, height: 14, radius: 6),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                          (_) => Column(
                        children: [
                          _Shimmer(
                            width: 36,
                            height: 36,
                            radius: 18,
                            circle: true,
                          ),
                          const SizedBox(height: 5),
                          const _Shimmer(width: 20, height: 9, radius: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _Shimmer(width: double.infinity, height: 6, radius: 6),
                  const SizedBox(height: 8),
                  const _Shimmer(width: 180, height: 11, radius: 5),
                ],
              ),
            ),
            _gap(),

            // My Progress header
            const _Shimmer(width: 100, height: 16, radius: 6),
            const SizedBox(height: 10),
            Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          _Shimmer(width: 20, height: 20, radius: 4),
                          SizedBox(height: 5),
                          _Shimmer(width: 36, height: 14, radius: 5),
                          SizedBox(height: 4),
                          _Shimmer(width: 48, height: 10, radius: 4),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            _gap(),

            // Quick Actions header
            const _Shimmer(width: 110, height: 16, radius: 6),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Shimmer(width: 32, height: 32, radius: 10),
                          SizedBox(height: 8),
                          _Shimmer(width: double.infinity, height: 12, radius: 5),
                          SizedBox(height: 4),
                          _Shimmer(width: 60, height: 10, radius: 4),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            _gap(),

            // Body Focus card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: const [
                      _Shimmer(width: 90, height: 16, radius: 6),
                      Spacer(),
                      _Shimmer(width: 100, height: 13, radius: 6),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Focus area chips
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        5,
                            (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _Shimmer(width: 90, height: 40, radius: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Workout grid cards
                  SizedBox(
                    height: 260,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: const _Shimmer(
                          width: double.infinity,
                          height: double.infinity,
                          radius: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Small inline shimmer for focus-chip loading ──────────────────────────────
class _FocusChipsSkeleton extends StatelessWidget {
  const _FocusChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        5,
            (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _Shimmer(width: 90, height: 40, radius: 30),
        ),
      ),
    );
  }
}

// ─── Small inline shimmer for workout grid loading ────────────────────────────
class _WorkoutGridSkeleton extends StatelessWidget {
  const _WorkoutGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const _Shimmer(
          width: double.infinity,
          height: double.infinity,
          radius: 16,
        ),
      ),
    );
  }
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int selectedBodyFocusIndex = 0;

  bool isFocusLoading = false;
  List<dynamic> focusAreas = [];

  List<dynamic> workouts = [];
  bool isWorkoutLoading = false;

  // ─── Full-screen loading state ────────────────────────────────────────────
  bool isLoading = true;

  late int _quoteIndex;
  late AnimationController _quoteAnimController;
  late Animation<double> _quoteFadeAnim;


  int totalWorkouts = 0;
  double totalCalories = 0;
  int currentStreak = 0;
  int totalXp = 0;

  // ─── Weekly Status ────────────────────────────────────────────────────────
  List<dynamic> weeklyStatusDays = [];
  int weeklyTarget = 6;
  int weeklyCompleted = 0;

  // ─── 100 Motivational Quotes ─────────────────────────────────────────────
  static const List<Map<String, String>> _quotes = [
    {'text': 'The only bad workout is the one that didn\'t happen.', 'author': 'Unknown'},
    {'text': 'Push yourself because no one else is going to do it for you.', 'author': 'Unknown'},
    {'text': 'Your body can stand almost anything. It\'s your mind you have to convince.', 'author': 'Unknown'},
    {'text': 'The hard days are the best because that\'s when champions are made.', 'author': 'Gabby Douglas'},
    {'text': 'Don\'t wish for it. Work for it.', 'author': 'Unknown'},
    {'text': 'Sweat is just fat crying.', 'author': 'Unknown'},
    {'text': 'Train insane or remain the same.', 'author': 'Unknown'},
    {'text': 'It never gets easier, you just get stronger.', 'author': 'Unknown'},
    {'text': 'No pain, no gain. Shut up and train.', 'author': 'Unknown'},
    {'text': 'Believe in yourself and all that you are.', 'author': 'Christian D. Larson'},
    {'text': 'The difference between try and triumph is a little umph.', 'author': 'Marvin Phillips'},
    {'text': 'Success is what comes after you stop making excuses.', 'author': 'Luis Galarza'},
    {'text': 'You don\'t have to be great to start, but you have to start to be great.', 'author': 'Zig Ziglar'},
    {'text': 'Wake up. Work out. Look hot. Kick ass.', 'author': 'Unknown'},
    {'text': 'Be stronger than your strongest excuse.', 'author': 'Unknown'},
    {'text': 'The body achieves what the mind believes.', 'author': 'Unknown'},
    {'text': 'You are one workout away from a good mood.', 'author': 'Unknown'},
    {'text': 'Fitness is not about being better than someone else. It\'s about being better than you used to be.', 'author': 'Khloe Kardashian'},
    {'text': 'Take care of your body. It\'s the only place you have to live.', 'author': 'Jim Rohn'},
    {'text': 'A one-hour workout is 4% of your day. No excuses.', 'author': 'Unknown'},
    {'text': 'Hustle for that muscle.', 'author': 'Unknown'},
    {'text': 'If it doesn\'t challenge you, it doesn\'t change you.', 'author': 'Fred DeVito'},
    {'text': 'You\'re only one workout away from a better mood.', 'author': 'Unknown'},
    {'text': 'Results happen over time, not overnight. Work hard, stay consistent.', 'author': 'Unknown'},
    {'text': 'Get comfortable with being uncomfortable.', 'author': 'Unknown'},
    {'text': 'Strength does not come from the body. It comes from the will of the soul.', 'author': 'Gandhi'},
    {'text': 'Your health is an investment, not an expense.', 'author': 'Unknown'},
    {'text': 'Fall in love with taking care of yourself.', 'author': 'Unknown'},
    {'text': 'Excuses don\'t burn calories.', 'author': 'Unknown'},
    {'text': 'Work hard in silence. Let success make the noise.', 'author': 'Frank Ocean'},
    {'text': 'Champions aren\'t made in gyms. Champions are made from something deep inside them.', 'author': 'Muhammad Ali'},
    {'text': 'Once you see results, it becomes an addiction.', 'author': 'Unknown'},
    {'text': 'Strive for progress, not perfection.', 'author': 'Unknown'},
    {'text': 'Little by little, a little becomes a lot.', 'author': 'Tanzanian Proverb'},
    {'text': 'Do something today that your future self will thank you for.', 'author': 'Sean Patrick Flanery'},
    {'text': 'You didn\'t come this far to only come this far.', 'author': 'Unknown'},
    {'text': 'Every step forward is a step in the right direction.', 'author': 'Unknown'},
    {'text': 'Discipline is doing what needs to be done, even when you don\'t want to.', 'author': 'Unknown'},
    {'text': 'Energy and persistence conquer all things.', 'author': 'Benjamin Franklin'},
    {'text': 'You can feel sore tomorrow or you can feel sorry tomorrow. You choose.', 'author': 'Unknown'},
    {'text': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain'},
    {'text': 'Strong is the new skinny.', 'author': 'Unknown'},
    {'text': 'Don\'t stop when you\'re tired. Stop when you\'re done.', 'author': 'Unknown'},
    {'text': 'The pain you feel today will be the strength you feel tomorrow.', 'author': 'Unknown'},
    {'text': 'Be the best version of you.', 'author': 'Unknown'},
    {'text': 'The only way to define your limits is by going beyond them.', 'author': 'Arthur C. Clarke'},
    {'text': 'If you\'re tired of starting over, stop giving up.', 'author': 'Unknown'},
    {'text': 'What hurts today makes you stronger tomorrow.', 'author': 'Jay Cutler'},
    {'text': 'You have to push past your perceived limits to discover your true ones.', 'author': 'Unknown'},
    {'text': 'The gym is a place where you go to lose pounds and gain confidence.', 'author': 'Unknown'},
    {'text': 'It\'s not about having time. It\'s about making time.', 'author': 'Unknown'},
    {'text': 'A year from now you\'ll wish you had started today.', 'author': 'Karen Lamb'},
    {'text': 'You are stronger than you think.', 'author': 'Unknown'},
    {'text': 'Motivation gets you started. Habit keeps you going.', 'author': 'Jim Ryun'},
    {'text': 'You only fail when you stop trying.', 'author': 'Unknown'},
    {'text': 'Your only competition is who you were yesterday.', 'author': 'Unknown'},
    {'text': 'Health is the greatest gift, contentment the greatest wealth.', 'author': 'Buddha'},
    {'text': 'When you feel like quitting, remember why you started.', 'author': 'Unknown'},
    {'text': 'The successful warrior is the average person with laser-like focus.', 'author': 'Bruce Lee'},
    {'text': 'Difficult roads often lead to beautiful destinations.', 'author': 'Unknown'},
    {'text': 'You are capable of more than you know.', 'author': 'Unknown'},
    {'text': 'Don\'t limit your challenges. Challenge your limits.', 'author': 'Jerry Dunn'},
    {'text': 'Commit to be fit.', 'author': 'Unknown'},
    {'text': 'Progress, not perfection.', 'author': 'Unknown'},
    {'text': 'Every workout is a step forward.', 'author': 'Unknown'},
    {'text': 'Breathe. Believe. Battle.', 'author': 'Unknown'},
    {'text': 'Exercise is a celebration of what your body can do.', 'author': 'Unknown'},
    {'text': 'Eat well, move often, sleep enough.', 'author': 'Unknown'},
    {'text': 'Be patient with yourself. Nothing in nature blooms all year.', 'author': 'Unknown'},
    {'text': 'Go the extra mile. It\'s never crowded there.', 'author': 'Wayne Dyer'},
    {'text': 'Small steps every day lead to big results.', 'author': 'Unknown'},
    {'text': 'The difference between who you are and who you want to be is what you do.', 'author': 'Unknown'},
    {'text': 'Your future self is watching you right now through your memories.', 'author': 'Aubrey de Grey'},
    {'text': 'Success is the sum of small efforts repeated day in and day out.', 'author': 'Robert Collier'},
    {'text': 'Train like a beast, look like a beauty.', 'author': 'Unknown'},
    {'text': 'Good things come to those who sweat.', 'author': 'Unknown'},
    {'text': 'Show up. Work hard. Be kind.', 'author': 'Unknown'},
    {'text': 'The iron never lies to you.', 'author': 'Henry Rollins'},
    {'text': 'Every rep gets you one step closer.', 'author': 'Unknown'},
    {'text': 'Rise, grind, repeat.', 'author': 'Unknown'},
    {'text': 'Invest in yourself. It pays the best interest.', 'author': 'Benjamin Franklin'},
    {'text': 'Make yourself proud.', 'author': 'Unknown'},
    {'text': 'Suffer the pain of discipline or suffer the pain of regret.', 'author': 'Jim Rohn'},
    {'text': 'No shortcuts. Just hardwork.', 'author': 'Unknown'},
    {'text': 'Fit is not a destination, it\'s a way of life.', 'author': 'Unknown'},
    {'text': 'Your health is your wealth.', 'author': 'Unknown'},
    {'text': 'Consistency is the key to results.', 'author': 'Unknown'},
    {'text': 'Burn fat. Not time.', 'author': 'Unknown'},
    {'text': 'Every day is a new opportunity to be better.', 'author': 'Unknown'},
    {'text': 'Focus. Fuel. Finish.', 'author': 'Unknown'},
    {'text': 'One more rep. One more mile. One more reason to be proud.', 'author': 'Unknown'},
    {'text': 'Work out because you love your body, not because you hate it.', 'author': 'Unknown'},
    {'text': 'Stop doubting yourself. Work hard and make it happen.', 'author': 'Unknown'},
    {'text': 'Earn your body.', 'author': 'Unknown'},
    {'text': 'Sore today, strong tomorrow.', 'author': 'Unknown'},
    {'text': 'Grow through what you go through.', 'author': 'Unknown'},
    {'text': 'The only person you should try to be better than is who you were yesterday.', 'author': 'Unknown'},
  ];

  @override
  void initState() {
    super.initState();
    _quoteIndex = Random().nextInt(_quotes.length);
    _quoteAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _quoteFadeAnim = CurvedAnimation(
      parent: _quoteAnimController,
      curve: Curves.easeInOut,
    );
    _quoteAnimController.forward();
    _loadAllData();
  }

  @override
  void dispose() {
    _quoteAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      getUserProgress(),
      fetchFocusAreas(),
      fetchWeeklyStatus(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  void _refreshQuote() async {
    await _quoteAnimController.reverse();
    setState(() {
      int newIndex;
      do {
        newIndex = Random().nextInt(_quotes.length);
      } while (newIndex == _quoteIndex);
      _quoteIndex = newIndex;
    });
    _quoteAnimController.forward();
  }

  Future<void> fetchWeeklyStatus() async {
    try {
      final response = await UserApiService.fetchWeeklyStatus();
      if (!mounted) return;
      if (response["success"] == true) {
        final days = List<dynamic>.from(response["data"] ?? []);
        final completed = days.where((d) => d['completed'] == true).length;
        setState(() {
          weeklyStatusDays = days;
          weeklyTarget = days.length;
          weeklyCompleted = completed;
        });
      }
    } catch (e) {
      debugPrint("Weekly Status API Error: $e");
    }
  }

  Future<void> fetchWorkouts(int focusId) async {
    setState(() => isWorkoutLoading = true);
    final response =
    await UserApiService.fetchFocusAreaWorkouts(categoryId: focusId);
    if (!mounted) return;
    setState(() {
      workouts = response['data'] ?? [];
      isWorkoutLoading = false;
    });
  }

  Future<void> fetchFocusAreas() async {
    setState(() => isFocusLoading = true);
    final data = await UserApiService.getFocusAreas();
    if (!mounted) return;
    setState(() {
      focusAreas = data;
      isFocusLoading = false;
    });
    if (focusAreas.isNotEmpty) {
      await fetchWorkouts(focusAreas[0]['focus_areas_id']);
    }
  }

  Future<void> getUserProgress() async {
    try {
      final response = await UserApiService.fetchUserProgress();
      if (response["success"] == true) {
        final data = response["data"];
        if (!mounted) return;
        setState(() {
          totalWorkouts = data["total_workouts"] ?? 0;
          totalCalories = double.parse((double.tryParse(data["total_calories"].toString()) ?? 0.0).toStringAsFixed(2));
          currentStreak = data["current_streak"] ?? 0;
          totalXp = int.tryParse(data["total_xp"].toString()) ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Progress API Error: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning ☀️";
    if (hour >= 12 && hour < 17) return "Good Afternoon 🌤️";
    if (hour >= 17 && hour < 21) return "Good Evening 🌇";
    return "Good Night 🌙";
  }

  // ─── Weekly Goal Card ──────────────────────────────────────────────────────
  Widget _buildWeeklyGoalCard() {
    final bool hasData = weeklyStatusDays.isNotEmpty;
    final String todayDate = DateTime.now().toIso8601String().substring(0, 10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Weekly Goal",
                  style: textStyle(AppColors.black, 16, AppColors.w600)),
              const Spacer(),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "$weeklyCompleted",
                    style: textStyle(AppColors.primary, 17, AppColors.bold),
                  ),
                  TextSpan(
                    text: " / $weeklyTarget days",
                    style: textStyle(AppColors.grey, 13, AppColors.normal),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          hasData
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            List.generate(weeklyStatusDays.length, (index) {
              final day = weeklyStatusDays[index];
              final bool completed = day['completed'] == true;
              final String dayLabel = day['day']?.toString() ?? '';
              final String date = day['date']?.toString() ?? '';
              final bool isToday = date == todayDate;
              final bool isPast = date.compareTo(todayDate) < 0;

              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.grey.shade100,
                        border: Border.all(
                          color: completed
                              ? AppColors.primary
                              : isToday
                              ? AppColors.primary
                              : AppColors.grey.shade300,
                          width: isToday && !completed ? 1.8 : 1,
                        ),
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                            : isPast && !completed
                            ? Icon(Icons.close,
                            color: AppColors.grey, size: 14)
                            : Text(
                          '${index + 1}',
                          style: textStyle(
                            isToday
                                ? AppColors.primary
                                : AppColors.black,
                            12,
                            isToday
                                ? AppColors.bold
                                : AppColors.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dayLabel,
                      style: textStyle(
                        completed
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primary
                            : AppColors.grey,
                        9,
                        completed || isToday
                            ? AppColors.w600
                            : AppColors.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            List.generate(weeklyTarget > 0 ? weeklyTarget : 7, (i) {
              final bool completed = i < weeklyCompleted;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? AppColors.primary
                      : AppColors.grey.shade100,
                  border: Border.all(
                    color: completed
                        ? AppColors.primary
                        : AppColors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.check,
                      color: Colors.white, size: 18)
                      : Text(
                    '${i + 1}',
                    style: textStyle(
                        AppColors.black, 13, AppColors.w600),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: weeklyTarget > 0 ? weeklyCompleted / weeklyTarget : 0,
              minHeight: 6,
              backgroundColor: AppColors.grey.shade200,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Builder(builder: (_) {
            final String todayDate2 =
            DateTime.now().toIso8601String().substring(0, 10);
            final int remainingFutureDays = weeklyStatusDays.where((d) {
              final String date = d['date']?.toString() ?? '';
              final bool completed = d['completed'] == true;
              return !completed && date.compareTo(todayDate2) >= 0;
            }).length;

            final String msg = weeklyCompleted >= weeklyTarget
                ? "🎉 Weekly goal achieved! Amazing work!"
                : weeklyCompleted == 0
                ? "Start your first workout today! 💪"
                : remainingFutureDays == 0
                ? "No more workouts left this week!"
                : "Keep going! $remainingFutureDays more day${remainingFutureDays > 1 ? 's' : ''} left this week.";

            return Text(
              msg,
              style: textStyle(
                weeklyCompleted >= weeklyTarget
                    ? AppColors.primary
                    : AppColors.grey,
                11,
                AppColors.normal,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.white, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: textStyle(AppColors.white, 12, AppColors.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textStyle(
                  AppColors.white.withOpacity(0.8), 10, AppColors.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressTile({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textStyle(AppColors.black, 14, AppColors.bold),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: textStyle(AppColors.grey, 10, AppColors.normal),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Full-screen skeleton (replaces full-screen CircularProgressIndicator) ──
    if (isLoading) return const _HomeScreenSkeleton();

    final quote = _quotes[_quoteIndex];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(),
                style: textStyle(AppColors.grey, 13, AppColors.normal)),
            Text("Welcome Back!",
                style: textStyle(AppColors.black, 20, AppColors.bold)),
          ],
        ),

      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Motivational Quote Card ──────────────────────────────
              FadeTransition(
                opacity: _quoteFadeAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.92),
                        AppColors.primary.withOpacity(0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u201C',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 56,
                              height: 0.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                quote['text']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            quote['author']!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _refreshQuote,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ─── Weekly Goal ──────────────────────────────────────────
              _buildWeeklyGoalCard(),

              const SizedBox(height: 14),

              // ─── My Progress ──────────────────────────────────────────
              Text("My Progress",
                  style: textStyle(AppColors.black, 16, AppColors.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _progressTile(
                    icon: Icons.fitness_center,
                    value: "$totalWorkouts",
                    label: "Workouts",
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _progressTile(
                    icon: Icons.local_fire_department,
                    value: "$totalCalories",
                    label: "kcal Burned",
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _progressTile(
                    icon: Icons.bolt,
                    value: "$currentStreak 🔥",
                    label: "Day Streak",
                    iconColor: Colors.deepOrange,
                  ),
                  const SizedBox(width: 8),
                  _progressTile(
                    icon: Icons.star_rounded,
                    value: "$totalXp",
                    label: "Total XP",
                    iconColor: Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 14),


// ─── My Plans ─────────────────────────────────────────────
              Text("My Plans",
                  style: textStyle(AppColors.black, 16, AppColors.w600)),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Your Workout card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutPlans(),));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Your Workout",
                                      style: textStyle(
                                          AppColors.white, 14, AppColors.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "View your plan",
                                      style: textStyle(
                                        AppColors.white.withOpacity(0.8),
                                        11,
                                        AppColors.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.white.withOpacity(0.8),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Your Diet card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DietPlans(),));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2ECC71),
                                Color(0xFF27AE60),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2ECC71).withOpacity(0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Your Diet",
                                      style: textStyle(
                                          AppColors.white, 14, AppColors.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "View your plan",
                                      style: textStyle(
                                        AppColors.white.withOpacity(0.8),
                                        11,
                                        AppColors.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.white.withOpacity(0.8),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── Quick Actions ─────────────────────────────────────────
              Text("Quick Actions",
                  style: textStyle(AppColors.black, 16, AppColors.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.sports_gymnastics,
                      title: "Explore\nWorkouts",
                      subtitle: "Find your routine",
                      color: AppColors.primary,
                      onTap: () => widget.onNavigate?.call(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.restaurant_menu,
                      title: "Explore\nDiet Plans",
                      subtitle: "Fuel your body",
                      color: const Color(0xFF2ECC71),
                      onTap: () => widget.onNavigate?.call(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.leaderboard,
                      title: "Leader-\nboard",
                      subtitle: "See rankings",
                      color: const Color(0xFFE67E22),
                      onTap: () => widget.onNavigate?.call(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ─── Body Focus ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Body Focus",
                            style: textStyle(
                                AppColors.black, 16, AppColors.w600)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => widget.onNavigate?.call(1),
                          child: Text("All Workouts →",
                              style: textStyle(
                                  AppColors.primary, 13, AppColors.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Focus chips — shimmer while loading
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: isFocusLoading
                          ? const _FocusChipsSkeleton()    // ← was CircularProgressIndicator
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: focusAreas.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              selectedBodyFocusIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() =>
                                selectedBodyFocusIndex = index);
                                fetchWorkouts(focusAreas[index]
                                ['focus_areas_id']);
                              },
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey.shade100,
                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    focusAreas[index]
                                    ['focus_areas_name'],
                                    style: textStyle(
                                      isSelected
                                          ? AppColors.white
                                          : AppColors.black,
                                      13,
                                      AppColors.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Workout grid — shimmer while loading
                    SizedBox(
                      height: 260,
                      child: isWorkoutLoading
                          ? const _WorkoutGridSkeleton()    // ← was CircularProgressIndicator
                          : workouts.isEmpty
                          ? const Center(
                          child: Text("No workouts available"))
                          : GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: workouts.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedWorkoutScreen(workout_id: workout["workout_id"])));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        workout['workout_image_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                                color: Colors
                                                    .grey.shade300),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black
                                                  .withOpacity(0.75),
                                            ],
                                            begin:
                                            Alignment.topCenter,
                                            end: Alignment
                                                .bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                          BorderRadius.circular(
                                              20),
                                        ),
                                        child: Text(
                                          "${workout['workout_duration_minute'] ?? 0} min",
                                          style: textStyle(
                                              AppColors.white,
                                              10,
                                              AppColors.w600),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      right: 12,
                                      child: Text(
                                        workout['workout_name'] ?? "",
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: textStyle(
                                            AppColors.white,
                                            14,
                                            AppColors.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
