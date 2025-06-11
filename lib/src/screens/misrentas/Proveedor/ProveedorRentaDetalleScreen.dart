import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProveedorRentaDetalleScreen extends StatelessWidget {
  final String rentaId;

  const ProveedorRentaDetalleScreen({super.key, required this.rentaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Renta'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('rentas')
            .doc(rentaId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fechaInicio = (data['fechaInicio'] as Timestamp).toDate();
          final fechaFin = (data['fechaFin'] as Timestamp).toDate();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  data['vehiculo'] ?? '',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Cliente: ${data['cliente'] ?? ''}'),
                Text('Tel\u00e9fono: ${data['telefono'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Desde ${DateFormat('dd/MM/yyyy HH:mm').format(fechaInicio)}'),
                Text('Hasta ${DateFormat('dd/MM/yyyy HH:mm').format(fechaFin)}'),
                const SizedBox(height: 16),
                Text('Estado: ${data['estado']}'),
                const SizedBox(height: 16),
                Text('Total: \$${data['precioTotal']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

