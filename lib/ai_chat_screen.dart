import 'dart:convert';
import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _apiKey = 'AIzaSyCG4htiCYpmdxTT9ZT8P0QUebW9SD0Qt0k';
// 3 - AIzaSyAP6ubeVY5wsQ6JgLePlR4flzFiEQq-OA0

const String _systemPrompt = '''
You are FitAI — a world-class AI fitness coach and wellness expert built into a premium fitness app.

Your personality:
- Motivating, energetic, and supportive like a personal trainer
- Knowledgeable in workouts, nutrition, weight loss, muscle gain, flexibility, and mental wellness
- Concise yet impactful — no unnecessary fluff
- Use fitness emojis naturally (💪🔥🏃‍♂️🥗😤) to keep the vibe energetic

Your expertise covers:
- Workout plans (strength training, cardio, HIIT, yoga, calisthenics)
- Nutrition advice (macros, meal plans, healthy recipes, supplements)
- Goal setting (weight loss, muscle gain, endurance, flexibility)
- Recovery (sleep, stretching, rest days, foam rolling)
- Motivation and mindset
- Tracking progress and fitness metrics

Rules:
- If the user asks something completely unrelated to fitness/health/wellness (like politics, coding, history, etc.), politely redirect: "I'm your dedicated FitAI coach! I'm best at fitness and nutrition advice. Want me to help you crush your fitness goals instead? 💪"
- For casual greetings or small talk, respond warmly and naturally, then gently bring the conversation back to fitness
- Always be encouraging, never judgmental about fitness level or body
- Keep responses well-formatted with line breaks for readability
- If asked about serious medical conditions, always recommend consulting a doctor
''';

