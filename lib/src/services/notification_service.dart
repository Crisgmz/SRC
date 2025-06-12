import 'dart:convert';
import 'package:flutter/widgets.dart';
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

  // Define un canal Android (3º parámetro ahora es named: description)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'default_channel', // id
    'Notificaciones', // name
    description: 'Canal principal de notificaciones', // descripción
    importance: Importance.max, // prioridad máxima
  );

  /// Inicializa FCM y local notifications
  Future<void> init() async {
    // Pide permisos al usuario
    await _messaging.requestPermission();

    // Inicializa flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotificationsPlugin.initialize(initSettings);

    // Crea el canal en Android ≥Oreo
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Background handler (isolate separado)
    FirebaseMessaging.onBackgroundMessage(
      NotificationService._firebaseMessagingBackgroundHandler,
    );

    // Mensajes en primer plano
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Mensajes cuando la app está en background y el usuario la abre
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Aquí puedes navegar a una pantalla concreta, p.ej:
      // Navigator.of(context).pushNamed('/detalles', arguments: message);
    });

    // Mensaje que abrió la app desde estado terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Procesar mensaje inicial igual que onMessageOpenedApp
    }
  }

  /// Subscribe/unsubscribe a topics
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  /// Handler de foreground
  Future<void> _onMessage(RemoteMessage message) async {
    await _showNotification(message);
  }

  /// Handler de background (y terminated) — debe estar anotado para ser entry-point
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializa local notifications en este isolate
    final flnp = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flnp.initialize(initSettings);

    // Crea el canal también aquí
    await flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Muestra la notificación
    final notification = message.notification;
    if (notification != null) {
      await flnp.show(
        0,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  /// Muestra notificación local
  Future<void> _showNotification(RemoteMessage message) async {
    // Evita duplicados
    if (message.messageId != null && message.messageId == _lastMessageId) {
      return;
    }
    _lastMessageId = message.messageId;

    final notification = message.notification;
    if (notification != null) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
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
