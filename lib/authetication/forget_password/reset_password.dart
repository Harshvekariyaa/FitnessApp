import 'package:flutter/material.dart';
import 'dart:async';
import '../../Themes_and_color/app_colors.dart';
import '../../api/api_service.dart';
import '../../ui_helper/common_widgets.dart';


class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}


class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible1 = false;
  bool isPasswordVisible2 = false;
  bool isLoading = false; // To show progress indicator

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    try {
      final response = await UserApiService.resetPassword(
        email: widget.email,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Password reset successfully!")),
        );
        Navigator.pop(context); // Go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Password reset failed!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Reset Password"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
        
                // 🔐 Title
                const Text(
                  "Create New Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        
                const SizedBox(height: 6),
        
                // 📝 Subtitle
                Text(
                  "Your new password must be different from previously used passwords.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
        
                const SizedBox(height: 30),
        
                // 🔑 Password Field
                buildTextFormField(
                  controller: passwordController,
                  prefixIcon: const Icon(Icons.lock_outline),
                  hText: "Enter Password",
                  lText: "Password",
                  obscureText: !isPasswordVisible1,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 8) return "Minimum 8 characters";
                    return null;
                  },
                  suffixIcon: Icon(
                    isPasswordVisible1 ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primary,
                  ),
                  onSuffixIconPressed: () {
                    setState(() {
                      isPasswordVisible1 = !isPasswordVisible1;
                    });
                  },
                ),
        
                const SizedBox(height: 6),
        
                // ℹ️ Password hint
                Text(
                  "Use at least 8 characters with a mix of letters & numbers",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
        
                const SizedBox(height: 20),
        
                // 🔐 Confirm Password
                buildTextFormField(
                  controller: confirmPasswordController,
                  prefixIcon: const Icon(Icons.lock_outline),
                  hText: "Confirm Password",
                  lText: "Confirm Password",
                  obscureText: !isPasswordVisible2,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Confirm password is required";
                    if (passwordController.text != value) return "Passwords do not match";
                    return null;
                  },
                  suffixIcon: Icon(
                    isPasswordVisible2 ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primary,
                  ),
                  onSuffixIconPressed: () {
                    setState(() {
                      isPasswordVisible2 = !isPasswordVisible2;
                    });
                  },
                ),
        
                const SizedBox(height: 40),
        
                // 🔘 Button
        
              Row(
                children: [
                  Expanded(
                    child: elevetedbtn(
                      "Reset Password",
                      _submit,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
        
        
              ],
            ),
        
          ),
        ),
      ),
    );
  }
}
