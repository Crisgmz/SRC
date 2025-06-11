// lib/src/rentas/ProveedorRentasScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Proveedor/ProveedorRentaDetalleScreen.dart';

class ProveedorRentasScreen extends StatelessWidget {
  const ProveedorRentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rentas de mis Vehículos"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rentas')
                .orderBy('fechaInicio', descending: true)
                .snapshots(),
        builder: (context, rentasSnapshot) {
          if (rentasSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentas = rentasSnapshot.data?.docs ?? [];

          if (rentas.isEmpty) {
            return const Center(child: Text('No tienes rentas registradas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentas.length,
            itemBuilder: (context, index) {
              final rentaDoc = rentas[index];
              final renta = rentaDoc.data() as Map<String, dynamic>;

              return _buildRentaCard(renta, rentaDoc.id, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildRentaCard(
    Map<String, dynamic> data,
    String rentaId,
    BuildContext context,
  ) {
    final fechaInicio = (data["fechaInicio"] as Timestamp).toDate();
    final fechaFin = (data["fechaFin"] as Timestamp).toDate();
    final fechaInicioStr = DateFormat('d/M/yyyy').format(fechaInicio);
    final fechaFinStr = DateFormat('d/M/yyyy').format(fechaFin);
    final imagenUrl = data['imagen'] ?? '';

    Color getEstadoColor(String estado) {
      switch (estado.toLowerCase()) {
        case 'pre-agendada':
          return Colors.orange.shade200;
        case 'confirmada':
          return Colors.green.shade200;
        case 'en curso':
          return Colors.blue.shade200;
        case 'completada':
          return Colors.grey.shade200;
        case 'cancelada':
          return Colors.red.shade200;
        default:
          return Colors.grey.shade200;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ProveedorRentaDetallesScreen(
                  rentaData: data,
                  imagenUrl: imagenUrl,
                  idRenta: rentaId,
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          children: [
            if (imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imagenUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.car_rental,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["vehiculo"] ?? 'Vehículo sin nombre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Cliente: ${data["cliente"] ?? 'Sin nombre'}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (data["telefono"] != null)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          data["telefono"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Del $fechaInicioStr al $fechaFinStr",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data["lugarRecogida"] != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Recogida: ${data["lugarRecogida"]}",
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (data["lugarEntrega"] != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Entrega: ${data["lugarEntrega"]}",
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$${data["precioTotal"]?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "${data["diasReserva"] ?? 0} días",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          data["estado"] ?? 'Sin estado',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: getEstadoColor(data["estado"] ?? ''),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
