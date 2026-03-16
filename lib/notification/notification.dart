import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// INITIALIZE — call once in main()
  static Future<void> init() async {

    print("🔔 NotificationService init()");

    /// Initialize timezone
    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String currentTimeZone = timezoneInfo.identifier;

    print("🌍 Device timezone: $currentTimeZone");

    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    /// Android init settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    /// Initialize plugin
    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("📲 Notification tapped!");
        print("Payload: ${response.payload}");
      },
    );

    /// Android specific permissions
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {

      /// Request notification permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();

      /// Request exact alarm permission (Android 12+)
      await androidPlugin.requestExactAlarmsPermission();

      /// Check if exact alarm permission was actually granted
      final bool? granted = await androidPlugin.canScheduleExactNotifications();
      print("⏰ Can schedule exact alarms: $granted");

      if (granted == false) {
        print("⚠️ Exact alarm not granted — requesting again...");
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    /// Request battery optimization ignore
    await requestBatteryOptimization();

    print("✅ NotificationService initialized");
  }

  /// REQUEST ALL PERMISSIONS — call on Set Reminder screen open
  static Future<PermissionStatus> requestAllPermissions() async {

    print("🔐 Requesting all permissions...");

    /// 1. Notification permission (Android 13+)
    PermissionStatus notifStatus = await Permission.notification.status;
    if (notifStatus.isDenied) {
      notifStatus = await Permission.notification.request();
    }
    print("🔔 Notification permission: $notifStatus");

    /// 2. Exact alarm permission (Android 12+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? canSchedule = await androidPlugin.canScheduleExactNotifications();
      if (canSchedule == false) {
        print("⏰ Requesting exact alarm permission...");
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    /// 3. Battery optimization
    await requestBatteryOptimization();

    return notifStatus;
  }

  /// REQUEST BATTERY OPTIMIZATION IGNORE
  static Future<void> requestBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    print("🔋 Battery optimization status: $status");

    if (status.isDenied) {
      print("🔋 Requesting ignore battery optimization...");
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  /// CHECK IF ALL PERMISSIONS ARE GRANTED
  static Future<bool> arePermissionsGranted() async {

    /// Check notification
    final notifStatus = await Permission.notification.status;

    /// Check exact alarm
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    bool exactAlarmGranted = true;
    if (androidPlugin != null) {
      exactAlarmGranted = await androidPlugin.canScheduleExactNotifications() ?? false;
    }

    /// Check battery optimization
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    print("✅ notif: $notifStatus | exactAlarm: $exactAlarmGranted | battery: $batteryStatus");

    return notifStatus.isGranted && exactAlarmGranted;
  }

  /// SCHEDULE DAILY NOTIFICATION
  static Future<void> scheduleDailyNotification(int hour, int minute) async {

    print("📅 Scheduling notification at $hour:$minute");

    await notificationsPlugin.cancelAll();

    final tz.Location location = tz.local;
    final tz.TZDateTime now = tz.TZDateTime.now(location);

    print("🕐 Current time: $now");

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    /// if time passed → schedule tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print("⏩ Time passed → scheduling tomorrow");
    }

    print("📌 Notification scheduled for: $scheduledDate");

    final diff = scheduledDate.difference(now);
    print("⏳ Notification will fire in ${diff.inSeconds} seconds");

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fitness_reminder_channel',
        'Fitness Reminder',
        channelDescription: 'Daily workout reminder',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      0,
      "Let's Get Moving! 💪",
      "Your body can do it. It's your mind you have to convince. Show up, put in the work — one rep at a time! 🔥",
      scheduledDate,
      notificationDetails,
      payload: "fitness_reminder_triggered",
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Notification scheduled successfully");

    /// debug pending
    final pending = await notificationsPlugin.pendingNotificationRequests();
    print("📋 Pending notifications: ${pending.length}");
    for (var n in pending) {
      print("ID: ${n.id} | ${n.title}");
    }
  }

  /// CANCEL ALL
  static Future<void> cancelNotification() async {
    await notificationsPlugin.cancelAll();
    print("🗑️ All notifications cancelled");
  }


  /// DEBUG NOTIFICATION IN 1 MINUTE
  static Future<void> scheduleTestIn1Minute() async {

    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    print("⏳ Test notification scheduled for: $scheduledDate");

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fitness_reminder_channel',
        'Fitness Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      101,
      "Test Reminder ⏰",
      "This notification should appear in 1 minute",
      scheduledDate,
      notificationDetails,
      payload: "test_schedule",
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Test notification scheduled");
  }
}