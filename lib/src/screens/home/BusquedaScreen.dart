import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/screens/rentas/ClienteDetalleVehiculoScreen.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  String _searchTerm = '';
  String _transmisionFilter = 'Todos';
  String _combustibleFilter = 'Todos';
  String _tipoVehiculoFilter = 'Todos';
  String _pasajerosFilter = 'Todos';
  String _precioFilter = 'Todos';

  final List<String> _transmisiones = ['Todos', 'Automatica', 'Manual'];
  final List<String> _combustibles = [
    'Todos',
    'Gasolina',
    'Diesel',
    'Eléctrico',
  ];
  final List<String> _tiposVehiculo = [
    'Todos',
    'SUV',
    'Sedan',
    'Camioneta',
    'Deportivo',
  ];
  final List<String> _pasajeros = ['Todos', '2', '4', '5', '7', '8+'];
  final List<String> _precios = [
    'Todos',
    '< \$50.0',
    '\$50.0 - \$100.0',
    '> \$100.0',
  ];

  void _showFiltrosSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtros",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModernDropdown(
                    "Transmisión",
                    Icons.settings,
                    _transmisiones,
                    _transmisionFilter,
                    (val) => setState(() => _transmisionFilter = val),
                  ),
                  const SizedBox(height: 16),
                  _buildModernDropdown(
                    "Combustible",
                    Icons.local_gas_station,
                    _combustibles,
                    _combustibleFilter,
                    (val) => setState(() => _combustibleFilter = val),
                  ),
                  const SizedBox(height: 16),
                  _buildModernDropdown(
                    "Tipo de Vehículo",
                    Icons.directions_car,
                    _tiposVehiculo,
                    _tipoVehiculoFilter,
                    (val) => setState(() => _tipoVehiculoFilter = val),
                  ),
                  const SizedBox(height: 16),
                  _buildModernDropdown(
                    "Pasajeros",
                    Icons.people,
                    _pasajeros,
                    _pasajerosFilter,
                    (val) => setState(() => _pasajerosFilter = val),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            "Limpiar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Aplicar Filtros",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _transmisionFilter = 'Todos';
      _combustibleFilter = 'Todos';
      _tipoVehiculoFilter = 'Todos';
      _pasajerosFilter = 'Todos';
      _precioFilter = 'Todos';
    });
  }

  DateTimeRange? fechasSeleccionadas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    fechasSeleccionadas = args?['rangoFechas'];
  }

  Widget _buildModernDropdown(
    String label,
    IconData icon,
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        dropdownColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(251, 140, 0, 1),
        title: const Text(
          'Búsqueda de Vehículos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Barra de búsqueda moderna
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar vehículo...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchTerm = value.toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros horizontales modernos
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _precioFilter,
                            decoration: InputDecoration(
                              hintText: 'Precio',
                              prefixIcon: Icon(
                                Icons.monetization_on,
                                color: Colors.orange[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items:
                                _precios
                                    .map(
                                      (precio) => DropdownMenuItem(
                                        value: precio,
                                        child: Text(
                                          precio,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() => _precioFilter = value);
                              }
                            },
                            dropdownColor: Colors.white,
                            elevation: 8,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[600]!, Colors.orange[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _showFiltrosSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          icon: const Icon(Icons.tune, size: 20),
                          label: const Text(
                            "Filtros",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de resultados
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _filtrarVehiculosPorFecha(fechasSeleccionadas),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange[600]!,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data ?? [];

                final results =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre =
                          (data['nombre'] ?? '').toString().toLowerCase();
                      final transmision = data['transmision'] ?? '';
                      final combustible = data['combustible'] ?? '';
                      final tipo = data['tipo'] ?? '';
                      final pasajeros = data['pasajeros'] ?? 0;
                      final precio = data['precioPorDia'] ?? 0;

                      final matchesSearch =
                          _searchTerm.isEmpty || nombre.startsWith(_searchTerm);

                      final matchesTransmision =
                          _transmisionFilter == 'Todos' ||
                          transmision == _transmisionFilter;
                      final matchesCombustible =
                          _combustibleFilter == 'Todos' ||
                          combustible == _combustibleFilter;
                      final matchesTipo =
                          _tipoVehiculoFilter == 'Todos' ||
                          tipo == _tipoVehiculoFilter;
                      final matchesPasajeros =
                          _pasajerosFilter == 'Todos' ||
                          (_pasajerosFilter == '8+' && pasajeros >= 8) ||
                          (pasajeros.toString() == _pasajerosFilter);
                      final matchesPrecio =
                          _precioFilter == 'Todos' ||
                          (_precioFilter == '< \$50.0' && precio < 50) ||
                          (_precioFilter == '\$50.0 - \$100.0' &&
                              precio >= 50 &&
                              precio <= 100) ||
                          (_precioFilter == '> \$100.0' && precio > 100);

                      return matchesSearch &&
                          matchesTransmision &&
                          matchesCombustible &&
                          matchesTipo &&
                          matchesPasajeros &&
                          matchesPrecio;
                    }).toList();

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron vehículos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta ajustar los filtros de búsqueda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final doc = results[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final vehiculoId = doc.id;

                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ClienteDetalleVehiculoScreen(
                                  idVehiculo: vehiculoId,
                                ),
                          ),
                        );

                        await _registerVehicleView(vehiculoId);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: AspectRatio(
                                aspectRatio: 3 / 2,
                                child: Image.network(
                                  data['imagenes'][0],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['nombre'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "\$${data['precioPorDia'].toStringAsFixed(1)} /día",
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _buildInfoChip(
                                        Icons.settings,
                                        data['transmision'] ?? 'N/A',
                                      ),
                                      _buildInfoChip(
                                        Icons.local_gas_station,
                                        data['combustible'] ?? 'N/A',
                                      ),
                                      _buildInfoChip(
                                        Icons.people,
                                        '${data['pasajeros']} personas',
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _filtrarVehiculosPorFecha(
    DateTimeRange? rango,
  ) async {
    final vehiculosSnapshot =
        await FirebaseFirestore.instance
            .collection('vehiculos')
            .where('disponible', isEqualTo: true)
            .get();

    List<QueryDocumentSnapshot> disponibles = [];

    for (final vehiculo in vehiculosSnapshot.docs) {
      final String? vehiculoId = vehiculo.get('idVehiculo');
      if (vehiculoId == null) {
        continue; // seguridad por si algún documento no tiene el campo
      }

      // Si no se seleccionaron fechas, se considera disponible
      if (rango == null) {
        disponibles.add(vehiculo);
        continue;
      }

      // Verificar si el vehículo está disponible en el rango de fechas
      bool estaDisponible = await _verificarDisponibilidadVehiculo(
        vehiculoId,
        rango,
      );

      if (estaDisponible) {
        disponibles.add(vehiculo);
      }
    }

    return disponibles;
  }

  Future<bool> _verificarDisponibilidadVehiculo(
    String vehiculoId,
    DateTimeRange rango,
  ) async {
    try {
      // Obtener todas las rentas del vehículo que no estén canceladas
      final rentasSnapshot =
          await FirebaseFirestore.instance
              .collection('rentas')
              .where('vehiculoId', isEqualTo: vehiculoId)
              .where(
                'estado',
                whereIn: [
                  'confirmada',
                  'activa',
                  'pendiente_confirmacion',
                  'en_curso',
                  'Pre-agendada',
                ],
              )
              .get();

      // Normalizar fechas solicitadas (sin hora)
      final DateTime inicioSolicitado = DateTime(
        rango.start.year,
        rango.start.month,
        rango.start.day,
      );
      final DateTime finSolicitado = DateTime(
        rango.end.year,
        rango.end.month,
        rango.end.day,
      );

      print('🔍 Verificando disponibilidad para vehículo: $vehiculoId');
      print('📅 Rango solicitado: $inicioSolicitado -> $finSolicitado');

      // Verificar cada renta activa
      for (final rentaDoc in rentasSnapshot.docs) {
        final data = rentaDoc.data();
        final estado = data['estado'] ?? '';

        // Parseo robusto de fechas
        DateTime? inicioRenta;
        DateTime? finRenta;

        final rawInicio = data['fechaInicio'];
        final rawFin = data['fechaFin'];

        try {
          if (rawInicio is Timestamp) {
            inicioRenta = rawInicio.toDate();
          } else if (rawInicio is String) {
            inicioRenta = DateTime.tryParse(rawInicio);
          }

          if (rawFin is Timestamp) {
            finRenta = rawFin.toDate();
          } else if (rawFin is String) {
            finRenta = DateTime.tryParse(rawFin);
          }
        } catch (e) {
          print('❌ Error al parsear fechas: $e');
          continue;
        }

        if (inicioRenta == null || finRenta == null) continue;

        // Normalizar fechas existentes (sin hora)
        final inicioRentaNormalizada = DateTime(
          inicioRenta.year,
          inicioRenta.month,
          inicioRenta.day,
        );
        final finRentaNormalizada = DateTime(
          finRenta.year,
          finRenta.month,
          finRenta.day,
        );

        print(
          '🚗 Renta existente ($estado): $inicioRentaNormalizada -> $finRentaNormalizada',
        );

        // Verificar si hay conflicto
        final hayConflicto = _verificarConflictoFechas(
          inicioSolicitado,
          finSolicitado,
          inicioRentaNormalizada,
          finRentaNormalizada,
        );

        if (hayConflicto) {
          print('❌ Conflicto detectado - Vehículo no disponible');
          return false;
        }
      }

      print('✅ Vehículo disponible');
      return true;
    } catch (e) {
      print('❌ Error al verificar disponibilidad: $e');
      return false;
    }
  }

  bool _verificarConflictoFechas(
    DateTime inicioSolicitado,
    DateTime finSolicitado,
    DateTime inicioExistente,
    DateTime finExistente,
  ) {
    // Casos donde NO hay conflicto:
    // 1. La reserva solicitada termina antes de que empiece la existente
    // 2. La reserva solicitada empieza después de que termine la existente

    bool noHayConflicto =
        finSolicitado.isBefore(inicioExistente) ||
        inicioSolicitado.isAfter(finExistente);

    // Si no hay conflicto según las condiciones anteriores, entonces SÍ hay conflicto
    bool hayConflicto = !noHayConflicto;

    if (hayConflicto) {
      print('⚠️  Conflicto detectado:');
      print('   Solicitado: $inicioSolicitado -> $finSolicitado');
      print('   Existente:  $inicioExistente -> $finExistente');

      // Mostrar el tipo específico de conflicto
      if (inicioSolicitado.isBefore(inicioExistente) &&
          finSolicitado.isAfter(finExistente)) {
        print(
          '   Tipo: La reserva solicitada envuelve completamente a la existente',
        );
      } else if (inicioSolicitado.isAfter(inicioExistente) &&
          finSolicitado.isBefore(finExistente)) {
        print('   Tipo: La reserva solicitada está dentro de la existente');
      } else if (inicioSolicitado.isBefore(finExistente) &&
          finSolicitado.isAfter(inicioExistente)) {
        print('   Tipo: Las reservas se superponen parcialmente');
      }
    }

    return hayConflicto;
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _registerVehicleView(String vehiculoId) async {
    try {
      final vistasRef = FirebaseFirestore.instance.collection(
        'vistas_recientes',
      );

      final existingView =
          await vistasRef
              .where('userId', isEqualTo: currentUserId)
              .where('vehiculoId', isEqualTo: vehiculoId)
              .get();

      if (existingView.docs.isNotEmpty) {
        await existingView.docs.first.reference.update({
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await vistasRef.add({
          'userId': currentUserId,
          'vehiculoId': vehiculoId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      final allViews =
          await vistasRef
              .where('userId', isEqualTo: currentUserId)
              .orderBy('timestamp', descending: true)
              .get();

      if (allViews.docs.length > 5) {
        for (int i = 5; i < allViews.docs.length; i++) {
          await allViews.docs[i].reference.delete();
        }
      }

      // Incrementar contador global de vistas del vehículo
      await FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(vehiculoId)
          .update({'vistas': FieldValue.increment(1)});
    } catch (e) {
      print('Error al registrar vista: $e');
    }
  }
}
