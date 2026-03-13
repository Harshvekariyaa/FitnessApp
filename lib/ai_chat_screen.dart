import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
      _isTyping = true;
    });

    // Dummy AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": "I'm your Fitness AI 🤖. How can I help you today?"
        });
        _isTyping = false;
      });
    });
  }

  // ================= CHAT BUBBLE =================
  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message["sender"] == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Icon(Icons.smart_toy,
                  color: AppColors.primary, size: 18),
            ),

          if (!isUser) const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft:
                isUser ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              message["text"]!,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ================= TYPING INDICATOR =================
  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child:
            Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          const Text(
            "AI is typing...",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          )
        ],
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _messageInput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Ask your fitness AI...",
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar("Chat With AI"),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _typingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _messageInput(),
        ],
      ),
    );
  }
}
