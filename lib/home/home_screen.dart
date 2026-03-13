import 'dart:math';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

import '../api/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<int> weekly = [1, 2, 3, 4, 5, 6];
  int selectedBodyFocusIndex = 0;

  bool isFocusLoading = false;
  List<dynamic> focusAreas = [];

  List<dynamic> workouts = [];
  bool isWorkoutLoading = false;

  late int _quoteIndex;
  late AnimationController _quoteAnimController;
  late Animation<double> _quoteFadeAnim;

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

  // ─── Placeholder data ─────────────────────────────────────────────────────
  final Map<String, dynamic> userStats = {
    'calories': '320',
    'steps': '6,240',
    'water': '1.2L',
    'streak': '5',
  };

  final List<Map<String, dynamic>> recommendedPlans = [
    {'title': 'Weight Loss', 'weeks': '8 Weeks', 'icon': Icons.local_fire_department},
    {'title': 'Muscle Gain', 'weeks': '12 Weeks', 'icon': Icons.fitness_center},
    {'title': 'Flexibility', 'weeks': '4 Weeks', 'icon': Icons.self_improvement},
    {'title': 'Cardio Core', 'weeks': '6 Weeks', 'icon': Icons.directions_run},
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
    fetchFocusAreas();
  }

  @override
  void dispose() {
    _quoteAnimController.dispose();
    super.dispose();
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

  Future<void> fetchWorkouts(int focusId) async {
    setState(() => isWorkoutLoading = true);
    final response = await UserApiService.fetchFocusAreaWorkouts(categoryId: focusId);
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
      fetchWorkouts(focusAreas[0]['focus_areas_id']);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning ☀️";
    if (hour >= 12 && hour < 17) return "Good Afternoon 🌤️";
    if (hour >= 17 && hour < 21) return "Good Evening 🌇";
    return "Good Night 🌙";
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
        padding: const EdgeInsets.all(14),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: textStyle(AppColors.white, 15, AppColors.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: textStyle(AppColors.white.withOpacity(0.8), 11, AppColors.normal)),
          ],
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(value, style: textStyle(AppColors.black, 15, AppColors.bold)),
            Text(label, style: textStyle(AppColors.grey, 11, AppColors.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text(_getGreeting(), style: textStyle(AppColors.grey, 13, AppColors.normal)),
            Text("Welcome Back!", style: textStyle(AppColors.black, 20, AppColors.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 26, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 26, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── Motivational Quote Card ──────────────────────────────────
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
                          // Large decorative quote mark
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

              // ─── Weekly Goal ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Weekly Goal", style: textStyle(AppColors.black, 16, AppColors.w600)),
                        const Spacer(),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "2", style: textStyle(AppColors.primary, 17, AppColors.bold)),
                            TextSpan(text: " / 6 days", style: textStyle(AppColors.grey, 13, AppColors.normal)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekly.map((day) {
                        final bool completed = day <= 2;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed ? AppColors.primary : AppColors.grey.shade100,
                            border: Border.all(
                              color: completed ? AppColors.primary : AppColors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: completed
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : Text(day.toString(), style: textStyle(AppColors.black, 13, AppColors.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 2 / 6,
                        minHeight: 6,
                        backgroundColor: AppColors.grey.shade200,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── Today's Stats ─────────────────────────────────────────────
              Text("Today's Stats", style: textStyle(AppColors.black, 16, AppColors.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statTile(icon: Icons.local_fire_department, value: userStats['calories']!, label: "kcal", iconColor: Colors.orange),
                  const SizedBox(width: 10),
                  _statTile(icon: Icons.directions_walk, value: userStats['steps']!, label: "Steps", iconColor: Colors.blue),
                  const SizedBox(width: 10),
                  _statTile(icon: Icons.water_drop, value: userStats['water']!, label: "Water", iconColor: Colors.cyan),
                  const SizedBox(width: 10),
                  _statTile(icon: Icons.bolt, value: "${userStats['streak']} 🔥", label: "Streak", iconColor: Colors.deepOrange),
                ],
              ),
              const SizedBox(height: 14),

              // ─── Quick Actions ─────────────────────────────────────────────
              Text("Quick Actions", style: textStyle(AppColors.black, 16, AppColors.w600)),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.restaurant_menu,
                      title: "Explore\nDiet Plans",
                      subtitle: "Fuel your body",
                      color: const Color(0xFF2ECC71),
                      onTap: () => widget.onNavigate?.call(2),
                    ),
                  ),
                  const SizedBox(width: 12),
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

              // ─── Recommended Plans ─────────────────────────────────────────
              Row(
                children: [
                  Text("Recommended Plans", style: textStyle(AppColors.black, 16, AppColors.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => widget.onNavigate?.call(1),
                    child: Text("See all", style: textStyle(AppColors.primary, 13, AppColors.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedPlans.length,
                  itemBuilder: (context, index) {
                    final plan = recommendedPlans[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => widget.onNavigate?.call(1),
                        child: Container(
                          width: 130,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(plan['icon'] as IconData, color: AppColors.primary, size: 24),
                              const SizedBox(height: 8),
                              Text(plan['title'], style: textStyle(AppColors.black, 13, AppColors.bold)),
                              const SizedBox(height: 2),
                              Text(plan['weeks'], style: textStyle(AppColors.grey, 11, AppColors.normal)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // ─── Body Focus ────────────────────────────────────────────────
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
                        Text("Body Focus", style: textStyle(AppColors.black, 16, AppColors.w600)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => widget.onNavigate?.call(1),
                          child: Text("All Workouts →", style: textStyle(AppColors.primary, 13, AppColors.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: isFocusLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: focusAreas.length,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedBodyFocusIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedBodyFocusIndex = index);
                                fetchWorkouts(focusAreas[index]['focus_areas_id']);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.grey.shade100,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    focusAreas[index]['focus_areas_name'],
                                    style: textStyle(
                                      isSelected ? AppColors.white : AppColors.black,
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
                    SizedBox(
                      height: 260,
                      child: isWorkoutLoading
                          ? const Center(child: CircularProgressIndicator())
                          : workouts.isEmpty
                          ? const Center(child: Text("No workouts available"))
                          : GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: workouts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      workout['workout_image_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${workout['workout_duration_minute'] ?? 0} min",
                                        style: textStyle(AppColors.white, 10, AppColors.w600),
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
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyle(AppColors.white, 14, AppColors.bold),
                                    ),
                                  ),
                                ],
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
