import 'package:fitnessai/profile/about_app.dart';
import 'package:fitnessai/profile/feedback/feedback_screen.dart';
import 'package:fitnessai/profile/personalized_plan/workout_and_diet_plan_screen.dart';
import 'package:fitnessai/profile/set_reminder.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/profile/edit_profile_screen.dart';
import 'package:fitnessai/ai_chat_screen.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Themes_and_color/app_colors.dart';
import '../api/api_service.dart';
import '../authetication/login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  String userName = "";
  String userEmail = "";
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    loadSession();
  }

  Future<void> loadSession() async {
    final session = await UserApiService.getUserSession();

    setState(() {
      userName = session['user_name'];
      userEmail = session['user_email'];
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Settings"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [


            /// ====== USER HEADER (Leaderboard Style) =======
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.powerOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.powerOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "-", // First letter or "-"
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty ? "-" : userName,
                          style: textStyle(AppColors.white, 18, AppColors.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail.isEmpty ? "-" : userEmail,
                          style: textStyle(AppColors.white70, 13, AppColors.normal),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "AI Powered Plan",
                            style: textStyle(
                                AppColors.white, 12, AppColors.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ===== EXPLORE & PERSONALIZED =====
            _SectionCard(
              title: "Explore & Personalized",
              children: [
                _SettingTile(
                  icon: Icons.person,
                  title: "Edit Profile",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ),
                ),
                _SettingTile(
                  icon: Icons.alarm,
                  title: "Set Reminder",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SetReminder(),));
                  },
                ),
                _SettingTile(
                  icon: Icons.auto_graph,
                  title: "Personalized Plan",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutAndDietPlanScreen(),));
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// ===== APP & INFO =====
            _SectionCard(
              title: "App & Info",
              children: [
                _SettingTile(
                  icon: Icons.share,
                  title: "Share with Friends",
                  onTap: () {},
                ),
                _SettingTile(
                  icon: Icons.feedback,
                  title: "Feedback & Support",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen(),));
                  },
                ),
                _SettingTile(
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutApp()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// ===== LOGOUT =====
            GestureDetector(
              onTap: () async {
                // 1. Clear token & user data
                await UserApiService.logout();

                // 2. Navigate to Login & remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: textStyle(AppColors.white, 16, AppColors.bold),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// ===== SECTION CARD =====
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: textStyle(AppColors.black, 18, AppColors.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// ===== SETTING TILE =====
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style:
                textStyle(AppColors.black, 15, AppColors.w500),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
