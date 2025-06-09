import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class VehiculosPorMarcaScreen extends StatelessWidget {
  final String marca;

  const VehiculosPorMarcaScreen({super.key, required this.marca});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Vehículos $marca"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('vehiculos')
                .where('marca', isEqualTo: marca)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled_outlined,
                    size: 72,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay vehículos disponibles de esta marca.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.61,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final idVehiculo = docs[index].id;

              return _VehicleCard(
                data: data,
                idVehiculo: idVehiculo,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ClienteDetalleVehiculoScreen(
                              idVehiculo: idVehiculo,
                            ),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String idVehiculo;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.data,
    required this.idVehiculo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final nombre = data['nombre'] ?? 'Vehículo';
    final precio =
        data['precioPorDia'] != null ? '\$${data['precioPorDia']}' : '\$99';
    final imagenes = data['imagenes'] as List<dynamic>? ?? [];
    final imagen = imagenes.isNotEmpty ? imagenes.first : '';
    final transmision = data['transmision'] ?? 'Automático';
    final combustible = data['combustible'] ?? 'Gasolina';
    final pasajeros = data['pasajeros']?.toString() ?? '4';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    imagen.isNotEmpty
                        ? Image.network(imagen, fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transmision,
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station,
                        size: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        combustible,
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.event_seat,
                        size: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$pasajeros Pasajeros',
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: precio,
                          style: TextStyle(
                            fontSize: screenWidth * 0.036,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF9A825),
                          ),
                        ),
                        TextSpan(
                          text: ' /día',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9A825),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTap,
                      child: const Text('Rentar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
