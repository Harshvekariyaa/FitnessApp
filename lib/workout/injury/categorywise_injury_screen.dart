import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:fitnessai/workout/injury/injury_detailed_screen.dart';
import '../../api/api_service.dart';

class CategorywiseInjuryScreen extends StatefulWidget {
  final int focusAreaId;

  const CategorywiseInjuryScreen({super.key, required this.focusAreaId});

  @override
  State<CategorywiseInjuryScreen> createState() =>
      _CategorywiseInjuryScreenState();
}

class _CategorywiseInjuryScreenState extends State<CategorywiseInjuryScreen> {
  List<dynamic> injuriesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInjuries();
  }

  Future<void> fetchInjuries() async {
    final data =
    await UserApiService.getInjuryListByFocusArea(widget.focusAreaId);

    setState(() {
      injuriesList = data ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Injuries"),
      body: isLoading
          ? Center(child: buildLoader())
          : injuriesList.isEmpty
          ? _emptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: injuriesList.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> injury = injuriesList[index];

          return _injuryCard(
            context: context,
            injury: injury,
          );
        },
      ),
    );
  }

  /// 🔹 Empty State UI
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            "No Injuries Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "This focus area currently has no injuries listed.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Injury Card Widget
  Widget _injuryCard({
    required BuildContext context,
    required Map<String, dynamic> injury,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InjuryDetailedScreen(injuryid: injury["injury_id"],),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(injury["injury_image_url"]),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.2),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /// Category Chip
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  injury["focus_area"]["focus_areas_name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Injury Name
              Text(
                injury["injury_name"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              /// Description
              Text(
                injury["injury_description"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}