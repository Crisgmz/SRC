import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solutions_rent_car/src/screens/home/BusquedaAvanzadaScreen.dart';
import 'package:solutions_rent_car/src/screens/home/BusquedaScreen.dart';
import 'package:solutions_rent_car/src/screens/home/ClientProfileScreen.dart';
import 'package:solutions_rent_car/src/screens/home/alternas/Todorentaspopulares.dart';
import 'package:solutions_rent_car/src/screens/home/alternas/VehiculosPorMarcaScreen.dart';
import 'package:solutions_rent_car/src/screens/home/todos_los_vehiculos_screen.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Cliente/ClienteRentasScreen.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

// Singleton para manejo de caché global
class DataCacheManager {
  static final DataCacheManager _instance = DataCacheManager._internal();
  factory DataCacheManager() => _instance;
  DataCacheManager._internal();

  // Cachés para diferentes tipos de datos
  final Map<String, Map<String, dynamic>> _vehiculosCache = {};
  final Map<String, Map<String, dynamic>> _marcasCache = {};
  final Map<String, List<DocumentSnapshot>> _brandDocsCache = {};
  final Map<String, List<DocumentSnapshot>> _featuredVehiclesCache = {};

  // Control de tiempo de caché
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Verificar si el caché ha expirado
  bool _isCacheExpired(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiration;
  }

  // Actualizar timestamp del caché
  void _updateCacheTimestamp(String key) {
    _cacheTimestamps[key] = DateTime.now();
  }

  // Caché de vehículos
  Future<Map<String, dynamic>> getVehiculo(String id) async {
    final cacheKey = 'vehiculo_$id';

    if (_vehiculosCache.containsKey(id) && !_isCacheExpired(cacheKey)) {
      return _vehiculosCache[id]!;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('vehiculos')
              .doc(id)
              .get();

      final data = doc.data() ?? {};
      _vehiculosCache[id] = data;
      _updateCacheTimestamp(cacheKey);

      return data;
    } catch (e) {
      // Si falla la consulta pero tenemos caché, devolverlo aunque haya expirado
      if (_vehiculosCache.containsKey(id)) {
        return _vehiculosCache[id]!;
      }
      return {};
    }
  }

  // Caché de marcas
  Future<Map<String, dynamic>> getMarca(String id) async {
    final cacheKey = 'marca_$id';

    if (_marcasCache.containsKey(id) && !_isCacheExpired(cacheKey)) {
      return _marcasCache[id]!;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('marcas').doc(id).get();

      final data = doc.data() ?? {};
      _marcasCache[id] = data;
      _updateCacheTimestamp(cacheKey);

      return data;
    } catch (e) {
      if (_marcasCache.containsKey(id)) {
        return _marcasCache[id]!;
      }
      return {};
    }
  }

  // Caché de marcas filtradas
  Future<List<DocumentSnapshot>> getFilteredBrandDocs() async {
    const cacheKey = 'filtered_brands';

    if (_brandDocsCache.containsKey(cacheKey) && !_isCacheExpired(cacheKey)) {
      return _brandDocsCache[cacheKey]!;
    }

    try {
      // Obtener vehículos para filtrar marcas activas
      final vehiculosSnapshot =
          await FirebaseFirestore.instance.collection('vehiculos').get();

      final Set<String> usedBrands =
          vehiculosSnapshot.docs
              .map((doc) => doc['marca']?.toString())
              .whereType<String>()
              .toSet();

      // Consultar marcas
      final marcasSnapshot =
          await FirebaseFirestore.instance.collection('marcas').get();

      final filteredDocs =
          marcasSnapshot.docs.where((doc) {
            final marca = doc['marca']?.toString();
            return usedBrands.contains(marca);
          }).toList();

      _brandDocsCache[cacheKey] = filteredDocs;
      _updateCacheTimestamp(cacheKey);

      return filteredDocs;
    } catch (e) {
      if (_brandDocsCache.containsKey(cacheKey)) {
        return _brandDocsCache[cacheKey]!;
      }
      return [];
    }
  }

