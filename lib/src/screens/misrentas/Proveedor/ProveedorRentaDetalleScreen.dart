import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProveedorRentaDetallesScreen extends StatelessWidget {
  final Map<String, dynamic> rentaData;
  final String imagenUrl;
  final String idRenta;

  const ProveedorRentaDetallesScreen({
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
    final puedeAccionar = estado == 'pendiente' ||
        estado == 'cancelacion_pendiente' ||
        estado == 'pre-agendada';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text(
            "Gestionar Reservación",
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
                              _getEstadoIcon(rentaData['estado']),
                              size: 16,
                              color: _getEstadoTextColor(rentaData['estado']),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getEstadoTexto(rentaData['estado']),
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

            // Información del cliente
            _buildInfoCard(
              title: "Datos del Cliente",
              icon: Icons.person,
              children: [
                _buildDetailRow("Nombre", rentaData['nombreCliente']),
                _buildDetailRow("Teléfono", rentaData['telefonoCliente']),
                _buildDetailRow("Email", rentaData['emailCliente']),
                _buildDetailRow("Cédula", rentaData['cedulaCliente']),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () =>
                                _contactarCliente(rentaData['telefonoCliente']),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text("Llamar"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _enviarWhatsApp(rentaData['telefonoCliente']),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text("WhatsApp"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Información de la reservación
            _buildInfoCard(
              title: "Detalles de la Reservación",
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
                const SizedBox(height: 12),
                _buildDetailRow(
                  "Días de reserva",
                  rentaData['diasReserva']?.toString(),
                ),
                _buildDetailRow(
                  "Fecha de solicitud",
                  rentaData['fechaSolicitud'] != null
                      ? DateFormat('dd MMM yyyy - HH:mm', 'es').format(
                        (rentaData['fechaSolicitud'] as Timestamp).toDate(),
                      )
                      : 'N/A',
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
                  "Precio por día",
                  "\$${rentaData['precioPorDia']}",
                ),
                _buildDetailRow(
                  "Días de reserva",
                  rentaData['diasReserva']?.toString(),
                ),
                const Divider(),
                _buildDetailRow(
                  "Total a recibir",
                  "\$${rentaData['precioTotal']}",
                  isTotal: true,
                ),
              ],
            ),

            // Botones de acción del proveedor
            if (puedeAccionar) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estado == 'cancelacion_pendiente'
                                ? "Solicitud de cancelación"
                                : "Gestionar reservación",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            estado == 'cancelacion_pendiente'
                                ? "El cliente solicita cancelar esta reservación."
                                : "Confirma o cancela esta reservación.",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text("Cancelar"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmDialog(context),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Confirmar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Mensaje cuando no se puede accionar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getMensajeEstado(estado),
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
        return Colors.amber[100]!;
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
        return Colors.amber[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getEstadoIcon(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activa':
      case 'confirmada':
        return Icons.check_circle;
      case 'pendiente':
        return Icons.schedule;
      case 'cancelada':
        return Icons.cancel;
      case 'cancelacion_pendiente':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getEstadoTexto(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activa':
        return 'Activa';
      case 'confirmada':
        return 'Confirmada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      case 'cancelacion_pendiente':
        return 'Cancelación Pendiente';
      default:
        return estado ?? 'Desconocido';
    }
  }

  String _getMensajeEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
      case 'confirmada':
        return 'Esta reservación ya está confirmada y activa.';
      case 'cancelada':
        return 'Esta reservación ha sido cancelada.';
      default:
        return 'Esta reservación no requiere acciones en este momento.';
    }
  }

  void _contactarCliente(String? telefono) async {
    if (telefono != null && telefono.isNotEmpty) {
      final url = "tel:$telefono";
      await launchUrl(Uri.parse(url));
    }
  }

  void _enviarWhatsApp(String? telefono) async {
    if (telefono != null && telefono.isNotEmpty) {
      final mensaje = Uri.encodeComponent(
        "Hola, te contacto sobre tu reservación del vehículo ${rentaData['vehiculo'] ?? ''} "
        "con placa ${rentaData['placa'] ?? ''}. ¿En qué puedo ayudarte?",
      );
      final url = "https://wa.me/$telefono?text=$mensaje";
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirmar Reservación",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "¿Deseas confirmar esta reservación? El cliente será notificado automáticamente.",
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
                Navigator.of(context).pop();
                _confirmarReservacion(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
            "¿Estás seguro de que deseas cancelar esta reservación? Esta acción no se puede deshacer.",
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
                Navigator.of(context).pop();
                _cancelarReservacion(context);
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

  void _confirmarReservacion(BuildContext context) async {
    try {
      // Actualizar estado en Firestore
      await FirebaseFirestore.instance.collection('rentas').doc(idRenta).update(
        {
          'estado': 'confirmada',
          'fechaConfirmacion': FieldValue.serverTimestamp(),
        },
      );

      // Notificar al cliente por WhatsApp
      final telefono = rentaData['telefonoCliente'];
      if (telefono != null && telefono.isNotEmpty) {
        final mensaje = Uri.encodeComponent(
          "✅ *Reservación Confirmada*\n\n"
          "*Vehículo:* ${rentaData['vehiculo'] ?? 'N/A'}\n"
          "*Placa:* ${rentaData['placa'] ?? 'N/A'}\n"
          "*Desde:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaInicio'] as Timestamp).toDate())}\n"
          "*Hasta:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaFin'] as Timestamp).toDate())}\n"
          "*Lugar de recogida:* ${rentaData['lugarEntrega'] ?? 'N/A'}\n\n"
          "Tu reservación ha sido confirmada. ¡Te esperamos! 🚗",
        );

        final url = "https://wa.me/$telefono?text=$mensaje";
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservación confirmada exitosamente"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al confirmar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelarReservacion(BuildContext context) async {
    try {
      // Actualizar estado en Firestore
      await FirebaseFirestore.instance.collection('rentas').doc(idRenta).update(
        {
          'estado': 'cancelada',
          'fechaCancelacion': FieldValue.serverTimestamp(),
        },
      );

      // Notificar al cliente por WhatsApp
      final telefono = rentaData['telefonoCliente'];
      if (telefono != null && telefono.isNotEmpty) {
        final mensaje = Uri.encodeComponent(
          "❌ *Reservación Cancelada*\n\n"
          "*Vehículo:* ${rentaData['vehiculo'] ?? 'N/A'}\n"
          "*Placa:* ${rentaData['placa'] ?? 'N/A'}\n"
          "*Desde:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaInicio'] as Timestamp).toDate())}\n"
          "*Hasta:* ${DateFormat('dd/MM/yyyy – HH:mm').format((rentaData['fechaFin'] as Timestamp).toDate())}\n\n"
          "Lamentamos informarte que tu reservación ha sido cancelada. Para más información, contáctanos.",
        );

        final url = "https://wa.me/$telefono?text=$mensaje";
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservación cancelada"),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cancelar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
