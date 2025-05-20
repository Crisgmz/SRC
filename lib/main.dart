import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ⬅️ Asegúrate de tener esto
import 'package:solutions_rent_car/firebase_options.dart';
import 'package:solutions_rent_car/src/screens/auth/register_screen.dart';
import 'package:solutions_rent_car/src/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isNotEmpty) {
      await Firebase.app().delete();
    }
  } catch (e) {
    print('Error al eliminar la app de Firebase: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Activar cache Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Activar App Check con modo de depuración
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          AndroidProvider.debug, // cambia a playIntegrity para producción
    );
  } catch (e) {
    print('Error al inicializar Firebase o AppCheck: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterTypeScreen(),
      },
    );
  }
}
