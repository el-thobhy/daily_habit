import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('Web platform detected, skipping local notification & timezone initialization.');
      return;
    }

    tz.initializeTimeZones();

    // 🔹 Dapatkan zona waktu asli dari perangkat (misal: "Asia/Jakarta")
    try {
      // 1. Dapatkan objek TimezoneInfo
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();

      // 2. Ambil properti .name (String, contoh: "Asia/Jakarta")
      final String timeZoneName = timeZoneInfo.identifier;

      // 3. Set lokasi waktu lokal
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Gagal mendapatkan local timezone: $e');
      // Fallback default jika terjadi error
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {}

    await scheduleDailyNotifications();
  }

  Future<void> scheduleDailyNotifications() async {
    await _scheduleDailyAt(
      id: 100,
      title: "Semangat Pagi! ☀️",
      body: "Saatnya menyusun Daily Planner & cek habit kamu hari ini.",
      hour: 7,
      minute: 0,
    );

    await _scheduleDailyAt(
      id: 101,
      title: "Evaluasi Malam 🌙",
      body:
          "Bagaimana harimu? Lengkapi task & tulis catatan pelajaran hari ini!",
      hour: 20,
      minute: 0,
    );
  }

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_planner_channel',
        'Daily Planner Notifications',
        channelDescription:
            'Notifications for morning planning and evening reflection',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Gracefully handle web/platforms without notification support
    }
  }

  // 1. Menjadwalkan Notifikasi Task Spesifik
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    String? description,
    required DateTime date,
    required String timeString,
  }) async {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      final now = tz.TZDateTime.now(tz.local);
      if (scheduledDate.isBefore(now)) {
        debugPrint('⚠️ Waktu notifikasi sudah lewat: $scheduledDate vs $now');
        return;
      }

      final int notificationId = taskId.hashCode.abs();

      // 🔹 Cek Izin Exact Alarm dari OS
      AndroidScheduleMode scheduleMode =
          AndroidScheduleMode.exactAllowWhileIdle;
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canExact = await androidPlugin?.canScheduleExactNotifications();
      if (canExact == false) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
      debugPrint('🔍 canScheduleExactNotifications: $canExact | Using scheduleMode: $scheduleMode');

      const androidDetails = AndroidNotificationDetails(
        'planner_task_channel',
        'Pengingat Agenda & Task',
        channelDescription: 'Notifikasi pengingat untuk agenda harian',
        importance: Importance.max,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Agenda: $title',
        description ?? 'Waktunya melaksanakan agenda Anda!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: scheduleMode, // 👈 Gunakan scheduleMode dinamis
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(' Notifikasi berhasil dijadwalkan untuk: $scheduledDate');
    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling task notification: $e');
      debugPrint(stackTrace.toString());
    }
  }

  // 2. Membatalkan Notifikasi Task
  Future<void> cancelTaskNotification(String taskId) async {
    try {
      await _notificationsPlugin.cancel(taskId.hashCode.abs());
    } catch (_) {}
  }

  // 3. Tes Notifikasi Instan (Langsung Muncul)
  Future<void> showTestNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'planner_task_channel',
        'Pengingat Agenda & Task',
        channelDescription: 'Notifikasi pengingat untuk agenda harian',
        importance: Importance.max,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        999,
        '🧪 Tes Notifikasi Instan',
        'Notifikasi instan berhasil terkirim!',
        notificationDetails,
      );
      debugPrint(' Notifikasi tes instan terkirim.');

      final testScheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
      debugPrint('⏰ Memasang tes scheduled (10 detik) untuk: $testScheduledDate');
      
      await _notificationsPlugin.zonedSchedule(
        998,
        '🧪 Tes Scheduled (10 Detik)',
        'Notifikasi terjadwal 10 detik berhasil berbunyi!',
        testScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending test notification: $e');
      debugPrint(stackTrace.toString());
    }
  }

  // 4. Membatalkan Semua Notifikasi Task (Saat Logout)
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      await scheduleDailyNotifications();
    } catch (_) {}
  }
}