  // Caché de vehículos destacados
  Future<List<DocumentSnapshot>> getFeaturedVehicles() async {
    const cacheKey = 'featured_vehicles';

    if (_featuredVehiclesCache.containsKey(cacheKey) &&
        !_isCacheExpired(cacheKey)) {
      return _featuredVehiclesCache[cacheKey]!;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('vehiculos')
              .where('destacado', isEqualTo: true)
              .limit(6)
              .get();

      _featuredVehiclesCache[cacheKey] = snapshot.docs;
      _updateCacheTimestamp(cacheKey);

      return snapshot.docs;
    } catch (e) {
      if (_featuredVehiclesCache.containsKey(cacheKey)) {
        return _featuredVehiclesCache[cacheKey]!;
      }
      return [];
    }
  }

  // Limpiar caché cuando sea necesario
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys =
        _cacheTimestamps.entries
            .where((entry) => now.difference(entry.value) > _cacheExpiration)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredKeys) {
      _cacheTimestamps.remove(key);

      if (key.startsWith('vehiculo_')) {
        final id = key.substring(9);
        _vehiculosCache.remove(id);
      } else if (key.startsWith('marca_')) {
        final id = key.substring(6);
        _marcasCache.remove(id);
      } else if (key == 'filtered_brands') {
        _brandDocsCache.remove(key);
      } else if (key == 'featured_vehicles') {
        _featuredVehiclesCache.remove(key);
      }
    }
  }

  // Invalidar caché específico (útil después de actualizaciones)
  void invalidateCache(String type, [String? id]) {
    switch (type) {
      case 'vehiculo':
        if (id != null) {
          _vehiculosCache.remove(id);
          _cacheTimestamps.remove('vehiculo_$id');
        }
        break;
      case 'marca':
        if (id != null) {
          _marcasCache.remove(id);
          _cacheTimestamps.remove('marca_$id');
        }
        break;
      case 'brands':
        _brandDocsCache.clear();
        _cacheTimestamps.remove('filtered_brands');
        break;
      case 'featured':
        _featuredVehiclesCache.clear();
        _cacheTimestamps.remove('featured_vehicles');
        break;
    }
  }
}

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  String? _currentUserId;
  final DataCacheManager _cacheManager = DataCacheManager();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _currentUserId = uid;

    _screens = [
      _HomeScreen(currentUserId: uid, cacheManager: _cacheManager),
      const BusquedaScreen(),
      const TodosLosVehiculosScreen(),
      const ClientRentalsScreen(),
      const PantallaPerfilCliente(),
    ];

    // Limpiar caché expirado periódicamente
    _schedulePeriodicCacheCleanup();
  }

  void _schedulePeriodicCacheCleanup() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _cacheManager.clearExpiredCache();
        _schedulePeriodicCacheCleanup();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 26),
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = 2),
          child: Container(
            height: screenWidth * 0.18,
            width: screenWidth * 0.18,
            padding: EdgeInsets.all(screenWidth * 0.012),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      _currentIndex == 2
                          ? Colors.orange
                          : Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentIndex == 2 ? Colors.orange : Colors.orange,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.storefront,
                size: screenWidth * 0.075,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomAppBar(
            notchMargin: 8,
            elevation: 0,
            padding: EdgeInsets.zero,
            height: screenWidth * 0.16,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.home,
                        label: 'Explorar',
                        index: 0,
                        screenWidth: screenWidth,
                      ),
                      _buildNavItem(
                        icon: Icons.search,
                        label: 'Buscar',
                        index: 1,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.2),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Rentas',
                        index: 3,
                        screenWidth: screenWidth,
                      ),
                      _buildNavItem(
                        icon: Icons.person_outline,
                        label: 'Perfil',
                        index: 4,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required double screenWidth,
  }) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFFF9A825);
    final inactiveColor = Colors.grey;

    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: screenWidth * 0.06,
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: isActive ? activeColor : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  final String? currentUserId;
  final DataCacheManager cacheManager;

  const _HomeScreen({required this.currentUserId, required this.cacheManager});

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  // Streams con caché
  Stream<QuerySnapshot>? _recentViewsStream;
  Stream<QuerySnapshot>? _featuredVehiclesStream;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      widget.cacheManager.getFilteredBrandDocs(),
      widget.cacheManager.getFeaturedVehicles(),
    ]);
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _initializeStreams() {
    if (widget.currentUserId != null) {
      _recentViewsStream =
          FirebaseFirestore.instance
              .collection('vistas_recientes')
              .where('userId', isEqualTo: widget.currentUserId)
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots();
    }

    _featuredVehiclesStream =
        FirebaseFirestore.instance
            .collection('vehiculos')
            .where('destacado', isEqualTo: true)
            .limit(6)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_loading) {
      return _buildHomeShimmer(screenWidth, screenHeight);
    }

    return Column(
      children: [
        // Header fijo
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.06,
            MediaQuery.of(context).padding.top + screenHeight * 0.02,
            screenWidth * 0.06,
            screenHeight * 0.035,
          ),
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Cristian!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        Text(
                          'Que quieres hacer Hoy?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.07,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusquedaAvanzadaScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '¿Dónde quieres rentar?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.043,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(height: screenHeight * 0.015),

              // Brands section con caché
              FutureBuilder<List<DocumentSnapshot>>(
                future: widget.cacheManager.getFilteredBrandDocs(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: screenWidth * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        itemCount: 5,
                        itemBuilder: (_, __) =>
                            _buildBrandShimmerCard(screenWidth),
                      ),
                    );
                  }

                  final docs = snapshot.data!;

                  return SizedBox(
                    height: screenWidth * 0.25,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final nombre = data['marca'] ?? 'Marca';
                        final logoUrl = data['logo'] ?? '';

                        return _buildBrandCard(nombre, logoUrl, screenWidth);
                      },
                    ),
                  );
                },
              ),

              // Recently viewed section
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.04,
                  0,
                  screenWidth * 0.04,
                  screenHeight * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recientes Vistas',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Recently viewed cars con caché
              if (_recentViewsStream != null)
                StreamBuilder<QuerySnapshot>(
                  stream: _recentViewsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        height: screenHeight * 0.42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                          ),
                          itemCount: 3,
                          itemBuilder:
                              (context, index) => _buildShimmerCard(
                                width: screenWidth * 0.65,
                                height: screenWidth * 0.25,
                                screenWidth: screenWidth,
                              ),
                        ),
                      );
                    }

                    final vistasRecientes = snapshot.data!.docs;

                    return SizedBox(
                      height: screenWidth * 0.34,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.04,
                          right: screenWidth * 0.04,
                          top: screenWidth * 0.02,
                          bottom: screenWidth * 0.02,
                        ),
                        itemCount: vistasRecientes.length,
                        itemBuilder: (context, index) {
                          final vistaData =
                              vistasRecientes[index].data()
                                  as Map<String, dynamic>;
                          final vehiculoId = vistaData['vehiculoId'];

                          return FutureBuilder<Map<String, dynamic>>(
                            future: widget.cacheManager.getVehiculo(vehiculoId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return _buildShimmerCard(
                                  width: screenWidth * 0.65,
                                  height: screenWidth * 0.25,
                                  screenWidth: screenWidth,
                                );
                              }

                              final vehiculoData = snapshot.data!;
                              final nombre =
                                  vehiculoData['nombre'] ?? 'Vehículo';
                              final precio =
                                  vehiculoData['precioPorDia'] != null
                                      ? '\$${vehiculoData['precioPorDia']}'
                                      : '\$99';
                              final imagenes =
                                  vehiculoData['imagenes'] as List<dynamic>? ??
                                  [];
                              final imagen =
                                  imagenes.isNotEmpty ? imagenes.first : '';

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
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.04,
                                    bottom: screenWidth * 0.02,
                                  ),
                                  child: _buildRecentCarCard(
                                    nombre,
                                    'Solutions\nRent A Car',
                                    precio,
                                    imagen,
                                    screenWidth,
                                    MediaQuery.of(context).size.height,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              //        SizedBox(height: screenWidth * 0.04), // ← Espacio entre secciones
              // Popular rentals section
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.042,
                  0,
                  screenWidth * 0.042,
                  screenHeight * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rentas Populares',
                      style: TextStyle(
                        fontSize: screenWidth * 0.058,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RentasPopularesScreen(),
                            ),
                          );
                        },

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver Todo',
                              style: TextStyle(
                                color: const Color(0xFFF9A825),
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: const Color(0xFFF9A825),
                              size: screenWidth * 0.045,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Popular rentals con caché
              StreamBuilder<QuerySnapshot>(
                stream: _featuredVehiclesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: screenWidth * 0.85,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: screenWidth * 0.042),
                        itemCount: 3,
                        itemBuilder:
                            (context, index) => _buildShimmerCard(
                              width: screenWidth * 0.45,
                              height: screenWidth * 0.8,
                              screenWidth: screenWidth,
                            ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Column(
                    children: [
                      SizedBox(
                        height: screenWidth * 0.75,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(right: screenWidth * 0.032),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final idVehiculo = docs[index].id;
                            final nombre = data['nombre'] ?? 'Vehículo';
                            final pasajeros =
                                data['pasajeros']?.toString() ?? 'N/A';
                            final combustible = data['combustible'] ?? 'N/A';
                            final transmision = data['transmision'] ?? 'N/A';
                            final precio =
                                data['precioPorDia'] != null
                                    ? '\$${data['precioPorDia']}'
                                    : '\$99';
                            final imagenes =
                                data['imagenes'] as List<dynamic>? ?? [];
                            final imagen =
                                imagenes.isNotEmpty ? imagenes.first : '';

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ClienteDetalleVehiculoScreen(
                                          idVehiculo: idVehiculo,
                                        ),
                                  ),
                                );
                                await _registerVehicleView(idVehiculo);
                              },
                              child: _buildFeaturedCarCard(
                                idVehiculo,
                                nombre,
                                pasajeros,
                                combustible,
                                transmision,
                                precio,
                                imagen,
                                screenWidth,
                                index,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método para registrar la vista de un vehículo (optimizado)
  Future<void> _registerVehicleView(String vehiculoId) async {
    if (widget.currentUserId == null) return;

    try {
      final vistasRef = FirebaseFirestore.instance.collection(
        'vistas_recientes',
      );

      // Verificar si ya existe una vista de este vehículo por este usuario
      final existingView =
          await vistasRef
              .where('userId', isEqualTo: widget.currentUserId)
              .where('vehiculoId', isEqualTo: vehiculoId)
              .get();

      if (existingView.docs.isNotEmpty) {
        // Si ya existe, actualizar el timestamp
        await existingView.docs.first.reference.update({
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Si no existe, crear nueva vista
        await vistasRef.add({
          'userId': widget.currentUserId,
          'vehiculoId': vehiculoId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Limpiar vistas antiguas (mantener solo las últimas 5)
      final allViews =
          await vistasRef
              .where('userId', isEqualTo: widget.currentUserId)
              .orderBy('timestamp', descending: true)
              .get();

      if (allViews.docs.length > 5) {
        // Eliminar las vistas que excedan el límite
        for (int i = 5; i < allViews.docs.length; i++) {
          await allViews.docs[i].reference.delete();
        }
      }
    } catch (e) {
      print('Error al registrar vista: $e');
    }
  }

  Future<List<DocumentSnapshot>> _getFilteredBrandDocs() async {
    final vehiculosSnapshot =
        await FirebaseFirestore.instance.collection('vehiculos').get();

    // Obtener las marcas únicas desde los vehículos
    final Set<String> usedBrands =
        vehiculosSnapshot.docs
            .map((doc) => doc['marca']?.toString())
            .whereType<String>()
            .toSet();

    // Consultar solo las marcas activas
    final marcasSnapshot =
        await FirebaseFirestore.instance.collection('marcas').get();

    final filteredDocs =
        marcasSnapshot.docs.where((doc) {
          final marca = doc['marca']?.toString();
          return usedBrands.contains(marca);
        }).toList();

    return filteredDocs;
  }

  Widget _buildIconInfo(IconData icon, String text, double screenWidth) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.04, color: Colors.grey[600]),
        SizedBox(width: screenWidth * 0.01),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: screenWidth * 0.03,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard({
    required double width,
    required double height,
    required double screenWidth,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(right: screenWidth * 0.04),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBrandShimmerCard(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.015,
        ),
        width: screenWidth * 0.2,
        height: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHomeShimmer(double screenWidth, double screenHeight) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.06,
            MediaQuery.of(context).padding.top + screenHeight * 0.02,
            screenWidth * 0.06,
            screenHeight * 0.035,
          ),
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: screenWidth * 0.07,
                  width: screenWidth * 0.4,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: screenWidth * 0.045,
                  width: screenWidth * 0.6,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        SizedBox(
          height: screenWidth * 0.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            itemCount: 5,
            itemBuilder: (_, __) => _buildBrandShimmerCard(screenWidth),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        SizedBox(
          height: screenWidth * 0.34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            itemCount: 3,
            itemBuilder: (_, __) => _buildShimmerCard(
              width: screenWidth * 0.65,
              height: screenWidth * 0.25,
              screenWidth: screenWidth,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        SizedBox(
          height: screenWidth * 0.75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenWidth * 0.042),
            itemCount: 3,
            itemBuilder: (_, __) => _buildShimmerCard(
              width: screenWidth * 0.45,
              height: screenWidth * 0.8,
              screenWidth: screenWidth,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandCard(String name, String logoUrl, double screenWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehiculosPorMarcaScreen(marca: name),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.015,
        ),
        width: screenWidth * 0.2,
        height: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: screenWidth * 0.16,
            height: screenWidth * 0.16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  logoUrl.isNotEmpty
                      ? Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                size: screenWidth * 0.075,
                                color: Colors.grey[600],
                              ),
                            ),
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.directions_car,
                          size: screenWidth * 0.075,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCarCard(
    String title,
    String subtitle,
    String price,
    String imageUrl,
    double screenWidth,
    double screenHeight,
  ) {
    final vehiculoId = title;

    return Container(
      margin: EdgeInsets.fromLTRB(
        0,
        screenHeight * 0.0010,
        screenWidth * 0.04,
        screenHeight * 0.0025,
      ),
      width: screenWidth * 0.65,
      height: screenHeight * 0.25,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Valor fijo como las marcas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10, // Valor fijo como las marcas
            spreadRadius: 2, // Valor fijo como las marcas
            offset: const Offset(0, 4), // Valor fijo como las marcas
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6, // Valor fijo como las marcas
            spreadRadius: 0, // Valor fijo como las marcas
            offset: const Offset(0, 2), // Valor fijo como las marcas
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Hero(
              tag: 'vehicle_image_$vehiculoId',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Consistente con las marcas
                child: SizedBox(
                  width: screenWidth * 0.25,
                  height: screenHeight * 0.18,
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.directions_car,
                                    size: screenWidth * 0.08,
                                    color: Colors.grey[600],
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.directions_car,
                              size: screenWidth * 0.08,
                              color: Colors.grey[600],
                            ),
                          ),
                ),
              ),
            ),
          ),

          // Contenido textual
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.028,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: screenWidth * 0.032,
                        color: Colors.amber,
                      ),
                      SizedBox(width: screenWidth * 0.008),
                      Flexible(
                        child: Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                            color: const Color(0xFFF9A825),
                            height: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "/día",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.026,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarCard(
    String idVehiculo,
    String nombre,
    String pasajeros,
    String combustible,
    String transmision,
    String precio,
    String imagen,
    double screenWidth,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.035,
        right: screenWidth * 0.015, // Agregado margen derecho
        top: screenWidth * 0.02, // Agregado margen superior
        bottom: screenWidth * 0.02, // Reducido el margen inferior
      ),
      width: screenWidth * 0.45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0, // Cambiado de 2 a 0 para evitar superposición
            offset: const Offset(
              0,
              2,
            ), // Cambiado de (0, 0) a (0, 2) para sombra más natural
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.015,
              right: screenWidth * 0.015,
              top: screenWidth * 0.015,
              bottom: screenWidth * 0.01, // menor separación abajo
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  imagen,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
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
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
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
        ],
      ),
    );
  }
}
