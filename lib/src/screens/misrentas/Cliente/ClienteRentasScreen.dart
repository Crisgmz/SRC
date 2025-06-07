// lib/src/rentas/ClientRentalsScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Cliente/ClienteRentaDetalleScreen.dart';

class ClientRentalsScreen extends StatefulWidget {
  const ClientRentalsScreen({super.key});

  @override
  State<ClientRentalsScreen> createState() => _ClientRentalsScreenState();
}

class _ClientRentalsScreenState extends State<ClientRentalsScreen> {
  String _sortBy = 'fechaInicio';
  bool _sortDescending = true;
  String _statusFilter = 'Todos';
  DateTimeRange? _dateFilter;

  final List<String> _sortOptions = [
    'Fecha más reciente',
    'Fecha más antigua',
    'Precio mayor',
    'Precio menor',
    'Estado',
  ];

  final List<String> _statusOptions = [
    'Todos',
    'Pendiente',
    'Confirmada',
    'En curso',
    'Completada',
    'Cancelada',
  ];

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text(
            "Mis Rentas",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(251, 140, 0, 1),
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
      ),

      body: Column(
        children: [
          // Header con controles de organización y filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Organizar (izquierda)
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

                // Botón Filtros (derecha)
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

          const Divider(height: 1),
          // Lista de rentas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rentas = snapshot.data?.docs ?? [];

                if (rentas.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rentas.length,
                  itemBuilder: (context, index) {
                    final doc = rentas[index];
                    final renta = doc.data() as Map<String, dynamic>;
                    final vehiculoId = renta['vehiculoId'];
                    final idReserva =
                        doc.id; // Este es el ID real del documento

                    return _buildModernRentCard(
                      renta,
                      vehiculoId,
                      idReserva,
                      context,
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

  Widget _buildModernRentCard(
    Map<String, dynamic> rentData,
    String vehiculoId,
    String idReserva,
    BuildContext context,
  ) {
    final fechaInicio = (rentData["fechaInicio"] as Timestamp).toDate();
    final fechaFin = (rentData["fechaFin"] as Timestamp).toDate();
    final fechaInicioStr = DateFormat('M/d/yyyy').format(fechaInicio);
    final fechaFinStr = DateFormat('M/d/yyyy').format(fechaFin);
    final estado = rentData["estado"] ?? 'Pendiente';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    ClienteRentaDetallesScreen(
                      rentaData: rentData,
                      imagenUrl: rentData['imagen'] ?? '',
                      idRenta: idReserva,
                    ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.1), // desde abajo
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              );

              final fadeAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
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
            // Imagen del vehículo con overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child:
                      rentData['imagen'] != null &&
                              rentData['imagen'].toString().isNotEmpty
                          ? Image.network(
                            rentData['imagen'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                          : Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.directions_car,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SOLUTIONS RENT CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Información del vehículo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del vehículo y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          rentData["vehiculo"] ?? 'Vehículo',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '\$${(rentData["precioTotal"] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Calificación
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        (rentData["calificacion"] ?? 5.0).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fechas
                  Text(
                    "Desde $fechaInicioStr hasta $fechaFinStr",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  // Estado
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(estado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          color: _getStatusTextColor(estado),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes rentas registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus rentas aparecerán aquí cuando realices una reserva',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery(String? userId) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('rentas')
        .where('clienteId', isEqualTo: userId);

    // Aplicar filtro de estado
    if (_statusFilter != 'Todos') {
      query = query.where('estado', isEqualTo: _statusFilter);
    }

    // Aplicar ordenamiento
    String orderField = 'fechaInicio';
    bool descending = true;

    switch (_sortBy) {
      case 'fechaInicio':
        orderField = 'fechaInicio';
        descending = _sortDescending;
        break;
      case 'precioTotal':
        orderField = 'precioTotal';
        descending = _sortDescending;
        break;
      case 'estado':
        orderField = 'estado';
        descending = false;
        break;
    }

    return query.orderBy(orderField, descending: descending).snapshots();
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
                  ..._sortOptions.map(
                    (option) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option),
                      onTap: () {
                        setState(() {
                          switch (option) {
                            case 'Fecha más reciente':
                              _sortBy = 'fechaInicio';
                              _sortDescending = true;
                              break;
                            case 'Fecha más antigua':
                              _sortBy = 'fechaInicio';
                              _sortDescending = false;
                              break;
                            case 'Precio mayor':
                              _sortBy = 'precioTotal';
                              _sortDescending = true;
                              break;
                            case 'Precio menor':
                              _sortBy = 'precioTotal';
                              _sortDescending = false;
                              break;
                            case 'Estado':
                              _sortBy = 'estado';
                              _sortDescending = false;
                              break;
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => SafeArea(
                  // <--- aquí
                  child: Container(
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
                                  _statusFilter = 'Todos';
                                  _dateFilter = null;
                                });
                                setState(() {
                                  _statusFilter = 'Todos';
                                  _dateFilter = null;
                                });
                              },
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Estado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              _statusOptions
                                  .map(
                                    (status) => FilterChip(
                                      label: Text(status),
                                      selected: _statusFilter == status,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          _statusFilter =
                                              selected ? status : 'Todos';
                                        });
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

  bool _hasActiveFilters() {
    return _statusFilter != 'Todos' || _dateFilter != null;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_statusFilter != 'Todos') count++;
    if (_dateFilter != null) count++;
    return count;
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange.withOpacity(0.2);
      case 'confirmada':
        return Colors.blue.withOpacity(0.2);
      case 'en curso':
        return Colors.green.withOpacity(0.2);
      case 'completada':
        return Colors.teal.withOpacity(0.2);
      case 'cancelada':
        return Colors.red.withOpacity(0.2);
      case 'cancelacion_pendiente':
        return const Color.fromARGB(255, 255, 215, 175)!;
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange[700]!;
      case 'confirmada':
        return Colors.blue[700]!;
      case 'en curso':
        return Colors.green[700]!;
      case 'completada':
        return Colors.teal[700]!;
      case 'cancelacion_pendiente':
        return Colors.orange[700]!;
      case 'cancelada':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
