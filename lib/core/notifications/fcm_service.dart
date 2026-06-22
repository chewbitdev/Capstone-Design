import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  static final _local = FlutterLocalNotificationsPlugin();
  static int _notifId = 0;

  static Future<void> init() async {
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(const InitializationSettings(iOS: iosInit));

    await _local
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(
      _notifId++,
      title,
      body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }
}
