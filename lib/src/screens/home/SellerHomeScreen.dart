import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solutions_rent_car/src/screens/misrentas/Proveedor/ProveedorRentasScreen.dart';
import 'package:solutions_rent_car/src/vehiculos/Proveedor/ConfiguraciónEmpresaScreen.dart';
import 'package:solutions_rent_car/src/vehiculos/Proveedor/MisVehiculosScreen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _currentIndex = 0;

  // Colores personalizados
  final Color primaryColor = const Color(0xFFF8A023);
  final Color iconBorderColor = const Color(0xFF9DB2CE);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final List<Widget> screens = [
      const Center(child: Text('Bienvenido, Vendedor')),
      const ProveedorRentasScreen(),
      const MisVehiculosScreen(),
      ConfiguracionEmpresaScreen(userId: userId), // ✅ Corrección aquí
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              color: isSelected ? primaryColor : iconBorderColor,
            );
          }),
          indicatorColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: screens[_currentIndex],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 5,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            _buildNavigationDestination(
              iconAsset: 'assets/icons/hogar.png',
              iconAssetSelected: 'assets/icons/hogar_fill.png',
              label: 'Inicio',
              index: 0,
            ),
            _buildNavigationDestination(
              iconAsset: 'assets/icons/rentas.png',
              iconAssetSelected: 'assets/icons/rentas_fill.png',
              label: 'Rentas',
              index: 1,
            ),
            _buildNavigationDestination(
              iconAsset: 'assets/icons/coche.png',
              iconAssetSelected: 'assets/icons/coche_fill.png',
              label: 'Vehículos',
              index: 2,
            ),
            _buildNavigationDestination(
              iconAsset: 'assets/icons/cuenta.png',
              iconAssetSelected: 'assets/icons/cuenta_fill.png',
              label: 'Perfil',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Inicio";
      case 1:
        return "Mis Rentas";
      case 2:
        return "Mis Vehículos";
      case 3:
        return "Mi Perfil";
      default:
        return "Solutions Rent Car";
    }
  }

  NavigationDestination _buildNavigationDestination({
    required String iconAsset,
    required String iconAssetSelected,
    required String label,
    required int index,
  }) {
    bool isSelected = _currentIndex == index;
    return NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          isSelected ? iconAssetSelected : iconAsset,
          height: 20,
          width: 20,
        ),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(iconAssetSelected, height: 24, width: 24),
      ),
      label: label,
    );
  }
}
