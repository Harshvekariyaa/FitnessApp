import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import '../../api/api_service.dart';

class InjuryDetailedScreen extends StatefulWidget {
  final int injuryid;

  const InjuryDetailedScreen({super.key, required this.injuryid});

  @override
  State<InjuryDetailedScreen> createState() => _InjuryDetailedScreenState();
}

class _InjuryDetailedScreenState extends State<InjuryDetailedScreen> {
  Map<String, dynamic>? injuryData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInjuryDetails();
  }

  Future<void> fetchInjuryDetails() async {
    final data = await UserApiService.getInjuryDetails(widget.injuryid);

    setState(() {
      injuryData = data;
      isLoading = false;
    });
  }

  /// 🔹 Image Preview Popup
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Injury Details"),
      body: isLoading
          ? Center(child: buildLoader())
          : injuryData == null
          ? const Center(child: Text("Injury not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Injury Image Header
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showImagePreview(
                          injuryData!["injury_image_url"]);
                    },
                    child: Hero(
                      tag: injuryData!["injury_image_url"],
                      child: Image.network(
                        injuryData!["injury_image_url"],
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          injuryData!["injury_name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue.withOpacity(0.85),
                          ),
                          child: Text(
                            injuryData!["focus_area"]
                            ["focus_areas_name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Injury Overview
            _outlinedCard(
              title: "Injury Overview",
              content: injuryData!["injury_description"],
            ),

            const SizedBox(height: 28),

            /// 🔹 Exercise Technique
            const Text(
              "Exercise Technique",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _techniqueCard(
                    image: injuryData!["injury_wrong_image_url"],
                    label: "Wrong Technique",
                    color: Colors.red,
                    icon: Icons.close,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _techniqueCard(
                    image: injuryData!["injury_right_image_url"],
                    label: "Correct Technique",
                    color: Colors.green,
                    icon: Icons.check,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// 🔹 Prevention Tips — Numbered List Style
            _preventionCard(
              content: injuryData!["prevention_steps"],
            ),

            const SizedBox(height: 20),

            /// 🔹 Recovery Tips — Timeline Style
            _recoveryCard(
              content: injuryData!["recovery_tips"],
            ),

            const SizedBox(height: 20),

            /// 🔹 Related Exercise — Stat Chips Style
            _relatedExerciseCard(
              name: injuryData!["exercise"]["exercise_name"],
              sets: injuryData!["exercise"]["exercise_sets"]
                  .toString(),
              reps: injuryData!["exercise"]["exercise_reps"]
                  .toString(),
              duration: injuryData!["exercise"]
              ["exercise_duration_second"]
                  .toString(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔹 Prevention Tips Card — Accent left-bar style with numbered steps
  Widget _preventionCard({required String content}) {
    final steps = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC02).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFE6AC00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Prevention Tips",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A5800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (steps.length > 1)
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCC02),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${entry.key + 1}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 Recovery Tips Card — Timeline/step style
  Widget _recoveryCard({required String content}) {
    final steps = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.healing_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Recovery Tips",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (steps.length > 1)
            ...steps.asMap().entries.map((entry) {
              final isLast = entry.key == steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Timeline line + dot
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        child: Text(
                          entry.value.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 Related Exercise Card — Horizontal stat chips
  Widget _relatedExerciseCard({
    required String name,
    required String sets,
    required String reps,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.08),
            const Color(0xFF42A5F5).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF1565C0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Related Exercise",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statChip(
                icon: Icons.repeat_rounded,
                label: "Sets",
                value: sets,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 10),
              _statChip(
                icon: Icons.loop_rounded,
                label: "Reps",
                value: reps,
                color: const Color(0xFF0288D1),
              ),
              const SizedBox(width: 10),
              _statChip(
                icon: Icons.timer_outlined,
                label: "Sec",
                value: duration,
                color: const Color(0xFF0097A7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Stat Chip for exercise
  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Technique Card
  Widget _techniqueCard({
    required String image,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                onTap: () {
                  _showImagePreview(image);
                },
                child: Hero(
                  tag: image,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 16),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 Info Card (used for Injury Overview)
  Widget _outlinedCard({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}