import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:fitnessai/ui_helper/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notification/notification.dart';

class SetReminder extends StatefulWidget {
  const SetReminder({super.key});

  @override
  State<SetReminder> createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder>
    with SingleTickerProviderStateMixin {
  TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);
  bool reminderEnabled = true;
  bool permissionsGranted = false;
  bool showPermissionBanner = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    loadReminder();
    _checkAndRequestPermissions();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    bool granted = await NotificationService.arePermissionsGranted();
    if (!granted) {
      await NotificationService.requestAllPermissions();
      granted = await NotificationService.arePermissionsGranted();
    }
    setState(() {
      permissionsGranted = granted;
      if (granted) showPermissionBanner = false;
    });
  }

  Future<void> loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt("reminder_hour") ?? 7;
    int minute = prefs.getInt("reminder_minute") ?? 0;
    bool enabled = prefs.getBool("reminder_enabled") ?? true;
    setState(() {
      selectedTime = TimeOfDay(hour: hour, minute: minute);
      reminderEnabled = enabled;
    });
  }

  Future<void> saveReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("reminder_hour", selectedTime.hour);
    await prefs.setInt("reminder_minute", selectedTime.minute);
    await prefs.setBool("reminder_enabled", reminderEnabled);
  }

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => selectedTime = time);
  }

  String get _amPm => selectedTime.hour < 12 ? 'AM' : 'PM';
  String get _hour {
    int h = selectedTime.hourOfPeriod;
    return (h == 0 ? 12 : h).toString().padLeft(2, '0');
  }
  String get _minute => selectedTime.minute.toString().padLeft(2, '0');

  String _greetingLabel() {
    int h = selectedTime.hour;
    if (h < 12) return '🌅  Morning Workout';
    if (h < 17) return '☀️  Afternoon Session';
    return '🌙  Evening Training';
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notifications_off_rounded,
                  color: Colors.orange.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Permission Required",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          "Notification permission is required to set reminders.\n\nPlease enable it from App Settings.",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar('Set Reminder'),
      backgroundColor: AppColors.scaffoldBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Permission Banner ─────────────────────────────────────
                if (!permissionsGranted && showPermissionBanner)
                  GestureDetector(
                    onTap: () async {
                      await _checkAndRequestPermissions();
                      setState(() => showPermissionBanner = false);
                      if (!permissionsGranted) _showPermissionDialog();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.orange.shade200, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notifications Disabled",
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Tap to grant permission · Tap to dismiss",
                                  style: TextStyle(
                                      color: Colors.orange.shade600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.close_rounded,
                              color: Colors.orange.shade400, size: 18),
                        ],
                      ),
                    ),
                  ),

                // ── Header ────────────────────────────────────────────────
                const Text(
                  "Daily Reminder",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Pick a time and we'll nudge you every day\nto keep your fitness streak alive. 💪",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13.5,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Time Card ─────────────────────────────────────────────
                GestureDetector(
                  onTap: pickTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.32),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _greetingLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Clock display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$_hour:$_minute",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 68,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -3,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 8),
                              child: Text(
                                _amPm,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.touch_app_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Divider(
                            color: Colors.white.withOpacity(0.2),
                            thickness: 1),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.white.withOpacity(0.6),
                                size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Tap this card to change the time",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Enable Switch ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: reminderEnabled
                              ? AppColors.primary.withOpacity(0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          reminderEnabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_outlined,
                          color: reminderEnabled
                              ? AppColors.primary
                              : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Enable Reminder",
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reminderEnabled
                                  ? "You'll be notified every day"
                                  : "Reminders are turned off",
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminderEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) =>
                            setState(() => reminderEnabled = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── How It Works ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "How it works",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _howItWorksRow(
                        Icons.schedule_rounded,
                        "Repeats daily",
                        "Fires every day at your chosen time",
                      ),
                      _divider(),
                      _howItWorksRow(
                        Icons.edit_notifications_rounded,
                        "Easy to change",
                        "Tap the time card above anytime",
                      ),
                      _divider(),
                      _howItWorksRow(
                        Icons.toggle_off_rounded,
                        "Turn off anytime",
                        "Toggle the switch above to disable",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Save Button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      bool granted =
                      await NotificationService.arePermissionsGranted();

                      if (!granted) {
                        await NotificationService.requestAllPermissions();
                        granted =
                        await NotificationService.arePermissionsGranted();
                        setState(() {
                          permissionsGranted = granted;
                          showPermissionBanner = !granted;
                        });
                        if (!granted) {
                          _showPermissionDialog();
                          return;
                        }
                      }

                      await saveReminder();

                      if (reminderEnabled) {
                        await NotificationService.scheduleDailyNotification(
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      } else {
                        await NotificationService.cancelNotification();
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text(
                                "Reminder saved successfully!",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Save Reminder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(color: const Color(0xFFF1F5F9), thickness: 1, height: 1),
  );

  Widget _howItWorksRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}