import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'food_detail_screen.dart'; // <-- import your detail screen

class MealListScreen extends StatefulWidget {
  final int dietPlanId;

  const MealListScreen({super.key, required this.dietPlanId});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<dynamic> meals = [];
  List<dynamic> filteredMeals = [];
  bool isLoading = true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';
  String? _selectedMealType; // breakfast/lunch/dinner filter


  // Convert goal number to text
  String _getGoalText(int goal) {
    switch (goal) {
      case 1:
        return "Weight Loss";
      case 2:
        return "Muscle Gain";
      case 3:
        return "Maintenance";
      default:
        return "General";
    }
  }

// Format date nicely
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> fetchMeals() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data =
      await UserApiService.fetchMeals(dietPlanId: widget.dietPlanId);

      if (!mounted) return;

      setState(() {
        meals = data['data'] ?? [];
        filteredMeals = List.from(meals);
      });
    } catch (e) {
      print("Error fetching meals: $e");
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMeals() {
    setState(() {
      filteredMeals = meals.where((meal) {
        final matchesSearch = meal['meal_name']
            .toString()
            .toLowerCase()
            .contains(_searchText.toLowerCase());
        final matchesType = _selectedMealType == null
            ? true
            : meal['meal_type'] == _selectedMealType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocus.requestFocus();
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchText = '';
      _searchController.clear();
      _filterMeals();
      _searchFocus.unfocus();
    });
  }

  void _navigateToMealDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailScreen(mealId: id,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        "Meal List",
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _isSearching ? _stopSearch : _startSearch,
          ),
        ],
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: isLoading
          ? Center(child: buildLoader())
          : meals.isEmpty
          ? const Center(child: Text("No meals available"))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Diet plan header
            // Diet plan header with slightly more details
            if (meals.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.network(
                        meals[0]['diet_plan']['diet_plan_image_url'] ?? "",
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Wrap the column in Flexible to prevent overflow
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meals[0]['diet_plan']['diet_plans_name'] ?? "",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meals[0]['diet_plan']['diet_plan_description'] ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                "${meals[0]['diet_plan']['daily_calorie_target']} kcal",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 4),

                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Goal: ${_getGoalText(meals[0]['diet_plan']['diet_plan_goal'])}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          ),
                          const SizedBox(height: 4),
                          // Wrap badges to allow multiple lines if needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Search bar
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: "Search meals...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchText = '';
                        _filterMeals();
                        _searchFocus.unfocus();
                        setState(() {});
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: AppColors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                  style: const TextStyle(
                      color: Colors.black87, fontSize: 16),
                  onChanged: (value) {
                    _searchText = value;
                    _filterMeals();
                    setState(() {});
                  },
                ),
              ),

            // Meal type filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _mealTypeFilterButton("All", null),
                  _mealTypeFilterButton("Breakfast", "breakfast"),
                  _mealTypeFilterButton("Lunch", "lunch"),
                  _mealTypeFilterButton("Dinner", "dinner"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Meal grid
            Expanded(
              child: filteredMeals.isEmpty
                  ? const Center(child: Text("No meals found"))
                  : GridView.builder(
                itemCount: filteredMeals.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.73,
                ),
                itemBuilder: (context, index) {
                  final meal = filteredMeals[index];
                  return GestureDetector(
                    onTap: () => _navigateToMealDetail(meal["meal_id"]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: AppColors.grey.shade300)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              meal['meal_image_url'] ?? "",
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded( // <-- this allows Column to use remaining space
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal['meal_name'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meal['meal_type']?.toUpperCase() ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${meal['meal_calories']} kcal",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    meal['meal_description'] ?? meal['meal_recipe'] ?? "",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealTypeFilterButton(String label, String? type) {
    final isSelected = _selectedMealType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = type;
          _filterMeals();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _nutritionInfo(String label, dynamic value, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          "$value g",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

