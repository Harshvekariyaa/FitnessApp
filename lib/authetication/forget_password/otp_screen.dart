import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import '../../api/api_service.dart';
import '../../ui_helper/common_widgets.dart';
import 'reset_password.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _controllers.map((e) => e.text).join();
    if (enteredOtp.length < 6) return; // Wait until all digits entered

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserApiService.verifyOtp(
        email: widget.email,
        otp: int.parse(enteredOtp),
      );

      setState(() {
        _isLoading = false;
      });

      if (response["success"] == true) {
        // OTP verified successfully → navigate to ResetPassword
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResetPassword(email: widget.email,)),
        );
      } else {
        // OTP verification failed → clear fields
        _clearOtpFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid OTP. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _clearOtpFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying OTP: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 48,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }

          // Auto verify OTP on last digit
          if (_controllers.every((ctrl) => ctrl.text.isNotEmpty)) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Password Recovery"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔐 Title
              const Text(
                "OTP Verification",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary
                ),
              ),

              const SizedBox(height: 8),

              // 📩 Instruction
              Text(
                "Enter the 6-digit code sent to your email",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // 📧 Email
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              // 🔢 OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _otpBox(index)),
              ),

              const SizedBox(height: 20),

              // ⏳ Loader
              if (_isLoading)
                buildLoader(),

              SizedBox(height: 12),

              // 📝 Helper Text
              Text(
                "Please enter the OTP to continue",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
