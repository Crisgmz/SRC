import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmService {
  FcmService._();

  // URL de tu Function, la pasamos por dart-define para no hardcodear en el código
  static const String _functionUrl = String.fromEnvironment(
    'FCM_FUNCTION_URL',
    defaultValue: 'https://sendnewrentalnotification-cqkyaucrrq-uc.a.run.app',
  );

  /// Envía la petición de notificación a la Cloud Function
  static Future<void> sendNewRentalNotification(
    Map<String, dynamic> renta,
  ) async {
    final uri = Uri.parse(_functionUrl);

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehiculo': renta['vehiculo'] ?? '',
          'idReserva': renta['idReserva'] ?? '',
        }),
      );

      if (resp.statusCode >= 400) {
        // Opcional: loguear el error o lanzar excepción
        print('Error al enviar notificación: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      // Silenciar o manejar errores de red/API
      print('Fallo al llamar Function: $e');
    }
  }
}
