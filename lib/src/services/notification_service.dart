import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _lastMessageId;

  Future<void> init() async {
    await _messaging.requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(settings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessage);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    await _showNotification(message);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await NotificationService()._showNotification(message);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    if (message.messageId != null && message.messageId == _lastMessageId) {
      return;
    }
    _lastMessageId = message.messageId;

    final notification = message.notification;
    if (notification != null) {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      await _localNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        details,
      );
    }
  }
}
