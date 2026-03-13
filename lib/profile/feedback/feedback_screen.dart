import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import 'feedbacklist_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

  final _formKey = GlobalKey<FormState>();

  String? feedbackType;
  bool isLoading = false;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  List<String> feedbackTypes = [
    "bug",
    "suggestion",
    "complaint",
    "other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Feedback & Support"),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// Scrollable form section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      Text(
                        "We value your feedback! Please fill out the form below to report a bug, suggest a feature, or share your experience with us.",
                        textAlign: TextAlign.left,
                        style: textStyle(
                            AppColors.grey.shade700, 14, AppColors.normal),
                      ),

                      const SizedBox(height: 20),

                      /// Feedback Type Dropdown
                      DropdownButtonFormField<String>(
                        value: feedbackType,
                        hint: Text(
                          "Select Feedback Type",
                          style: textStyle(
                              AppColors.grey.shade600, 14, AppColors.normal),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          prefixIcon: Icon(Icons.feedback_outlined,
                              color: AppColors.primaryDark),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: AppColors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: AppColors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: AppColors.primaryDark),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.red.shade800),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),

                        items: feedbackTypes.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: textStyle(
                                  AppColors.black, null, AppColors.normal),
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            feedbackType = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return "Please select feedback type";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Subject
                      buildTextFormField(
                          controller: subjectController,
                          lText: "Subject",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter subject";
                            }
                            return null;
                          }),

                      const SizedBox(height: 20),

                      /// Message
                      buildTextFormField(
                        controller: messageController,
                        maxLines: 4,
                        lText: "Message",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter message";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// Submit Button
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: elevetedbtn(
                  "Submit Feedback",
                      () async {
                    if (_formKey.currentState!.validate()) {

                      setState(() {
                        isLoading = true;
                      });

                      String subject = subjectController.text.trim();
                      String message = messageController.text.trim();

                      bool success = await UserApiService.sendFeedback(
                        feedbackType: feedbackType!,
                        feedbackSubject: subject,
                        feedbackMessage: message,
                      );


                      setState(() {
                        isLoading = false;
                      });

                      if (success) {

                        subjectController.clear();
                        messageController.clear();

                        setState(() {
                          feedbackType = null;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Feedback submitted successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);

                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to submit feedback. Please try again."),
                            backgroundColor: Colors.red,
                          ),
                        );

                      }
                    }
                  },
                  isLoading: isLoading,
                ),
              ),


              const SizedBox(height: 10),

              /// View Feedback Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbacklistScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list_alt, color: AppColors.primaryDark),
                  label: Text(
                    "View Feedback & Responses",
                    style: textStyle(
                        AppColors.primaryDark, 14, AppColors.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryDark),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}