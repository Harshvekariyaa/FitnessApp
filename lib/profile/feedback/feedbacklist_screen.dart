import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/api_service.dart';
import '../../ui_helper/common_widgets.dart';

class FeedbacklistScreen extends StatefulWidget {
  const FeedbacklistScreen({super.key});

  @override
  State<FeedbacklistScreen> createState() => _FeedbacklistScreenState();
}

class _FeedbacklistScreenState extends State<FeedbacklistScreen> {

  List feedbackList = [];
  bool isLoading = true;
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    loadFeedback();
  }

  Future<void> loadFeedback() async {
    try {
      final response = await UserApiService.fetchFeedbackList();
      setState(() {
        feedbackList = response['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "resolved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String formatDate(String date) {
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("Feedback & Responses"),
      backgroundColor: AppColors.scaffoldBackground,

      body: isLoading
          ? Center(child: buildLoader())
          : feedbackList.isEmpty
          ? const Center(child: Text("No Feedback Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedbackList.length,
        itemBuilder: (context, index) {

          final item = feedbackList[index];
          final isExpanded = expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(vertical: 4),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),

            child: Column(
              children: [

                /// HEADER
                ListTile(

                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),

                  title: Text(
                    item['feedback_subject'] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item['feedback_type'] ?? "",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),

                        decoration: BoxDecoration(
                          color: getStatusColor(item['status'])
                              .withOpacity(0.12),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: Text(
                          item['status'].toUpperCase(),
                          style: TextStyle(
                            color: getStatusColor(item['status']),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            expandedIndex =
                            isExpanded ? null : index;
                          });
                        },
                      )
                    ],
                  ),
                ),

                /// EXPANDABLE CONTENT
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                        16, 10, 16, 16),

                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        /// MESSAGE
                        Text(
                          "Message",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item['feedback_message'] ?? "",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// ADMIN REPLY (HIDE FOR SUGGESTION)
                        if (item['feedback_type']
                            .toString()
                            .toLowerCase() !=
                            "suggestion") ...[

                          Text(
                            "Admin Reply",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),

                            child: Text(
                              item['admin_reply'] ??
                                  "No reply yet",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],

                        /// DATE
                        Row(
                          children: [

                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              formatDate(
                                  item['created_at'] ?? ""),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}