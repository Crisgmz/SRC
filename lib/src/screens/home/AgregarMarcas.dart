import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarMarcasScreen extends StatefulWidget {
  const AgregarMarcasScreen({super.key});

  @override
  State<AgregarMarcasScreen> createState() => _AgregarMarcasScreenState();
}

class _AgregarMarcasScreenState extends State<AgregarMarcasScreen> {
  bool _isLoading = false;
  bool _isUploaded = false;

  Future<void> uploadMarcasToFirestore() async {
    setState(() {
      _isLoading = true;
      _isUploaded = false;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final String response = await rootBundle.loadString(
        'assets/marcas_firestore.json',
      );
      final List<dynamic> data = json.decode(response);

      for (var marca in data) {
        final String nombreMarca = marca['marca'];
        final List<dynamic> modelos = marca['modelos'];

        await firestore.collection('marcas').doc(nombreMarca).set({
          'marca': nombreMarca,
          'modelos': modelos,
        });
      }

      setState(() {
        _isUploaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir marcas: \$e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Marcas'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: uploadMarcasToFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF404C8C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Subir Marcas',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isUploaded)
                      const Text(
                        'Marcas cargadas exitosamente!',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
      ),
    );
  }
}
