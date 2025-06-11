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
        stream: FirebaseFirestore.instance
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
            builder: (_) => ProveedorRentaDetalleScreen(rentaId: idReserva),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((rentData['imagen'] ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  rentData['imagen'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rentData['vehiculo'] ?? 'Veh\u00edculo',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${(rentData['precioTotal'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desde $fechaInicioStr hasta $fechaFinStr',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _statusColor(estado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          color: _statusTextColor(estado),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
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
