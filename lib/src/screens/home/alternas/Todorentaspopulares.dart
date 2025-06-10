import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class RentasPopularesScreen extends StatelessWidget {
  const RentasPopularesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rentas Populares'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('vehiculos')
                .where('destacado', isEqualTo: true)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No hay vehículos destacados.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = 2;
              final crossAxisSpacing = screenWidth * 0.04;
              final itemWidth =
                  (constraints.maxWidth -
                      crossAxisSpacing * (crossAxisCount - 1)) /
                  crossAxisCount;

              // ⬇ Reducido el aspect ratio = tarjetas más altas
              final aspectRatio = 0.58;

              return GridView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: screenWidth * 0.04,
                  crossAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final idVehiculo = docs[index].id;
                  final nombre = data['nombre'] ?? 'Vehículo';
                  final precio =
                      data['precioPorDia'] != null
                          ? '\$${data['precioPorDia']}'
                          : '\$99';
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
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(imagen),
                                  fit: BoxFit.cover,
                                  onError: (_, __) {},
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              foregroundDecoration:
                                  imagen.isEmpty
                                      ? BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      )
                                      : null,
                              child:
                                  imagen.isEmpty
                                      ? const Center(
                                        child: Icon(Icons.image_not_supported),
                                      )
                                      : null,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.025),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
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
                                    SizedBox(height: screenWidth * 0.01),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          size: screenWidth * 0.035,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          transmision,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.028,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_gas_station,
                                          size: screenWidth * 0.035,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          combustible,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.028,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.event_seat,
                                          size: screenWidth * 0.035,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '$pasajeros Pasajeros',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.028,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenWidth * 0.02),
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
                                  ],
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.025),
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
                                    textStyle: TextStyle(
                                      fontSize: screenWidth * 0.033,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ClienteDetalleVehiculoScreen(
                                              idVehiculo: idVehiculo,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text('Rentar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
