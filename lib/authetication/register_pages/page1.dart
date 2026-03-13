import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const Page1({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  bool isPasswordVisible1 = false;
  bool isPasswordVisible2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              header(
                "Basic Information",
                "Please enter all required fields and make sure passwords match.",
              ),

              const SizedBox(height: 20),

              buildTextFormField(
                controller: widget.nameController,
                hText: "abc xyz",
                lText: "Enter Name",
                prefixIcon: const Icon(Icons.person),
                validator: (value) =>
                value == null || value.isEmpty ? "Name is required" : null,
              ),

              const SizedBox(height: 10),

              buildTextFormField(
                controller: widget.emailController,
                hText: "you@example.com",
                lText: "Email Address",
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              buildTextFormField(
                controller: widget.phoneController,
                inputType: TextInputType.number,
                prefixIcon: const Icon(Icons.phone),
                hText: "973XXXXXXXX",
                lText: "Phone Number",
                validator: (value) =>
                value == null || value.isEmpty ? "Phone is required" : null,
              ),

              const SizedBox(height: 10),

              buildTextFormField(
                controller: widget.cityController,
                prefixIcon: const Icon(Icons.location_city),
                hText: "E.g. Ahmedabad",
                lText: "City",
                validator: (value) =>
                value == null || value.isEmpty ? "City is required" : null,
              ),

              const SizedBox(height: 10),

              buildTextFormField(
                controller: widget.passwordController,
                prefixIcon: const Icon(Icons.lock_outline),
                hText: "******",
                lText: "Password",
                obscureText: !isPasswordVisible1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 8) {
                    return "Minimum 8 characters";
                  }
                  return null;
                },
                suffixIcon: Icon(
                  isPasswordVisible1
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onSuffixIconPressed: () {
                  setState(() {
                    isPasswordVisible1 = !isPasswordVisible1;
                  });
                },
              ),

              const SizedBox(height: 10),

              buildTextFormField(
                controller: widget.confirmPasswordController,
                prefixIcon: const Icon(Icons.lock_outline),
                hText: "******",
                lText: "Confirm Password",
                obscureText: !isPasswordVisible2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm password required";
                  }
                  if (widget.passwordController.text != value) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                suffixIcon: Icon(
                  isPasswordVisible2
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onSuffixIconPressed: () {
                  setState(() {
                    isPasswordVisible2 = !isPasswordVisible2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
