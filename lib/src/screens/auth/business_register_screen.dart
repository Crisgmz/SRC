import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  _BusinessRegisterScreenState createState() => _BusinessRegisterScreenState();
}

final _passwordController = TextEditingController();

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Datos de la "Cuenta de acceso"
  String ownerName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';

  // "Información del negocio"
  String businessName = '';
  String clothingType = '';
  String businessDescription = '';
  String categoriesInput = '';

  // "Información legal"
  String? rnc;
  String legalAddress = '';

  // "Datos para recibir pagos"
  String bankName = '';
  String accountType = '';
  String accountNumber = '';
  String accountHolderName = '';
  String accountHolderID = '';

  // "Información de envío"
  String shippingZones = '';
  String deliveryTime = '';
  String shippingCost = '';
  String returnPolicy = '';

  // "Ubicación" (opcional)
  String storeAddress = '';
  String geolocation = '';

  // Estilos personalizados
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  final TextStyle _subtitleStyle = const TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Negocio',
          style: _titleStyle.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Stepper personalizado CENTRADO
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    // Envuelve el stepper en un Center
                    child: SizedBox(
                      height: 60,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(5, (index) {
                          return Row(
                            children: [
                              if (index > 0)
                                Container(
                                  width: 30,
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              InkWell(
                                onTap: () {
                                  if (index < _currentStep) {
                                    setState(() => _currentStep = index);
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentStep >= index
                                            ? const Color(0xFF4361EE)
                                            : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          _currentStep >= index
                                              ? Colors.white
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contenido del paso actual
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(_currentStep),
                ),

                // Botones de navegación
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep != 0)
                        OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            side: const BorderSide(color: Color(0xFF4361EE)),
                          ),
                          child: Text(
                            'Atrás',
                            style: TextStyle(
                              color: Color(0xFF4361EE),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4361EE),
                          minimumSize: const Size(120, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _currentStep == 4 ? 'Enviar' : 'Siguiente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildBusinessStep();
      case 2:
        return _buildLegalStep();
      case 3:
        return _buildPaymentStep();
      case 4:
        return _buildShippingStep();
      default:
        return Container();
    }
  }

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información de acceso', style: _titleStyle),
        const SizedBox(height: 8),
        Text(
          'Crea tus credenciales para ingresar a la plataforma',
          style: _subtitleStyle,
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: const Icon(Icons.person),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => ownerName = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(Icons.email),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          keyboardType: TextInputType.emailAddress,
          validator:
              (value) =>
                  value == null || !value.contains('@')
                      ? 'Correo inválido'
                      : null,
          onSaved: (value) => email = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          obscureText: true,
          validator:
              (value) =>
                  value == null || value.length < 6
                      ? 'Mínimo 6 caracteres'
                      : null,
          onSaved: (value) => password = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requerido';
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
          onSaved: (value) => confirmPassword = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Número de teléfono',
            prefixIcon: const Icon(Icons.phone),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          keyboardType: TextInputType.phone,
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => phone = value!.trim(),
        ),
      ],
    );
  }

  Widget _buildBusinessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información del negocio', style: _titleStyle),
        const SizedBox(height: 8),
        Text('Describe los detalles de tu negocio', style: _subtitleStyle),
        const SizedBox(height: 24),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre del negocio',
            prefixIcon: const Icon(Icons.store),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => businessName = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Tipo de ropa que vende',
            prefixIcon: const Icon(Icons.style),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => clothingType = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Descripción del negocio',
            prefixIcon: const Icon(Icons.description),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          maxLines: 3,
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => businessDescription = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Categorías (separadas por comas)',
            prefixIcon: const Icon(Icons.category),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => categoriesInput = value!.trim(),
        ),
      ],
    );
  }

  Widget _buildLegalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información legal', style: _titleStyle),
        const SizedBox(height: 8),
        Text(
          'Proporciona los datos legales de tu negocio',
          style: _subtitleStyle,
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'RNC o Registro (opcional)',
            prefixIcon: const Icon(Icons.article_outlined),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => rnc = value?.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Dirección física',
            prefixIcon: const Icon(Icons.location_on),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => legalAddress = value!.trim(),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información de pagos', style: _titleStyle),
        const SizedBox(height: 8),
        Text('Configura cómo recibirás los pagos', style: _subtitleStyle),
        const SizedBox(height: 24),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre del banco',
            prefixIcon: const Icon(Icons.account_balance),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => bankName = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Tipo de cuenta (ahorros, corriente)',
            prefixIcon: const Icon(Icons.credit_card),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => accountType = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Número de cuenta',
            prefixIcon: const Icon(Icons.numbers),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => accountNumber = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre del titular',
            prefixIcon: const Icon(Icons.person_outline),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => accountHolderName = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Identificación del titular',
            prefixIcon: const Icon(Icons.badge),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => accountHolderID = value!.trim(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // Lógica para conectar con la pasarela de pago
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              side: const BorderSide(color: Color(0xFF4361EE)),
            ),
            icon: const Icon(Icons.payment, color: Color(0xFF4361EE)),
            label: Text(
              'Conectar Pasarela de Pago',
              style: TextStyle(color: Color(0xFF4361EE)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configuración de envíos', style: _titleStyle),
        const SizedBox(height: 8),
        Text(
          'Define cómo manejarás los envíos a tus clientes',
          style: _subtitleStyle,
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Zonas de entrega',
            prefixIcon: const Icon(Icons.local_shipping),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => shippingZones = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Tiempo estimado de entrega',
            prefixIcon: const Icon(Icons.timer),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => deliveryTime = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Costo de envío',
            prefixIcon: const Icon(Icons.attach_money),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
          onSaved: (value) => shippingCost = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Política de cambios o devoluciones',
            prefixIcon: const Icon(Icons.policy),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          maxLines: 3,
          onSaved: (value) => returnPolicy = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Dirección de la tienda (opcional)',
            prefixIcon: const Icon(Icons.store_mall_directory),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => storeAddress = value!.trim(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Geolocalización (lat, long)',
            prefixIcon: const Icon(Icons.map),
            border: _inputBorder,
            focusedBorder: _focusedBorder,
          ),
          onSaved: (value) => geolocation = value!.trim(),
        ),
      ],
    );
  }

  // Reemplaza la función _nextStep actual con esta versión actualizada
  void _nextStep() async {
    final isLastStep = _currentStep == 4;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (isLastStep) {
        try {
          // Mostrar indicador de carga
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );

          // 1. Crear usuario en Firebase Authentication
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          String userId = userCredential.user!.uid;

          // 2. Crear colección de tiendas en Firestore
          await FirebaseFirestore.instance
              .collection('tiendas')
              .doc(userId)
              .set({
                // Información del negocio
                "nombreNegocio": businessName,
                "tipoRopa": clothingType,
                "descripcion": businessDescription,
                "categorias":
                    categoriesInput.split(',').map((e) => e.trim()).toList(),

                // Información legal
                "rnc": rnc,
                "direccionLegal": legalAddress,

                // Información de envío
                "zonasEntrega": shippingZones,
                "tiempoEntrega": deliveryTime,
                "costoEnvio": shippingCost,
                "politicaDevolucion": returnPolicy,
                "direccionTienda": storeAddress,
                "geolocalizacion": geolocation,

                // Información de pagos
                "datosBancarios": {
                  "banco": bankName,
                  "tipoCuenta": accountType,
                  "numeroCuenta": accountNumber,
                  "nombreTitular": accountHolderName,
                  "idTitular": accountHolderID,
                },

                // Metadatos
                "fechaCreacion": FieldValue.serverTimestamp(),
                "usuarioId": userId,
                "estadoTienda":
                    "pendiente", // Para aprobación por administrador
              });

          // 3. Crear colección de usuarios en Firestore
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userId)
              .set({
                "nombreCompleto": ownerName,
                "email": email,
                "telefono": phone,
                "rol": "vendedor", // Roles: cliente, vendedor, admin
                "tiendaId": userId, // Referencia a la tienda
                "fechaRegistro": FieldValue.serverTimestamp(),
                "ultimoAcceso": FieldValue.serverTimestamp(),
                "activo": true,
              });

          // Cerrar diálogo de carga
          Navigator.pop(context);

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro completado con éxito!'),
              backgroundColor: Colors.green,
            ),
          );

          // Redirigir a la página de inicio o dashboard
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          // Cerrar diálogo de carga si hay error
          Navigator.pop(context);

          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _currentStep += 1);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }
}
