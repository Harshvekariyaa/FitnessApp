import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/profile/personalized_plan/diet_plans.dart';
import 'package:fitnessai/profile/personalized_plan/workout_plans.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class WorkoutAndDietPlanScreen extends StatefulWidget {
  const WorkoutAndDietPlanScreen({super.key});

  @override
  State<WorkoutAndDietPlanScreen> createState() =>
      _WorkoutAndDietPlanScreenState();
}

class _WorkoutAndDietPlanScreenState extends State<WorkoutAndDietPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slide1;
  late Animation<Offset> _slide2;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slide1 = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _slide2 = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Workout & Diet Plan"),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header label
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 4),
                  child: Text(
                    "YOUR PLANS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.5,
                    ),
                  ),
                ),

                // Workout Card
                SlideTransition(
                  position: _slide1,
                  child: _planCard(
                    context: context,
                    image: "assets/images/stretch.jpeg",
                    name: "Workout Plans",
                    planLabel: "plans available",
                    tag: "STRENGTH · CARDIO · HIIT",
                    accentColor: const Color(0xFF4FACFE),
                    iconData: Icons.fitness_center_rounded,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkoutPlans()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Diet Card
                SlideTransition(
                  position: _slide2,
                  child: _planCard(
                    context: context,
                    image: "assets/images/f1.jpeg",
                    name: "Diet Plans",
                    planLabel: "plans available",
                    tag: "KETO · BALANCED · VEGAN",
                    accentColor: const Color(0xFF43E97B),
                    iconData: Icons.restaurant_menu_rounded,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DietPlans()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom hint
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          color: Colors.white.withOpacity(0.2), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Tap a card to explore",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planCard({
    required BuildContext context,
    required String name,
    required String image,
    required String planLabel,
    required String tag,
    required Color accentColor,
    required IconData iconData,
    required VoidCallback ontap,
  }) {
    return _AnimatedPlanCard(
      image: image,
      name: name,
      tag: tag,
      accentColor: accentColor,
      iconData: iconData,
      ontap: ontap,
    );
  }
}

class _AnimatedPlanCard extends StatefulWidget {
  final String image;
  final String name;
  final String tag;
  final Color accentColor;
  final IconData iconData;
  final VoidCallback ontap;

  const _AnimatedPlanCard({
    required this.image,
    required this.name,
    required this.tag,
    required this.accentColor,
    required this.iconData,
    required this.ontap,
  });

  @override
  State<_AnimatedPlanCard> createState() => _AnimatedPlanCardState();
}

class _AnimatedPlanCardState extends State<_AnimatedPlanCard> {
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.ontap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                ),

                // Deep gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.82),
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

                // Accent color tint on left edge
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Tag + Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category tag pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.tag,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          // Icon circle
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.accentColor.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              widget.iconData,
                              color: widget.accentColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),

                      // Bottom section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plan name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),

                              // Arrow button
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: widget.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
