import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/api/api_service.dart';
import 'package:fitnessai/authetication/register_pages/page1.dart';
import 'package:fitnessai/authetication/register_pages/page2.dart';
import 'package:fitnessai/authetication/register_pages/page3.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../api/model/user_model.dart';
import 'login_screen.dart' show LoginScreen;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false; // Add at the top of _RegisterScreenState

  // -------- PAGE 1 --------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // -------- PAGE 2 --------
  String selectedGender = 'Male';
  int height = 170;
  int weight = 65;
  DateTime? birthDate;

  // -------- PAGE 3 --------
  int targetWeight = 65;
  String selectedGoal = 'Weight Loss';
  String selectedBodyType = 'Ectomorph';


  PageController _pageController = PageController();
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  void _nextPage() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
        setState(() => _currentStep++);
      } else {
        _submitRegistration(); // ✅ FINAL API CALL
      }
    }
  }


  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
      setState(() => _currentStep--);
    }
  }

  int _mapGoalToInt(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 1;
      case 'Weight Gain':
        return 2;
      case 'Muscle Gain':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _submitRegistration() async {
    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select birth date")),
      );
      return;
    }

    setState(() => _isLoading = true); // Show loader

    User user = User(
      userName: nameController.text.trim(),
      userEmail: emailController.text.trim(),
      userPhone: phoneController.text.trim(),
      userCity: cityController.text.trim(),
      userBirthdate: birthDate!.toIso8601String(),
      userHeight: height,
      userWeight: weight,
      userTargetWeight: targetWeight,
      userGender: selectedGender,
      userGoal: _mapGoalToInt(selectedGoal),
      userBodyType: selectedBodyType,
      userImage: null,
      userPassword: passwordController.text.trim(),
      userConfirmPassword: confirmPasswordController.text.trim(),
    );

    final User? result = await UserApiService.registerUser(user);

    setState(() => _isLoading = false); // Hide loader

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Registration Successful")),
      );

      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Registration Failed")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,

      body: Padding(
        padding: EdgeInsets.fromLTRB(25.0, screenHeight * 0.08, 25.0, 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.black),
                    ),
                    child: Icon(Icons.chevron_left, color: AppColors.black,size: 30,),
                  ),
                ),
                SizedBox(width: 15,),
                Text("Create Your Account", style: textStyle(AppColors.black, 25, AppColors.bold),),
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: StepProgressIndicator(
                totalSteps: 3,
                currentStep: _currentStep + 1,
                size: 5,
                selectedColor: AppColors.primary,
                unselectedColor: AppColors.grey.shade400,
                roundedEdges: Radius.circular(10),

              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Page1(
                    formKey: _formKeys[0],
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    cityController: cityController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                  ),

                  Page2(
                    formKey: _formKeys[1],
                    selectedGender: selectedGender,
                    height: height,
                    weight: weight,
                    birthDate: birthDate,
                    onChanged: (g, h, w, b) {
                      selectedGender = g;
                      height = h;
                      weight = w;
                      birthDate = b;
                    },
                  ),

                  Page3(
                    formKey: _formKeys[2],
                    targetWeight: targetWeight,
                    selectedGoal: selectedGoal,
                    selectedBodyType: selectedBodyType,
                    onChanged: (tw, goal, bodyType) {
                      targetWeight = tw;
                      selectedGoal = goal;
                      selectedBodyType = bodyType;
                    },
                  ),


                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0,10,0,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    InkWell(
                      onTap: _previousPage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // border: Border.all(color: AppColors.primary),
                          color: AppColors.primary
                        ),
                        child: Icon(Icons.chevron_left, color: AppColors.white,size: 40,),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: _previousPage,
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppColors.grey.shade100,
                    //     foregroundColor: Colors.white,
                    //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   child: Text("Previous", style: TextStyle(fontSize: 14, color: AppColors.black)),
                    // ),
                  if (_currentStep > 0) SizedBox(width: 10), // Space between buttons
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep < 2 ? "Next" : "Submit",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





