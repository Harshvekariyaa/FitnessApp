import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/authetication/forget_password/otp_screen.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../api/api_service.dart';

// Assuming AppColors is defined in the shared location
// import '../Themes_and_color/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Password Recovery"),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // --- 1. Header Text ---
                    Text(
                      "Trouble Logging In?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- 2. Instructions ---
                    Text(
                      "Enter the email address linked to your account. We’ll send you an OTP to help you securely reset your password.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.08),

                    buildTextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      lText: "Registered Email",
                      hText: "you@example.com",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    elevetedbtn(
                      "Send OTP",
                          () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true; // Show loading
                          });

                          final message = await UserApiService()
                              .forgotPassword(emailController.text);

                          setState(() {
                            isLoading = false; // Hide loading
                          });

                          if (message != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OtpScreen(email: emailController.text.toString(),)),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Failed to send OTP. Try again."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Remember your password? ",
                          style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Back To Login",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Loading Indicator Overlay ---
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

}