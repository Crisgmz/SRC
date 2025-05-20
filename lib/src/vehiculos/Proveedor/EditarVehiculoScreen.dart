import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class EditarVehiculoScreen extends StatefulWidget {
  final String idVehiculo;

  const EditarVehiculoScreen({super.key, required this.idVehiculo});

  @override
  State<EditarVehiculoScreen> createState() => _EditarVehiculoScreenState();
}

class _EditarVehiculoScreenState extends State<EditarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController transmisionController = TextEditingController();
  final TextEditingController combustibleController = TextEditingController();
  final TextEditingController pasajerosController = TextEditingController();

  bool disponible = true;
  bool cargando = true;
  List<String> imagenes = [];

  @override
  void initState() {
    super.initState();
    cargarDatosVehiculo();
  }

  Future<void> cargarDatosVehiculo() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('vehiculos')
            .doc(widget.idVehiculo)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      marcaController.text = data['marca'] ?? '';
      modeloController.text = data['modelo'] ?? '';
      anioController.text = (data['anio'] ?? '').toString();
      precioController.text = (data['precioPorDia'] ?? '').toString();
      descripcionController.text = data['descripcion'] ?? '';
      transmisionController.text = data['transmision'] ?? '';
      combustibleController.text = data['combustible'] ?? '';
      pasajerosController.text = (data['pasajeros'] ?? '').toString();
      disponible = data['disponible'] ?? true;
      imagenes = List<String>.from(data['imagenes'] ?? []);
    }
    setState(() => cargando = false);
  }

  Future<void> eliminarImagen(int index) async {
    setState(() {
      imagenes.removeAt(index);
    });
  }

  Future<void> agregarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'vehiculos/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      setState(() {
        imagenes.add(url);
      });
    }
  }

  Future<void> guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(widget.idVehiculo)
          .update({
            'nombre': nombreController.text,
            'marca': marcaController.text,
            'modelo': modeloController.text,
            'anio': int.tryParse(anioController.text),
            'precioPorDia': double.tryParse(precioController.text),
            'descripcion': descripcionController.text,
            'transmision': transmisionController.text,
            'combustible': combustibleController.text,
            'pasajeros': int.tryParse(pasajerosController.text),
            'disponible': disponible,
            'imagenes': imagenes,
          });
      Navigator.pop(context);
    }
  }

  Widget shimmerPlaceholder() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 230,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          6,
          (index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCED4DA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body:
          cargando
              ? shimmerPlaceholder()
              : Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput('Nombre', nombreController),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput('Marca', marcaController),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput('Modelo', modeloController),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput(
                              'Año',
                              anioController,
                              type: TextInputType.number,
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput(
                              'Precio por Día',
                              precioController,
                              type: TextInputType.number,
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput(
                              'Pasajeros',
                              pasajerosController,
                              type: TextInputType.number,
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput(
                              'Transmisión',
                              transmisionController,
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                            child: buildInput(
                              'Combustible',
                              combustibleController,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: descripcionController,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFCED4DA),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obligatorio'
                                      : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Imágenes del vehículo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (int i = 0; i < imagenes.length; i++)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imagenes[i],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => eliminarImagen(i),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          GestureDetector(
                            onTap: agregarImagen,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text('Disponible para renta'),
                        value: disponible,
                        onChanged:
                            (value) => setState(() => disponible = value),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: guardarCambios,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar cambios'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
