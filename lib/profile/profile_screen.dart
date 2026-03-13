import 'package:fitnessai/profile/progress_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/profile/edit_profile_screen.dart';
import 'package:fitnessai/profile/setting_screen.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/api/api_service.dart';
import '../Themes_and_color/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await UserApiService.getUserProfile();
    setState(() {
      profileData = data;
      isLoading = false;
    });
  }

  String getValue(String key, {String suffix = ""}) {
    if (profileData == null) return "-";
    final value = profileData![key];
    if (value == null || value.toString().isEmpty) return "-";
    return "$value$suffix";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar(
        "Profile",
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingScreen()),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            /// ===== PROFILE HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with ring
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.white.withOpacity(0.8),
                              width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundImage:
                          profileData?['user_image_url'] != null
                              ? NetworkImage(
                              profileData!['user_image_url'])
                              : const AssetImage(
                              'assets/images/r4.jpeg')
                          as ImageProvider,
                        ),
                      ),
                      // Online dot
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.white, width: 2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    getValue("user_name"),
                    style: textStyle(
                        AppColors.white, 22, AppColors.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined,
                          size: 13,
                          color: AppColors.white.withOpacity(0.75)),
                      const SizedBox(width: 4),
                      Text(
                        getValue("user_email"),
                        style: textStyle(
                            AppColors.white70, 13, AppColors.normal),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // XP Chip + Edit Button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // XP Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.white.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${getValue("user_xp_points")} XP",
                              style: textStyle(
                                  AppColors.white, 13, AppColors.w600),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        icon: Icon(Icons.edit_outlined,
                            size: 15, color: AppColors.white),
                        label: Text(
                          "Edit Profile",
                          style: textStyle(
                              AppColors.white, 13, AppColors.w600),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const EditProfileScreen()),
                          );
                          if (result == true) loadProfile();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  /// ===== QUICK STATS ROW =====
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.straighten,
                        label: "Height",
                        value: getValue("user_height", suffix: " cm"),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.monitor_weight_outlined,
                        label: "Weight",
                        value: getValue("user_weight", suffix: " kg"),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.flag_outlined,
                        label: "Target",
                        value: getValue("user_target_weight",
                            suffix: " kg"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ===== PERSONAL INFO =====
                  _InfoCard(
                    title: "Personal Info",
                    icon: Icons.person_outline,
                    children: [
                      _InfoRow(
                          icon: Icons.cake_outlined,
                          label: "Birthdate",
                          value: getValue("user_birthdate")),
                      _InfoRow(
                          icon: Icons.wc_outlined,
                          label: "Gender",
                          value: getValue("user_gender")),
                      _InfoRow(
                          icon: Icons.accessibility_new_outlined,
                          label: "Body Type",
                          value: getValue("user_body_type")),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// ===== CONTACT INFO =====
                  _InfoCard(
                    title: "Contact & Location",
                    icon: Icons.contact_mail_outlined,
                    children: [
                      _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: "City",
                          value: getValue("user_city")),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: "Phone",
                          value: getValue("user_phone")),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// ===== CTA BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    child: elevetedbtn("Track Your Progress", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const ProgressTrackingScreen()),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== STAT CHIP =====
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: textStyle(AppColors.black, 14, AppColors.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: textStyle(AppColors.grey, 11, AppColors.normal)),
          ],
        ),
      ),
    );
  }
}

// ===== INFO CARD =====
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: textStyle(AppColors.black, 16, AppColors.bold)),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

// ===== INFO ROW =====
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.grey),
          const SizedBox(width: 10),
          Text(label,
              style: textStyle(AppColors.grey, 14, AppColors.normal)),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value,
                style: textStyle(AppColors.primary, 14, AppColors.bold)),
          ),
        ],
      ),
    );
  }
}
