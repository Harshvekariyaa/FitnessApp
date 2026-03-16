import 'dart:async';

import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/authetication/login_screen.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart' show UserApiService;
import '../ui_helper/bottomnavbar.dart' show BottomNavBar;
import '../ui_helper/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    bool isLoggedIn = await UserApiService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? BottomNavBar() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(
              "assets/images/r1.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(
            height: size.height,
            width: size.width,
            color: Colors.black.withValues(alpha: 0.75),
          ),

          // Bottom content: logo + title + progress
          Positioned(
            bottom: 30,
            left: 15,
            right: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/r1.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Text + progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Fit AI | Ai Fitness App",
                        style: textStyle(AppColors.primaryLight, 17, AppColors.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Train Today, Transform Tomorrow",
                        style: textStyle(AppColors.white70, 14, AppColors.w300),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: AppColors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}