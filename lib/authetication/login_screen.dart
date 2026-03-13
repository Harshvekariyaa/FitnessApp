import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/authetication/forget_password/forget_password.dart';
import 'package:fitnessai/authetication/register_screen.dart';
import 'package:fitnessai/ui_helper/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../ui_helper/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Decorative circles in background (kept as-is)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.08),

                      Center(
                        child: Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/logorect.png",
                              width: 120,
                              height: 50,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Clean Welcome Text
                      Text(
                        "Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Sign in to continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: 48),

                      // Email field (using your custom widget)
                      buildTextFormField(
                        controller: emailController,
                        hText: "you@example.com",
                        lText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, size: 22),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password field (using your custom widget)
                      buildTextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Must contain at least one uppercase letter';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Must contain at least one lowercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Must contain at least one digit';
                          }
                          if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
                              .hasMatch(value)) {
                            return 'Must contain at least one special character';
                          }
                          return null;
                        },
                        lText: "Password",
                        hText: "••••••••",
                        prefixIcon: Icon(Icons.lock_outline, size: 22),
                        obscureText: !isPasswordVisible,
                        suffixIcon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        onSuffixIconPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // Forgot password - cleaner style
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Login button (using your custom widget)
                      elevetedbtn(
                        "Sign In",
                            () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            bool success = await UserApiService.login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            setState(() => isLoading = false);

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BottomNavBar(),
                                ),
                              );
                            } else {

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("LOGIN FAILED"), backgroundColor: Colors.redAccent.shade700,));
                              // Get.snackbar(
                              //   "Login Failed",
                              //   "Invalid email or password",
                              //   snackPosition: SnackPosition.BOTTOM,
                              //   backgroundColor: Colors.redAccent,
                              //   colorText: Colors.white,
                              // );
                            }
                          }
                        },
                        isLoading: isLoading,
                      ),

                      SizedBox(height: 40),

                      // Simple register prompt
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}