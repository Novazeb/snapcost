import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  }

  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    const androidDetails = AndroidNotificationDetails(
      'snapcost_daily_reminder',
      'Pengingat Harian SnapCost',
      channelDescription: 'Notifikasi harian untuk mencatat pengeluaran dan pemindaian resi.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      100,
      'Jangan Lupa Catat Pengeluaran! 🧾',
      'Pindai resi belanja hari ini di SnapCost untuk mengontrol anggaran bulananmu.',
      details,
    );
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
