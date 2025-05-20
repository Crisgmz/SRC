import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/vehiculos/ClienteDetalleVehiculoScreen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeScreen(),
    const _SearchScreen(),
    const _RentalsScreen(),
    const _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20), // Bájalo más
        child: Container(
          height: 80,
          width: 80,
          padding: const EdgeInsets.all(4),
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
              color: Color(0xFFF9A825),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, size: 30, color: Colors.white),
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
            height: 65,
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.home,
                              color:
                                  _currentIndex == 0
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                              size: 24,
                            ),
                            onPressed: () => setState(() => _currentIndex = 0),
                          ),
                          Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _currentIndex == 0
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color:
                                  _currentIndex == 1
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                              size: 24,
                            ),
                            onPressed: () => setState(() => _currentIndex = 1),
                          ),
                          Text(
                            'Buscar',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _currentIndex == 1
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Empty space for FAB
                const SizedBox(width: 80),

                // Right side icons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color:
                                  _currentIndex == 2
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                              size: 24,
                            ),
                            onPressed: () => setState(() => _currentIndex = 2),
                          ),
                          Text(
                            'Rentas',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _currentIndex == 2
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.person_outline,
                              color:
                                  _currentIndex == 3
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                              size: 24,
                            ),
                            onPressed: () => setState(() => _currentIndex = 3),
                          ),
                          Text(
                            'Perfil',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _currentIndex == 3
                                      ? const Color(0xFFF9A825)
                                      : Colors.grey,
                            ),
                          ),
                        ],
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
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with orange background
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
            decoration: const BoxDecoration(
              color: Color(0xFFF9A825), // Orange color
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hola, Cristian!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Que quieres hacer Hoy?',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        // Reemplazado con un placeholder circular
                        child: Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
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
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Busca lo que quieras...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Brands section
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('marcas').get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data!.docs;

              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final nombre = data['marca'] ?? 'Marca';

                    return _buildBrandCard(nombre);
                  },
                ),
              );
            },
          ),

          // Recently viewed section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recientes Vistas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: const [
                      Text(
                        'Ver Todo',
                        style: TextStyle(
                          color: Color(0xFFF9A825),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Color(0xFFF9A825)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recently viewed cars
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildRecentCarCard(
                  'Honda Pilot 2021',
                  'Solutions\nRent A Car',
                  '\$75.00',
                ),
                _buildRecentCarCard(
                  'Toyota Highlander 2022',
                  'Solutions\nRent A Car',
                  '\$80.00',
                ),
              ],
            ),
          ),

          // Popular rentals section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rentas Populares',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: const [
                      Text(
                        'Ver Todo',
                        style: TextStyle(
                          color: Color(0xFFF9A825),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Color(0xFFF9A825)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Popular rentals grid - IMPROVED VERSION
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('vehiculos')
                    .where('destacado', isEqualTo: true)
                    .limit(6)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data!.docs;

              // Volvemos al ListView horizontal (carrusel)
              return SizedBox(
                height: 240, // Altura del carrusel
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      onTap: () {
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
                      child: Container(
                        width: 180, // Ancho fijo para cada tarjeta
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
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
                            // Imagen con proporción 3:2 redondeada
                            Padding(
                              padding: const EdgeInsets.all(8),
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
                                                (_, __, ___) => const Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                          )
                                          : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.directions_car,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Fila con transmisión y combustible (más compactos)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    transmision,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.local_gas_station,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    combustible,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Fila con pasajeros
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: _buildIconInfo(
                                Icons.people,
                                '$pasajeros Pasajeros',
                              ),
                            ),

                            const Spacer(),

                            // Fila con precio DESTACADO
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Color(0xFFF9A825),
                                    size: 18,
                                  ),
                                  Text(
                                    precio,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // Tamaño más grande
                                      color: Color(0xFFF9A825),
                                    ),
                                  ),
                                  const Text(
                                    "/día",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.black87, fontSize: 12)),
      ],
    );
  }

  Widget _buildBrandCard(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder para el logo
          Container(
            height: 40,
            width: 40,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                name[0], // Primera letra de la marca
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildRecentCarCard(String title, String subtitle, String price) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder para la imagen del coche
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 120,
              height: 140,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.directions_car,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

  // NUEVO método para las tarjetas de rentas populares
  Widget _buildRentalCard(
    String title,
    String description,
    String price,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image with proper handling for network images
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[200],
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (ctx, error, _) => Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: const Color(0xFFF9A825),
                            ),
                          );
                        },
                      )
                      : Center(
                        child: Icon(
                          Icons.directions_car,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Adding price at the bottom like in your example
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: Color(0xFFF9A825),
                      size: 16,
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFF9A825),
                      ),
                    ),
                    const Text(
                      "/day",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchScreen extends StatelessWidget {
  const _SearchScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Buscar'));
  }
}

class _RentalsScreen extends StatelessWidget {
  const _RentalsScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Rentas'));
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil'));
  }
}
