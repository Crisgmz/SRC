import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solutions_rent_car/firebase_options.dart';
import 'package:solutions_rent_car/src/screens/auth/register_screen.dart';
import 'package:solutions_rent_car/src/screens/auth/login_screen.dart';
import 'package:solutions_rent_car/src/screens/home/ClientHomeScreen.dart';
import 'package:solutions_rent_car/src/screens/home/SellerHomeScreen.dart';
import 'package:solutions_rent_car/src/services/notification_service.dart';

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ajustes de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Localización de fechas
  await initializeDateFormatting('es', null);

  // Inicializa notificaciones y suscribe al topic
  await NotificationService().init();
  await NotificationService().subscribeToTopic('providers');

  // Maneja notificaciones que abren la app desde estado terminated
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null && message.data.isNotEmpty) {
      _handleMessageTap(message.data);
    }
  });

  // Maneja taps cuando la app está en background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.data.isNotEmpty) {
      _handleMessageTap(message.data);
    }
  });

  runApp(const MyApp());
}

/// Navega según el contenido del `data` de la notificación
void _handleMessageTap(Map<String, dynamic> data) {
  final screen = data['screen'] as String?;
  switch (screen) {
    case 'cliente':
      _navKey.currentState?.pushNamed('/client-home');
      break;
    case 'vendedor':
      _navKey.currentState?.pushNamed('/seller-home');
      break;
    // añade más casos según tu payload...
    default:
      break;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        // Mientras esperamos estado de auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final isLoggedIn = snapshot.hasData;

        return MaterialApp(
          navigatorKey: _navKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, primarySwatch: Colors.amber),
          home: isLoggedIn ? const RoleBasedHome() : const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterTypeScreen(),
            '/client-home': (context) => const ClientHomeScreen(),
            '/seller-home': (context) => const SellerHomeScreen(),
          },
        );
      },
    );
  }
}

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  Future<String?> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error obteniendo rol del usuario: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        // Mientras carga el rol
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando perfil...'),
                ],
              ),
            ),
          );
        }

        // Si hay error o no se encuentra rol
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error al cargar el perfil de usuario'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          );
        }

        final role = snapshot.data!;

        // Navegar según el rol
        switch (role.toLowerCase()) {
          case 'vendedor':
            return const SellerHomeScreen();
          case 'cliente':
            return const ClientHomeScreen();
          default:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text('Rol no reconocido: $role'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
