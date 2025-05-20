import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CrearVehiculoScreen extends StatefulWidget {
  const CrearVehiculoScreen({super.key});

  @override
  State<CrearVehiculoScreen> createState() => _CrearVehiculoScreenState();
}

class _CrearVehiculoScreenState extends State<CrearVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController placaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController precioPorDiaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController pasajerosController = TextEditingController();

  bool disponible = true;
  List<File> imagenesSeleccionadas = [];
  List<String> imagenesUrl = [];
  final picker = ImagePicker();

  String? marcaSeleccionada;
  String? modeloSeleccionado;
  String? transmisionSeleccionada;
  String? combustibleSeleccionado;

  Map<String, dynamic> marcasModelos = {};

  @override
  void initState() {
    super.initState();
    cargarMarcasYModelos();
  }

  Future<void> cargarMarcasYModelos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('marcas').get();
    Map<String, dynamic> temp = {};
    for (var doc in snapshot.docs) {
      temp[doc['marca']] = List<String>.from(doc['modelos']);
    }
    setState(() {
      marcasModelos = temp;
    });
  }

  Future<void> seleccionarImagen() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imagenesSeleccionadas = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<String?> subirImagen(File imagen) async {
    try {
      String nombreArchivo =
          'vehiculos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(nombreArchivo);
      await ref.putFile(imagen);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    for (var img in imagenesSeleccionadas) {
      String? url = await subirImagen(img);
      if (url != null) imagenesUrl.add(url);
    }

    String idGenerado = 'VEH${DateTime.now().millisecondsSinceEpoch}';

    final vehiculo = {
      'idVehiculo': idGenerado,
      'placa': placaController.text,
      'nombre': nombreController.text,
      'marca': marcaSeleccionada ?? '',
      'modelo': modeloSeleccionado ?? '',
      'anio': int.tryParse(anioController.text) ?? 0,
      'precioPorDia': double.tryParse(precioPorDiaController.text) ?? 0.0,
      'descripcion': descripcionController.text,
      'transmision': transmisionSeleccionada ?? '',
      'pasajeros': int.tryParse(pasajerosController.text) ?? 0,
      'combustible': combustibleSeleccionado ?? '',
      'imagenes': imagenesUrl,
      'calificacion': 0.0,
      'totalReservas': 0,
      'disponible': disponible,
      'fechaCreacion': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('vehiculos').add(vehiculo);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ Vehículo guardado: $idGenerado')));

    _formKey.currentState?.reset();
    setState(() {
      imagenesSeleccionadas = [];
      imagenesUrl = [];
      disponible = true;
      marcaSeleccionada = null;
      modeloSeleccionado = null;
      transmisionSeleccionada = null;
      combustibleSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Vehículo 🚗'),
        backgroundColor: Colors.indigo[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InfoInputField(hint: 'Placa', controller: placaController),
              InfoInputField(hint: 'Nombre', controller: nombreController),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: marcaSeleccionada,
                      items:
                          marcasModelos.keys.map((marca) {
                            return DropdownMenuItem(
                              value: marca,
                              child: Text(marca),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          marcaSeleccionada = value;
                          modeloSeleccionado = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value == null ? 'Selecciona una marca' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: modeloSeleccionado,
                      items:
                          marcaSeleccionada == null
                              ? []
                              : List<String>.from(
                                marcasModelos[marcaSeleccionada]!,
                              ).map((modelo) {
                                return DropdownMenuItem(
                                  value: modelo,
                                  child: Text(modelo),
                                );
                              }).toList(),
                      onChanged: (value) {
                        setState(() {
                          modeloSeleccionado = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value == null ? 'Selecciona un modelo' : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InfoInputField(
                      hint: 'Año',
                      controller: anioController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoInputField(
                      hint: 'Precio por Día',
                      controller: precioPorDiaController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              InfoInputField(
                hint: 'Descripción',
                controller: descripcionController,
                isMultiLine: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: transmisionSeleccionada,
                      items:
                          ['Automática', 'Manual'].map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => transmisionSeleccionada = value),
                      decoration: const InputDecoration(
                        labelText: 'Transmisión',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value == null
                                  ? 'Selecciona una transmisión'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: combustibleSeleccionado,
                      items:
                          ['Gasolina', 'Gasoil', 'Gas (GLP)'].map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => combustibleSeleccionado = value),
                      decoration: const InputDecoration(
                        labelText: 'Combustible',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value == null
                                  ? 'Selecciona un tipo de combustible'
                                  : null,
                    ),
                  ),
                ],
              ),
              InfoInputField(
                hint: 'Capacidad de Pasajeros',
                controller: pasajerosController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    onPressed: seleccionarImagen,
                    label: const Text('Subir Imágenes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${imagenesSeleccionadas.length} imagen(es) seleccionada(s)',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Disponible'),
                value: disponible,
                onChanged: (value) {
                  setState(() {
                    disponible = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: guardarVehiculo,
                  label: const Text(
                    'Guardar Vehículo',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoInputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isMultiLine;

  const InfoInputField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: isMultiLine ? 5 : 1,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF4F6FC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCED4DA), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
