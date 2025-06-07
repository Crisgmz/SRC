import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solutions_rent_car/src/screens/home/BusquedaAvanzadaScreen.dart';
import 'package:solutions_rent_car/src/screens/home/BusquedaScreen.dart';
import 'package:solutions_rent_car/src/screens/home/ClientProfileScreen.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Cliente/ClienteRentasScreen.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _screens = [
      _HomeScreen(currentUserId: uid),
      const BusquedaScreen(),
      const ClientRentalsScreen(),
      const PantallaPerfilCliente(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20),
        child: Container(
          height: screenWidth * 0.2,
          width: screenWidth * 0.2,
          padding: EdgeInsets.all(screenWidth * 0.01),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront,
              size: screenWidth * 0.075,
              color: Colors.white,
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
                // Left side icons
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
                // Empty space for FAB
                SizedBox(width: screenWidth * 0.2),
                // Right side icons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Rentas',
                        index: 2,
                        screenWidth: screenWidth,
                      ),
                      _buildNavItem(
                        icon: Icons.person_outline,
                        label: 'Perfil',
                        index: 3,
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

class _HomeScreen extends StatelessWidget {
  final String? currentUserId;

  const _HomeScreen({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header con tamaño adaptativo
        Container(
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

        SizedBox(height: screenHeight * 0.015),

        // Brands section
        FutureBuilder<List<DocumentSnapshot>>(
          future: _getFilteredBrandDocs(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: screenWidth * 0.25,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data!;

            return SizedBox(
              height: screenWidth * 0.25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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

        // Recently viewed cars
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('vistas_recientes')
                  .where('userId', isEqualTo: currentUserId)
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: screenHeight * 0.42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
              height: screenWidth * 0.28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: vistasRecientes.length,
                itemBuilder: (context, index) {
                  final vistaData =
                      vistasRecientes[index].data() as Map<String, dynamic>;
                  final vehiculoId = vistaData['vehiculoId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('vehiculos')
                            .doc(vehiculoId)
                            .get(),
                    builder: (context, vehiculoSnapshot) {
                      if (!vehiculoSnapshot.hasData) {
                        return _buildShimmerCard(
                          width: screenWidth * 0.65,
                          height: screenWidth * 0.25,
                          screenWidth: screenWidth,
                        );
                      }

                      if (!vehiculoSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      final vehiculoData =
                          vehiculoSnapshot.data!.data() as Map<String, dynamic>;
                      final nombre = vehiculoData['nombre'] ?? 'Vehículo';
                      final precio =
                          vehiculoData['precioPorDia'] != null
                              ? '\$${vehiculoData['precioPorDia']}'
                              : '\$99';
                      final imagenes =
                          vehiculoData['imagenes'] as List<dynamic>? ?? [];
                      final imagen = imagenes.isNotEmpty ? imagenes.first : '';

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
                        child: _buildRecentCarCard(
                          nombre,
                          'Solutions\nRent A Car',
                          precio,
                          imagen,
                          screenWidth,
                          screenHeight,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),

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
                  onPressed: () {},
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

        SizedBox(height: screenHeight * 0.002),

        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('vehiculos')
                  .where('destacado', isEqualTo: true)
                  .limit(6)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: screenWidth * 0.85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
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

            return SizedBox(
              height: screenWidth * 0.85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: screenWidth * 0.032),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final idVehiculo = docs[index].id;
                  final nombre = data['nombre'] ?? 'Vehículo';
                  final pasajeros = data['pasajeros']?.toString() ?? 'N/A';
                  final combustible = data['combustible'] ?? 'N/A';
                  final transmision = data['transmision'] ?? 'N/A';
                  final precio =
                      data['precioPorDia'] != null
                          ? '\$${data['precioPorDia']}'
                          : '\$99';
                  final imagenes = data['imagenes'] as List<dynamic>? ?? [];
                  final imagen = imagenes.isNotEmpty ? imagenes.first : '';

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
                    child: Container(
                      width: screenWidth * 0.45,
                      margin: EdgeInsets.only(
                        left: index == 0 ? screenWidth * 0.042 : 0,
                        right: screenWidth * 0.032,
                        top: screenWidth * 0.03,
                        bottom: screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.021),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 3 / 2,
                                child:
                                    imagen.isNotEmpty
                                        ? Image.network(
                                          imagen,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Icon(
                                                Icons.image_not_supported,
                                                size: screenWidth * 0.1,
                                                color: Colors.grey,
                                              ),
                                        )
                                        : Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.directions_car,
                                            size: screenWidth * 0.1,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.026,
                            ),
                            child: Text(
                              nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.026,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Flexible(
                                  child: Text(
                                    transmision,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Icon(
                                  Icons.local_gas_station,
                                  size: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Flexible(
                                  child: Text(
                                    combustible,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.026,
                            ),
                            child: _buildIconInfo(
                              Icons.people,
                              '$pasajeros Pasajeros',
                              screenWidth,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              screenWidth * 0.026,
                              screenWidth * 0.01,
                              screenWidth * 0.026,
                              screenWidth * 0.03,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: const Color(0xFFF9A825),
                                  size: screenWidth * 0.045,
                                ),
                                Text(
                                  precio,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    color: const Color(0xFFF9A825),
                                  ),
                                ),
                                Text(
                                  "/día",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        SizedBox(height: screenWidth * 0.06),
      ],
    );
  }

  // Método para registrar la vista de un vehículo
  Future<void> _registerVehicleView(String vehiculoId) async {
    try {
      final vistasRef = FirebaseFirestore.instance.collection(
        'vistas_recientes',
      );

      // Verificar si ya existe una vista de este vehículo por este usuario
      final existingView =
          await vistasRef
              .where('userId', isEqualTo: currentUserId)
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
          'userId': currentUserId,
          'vehiculoId': vehiculoId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Limpiar vistas antiguas (mantener solo las últimas 5)
      final allViews =
          await vistasRef
              .where('userId', isEqualTo: currentUserId)
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

  Widget _buildBrandCard(String name, String logoUrl, double screenWidth) {
    return Container(
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
      height: screenHeight * 0.25, // Mantenemos la altura original
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: screenWidth * 0.025,
            spreadRadius: screenWidth * 0.005,
            offset: Offset(0, screenHeight * 0.005),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: screenWidth * 0.015,
            spreadRadius: 0,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen - sin cambios
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Hero(
              tag: 'vehicle_image_$vehiculoId',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
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

          // Contenido textual - TEXTOS OPTIMIZADOS
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
                  // Título - Reducido de 0.04 a 0.035
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035, // Reducido
                      height: 1.1, // Control preciso del line height
                    ),
                    maxLines: 2, // Permitir 2 líneas
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenHeight * 0.004), // Espaciado reducido
                  // Subtítulo - Reducido de 0.03 a 0.028
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.028, // Reducido
                      height: 1.2, // Control del line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenHeight * 0.008), // Espaciado reducido
                  // Precio y estrella - Ajustado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: screenWidth * 0.032, // Reducido de 0.035 a 0.032
                        color: Colors.amber,
                      ),
                      SizedBox(
                        width: screenWidth * 0.008,
                      ), // Espaciado reducido
                      Flexible(
                        child: Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                screenWidth * 0.035, // Reducido de 0.04 a 0.035
                            color: const Color(0xFFF9A825),
                            height: 1.0, // Sin espacio extra
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "/día",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize:
                              screenWidth * 0.026, // Reducido de 0.03 a 0.026
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
}
