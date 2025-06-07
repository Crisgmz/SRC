import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

class UploadLogosScreen extends StatefulWidget {
  const UploadLogosScreen({super.key});

  @override
  State<UploadLogosScreen> createState() => _UploadLogosScreenState();
}

class _UploadLogosScreenState extends State<UploadLogosScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> carBrands = [
    "Audi",
    "BAIC",
    "BMW",
    "BYD",
    "Changan",
    "Chery",
    "Chevrolet",
    "Citroën",
    "Cupra",
    "DFSK",
    "Dodge",
    "Dongfeng",
    "FAW",
    "Fiat",
    "Ford",
    "Geely",
    "Great Wall",
    "Honda",
    "Hyundai",
    "Isuzu",
    "JAC",
    "Jeep",
    "Kia",
    "Land Rover",
    "Mahindra",
    "Mazda",
    "Mercedes-Benz",
    "MG",
    "Mitsubishi",
    "Nissan",
    "Opel",
    "Peugeot",
    "Ram",
    "Renault",
    "SEAT",
    "Skoda",
    "Subaru",
    "Suzuki",
    "Tata",
    "Tesla",
    "Toyota",
    "Volkswagen",
    "Volvo",
  ];

  bool isUploading = false;
  Map<String, String> results = {};

  String _normalizeBrandName(String name) {
    return name
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll('é', 'e')
        .replaceAll('ë', 'e');
  }

  Future<void> uploadAndAssignLogos() async {
    setState(() {
      isUploading = true;
      results.clear();
    });

    for (String brand in carBrands) {
      final logoFileName = '${_normalizeBrandName(brand)}.png';
      final localPath = 'assets/car_logos/$logoFileName';

      try {
        final byteData = await rootBundle.load(localPath);
        final storageRef = _storage.ref('car_logos/$logoFileName');
        await storageRef.putData(byteData.buffer.asUint8List());

        final downloadUrl = await storageRef.getDownloadURL();

        // Actualizar Firestore
        await _firestore.collection('marcas').doc(brand).update({
          'logo': downloadUrl,
        });

        results[brand] = '✅ Subido y asignado';
      } catch (e) {
        results[brand] = '❌ Error: ${e.toString()}';
      }

      setState(() {}); // Actualiza la UI después de cada iteración
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir logos de marcas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isUploading ? null : uploadAndAssignLogos,
              child: Text(
                isUploading ? 'Subiendo...' : 'Subir y asignar logos',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children:
                    results.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text(entry.value),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
