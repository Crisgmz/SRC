import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solutions_rent_car/src/utils/cache_service.dart';
import 'package:shimmer/shimmer.dart';

class AgregarNuevoVehiculoScreen extends StatefulWidget {
  const AgregarNuevoVehiculoScreen({super.key});
  @override
  State<AgregarNuevoVehiculoScreen> createState() =>
      _AgregarNuevoVehiculoScreenState();
}

class _AgregarNuevoVehiculoScreenState
    extends State<AgregarNuevoVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController pasajerosController = TextEditingController();

  bool disponible = true;
  bool destacado = false;
  bool verificado = true;
  List<File> imagenesSeleccionadas = [];
  String? marcaSeleccionada;
  String? modeloSeleccionado;
  String? transmisionSeleccionada;
  String? combustibleSeleccionado;
  String? colorSeleccionado;
  String? tipoVehiculoSeleccionado;

  Map<String, dynamic> marcasModelos = {};
  final List<String> coloresDisponibles = [
    'Negro',
    'Blanco',
    'Gris',
    'Rojo',
    'Azul',
    'Verde',
    'Amarillo',
    'Plateado',
    'Marrón',
    'Beige',
  ];

  bool _isLoading = true;
  final Color primaryColor = const Color(0xFFF8A023);
  final Color iconBorderColor = const Color(0xFF9DB2CE);
  final Color textColor = const Color(0xFF6B7280);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    cargarMarcasYModelos();
  }

  Future<void> cargarMarcasYModelos() async {
    final snapshot =
        await CacheService.getCollection('marcas');

    if (snapshot.docs.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    Map<String, dynamic> temp = {};
    for (var doc in snapshot.docs) {
      temp[doc['marca']] = List<String>.from(doc['modelos']);
    }

    setState(() {
      marcasModelos = temp;
      _isLoading = false;
    });
  }

  Future<void> seleccionarImagen() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imagenesSeleccionadas = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<List<String>> subirImagenes() async {
    List<String> urls = [];
    for (var imagen in imagenesSeleccionadas) {
      final ref = FirebaseStorage.instance.ref().child(
        'vehiculos/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(imagen);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;
    if (imagenesSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una imagen')),
      );
      return;
    }

    final imagenesUrl = await subirImagenes();
    final idVehiculo = 'VEH${DateTime.now().millisecondsSinceEpoch}';
    await FirebaseFirestore.instance.collection('vehiculos').add({
      'idVehiculo': idVehiculo,
      'nombre': nombreController.text,
      'marca': marcaSeleccionada ?? '',
      'modelo': modeloSeleccionado ?? '',
      'placa': placaController.text,
      'anio': int.tryParse(anioController.text),
      'precioPorDia': double.tryParse(precioController.text),
      'descripcion': descripcionController.text,
      'transmision': transmisionSeleccionada ?? '',
      'combustible': combustibleSeleccionado ?? '',
      'pasajeros': int.tryParse(pasajerosController.text),
      'color': colorSeleccionado ?? '',
      'disponible': disponible,
      'destacado': destacado,
      'verificado': verificado,
      'imagenes': imagenesUrl,
      'vistas': 0,
      'calificacion': 0.0,
      'totalReservas': 0,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehículo agregado correctamente')),
    );

    Navigator.pop(context);
  }

  Widget buildInput(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 18.0 : 18.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: iconBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: iconBorderColor),
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: textColor)),
                  ),
                )
                .toList(),
        onChanged: _isLoading ? null : onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: iconBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: iconBorderColor),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget shimmerEffect(Widget child) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Agregar nuevo vehículo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor, // Usa tu color naranja definido
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInput('Nombre del vehículo', nombreController),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: shimmerEffect(
                          buildDropdown(
                            label: 'Marca',
                            value: marcaSeleccionada,
                            items: marcasModelos.keys.toList(),
                            onChanged: (value) {
                              if (value != null && value != 'Elegir Marca') {
                                setState(() {
                                  marcaSeleccionada = value;
                                  modeloSeleccionado = null;
                                });
                              } else {
                                setState(() {
                                  marcaSeleccionada = null;
                                  modeloSeleccionado = null;
                                });
                              }
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Selecciona una marca'
                                        : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: shimmerEffect(
                          buildDropdown(
                            label: 'Modelo',
                            value: modeloSeleccionado,
                            items:
                                marcaSeleccionada == null
                                    ? []
                                    : List<String>.from(
                                      marcasModelos[marcaSeleccionada]!,
                                    ),
                            onChanged: (value) {
                              setState(() => modeloSeleccionado = value);
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Selecciona un modelo'
                                        : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: buildInput('Placa', placaController)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInput(
                          'Año',
                          anioController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildInput(
                          'Precio por día',
                          precioController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInput(
                          'Pasajeros',
                          pasajerosController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: shimmerEffect(
                          buildDropdown(
                            label: 'Color',
                            value: colorSeleccionado,
                            items: coloresDisponibles,
                            onChanged:
                                (value) =>
                                    setState(() => colorSeleccionado = value),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Selecciona un color'
                                        : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildDropdown(
                          label: 'Tipo de Vehículo',
                          value: tipoVehiculoSeleccionado,
                          items: [
                            'SUV',
                            'Full Size SUV',
                            'Sedán',
                            'Camioneta',
                            'Todoterreno',
                            'Pickup',
                            'Deportivo',
                            'Hatchback',
                            'Convertible',
                            'Van',
                          ],
                          onChanged:
                              (value) => setState(
                                () => tipoVehiculoSeleccionado = value,
                              ),
                          validator:
                              (value) =>
                                  value == null ? 'Selecciona un tipo' : null,
                        ),
                      ),
                    ],
                  ),

                  buildInput('Descripción', descripcionController, maxLines: 3),

                  Row(
                    children: [
                      Expanded(
                        child: buildDropdown(
                          label: 'Transmisión',
                          value: transmisionSeleccionada,
                          items: ['Automática', 'Manual'],
                          onChanged:
                              (value) => setState(
                                () => transmisionSeleccionada = value,
                              ),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Selecciona una transmisión'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildDropdown(
                          label: 'Combustible',
                          value: combustibleSeleccionado,
                          items: ['Gasolina', 'Gasoil', 'Gas (GLP)'],
                          onChanged:
                              (value) => setState(
                                () => combustibleSeleccionado = value,
                              ),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Selecciona un combustible'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        imagenesSeleccionadas
                            .map(
                              (img) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    img,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : seleccionarImagen,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Agregar fotos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    color: Colors.grey.shade50,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            '¿Disponible para renta?',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: disponible,
                          onChanged: (v) => setState(() => disponible = v),
                          activeColor: primaryColor,
                        ),
                        SwitchListTile(
                          title: const Text(
                            '¿Destacado (Rentas populares)?',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: destacado,
                          onChanged: (v) => setState(() => destacado = v),
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: _isLoading ? null : guardarVehiculo,
                      label: const Text(
                        'Guardar Vehículo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
