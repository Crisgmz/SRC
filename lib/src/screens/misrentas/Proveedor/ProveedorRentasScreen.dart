// lib/src/rentas/ClientRentalsScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Cliente/ClienteRentaDetalleScreen.dart';

class Proveedorrentasscreen extends StatelessWidget {
  const Proveedorrentasscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Rentas"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rentas')
                .where('clienteId', isEqualTo: userId)
                .orderBy('fechaInicio', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentas = snapshot.data?.docs ?? [];

          if (rentas.isEmpty) {
            return const Center(child: Text('No tienes rentas registradas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentas.length,
            itemBuilder: (context, index) {
              final renta = rentas[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('vehiculos')
                        .doc(renta['vehiculoId'])
                        .get(),
                builder: (context, vehiculoSnapshot) {
                  if (!vehiculoSnapshot.hasData) return const SizedBox.shrink();

                  final vehiculoData =
                      vehiculoSnapshot.data!.data() as Map<String, dynamic>?;
                  final imagenUrl = vehiculoData?['imagenes']?[0] ?? '';

                  return _buildReservaCard(renta, imagenUrl, context);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReservaCard(
    Map<String, dynamic> data,
    String imagenUrl,
    BuildContext context,
  ) {
    final fechaInicio = (data["fechaInicio"] as Timestamp).toDate();
    final fechaFin = (data["fechaFin"] as Timestamp).toDate();
    final fechaInicioStr = DateFormat('M/d/yyyy').format(fechaInicio);
    final fechaFinStr = DateFormat('M/d/yyyy').format(fechaFin);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
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
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
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
}
