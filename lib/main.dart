import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solutions_rent_car/firebase_options.dart';
import 'package:solutions_rent_car/src/screens/auth/register_screen.dart';
import 'package:solutions_rent_car/src/screens/auth/login_screen.dart';
import 'package:solutions_rent_car/src/screens/home/ClientHomeScreen.dart'; // Ajusta la ruta si es diferente
import 'package:solutions_rent_car/src/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isNotEmpty) {
      await Firebase.app().delete();
    }
  } catch (e) {
    print('Error al eliminar la app de Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );

    await initializeDateFormatting('es', null);
    await NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final user = FirebaseAuth.instance.currentUser;

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, primarySwatch: Colors.amber),
          home: user != null ? const ClientHomeScreen() : const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterTypeScreen(),
          },
        );
      },
    );
  }
}
