import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Proveedor/ProveedorRentaDetalleScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static StreamSubscription<QuerySnapshot>? _rentaSub;

  static Future<void> initialize() async {
    await _messaging.requestPermission();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        final payload = details.payload;
        if (payload != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection('rentas')
                  .doc(payload)
                  .get();

          if (doc.exists) {
            final data = doc.data()!;
            final imagenUrl = data['imagen'] ?? '';

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder:
                    (_) => ProveedorRentaDetallesScreen(
                      rentaData: data,
                      imagenUrl: imagenUrl,
                      idRenta: payload,
                    ),
              ),
            );
          }
        }
      },
    );

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static Future<void> _handleMessage(RemoteMessage message) async {
    final rentaId = message.data['rentaId'];
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rentas',
          'Rentas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: rentaId,
    );
  }

  static Future<void> updateToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  static void listenForRentas(String userId) {
    _rentaSub?.cancel();
    _rentaSub = FirebaseFirestore.instance
        .collection('rentas')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              _localNotifications.show(
                change.doc.hashCode,
                'Nueva renta',
                data['vehiculo'] ?? 'Nueva renta registrada',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'rentas',
                    'Rentas',
                    importance: Importance.max,
                    priority: Priority.high,
                  ),
                ),
                payload: change.doc.id,
              );
            }
          }
        });
  }
}
