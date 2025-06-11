// lib/src/rentas/ClientRentalsScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ProveedorRentaDetalleScreen.dart';

class ProveedorRentasScreen extends StatefulWidget {
  const ProveedorRentasScreen({super.key});

  @override
  State<ProveedorRentasScreen> createState() => _ProveedorRentasScreenState();
}

class _ProveedorRentasScreenState extends State<ProveedorRentasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis Rentas'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8A023),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rentas')
                .orderBy('fechaInicio', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay rentas registradas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildRentCard(data, docs[index].id, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildRentCard(
    Map<String, dynamic> rentData,
    String idReserva,
    BuildContext context,
  ) {
    final fechaInicio = (rentData['fechaInicio'] as Timestamp).toDate();
    final fechaFin = (rentData['fechaFin'] as Timestamp).toDate();
    final fechaInicioStr = DateFormat('M/d/yyyy').format(fechaInicio);
    final fechaFinStr = DateFormat('M/d/yyyy').format(fechaFin);
    final estado = rentData['estado'] ?? 'Pendiente';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => ClienteRentaDetallesScreen(
                  rentaData: data,
                  imagenUrl: imagenUrl,
                  idRenta: data['id'],
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((rentData['imagen'] ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  rentData['imagen'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["vehiculo"] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Desde $fechaInicioStr hasta $fechaFinStr"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${data["precioTotal"].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(data["estado"] ?? ''),
                        backgroundColor: Colors.orange.shade200,
                        labelStyle: const TextStyle(color: Colors.black),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
      case 'activa':
        return Colors.green[100]!;
      case 'pendiente':
        return Colors.orange[100]!;
      case 'cancelada':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
      case 'activa':
        return Colors.green[700]!;
      case 'pendiente':
        return Colors.orange[700]!;
      case 'cancelada':
        return Colors.red[700]!;
      default:
        return Colors.black54;
    }
  }
}
