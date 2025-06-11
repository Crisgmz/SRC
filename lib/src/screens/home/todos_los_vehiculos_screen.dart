import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class TodosLosVehiculosScreen extends StatefulWidget {
  const TodosLosVehiculosScreen({super.key});

  @override
  State<TodosLosVehiculosScreen> createState() =>
      _TodosLosVehiculosScreenState();
}

class _TodosLosVehiculosScreenState extends State<TodosLosVehiculosScreen> {
  String? filtroTransmision;
  String? filtroCombustible;
  int? filtroPasajeros;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'vehiculos',
    );
    if (filtroTransmision != null) {
      query = query.where('transmision', isEqualTo: filtroTransmision);
    }
    if (filtroCombustible != null) {
      query = query.where('combustible', isEqualTo: filtroCombustible);
    }
    if (filtroPasajeros != null) {
      query = query.where('pasajeros', isEqualTo: filtroPasajeros);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Todos los vehículos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Sección de filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown(
                    hint: 'Transmisión',
                    value: filtroTransmision,
                    items: ['Automático', 'Manual'],
                    onChanged: (v) => setState(() => filtroTransmision = v),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    hint: 'Combustible',
                    value: filtroCombustible,
                    items: ['Gasolina', 'Diésel', 'Eléctrico'],
                    onChanged: (v) => setState(() => filtroCombustible = v),
                  ),
                  const SizedBox(width: 12),
                  _buildPassengerDropdown(),
                  const SizedBox(width: 12),
                  _buildClearFiltersButton(),
                ],
              ),
            ),
          ),
          // Grid de vehículos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar vehículos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron vehículos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: const Text('Limpiar filtros'),
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
                    childAspectRatio:
                        0.68, // Altura ajustada para evitar overflow
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final idVehiculo = docs[index].id;

                    return _VehicleCard(
                      data: data,
                      idVehiculo: idVehiculo,
                      onTap: () => _navigateToDetails(idVehiculo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        hint: Text(hint),
        value: value,
        underline: const SizedBox(),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPassengerDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        hint: const Text('Pasajeros'),
        value: filtroPasajeros,
        underline: const SizedBox(),
        items:
            [2, 4, 5, 7]
                .map((p) => DropdownMenuItem(value: p, child: Text('$p')))
                .toList(),
        onChanged: (v) => setState(() => filtroPasajeros = v),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    final hasFilters =
        filtroTransmision != null ||
        filtroCombustible != null ||
        filtroPasajeros != null;

    return TextButton.icon(
      onPressed: hasFilters ? _clearAllFilters : null,
      icon: const Icon(Icons.clear_all, size: 18),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(
        foregroundColor: hasFilters ? Colors.orange : Colors.grey,
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      filtroTransmision = null;
      filtroCombustible = null;
      filtroPasajeros = null;
    });
  }

  void _navigateToDetails(String idVehiculo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteDetalleVehiculoScreen(idVehiculo: idVehiculo),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Imagen del vehículo
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child:
                      imagen.isEmpty
                          ? Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 32,
                                color: Colors.grey[500],
                              ),
                            ),
                          )
                          : Image.network(
                            imagen,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 32,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                          ),
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre
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
                    // Detalles del vehículo
                    Column(
                      children: [
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              size: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                combustible,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.028,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    // Precio
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
                    // Botón
                    SizedBox(
                      height: screenWidth * 0.08,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: TextStyle(fontSize: screenWidth * 0.033),
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
      ),
    );
  }
}
