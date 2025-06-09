// lib/src/rentas/ClienteRentaDetallesScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ClienteRentaDetallesScreen extends StatelessWidget {
  final Map<String, dynamic> rentaData;
  final String imagenUrl;
  final String idRenta;

  const ClienteRentaDetallesScreen({
    super.key,
    required this.rentaData,
    required this.imagenUrl,
    required this.idRenta,
  });

  @override
  Widget build(BuildContext context) {
    final fechaInicio = (rentaData['fechaInicio'] as Timestamp).toDate();
    final fechaFin = (rentaData['fechaFin'] as Timestamp).toDate();
    final estado = (rentaData['estado'] ?? '').toString().toLowerCase();
    final puedeCancelar =
        estado != 'cancelada' && estado != 'cancelacion_pendiente';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text(
            "Mi Reservación",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card principal del vehículo
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Imagen del vehículo
                  if (imagenUrl.isNotEmpty)
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.car_rental, size: 60),
                            );
                          },
                        ),
                      ),
                    ),

                  // Nombre del vehículo
                  Text(
                    rentaData['vehiculo'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Placa y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rentaData['placa'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(rentaData['estado']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield,
                              size: 16,
                              color: _getEstadoTextColor(rentaData['estado']),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rentaData['estado'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _getEstadoTextColor(rentaData['estado']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Información de la reservación
            _buildInfoCard(
              title: "Reservación",
              icon: Icons.event,
              children: [
                _buildInfoRow(
                  icon: Icons.access_time,
                  title: "desde ${DateFormat('HH:mm').format(fechaInicio)}",
                  subtitle: DateFormat('dd MMM yyyy', 'es').format(fechaInicio),
                  trailing: "hasta ${DateFormat('HH:mm').format(fechaFin)}",
                  trailingSubtitle: DateFormat(
                    'dd MMM yyyy',
                    'es',
                  ).format(fechaFin),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Agregar al calendario",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),

            // Ubicación
            _buildInfoCard(
              title: "Datos de Recogida y Entrega",
              icon: Icons.location_on,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recogida:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rentaData['lugarEntrega'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Entrega:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rentaData['lugarRecogida'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Detalles del vehículo
            _buildInfoCard(
              title: "Detalles del Vehículo",
              icon: Icons.directions_car,
              children: [
                _buildDetailRow("Marca", rentaData['marca']),
                _buildDetailRow("Modelo", rentaData['modelo']),
                _buildDetailRow("Año", rentaData['anio']?.toString()),
                _buildDetailRow("Color", rentaData['color']),
                _buildDetailRow("Transmisión", rentaData['transmision']),
                _buildDetailRow("Combustible", rentaData['combustible']),
                _buildDetailRow(
                  "Pasajeros",
                  rentaData['pasajeros']?.toString(),
                ),
              ],
            ),

            // Información de precios
            _buildInfoCard(
              title: "Información de Pago",
              icon: Icons.payment,
              children: [
                _buildDetailRow(
                  "Días de reserva",
                  rentaData['diasReserva']?.toString(),
                ),
                _buildDetailRow(
                  "Precio por día",
                  "\$${rentaData['precioPorDia']}",
                ),
                const Divider(),
                _buildDetailRow(
                  "Total",
                  "\$${rentaData['precioTotal']}",
                  isTotal: true,
                ),
              ],
            ),

            // Aviso de daños al vehículo
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "¿Encontraste nuevos daños?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                        Text(
                          "Repórtalos y evita penalizaciones.",
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ayuda
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Necesitas ayuda? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Acción para mostrar guía
                    },
                    child: const Text(
                      "Contactanos",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            // Botones de acción
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed:
                        puedeCancelar
                            ? () {
                              _showCancelDialog(context);
                            }
                            : null, // 🔒 Desactiva el botón
                    icon: const Icon(Icons.lock_outline, color: Colors.orange),
                    label: Text(
                      puedeCancelar
                          ? "Cancelar Reservación"
                          : "Cancelación en proceso",
                      style: TextStyle(
                        color: puedeCancelar ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      side: BorderSide(
                        color: puedeCancelar ? Colors.orange : Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    String? trailingSubtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailing,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (trailingSubtitle != null)
                Text(
                  trailingSubtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLocationRow(String entrega, String recogida) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entrega,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (recogida != entrega && recogida.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(left: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recogida,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? Colors.green[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activa':
      case 'confirmada':
        return Colors.green[100]!;
      case 'pendiente':
        return Colors.orange[100]!;
      case 'cancelada':
        return Colors.red[100]!;
      case 'cancelacion_pendiente':
        return const Color.fromARGB(255, 255, 215, 175);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getEstadoTextColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activa':
      case 'confirmada':
        return Colors.green[700]!;
      case 'pendiente':
        return Colors.orange[700]!;
      case 'cancelada':
        return Colors.red[700]!;
      case 'cancelacion_pendiente':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Cancelar Reservación",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "¿Deseas solicitar la cancelación de esta reservación? Esta solicitud será revisada por nosotros antes de confirmarse.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "No, mantener",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar primer diálogo

                // Mostrar segundo popup de confirmación
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        "Confirmar cancelación",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        "Para completar la solicitud, enviaremos los detalles de la cancelación vía WhatsApp. ¿Deseas continuar?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // Cerrar segundo diálogo
                            _cancelarReservacion(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Sí, continuar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Sí, cancelar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelarReservacion(BuildContext context) async {
    final rentaId = idRenta;

    try {
      // Actualizar estado en Firestore
      await FirebaseFirestore.instance
          .collection('rentas')
          .doc(rentaId)
          .update({
            'estado': 'cancelacion_pendiente',
            'fechaCancelacion': FieldValue.serverTimestamp(),
          });

      // Crear mensaje de WhatsApp
      final mensaje = Uri.encodeComponent(
        "🚨 *Solicitud de Cancelación de Reservación*\n\n"
        "*Cliente:* ${rentaData['nombreCliente'] ?? 'N/A'}\n"
        "*Vehículo:* ${rentaData['vehiculo'] ?? 'N/A'}\n"
        "*Placa:* ${rentaData['placa'] ?? 'N/A'}\n"
        "*Desde:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaInicio'] as Timestamp).toDate())}\n"
        "*Hasta:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaFin'] as Timestamp).toDate())}\n\n"
        "Solicito cancelar esta reservación. Quedo atento a confirmación de la agencia. ✅",
      );

      const telefonoSoporte = "18492678985";
      final url = "https://wa.me/$telefonoSoporte?text=$mensaje";

      // Mostrar SnackBar antes de salir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "La solicitud de cancelación fue enviada. Un agente confirmará pronto.",
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Abrir WhatsApp
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

      // Regresar a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cancelar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
