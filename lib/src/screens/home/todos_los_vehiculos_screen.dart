import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class TodosLosVehiculosScreen extends StatefulWidget {
  const TodosLosVehiculosScreen({super.key});

  @override
  State<TodosLosVehiculosScreen> createState() =>
      _TodosLosVehiculosScreenState();
}

class _TodosLosVehiculosScreenState extends State<TodosLosVehiculosScreen> {
  String _transmisionFilter = 'Todos';
  String _combustibleFilter = 'Todos';
  int? _pasajerosFilter;
  String _sortBy = 'precioPorDia';
  bool _sortDescending = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

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
          // Sección de filtros estilo Mis Rentas
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showSortOptions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_vert,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Organizar',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showFilterOptions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _hasActiveFilters() ? Colors.orange : Colors.white,
                      border: Border.all(
                        color:
                            _hasActiveFilters()
                                ? Colors.orange
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 20,
                          color:
                              _hasActiveFilters()
                                  ? Colors.white
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filtros',
                          style: TextStyle(
                            color:
                                _hasActiveFilters()
                                    ? Colors.white
                                    : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_hasActiveFilters()) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _getActiveFiltersCount().toString(),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid de vehículos
          Expanded(child: _buildVehicleStream(crossAxisCount)),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'vehiculos',
    );

    if (_transmisionFilter != 'Todos') {
      query = query.where('transmision', isEqualTo: _transmisionFilter);
    }
    if (_combustibleFilter != 'Todos') {
      query = query.where('combustible', isEqualTo: _combustibleFilter);
    }
    if (_pasajerosFilter != null) {
      query = query.where('pasajeros', isEqualTo: _pasajerosFilter);
    }

    return query.orderBy(_sortBy, descending: _sortDescending).snapshots();
  }

  bool _hasActiveFilters() {
    return _transmisionFilter != 'Todos' ||
        _combustibleFilter != 'Todos' ||
        _pasajerosFilter != null;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_transmisionFilter != 'Todos') count++;
    if (_combustibleFilter != 'Todos') count++;
    if (_pasajerosFilter != null) count++;
    return count;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organizar por',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Precio mayor'),
                    onTap: () {
                      setState(() {
                        _sortBy = 'precioPorDia';
                        _sortDescending = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Precio menor'),
                    onTap: () {
                      setState(() {
                        _sortBy = 'precioPorDia';
                        _sortDescending = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filtros',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  _transmisionFilter = 'Todos';
                                  _combustibleFilter = 'Todos';
                                  _pasajerosFilter = null;
                                });
                                setState(() {
                                  _transmisionFilter = 'Todos';
                                  _combustibleFilter = 'Todos';
                                  _pasajerosFilter = null;
                                });
                              },
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Transmisión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              ['Todos', 'Automático', 'Manual']
                                  .map(
                                    (t) => FilterChip(
                                      label: Text(t),
                                      selected: _transmisionFilter == t,
                                      onSelected: (v) {
                                        setModalState(
                                          () =>
                                              _transmisionFilter =
                                                  v ? t : 'Todos',
                                        );
                                      },
                                      selectedColor: Colors.orange.withOpacity(
                                        0.2,
                                      ),
                                      checkmarkColor: Colors.orange,
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Combustible',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              ['Todos', 'Gasolina', 'Diésel', 'Eléctrico']
                                  .map(
                                    (c) => FilterChip(
                                      label: Text(c),
                                      selected: _combustibleFilter == c,
                                      onSelected: (v) {
                                        setModalState(
                                          () =>
                                              _combustibleFilter =
                                                  v ? c : 'Todos',
                                        );
                                      },
                                      selectedColor: Colors.orange.withOpacity(
                                        0.2,
                                      ),
                                      checkmarkColor: Colors.orange,
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pasajeros',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              [2, 4, 5, 7]
                                  .map(
                                    (p) => FilterChip(
                                      label: Text('$p'),
                                      selected: _pasajerosFilter == p,
                                      onSelected: (v) {
                                        setModalState(
                                          () => _pasajerosFilter = v ? p : null,
                                        );
                                      },
                                      selectedColor: Colors.orange.withOpacity(
                                        0.2,
                                      ),
                                      checkmarkColor: Colors.orange,
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Aplicar filtros',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildVehicleStream(
    int crossAxisCount,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _buildQuery(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerGrid(crossAxisCount);
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar vehículos'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No se encontraron vehículos'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.6, // Altura ajustada para evitar overflow
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final idVehiculo = docs[index].id;

            return _VehicleCard(
              data: data,
              idVehiculo: idVehiculo,
              onTap: () => _navigateToDetails(idVehiculo),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: crossAxisCount * 2,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
    );
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
                    //         SizedBox(height: screenWidth * 0.01),
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