// ─── Message Model ───────────────────────────────────────────────────────────

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  bool isSelected;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  int _selectedCount = 0;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late final GenerativeModel _model;
  late AnimationController _sendBtnController;

  // ── Accent colors ── (navy-blue app bar companion palette)
  static const Color _accentBlue = Color(0xFF3B82F6);      // vibrant electric blue
  static const Color _accentBlueDark = Color(0xFF1D4ED8);  // deep blue
  static const Color _userBubble = Color(0xFF2563EB);      // strong blue for user bubbles
  static const Color _aiBubbleColor = Color(0xFF1C2340);   // dark navy for AI bubbles
  static const Color _inputBg = Color(0xFF161D35);         // deep navy input bg
  static const Color _chatBg = Color(0xFF0F1629);          // very dark navy chat bg

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _sendBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendBtnController.dispose();
    super.dispose();
  }

  // ── SharedPreferences ─────────────────────────────────────────────────────

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('fitai_chat_messages');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        _messages.addAll(decoded.map((e) => Message.fromJson(e)).toList());
      });
      _scrollToBottom(immediate: true);
    } else {
      // Welcome message on first launch
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
        "Hey there, Champion! 👋💪\n\nI'm **FitAI** — your personal AI fitness coach. I'm here to help you:\n\n🏋️ Build strength & muscle\n🔥 Burn fat & lose weight\n🥗 Nail your nutrition\n😴 Optimise recovery\n\nWhat fitness goal are we crushing today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _saveMessages();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('fitai_chat_messages', encoded);
  }

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (immediate) {
          _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  // ── Send Message ──────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _sendBtnController.forward().then((_) => _sendBtnController.reverse());

    final userMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _textController.clear();
      _isLoading = true;
    });

    await _saveMessages();
    _scrollToBottom();

    try {
      // Build conversation history for context
      final history = _messages
          .where((m) => m.id != userMsg.id)
          .map((m) => m.isUser
          ? Content.text(m.text)
          : Content.model([TextPart(m.text)]))
          .toList();

      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(text));
      final aiText =
          response.text?.trim() ?? 'Hmm, something went wrong. Try again! 💪';

      final aiMsg = Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMsg);
        _isLoading = false;
      });
      await _saveMessages();
    } catch (e) {
      setState(() {
        _messages.add(Message(
          id: '${DateTime.now().millisecondsSinceEpoch}_err',
          text:
          '⚠️ Connection issue. Check your internet and try again.\n\nError: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  // ── Selection & Delete ────────────────────────────────────────────────────

  void _toggleSelection(String id) {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx != -1) {
        _messages[idx].isSelected = !_messages[idx].isSelected;
        _selectedCount = _messages.where((m) => m.isSelected).count;
        _isSelectionMode = _selectedCount > 0;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      for (final m in _messages) {
        m.isSelected = false;
      }
      _selectedCount = 0;
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await _showDeleteDialog(
        '$_selectedCount message${_selectedCount > 1 ? 's' : ''}');
    if (confirmed == true) {
      setState(() {
        _messages.removeWhere((m) => m.isSelected);
        _isSelectionMode = false;
        _selectedCount = 0;
      });
      await _saveMessages();
    }
  }

  Future<void> _clearAllChat() async {
    final confirmed = await _showDeleteDialog('entire chat history');
    if (confirmed == true) {
      setState(() {
        _messages.clear();
        _isSelectionMode = false;
        _selectedCount = 0;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fitai_chat_messages');
      _addWelcomeMessage();
    }
  }

  Future<bool?> _showDeleteDialog(String target) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete $target? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: _accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── AppBar Actions ────────────────────────────────────────────────────────

  List<Widget> _buildAppBarActions() {
    if (_isSelectionMode) {
      return [
        IconButton(
          icon: const Icon(Icons.copy_rounded, color: Colors.white70),
          onPressed: () {
            final selected =
            _messages.where((m) => m.isSelected).map((m) => m.text).join('\n\n');
            _copyMessage(selected);
            _exitSelectionMode();
          },
          tooltip: 'Copy',
        ),
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          onPressed: _deleteSelected,
          tooltip: 'Delete',
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: _exitSelectionMode,
          tooltip: 'Cancel',
        ),
      ];
    }
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
        color: const Color(0xFF1C2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (val) {
          if (val == 'clear') _clearAllChat();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text('Clear Chat',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // ── Date Divider ──────────────────────────────────────────────────────────

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white10, thickness: 1)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2340),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.white10, thickness: 1)),
        ],
      ),
    );
  }

  // ── Time Formatter ────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  // ── Message Bubble ────────────────────────────────────────────────────────

  Widget _buildBubble(Message message, {bool showTail = true}) {
    final isUser = message.isUser;
    final isSelected = message.isSelected;

    return GestureDetector(
      onLongPress: () => _toggleSelection(message.id),
      onTap: _isSelectionMode ? () => _toggleSelection(message.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isSelected
            ? _accentBlue.withOpacity(0.12)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // AI Avatar
            if (!isUser) ...[
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(bottom: 4, right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: Colors.white, size: 15),
              ),
            ],

            // Bubble
            Flexible(
              child: Column(
                crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? _userBubble : _aiBubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(
                            isUser ? 18 : (showTail ? 4 : 18)),
                        bottomRight: Radius.circular(
                            isUser ? (showTail ? 4 : 18) : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? _accentBlue.withOpacity(0.25)
                              : Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 24),
                          child: _buildMessageText(
                              message.text, isUser),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 10,
                          child: Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white.withOpacity(0.65)
                                  : Colors.white30,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection check
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle_rounded,
                  color: _accentBlue, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  // Render **bold** markdown inline
  Widget _buildMessageText(String text, bool isUser) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w700)));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isUser ? Colors.white : const Color(0xFFCDD9F5),
          fontSize: 15,
          height: 1.45,
          fontFamily: 'sans-serif',
        ),
        children: spans,
      ),
    );
  }

  // ── Typing Indicator ──────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(bottom: 4, right: 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
              ),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: Colors.white, size: 15),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _aiBubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _Dot(delay: i * 200)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Group messages with date dividers
    final widgets = <Widget>[];
    DateTime? lastDate;

    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final msgDate = DateTime(
          msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);

      if (lastDate == null || msgDate != lastDate) {
        widgets.add(_buildDateDivider(msgDate));
        lastDate = msgDate;
      }

      // Tail logic: tail if next msg is from different sender or last
      final showTail = i == _messages.length - 1 ||
          _messages[i + 1].isUser != msg.isUser;

      widgets.add(_buildBubble(msg, showTail: showTail));
    }

    if (_isLoading) widgets.add(_buildTypingIndicator());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: commonAppBar(
        _isSelectionMode
            ? '$_selectedCount selected'
            : 'FitAI Coach',
        actions: _buildAppBarActions(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: _chatBg,
        ),
        child: Column(
          children: [
            // ── Chat Background Pattern ──
            Expanded(
              child: Stack(
                children: [
                  // Subtle radial glow
                  Positioned(
                    top: -80,
                    left: -60,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _accentBlue.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    itemCount: widgets.length,
                    itemBuilder: (_, i) => widgets[i],
                  ),
                ],
              ),
            ),

            // ── Input Bar ────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C1225),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _inputBg,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 14, bottom: 12),
                            child: Icon(Icons.fitness_center_rounded,
                                color: Color(0xFF3B82F6), size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              autofocus: true,
                              textCapitalization:
                              TextCapitalization.sentences,
                              onTap: _scrollToBottom,
                              onSubmitted: (_) => _sendMessage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ask your fitness coach...',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 15),
                                border: InputBorder.none,
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                              maxLines: 5,
                              minLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send Button
                  AnimatedBuilder(
                    animation: _sendBtnController,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 - (_sendBtnController.value * 0.1),
                      child: child,
                    ),
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _accentBlue.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                      ),
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

// ─── Animated Dot for Typing Indicator ────────────────────────────────────────

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Extension ───────────────────────────────────────────────────────────────

extension _IterCount<T> on Iterable<T> {
  int get count => fold(0, (acc, _) => acc + 1);
}