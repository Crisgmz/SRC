import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  _ClientRegisterScreenState createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';
  String? shippingAddress;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFF4361EE);

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

  TextStyle get _buttonStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registro de Cliente', style: _titleStyle),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: _inputDecoration('Nombre completo'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => name = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _inputDecoration('Correo electrónico'),
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
                  controller: passwordController,
                  decoration: _inputDecoration('Contraseña'),
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
                  controller: confirmPasswordController,
                  decoration: _inputDecoration('Confirmar contraseña'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (value != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onSaved: (value) => confirmPassword = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _inputDecoration('Número de teléfono'),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => phone = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _inputDecoration(
                    'Dirección principal de envío (opcional)',
                  ),
                  onSaved: (value) => shippingAddress = value?.trim(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: isLoading ? null : _register,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text('Registrarse', style: _buttonStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final uid = userCredential.user!.uid;

        // Guardar datos generales
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'Cliente',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Guardar datos del cliente
        await FirebaseFirestore.instance.collection('clientes').doc(uid).set({
          'shippingAddress': shippingAddress ?? '',
          'uid': uid,
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Registro exitoso!')));
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }
}
