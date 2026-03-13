import 'package:fitnessai/ai_chat_screen.dart';
import 'package:fitnessai/workout/injury/categorywise_injury_screen.dart';
import 'package:fitnessai/workout/injury/injury_detailed_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';

import '../../api/api_service.dart';

class InjuriesScreen extends StatefulWidget {
  const InjuriesScreen({super.key});

  @override
  State<InjuriesScreen> createState() => _InjuriesScreenState();
}

class _InjuriesScreenState extends State<InjuriesScreen> {
  List<dynamic> focusAreas = [];
  List<dynamic> injuries = [];
  List<dynamic> filteredInjuries = [];

  bool isLoadingCategories = true;
  bool isLoadingInjuries = true;
  bool showAll = false;

  static const int _defaultLimit = 5;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadFocusAreas();
    loadInjuries();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 🔹 Search listener
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredInjuries = injuries;
      } else {
        filteredInjuries = injuries.where((injury) {
          final name = (injury["injury_name"] ?? "").toString().toLowerCase();
          final desc =
          (injury["injury_description"] ?? "").toString().toLowerCase();
          return name.contains(query) || desc.contains(query);
        }).toList();
        // When searching, always show all results
        showAll = true;
      }
    });
  }

  /// 🔹 Load Categories
  Future<void> loadFocusAreas() async {
    final data = await UserApiService.getFocusAreas();
    setState(() {
      focusAreas = data;
      isLoadingCategories = false;
    });
  }

  /// 🔹 Load Injuries
  Future<void> loadInjuries() async {
    final data = await UserApiService.getInjuryList();
    setState(() {
      injuries = data;
      filteredInjuries = data;
      isLoadingInjuries = false;
    });
  }

  /// 🔹 Returns the injuries to display based on search + showAll
  List<dynamic> get _displayedInjuries {
    final isSearching = _searchController.text.trim().isNotEmpty;

    // When searching, show all filtered results
    if (isSearching) return filteredInjuries;

    // When not searching, respect showAll toggle
    if (showAll || filteredInjuries.length <= _defaultLimit) {
      return filteredInjuries;
    }
    return filteredInjuries.take(_defaultLimit).toList();
  }

  bool get _hasMore {
    final isSearching = _searchController.text.trim().isNotEmpty;
    return !isSearching &&
        !showAll &&
        filteredInjuries.length > _defaultLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Injuries"),
      body: GestureDetector(
        // Dismiss keyboard on tap outside
        onTap: () => _searchFocusNode.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Category Section
              _categorySection(),

              const SizedBox(height: 24),

              /// Injuries Title
              Text(
                "Injuries",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              /// 🔍 Search Bar
              _searchBar(),

              const SizedBox(height: 20),
              /// Injury List
              isLoadingInjuries
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedInjuries.isEmpty
                  ? _emptyState()
                  : Column(
                children: [
                  ListView.builder(
                    itemCount: _displayedInjuries.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final injury = _displayedInjuries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            _searchFocusNode.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InjuryDetailedScreen(
                                      injuryid: injury["injury_id"],
                                    ),
                              ),
                            );
                          },
                          child: _injuryCard(
                            image: injury["injury_image_url"],
                            title: injury["injury_name"],
                            description:
                            injury["injury_description"],
                          ),
                        ),
                      );
                    },
                  ),

                  /// 🔹 Explore All / Show Less Button
                  if (_hasMore) _exploreAllButton(),
                  if (showAll &&
                      filteredInjuries.length > _defaultLimit &&
                      _searchController.text.trim().isEmpty)
                    _showLessButton(),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      /// AI Chat Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        label: const Text(
          "Chat with AI",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          _searchFocusNode.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AIChatScreen()),
          );
        },
      ),
    );
  }

  /// 🔍 Search Bar Widget
  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _searchFocusNode.unfocus(),
      decoration: InputDecoration(
        hintText: "Search injuries...",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 22),
        suffixIcon: _searchController.text.isNotEmpty
            ? GestureDetector(
          onTap: () {
            _searchController.clear();
            _searchFocusNode.unfocus();
            setState(() {
              filteredInjuries = injuries;
              showAll = false;
            });
          },
          child: Icon(Icons.close, color: Colors.grey.shade500, size: 20),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  /// 🔹 Explore All Button
  Widget _exploreAllButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => showAll = true);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Explore All Injuries",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Show Less Button
  Widget _showLessButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => showAll = false);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Show Less",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_up,
                  color: Colors.grey.shade600, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Empty State
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "No injuries found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try a different search term",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Category Section
  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          itemCount: focusAreas.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = focusAreas[index];
            return GestureDetector(
              onTap: () {
                _searchFocusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorywiseInjuryScreen(
                      focusAreaId: category["focus_areas_id"],
                    ),
                  ),
                );
              },
              child: _CategoryCard(
                title: category["focus_areas_name"],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🔹 Injury Card
  Widget _injuryCard({
    required String image,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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

class _CategoryCard extends StatelessWidget {
  final String title;

  const _CategoryCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}