import 'dart:convert';

import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  int height = 170;
  int weight = 65;
  bool isUpdating = false;
  String? userImageUrl;
  bool isLoading = true;
  int? uid = 0;


  File? newImageFile; // picked new image file
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserProfile();

  }

  Future<void> loadUserProfile() async {
    final data = await UserApiService.getUserProfile();

    if (data != null) {
      uid = data['user_id'];

      nameController.text = data['user_name'] ?? "";
      phoneController.text = data['user_phone'] ?? "";
      cityController.text = data['user_city'] ?? "";

      height = int.tryParse(data['user_height'].toString()) ?? 170;
      weight = int.tryParse(data['user_weight'].toString()) ?? 65;
      userImageUrl = data['user_image_url'];
    }


    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        newImageFile = File(pickedFile.path);
      });
    }
  }


  // void _loadUserId() async {
  //   uid = await UserApiService.getUserId();
  // }

  Future<void> _handleUpdateProfile() async {
    setState(() => isUpdating = true);

    bool success = await UserApiService.updateUserProfile(
      userName: nameController.text,
      userPhone: phoneController.text,
      userCity: cityController.text,
      userHeight: height.toString(),
      userWeight: weight.toString(),
      userImageFile: newImageFile, // <-- pass File directly
    );

    setState(() => isUpdating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Profile Updated Successfully" : "Update Failed")),
    );

    if (success) Navigator.pop(context, true);
  }


  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Edit Your Profile"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// ===== PROFILE IMAGE HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.powerOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                            Border.all(color: AppColors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height * 0.06,
                            backgroundImage: newImageFile != null
                                ? FileImage(newImageFile!) as ImageProvider
                                : (userImageUrl != null &&
                                userImageUrl!.isNotEmpty
                                ? NetworkImage(userImageUrl!)
                                : const AssetImage(
                                "assets/images/r3.jpeg")),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height * 0.022,
                            backgroundColor: AppColors.white,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Update Your Profile",
                      style: textStyle(AppColors.white, 18, AppColors.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Keep your info up to date",
                      style: textStyle(AppColors.white70, 13, AppColors.normal),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 24),

              /// ===== BASIC INFO CARD =====
              _EditSection(
                title: "Basic Information",
                child: Column(
                  children: [
                    buildTextFormField(
                      controller: nameController,
                      hText: "abc xyz",
                      lText: "Enter Name",
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== BODY METRICS =====
              _EditSection(
                title: "Body Metrics",
                child: Row(
                  children: [
                    Expanded(
                      child: numberCard(
                        title: "Height",
                        unit: "cm",
                        value: height,
                        min: 100,
                        max: 220,
                        onChanged: (v) => setState(() => height = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: numberCard(
                        title: "Weight",
                        unit: "kg",
                        value: weight,
                        min: 30,
                        max: 150,
                        onChanged: (v) => setState(() => weight = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== CONTACT INFO =====
              _EditSection(
                title: "Contact Information",
                child: Column(
                  children: [
                    buildTextFormField(
                      controller: phoneController,
                      inputType: TextInputType.number,
                      prefixIcon: const Icon(Icons.phone),
                      hText: "973XXXXXXXX",
                      lText: "Enter Phone no.",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone no is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    buildTextFormField(
                      controller: cityController,
                      prefixIcon:
                      const Icon(Icons.location_city_sharp),
                      hText: "E.g. Ahmedabad",
                      lText: "Enter City",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ===== UPDATE BUTTON =====
              SizedBox(
                width: double.infinity,
                child: elevetedbtn(
                  isUpdating ? "Updating..." : "Update Profile",
                      () {
                    if (!isUpdating) {
                      _handleUpdateProfile();
                    }
                  },
                ),
              ),


            ],
          ),
        ),
      ),

    );
  }
}


class _EditSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _EditSection({required this.title, required this.child});

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
          Text(
            title,
            style: textStyle(AppColors.black, 17, AppColors.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

