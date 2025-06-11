import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _lastMessageId;

  /// Inicializa el sistema de notificaciones
  Future<void> init() async {
    await _messaging.requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          print('Notificación recibida con payload: $payload');
          // Aquí podrías usar navigatorKey.currentState?.pushNamed('/detalles', arguments: payload);
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessage);
  }

  /// Maneja mensajes en primer plano
  Future<void> _onMessage(RemoteMessage message) async {
    await _showNotification(message);
  }

  /// Manejador de mensajes en segundo plano
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await NotificationService()._showNotification(message);
  }

  /// Muestra una notificación local
  Future<void> _showNotification(RemoteMessage message) async {
    if (message.messageId != null && message.messageId == _lastMessageId)
      return;
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

  /// Guarda el token del dispositivo en Firestore
  Future<void> updateToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  /// Escucha cambios en las rentas del proveedor
  void listenForRentas(String userId) {
    FirebaseFirestore.instance
        .collection('rentas')
        .where('providerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            final data = change.doc.data();
            if (data == null) continue;

            final estado = data['estado'] ?? '';
            final nombreCliente = data['cliente'] ?? 'Cliente';
            final idRenta = change.doc.id;

            if (estado == 'Pre-agendada' &&
                change.type == DocumentChangeType.added) {
              _localNotificationsPlugin.show(
                0,
                'Nueva Renta',
                'Tienes una nueva solicitud de renta de $nombreCliente',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'default_channel',
                    'Notifications',
                    importance: Importance.high,
                    priority: Priority.high,
                  ),
                ),
                payload: idRenta,
              );
            }

            if (estado == 'completado' &&
                change.type == DocumentChangeType.modified) {
              _localNotificationsPlugin.show(
                1,
                'Renta Completada',
                'La renta de $nombreCliente ha sido completada',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'default_channel',
                    'Notifications',
                    importance: Importance.high,
                    priority: Priority.high,
                  ),
                ),
                payload: idRenta,
              );
            }
          }
        });
  }
}
