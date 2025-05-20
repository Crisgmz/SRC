import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class ConfirmacionReservaScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculoData;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int deliveryOption;
  final int pickupOption;
  final String nombreCliente;
  final String telefono;
  final String lugarEntrega;
  final String lugarRecogida;

  const ConfirmacionReservaScreen({
    super.key,
    required this.vehiculoData,
    required this.startDateTime,
    required this.endDateTime,
    required this.deliveryOption,
    required this.pickupOption,
    required this.nombreCliente,
    required this.telefono,
    required this.lugarEntrega,
    required this.lugarRecogida,
  });

  @override
  State<ConfirmacionReservaScreen> createState() =>
      _ConfirmacionReservaScreenState();
}

class _ConfirmacionReservaScreenState extends State<ConfirmacionReservaScreen> {
  bool isLoading = true;
  Map<String, dynamic>? vehiculoData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosVehiculo();
  }

  Future<void> _cargarDatosVehiculo() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Primero usamos los datos que ya tenemos
      setState(() {
        vehiculoData = widget.vehiculoData;
      });

      // Luego cargamos datos actualizados desde Firebase
      final String idVehiculo = widget.vehiculoData['idVehiculo'];

      if (idVehiculo != null && idVehiculo.isNotEmpty) {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('vehiculos')
                .where('idVehiculo', isEqualTo: idVehiculo)
                .get();

        if (snapshot.docs.isNotEmpty) {
          // Actualizamos con los datos más recientes
          setState(() {
            vehiculoData = snapshot.docs.first.data();
            isLoading = false;
          });
        } else {
          // Si no encuentra el vehículo, usamos los datos que ya tenemos
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Si no hay ID, simplemente usamos los datos pasados
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // En caso de error, usamos los datos que teníamos originalmente
      setState(() {
        errorMessage = null; // No mostramos error ya que tenemos datos
        isLoading = false;
      });
    }
  }

  // Calcular la cantidad de días entre las fechas
  int get diasReserva {
    return widget.endDateTime.difference(widget.startDateTime).inDays +
        1; // +1 para contar el día de inicio
  }

  // Calcular el precio total
  double get precioTotal {
    if (vehiculoData == null) return 0.0;
    return (vehiculoData!['precioPorDia'] * diasReserva).toDouble();
  }

  // Generar un ID único para la reserva
  String _generarIdReserva() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'RES${now.millisecondsSinceEpoch}$random';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confirmacion de Reserva'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9A825)),
              )
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con imagen del vehículo
                          _buildVehicleHeader(),
                          const SizedBox(height: 24),

                          // Datos del Cliente
                          _buildClientDataSection(),
                          const SizedBox(height: 24),

                          // Vehículo Seleccionado
                          _buildSelectedVehicleSection(),
                          const SizedBox(height: 24),

                          // Fecha y hora de la solicitud
                          _buildDateTimeSection(),
                          const SizedBox(height: 24),

                          // Recogida y Retorno
                          _buildPickupReturnSection(),
                          const SizedBox(height: 24),

                          // Payment Details
                          _buildPaymentDetailsSection(),
                        ],
                      ),
                    ),
                  ),

                  // Bottom bar fijo
                  _buildBottomBar(),
                ],
              ),
    );
  }

  Widget _buildVehicleHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen del vehículo con proporción 3x2 (ej. 180x120)
        Container(
          width: 150,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                (vehiculoData!['imagenes'] != null &&
                        vehiculoData!['imagenes'] is List &&
                        vehiculoData!['imagenes'].isNotEmpty)
                    ? Image.network(
                      vehiculoData!['imagenes'][0],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.car_rental, size: 40),
                          ),
                    )
                    : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.car_rental, size: 40),
                    ),
          ),
        ),
        const SizedBox(width: 16),

        // Información del vehículo como Card
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehiculoData!['marca']} ${vehiculoData!['modelo']} ${vehiculoData!['anio']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${vehiculoData!['calificacion']?.toStringAsFixed(2) ?? '5.00'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${vehiculoData!['totalReservas'] ?? 80} Reservas',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${vehiculoData!['precioPorDia']}/Día',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos del Cliente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.nombreCliente,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teléfono',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.telefono,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehículo Seleccionado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehiculoData!['marca']} ${vehiculoData!['modelo']} ${vehiculoData!['anio']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placa: ${vehiculoData!['placa'] ?? 'No especificada'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha y hora de la solicitud',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.startDateTime.day} ${_getMonthName(widget.startDateTime.month)},${_getDayName(widget.startDateTime.weekday)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.startDateTime.hour}:${widget.startDateTime.minute.toString().padLeft(2, '0')} ${widget.startDateTime.hour >= 12 ? 'PM' : 'AM'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48), // 👈 Aumentado
                child: Icon(Icons.arrow_forward, color: Colors.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.endDateTime.day} ${_getMonthName(widget.endDateTime.month)},${_getDayName(widget.endDateTime.weekday)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.endDateTime.hour}:${widget.endDateTime.minute.toString().padLeft(2, '0')} ${widget.endDateTime.hour >= 12 ? 'PM' : 'AM'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupReturnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recogida y Retorno',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Color(0xFFF9A825), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recogida:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.lugarEntrega,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Retorno:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.lugarRecogida,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de Pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${vehiculoData!['precioPorDia']} × $diasReserva days',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${precioTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Descuento', style: TextStyle(fontSize: 16)),
            const Text('-', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white, // <- Fondo blanco debajo del botón también
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${precioTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Cantidad Total',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _mostrarPopupConfirmacion(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Completar Reserva',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month];
  }

  String _getDayName(int weekday) {
    const days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday];
  }

  void _mostrarPopupConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Completar Reserva',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para finalizar tu reserva, serás redirigido a WhatsApp, donde enviaremos automáticamente todos los detalles de tu solicitud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _guardarReservaEnFirebase(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Completar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _abrirWhatsApp(String mensaje, BuildContext context) async {
    final String numeroTelefono = '13478526126';

    try {
      if (Platform.isAndroid) {
        // Primero intentar abrir la app nativa de WhatsApp
        final intent = AndroidIntent(
          action: 'action_view',
          data: 'https://wa.me/$numeroTelefono?text=$mensaje',
          package: 'com.whatsapp',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );

        await intent.launch();
      } else {
        // Para iOS, intentar abrir directamente con el esquema de WhatsApp
        final whatsappUri = Uri.parse(
          'whatsapp://send?phone=$numeroTelefono&text=$mensaje',
        );

        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('WhatsApp no está instalado');
        }
      }
    } catch (e) {
      // Si no puede abrir la app nativa, usar el navegador web como fallback
      try {
        final webUri = Uri.parse('https://wa.me/$numeroTelefono?text=$mensaje');

        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No se puede abrir WhatsApp');
        }
      } catch (webError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir WhatsApp: $webError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _guardarReservaEnFirebase(BuildContext context) async {
    try {
      // Generar un ID único para la reserva
      final String idReserva = _generarIdReserva();

      // Determinar la duración y el precio total
      final int dias = diasReserva;
      final double total = precioTotal;

      final reserva = {
        'idReserva': idReserva,
        'vehiculoId': vehiculoData!['idVehiculo'],
        'vehiculo': vehiculoData!['nombre'],
        'marca': vehiculoData!['marca'],
        'modelo': vehiculoData!['modelo'],
        'anio': vehiculoData!['anio'],
        'color': vehiculoData!['color'] ?? 'No especificado',
        'combustible': vehiculoData!['combustible'] ?? 'No especificado',
        'transmision': vehiculoData!['transmision'] ?? 'No especificada',
        'pasajeros': vehiculoData!['pasajeros'] ?? 0,
        'placa': vehiculoData!['placa'] ?? 'No especificada',
        'precioPorDia': vehiculoData!['precioPorDia'],
        'diasReserva': dias,
        'precioTotal': total,
        'cliente': widget.nombreCliente,
        'telefono': widget.telefono,
        'fechaInicio': widget.startDateTime,
        'fechaFin': widget.endDateTime,
        'lugarEntrega': widget.lugarEntrega,
        'lugarRecogida': widget.lugarRecogida,
        'estado': 'Pre-agendada',
        'fechaCreacion': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('rentas').add(reserva);

      // También actualizar el contador de reservas del vehículo
      final docRef =
          await FirebaseFirestore.instance
              .collection('vehiculos')
              .where('idVehiculo', isEqualTo: vehiculoData!['idVehiculo'])
              .get();

      if (docRef.docs.isNotEmpty) {
        await docRef.docs.first.reference.update({
          'totalReservas': FieldValue.increment(1),
        });
      }

      // Preparar el mensaje para WhatsApp
      final String mensaje = Uri.encodeComponent(
        'Hola, me gustaría confirmar la siguiente reserva:\n\n'
        '*ID de Reserva:* $idReserva\n'
        '*Cliente:* ${widget.nombreCliente}\n'
        '*Teléfono:* ${widget.telefono}\n'
        '*Vehículo:* ${vehiculoData!['nombre']}\n'
        '*Color:* ${vehiculoData!['color'] ?? 'No especificado'}\n'
        '*Combustible:* ${vehiculoData!['combustible'] ?? 'No especificado'}\n'
        '*Transmisión:* ${vehiculoData!['transmision'] ?? 'No especificada'}\n'
        '*Capacidad:* ${vehiculoData!['pasajeros'] ?? 0} pasajeros\n'
        '*Placa:* ${vehiculoData!['placa'] ?? 'No especificada'}\n'
        '*Desde:* ${widget.startDateTime.day}/${widget.startDateTime.month}/${widget.startDateTime.year} - ${widget.startDateTime.hour}:${widget.startDateTime.minute.toString().padLeft(2, '0')}\n'
        '*Hasta:* ${widget.endDateTime.day}/${widget.endDateTime.month}/${widget.endDateTime.year} - ${widget.endDateTime.hour}:${widget.endDateTime.minute.toString().padLeft(2, '0')}\n'
        '*Días:* $dias\n'
        '*Precio por día:* \$${vehiculoData!['precioPorDia']}\n'
        '*Precio total:* \$${total.toStringAsFixed(2)}\n'
        '*Lugar de entrega:* ${widget.lugarEntrega}\n'
        '*Lugar de recogida:* ${widget.lugarRecogida}\n',
      );

      // Llamar a la función para abrir WhatsApp
      await _abrirWhatsApp(mensaje, context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
