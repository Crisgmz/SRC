import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/utils/cache_service.dart';
import 'package:solutions_rent_car/src/screens/home/ClientHomeScreen.dart';
import 'package:solutions_rent_car/src/screens/home/SellerHomeScreen.dart';
import 'package:flutter/foundation.dart'; // asegúrate de tener esto

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isEmailSelected = true;
  String _selectedCountryCode = '+1';
  bool _isLoading = false; // Estado de carga añadido

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    required double screenWidth,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: screenWidth * 0.04,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 255, 155, 38),
          width: screenWidth * 0.005,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.04,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: screenHeight * 0.05),

                Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: screenWidth * 0.02),

                Text(
                  'Bienvenidos a Solutions Rent Car',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: screenWidth * 0.08),

                Row(
                  children: [
                    _buildLoginTab('Email', true, screenWidth),
                    SizedBox(width: screenWidth * 0.05),
                    _buildLoginTab('Teléfono', false, screenWidth),
                  ],
                ),

                SizedBox(height: screenWidth * 0.05),

                _isEmailSelected
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration(
                            hintText: 'hola@ejemplo.com',
                            screenWidth: screenWidth,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                          validator: (value) {
                            if (_isEmailSelected &&
                                (value == null || value.isEmpty)) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!value!.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Número de teléfono',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenWidth * 0.035,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                underline: const SizedBox(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black87,
                                ),
                                items:
                                    ['+1', '+52', '+57', '+34'].map((code) {
                                      return DropdownMenuItem(
                                        value: code,
                                        child: Text(code),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountryCode = value!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration(
                                  hintText: 'Número de teléfono',
                                  screenWidth: screenWidth,
                                ),
                                keyboardType: TextInputType.phone,
                                style: TextStyle(fontSize: screenWidth * 0.04),
                                validator: (value) {
                                  if (!_isEmailSelected &&
                                      (value == null || value.isEmpty)) {
                                    return 'Por favor ingresa tu número';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                SizedBox(height: screenWidth * 0.03),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navegar a recuperación de contraseña
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 155, 38),
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),

                //               SizedBox(height: screenWidth * 0.02),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                  decoration: _inputDecoration(
                    hintText: '•••••••••••••',
                    screenWidth: screenWidth,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[500],
                        size: screenWidth * 0.05,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                ),

                SizedBox(height: screenWidth * 0.05),

                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        activeColor: const Color.fromARGB(255, 254, 155, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.01,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Mantener sesión iniciada',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.05),
                // Botón de inicio de sesión con indicador de carga
                SizedBox(
                  height: screenWidth * 0.14,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 155, 38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.07),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.06),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Text(
                          'o inicia sesión con',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenWidth * 0.12,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.public, size: screenWidth * 0.06),
                    ),
                    label: Text(
                      'Continuar con Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.07),
                      ),
                      side: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.03),

                Center(
                  child: TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.pushNamed(context, '/register');
                            },
                    child: Text(
                      'Crear una cuenta',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 155, 38),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(String title, bool isEmailTab, double screenWidth) {
    final isActive =
        (title == 'Email' && _isEmailSelected) ||
        (title == 'Teléfono' && !_isEmailSelected);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEmailSelected = title == 'Email';
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.w500,
              color:
                  isActive
                      ? const Color.fromARGB(255, 255, 155, 38)
                      : Colors.grey,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Container(
            height: screenWidth * 0.005,
            width: screenWidth * 0.16,
            color:
                isActive
                    ? const Color.fromARGB(255, 255, 155, 38)
                    : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // Método para iniciar sesión con correo/teléfono y contraseña
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga
      });

      final valorLogin =
          _isEmailSelected
              ? _emailController.text.trim()
              : '$_selectedCountryCode${_phoneController.text.trim()}';
      final contrasena = _passwordController.text.trim();

      try {
        UserCredential credencial;

        if (_isEmailSelected) {
          // Inicio de sesión con correo electrónico
          credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: valorLogin,
            password: contrasena,
          );
        } else {
          // Para iniciar sesión con teléfono, se debería implementar el flujo completo de autenticación por teléfono
          // Esto es solo un placeholder para mantener la compatibilidad con tu implementación actual
          // En una app real deberías usar verifyPhoneNumber y el flujo de verificación por SMS
          credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email:
                valorLogin, // En realidad, deberías usar autenticación por teléfono
            password: contrasena,
          );
        }

        final userId = credencial.user?.uid;
        if (userId == null) {
          throw Exception('No se encontró el usuario');
        }

        // Verificar si se debe mantener la sesión iniciada
        if (kIsWeb) {
          if (_rememberMe) {
            await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
          } else {
            await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
          }
        }

        // Obtener el rol del usuario desde Firestore
        final documentoUsuario = await CacheService.getDocument(
          'usuarios',
          userId,
        );

        if (!documentoUsuario.exists) {
          throw Exception('El usuario no existe en la base de datos');
        }

        final datosUsuario = documentoUsuario.data();
        final rol = datosUsuario?['role']?.toString().trim();

        print('Rol obtenido: $rol');

        // Comparación de roles insensible a mayúsculas/minúsculas
        if (rol?.toLowerCase() == 'cliente') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
          );
        } else if (rol?.toLowerCase() == 'vendedor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          );
        } else {
          throw Exception('Rol no válido: $rol');
        }
      } on FirebaseAuthException catch (e) {
        String mensaje = 'Ocurrió un error';

        switch (e.code) {
          case 'user-not-found':
            mensaje = 'No existe una cuenta con este correo o número';
            break;
          case 'wrong-password':
            mensaje = 'Contraseña incorrecta';
            break;
          case 'invalid-credential':
            mensaje = 'Credenciales inválidas';
            break;
          case 'too-many-requests':
            mensaje = 'Demasiados intentos fallidos. Intenta más tarde';
            break;
          case 'user-disabled':
            mensaje = 'Esta cuenta ha sido desactivada';
            break;
          case 'invalid-email':
            mensaje = 'El formato del correo electrónico es inválido';
            break;
          default:
            mensaje = 'Error de autenticación: ${e.code}';
        }

        _mostrarMensajeError(mensaje);
      } catch (e) {
        _mostrarMensajeError('Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Ocultar indicador de carga
          });
        }
      }
    }
  }

  // Método para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí deberías implementar la autenticación con Google
      // Este es un método placeholder - necesitarás implementar la autenticación real con Google
      // Usando firebase_auth_oauth o google_sign_in

      // Ejemplo de implementación:
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth?.accessToken,
      //   idToken: googleAuth?.idToken,
      // );
      // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Por ahora, solo mostramos un mensaje
      _mostrarMensajeError('Funcionalidad de Google Sign-In no implementada');
    } catch (e) {
      _mostrarMensajeError(
        'Error al iniciar sesión con Google: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método auxiliar para mostrar mensajes de error
  void _mostrarMensajeError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
