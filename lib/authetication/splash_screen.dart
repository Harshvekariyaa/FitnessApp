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
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1,
                width: double.infinity,
                color: AppColors.black26,
                child: Image.asset("assets/images/r1.jpeg", fit: BoxFit.cover),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 1,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.75),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                      Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/images/r1.jpeg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          height: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                    "Fit AI | Ai Fitness App",
                                    style: textStyle(AppColors.primaryLight, 17, AppColors.w600),
                                  ),
                              Text(
                                    "Train Today, Transform Tomorrow",
                                    style: textStyle(AppColors.white70, 14, AppColors.w300),
                                  ),
                              Spacer(),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor: AppColors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                    // ListTile(
                    //   title: Text(
                    //     "Fit AI | Ai Fitness App",
                    //     style: textStyle(AppColors.white60, 17, AppColors.w600),
                    //   ),
                    //   leading: Container(
                    //     height: 60,
                    //     width: 60,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: Image.asset(
                    //       "assets/images/r1.jpeg",
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    //   subtitle: Text(
                    //     "Train Today, Transform Tomorrow",
                    //     style: textStyle(AppColors.white54, 15, AppColors.w400),
                    //   ),
                    // ),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }
}
