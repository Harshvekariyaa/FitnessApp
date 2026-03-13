import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/home/home_screen.dart';
import 'package:fitnessai/leaderboard/leaderboard_screen.dart';
import 'package:fitnessai/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../diet/food_plan_screen.dart';
import '../workout/workout_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime? lastBackPressTime;
  late final List<Widget> _pages;

  // 👇 Changes the active tab — called from HomeScreen via callback
  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    // Build pages here so _navigateToTab is fully bound before HomeScreen uses it
    _pages = [
      KeepAlivePage(child: HomeScreen(onNavigate: _navigateToTab)),
      KeepAlivePage(child: WorkoutScreen()),
      KeepAlivePage(child: FoodScreen()),
      KeepAlivePage(child: LeaderboardScreen()),
      KeepAlivePage(child: ProfileScreen()),
    ];
  }

  void _handleBackPress() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    DateTime now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap two times to exit")),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: GNav(
              gap: 8,
              backgroundColor: AppColors.white,
              color: AppColors.grey,
              activeColor: AppColors.white,
              tabBackgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 25,
                vertical: 12,
              ),
              iconSize: 22,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                GButton(icon: LucideIcons.home),
                GButton(icon: Icons.sports_gymnastics),
                GButton(icon: Icons.coffee),
                GButton(icon: Icons.leaderboard),
                GButton(icon: Icons.person),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}