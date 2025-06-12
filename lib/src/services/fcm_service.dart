import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmService {
  FcmService._();

  static const String _serverKey = String.fromEnvironment('FCM_SERVER_KEY');
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  static Future<void> sendNewRentalNotification(
      Map<String, dynamic> renta) async {
    if (_serverKey.isEmpty) return;

    final message = {
      'to': '/topics/providers',
      'notification': {
        'title': 'Nueva renta',
        'body': 'Se ha creado una renta de ${renta['vehiculo'] ?? ''}',
      },
      'data': {
        'idReserva': renta['idReserva'] ?? '',
      }
    };

    try {
      await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(message),
      );
    } catch (_) {
      // Silenciar errores en el envío de notificaciones
    }
  }
}

