import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("About App"),
      backgroundColor: AppColors.scaffoldBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// ── Hero Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.powerOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center,
                          size: 52, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "FitnessAI",
                      style: textStyle(AppColors.white, 32, AppColors.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your Smartest Fitness Companion",
                      style: textStyle(AppColors.white70, 14, AppColors.normal),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Version 1.0.0",
                        style: textStyle(AppColors.white, 13, AppColors.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ── Mission ──
              _InfoCard(
                icon: Icons.rocket_launch_rounded,
                title: "Our Mission",
                description:
                "FitnessAI is built to make elite-level fitness and nutrition accessible to everyone. We combine cutting-edge AI with real science to give you a plan that's truly yours.",
              ),

              const SizedBox(height: 16),

              /// ── Feature Cards ──
              _SectionTitle(title: "What We Offer"),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.auto_graph,
                      title: "AI Workout Plan",
                      subtitle: "Adaptive plans built for your goals",
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.restaurant_menu,
                      title: "AI Diet Plan",
                      subtitle: "Smart nutrition tailored to you",
                      color: AppColors.powerOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.smart_toy_rounded,
                      title: "AI Chatbot",
                      subtitle: "Ask anything, anytime",
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.leaderboard,
                      title: "Leaderboard",
                      subtitle: "Compete & stay motivated",
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),



              const SizedBox(height: 24),

              /// ── Why FitnessAI ──
              _SectionTitle(title: "Why FitnessAI?"),
              const SizedBox(height: 12),

              _WhyTile(
                icon: Icons.psychology_alt,
                title: "Powered by AI",
                subtitle: "Every plan is dynamically generated based on your body and goals.",
              ),
              _WhyTile(
                icon: Icons.track_changes,
                title: "Progress Tracking",
                subtitle: "Monitor your streaks, calories, and milestones in real time.",
              ),
              _WhyTile(
                icon: Icons.lock_outline,
                title: "Privacy First",
                subtitle: "Your data is secure. We never sell or share your information.",
              ),
              _WhyTile(
                icon: Icons.devices,
                title: "Beautiful UI",
                subtitle: "Designed to feel premium, fast, and effortless to use.",
              ),

              const SizedBox(height: 24),

              /// ── Footer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Text("Made with ❤️ for Fitness Lovers",
                        style:
                        textStyle(AppColors.black, 14, AppColors.w500),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text("© 2025 FitnessAI. All rights reserved.",
                        style:
                        textStyle(AppColors.grey, 12, AppColors.normal),
                        textAlign: TextAlign.center),
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

// ── Helpers ──────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: textStyle(AppColors.black, 18, AppColors.bold)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _InfoCard(
      {required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textStyle(AppColors.black, 16, AppColors.bold)),
                const SizedBox(height: 6),
                Text(description,
                    style:
                    textStyle(AppColors.grey, 13, AppColors.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _FeatureTile(
      {required this.icon,
        required this.title,
        required this.subtitle,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: textStyle(AppColors.black, 14, AppColors.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: textStyle(AppColors.grey, 12, AppColors.normal)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: textStyle(AppColors.primary, 22, AppColors.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: textStyle(AppColors.grey, 13, AppColors.normal)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.black12);
  }
}

class _WhyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _WhyTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textStyle(AppColors.black, 14, AppColors.bold)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: textStyle(AppColors.grey, 12, AppColors.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
