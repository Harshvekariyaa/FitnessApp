import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

import '../api/api_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final int mealId;

  FoodDetailScreen({super.key, required this.mealId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {


  Map<String, dynamic>? meal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMealDetails();
  }

  Future<void> loadMealDetails() async {
    try {
      final response = await UserApiService.fetchMealDetails(mealId: widget.mealId);

      setState(() {
        meal = response['data'];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching meal details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("Food Detail"),
      backgroundColor: AppColors.scaffoldBackground,
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : meal == null
    ? const Center(child: Text("Meal not found"))
        : SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 Hero Image
            Stack(
              children: [
                Image.network(
                  meal?['meal_image_url'] ?? '',
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 260,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Text(
                    meal?['meal_name'] ?? 'Meal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔹 Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Description
                  Text(
              meal?['meal_description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🔹 Info Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoTile(
                        Icons.restaurant_menu,
                        meal?['diet_plan']?['diet_plans_name'] ?? 'Diet Plan',
                      ),
                      _infoTile(
                        Icons.local_fire_department,
                        "${meal?['meal_calories'] ?? 0} kcal",
                      ),
                      _infoTile(
                        Icons.food_bank,
                        (meal?['meal_type'] ?? 'N/A').toString().toUpperCase(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// 🔹 Nutrition
                  const Text(
                    "Nutrition Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: _flatCard(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutritionItem("Protein", "${meal?['meal_protein']?.toString() ?? '0'} g"),
                        _verticalDivider(),
                        _nutritionItem("Carbs", "${meal?['meal_carbs']?.toString() ?? '0'} g"),
                        _verticalDivider(),
                        _nutritionItem("Fats","${meal?['meal_fats']?.toString() ?? '0'} g"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🔹 Recipe
                  const Text(
                    "Recipe & Ingredients",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: _flatCard(),
                    child: Text(
                      meal?['meal_recipe'] ?? 'Recipe not available',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Flat Info Tile
  Widget _infoTile(IconData icon, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _flatCard(),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Nutrition Item
  Widget _nutritionItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  /// 🔹 Flat Card Decoration (NO SHADOW)
  BoxDecoration _flatCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
    );
  }
}
