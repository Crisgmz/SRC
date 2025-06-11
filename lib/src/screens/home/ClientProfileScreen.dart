import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solutions_rent_car/src/screens/auth/login_screen.dart';

class PantallaPerfilCliente extends StatefulWidget {
  const PantallaPerfilCliente({super.key});

  @override
  State<PantallaPerfilCliente> createState() => _PantallaPerfilClienteState();
}

class _PantallaPerfilClienteState extends State<PantallaPerfilCliente> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();
    setState(() {
      userData = doc.data();
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(251, 140, 0, 1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/300",
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userData?['name'] ?? 'Nombre',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _opcionPerfil(Icons.person, "Mi perfil"),
                        _opcionPerfil(Icons.receipt_long, "Mis reservaciones"),
                        _opcionPerfil(Icons.settings, "Configuración"),
                        _opcionPerfil(Icons.help_outline, "Centro de ayuda"),
                        _opcionPerfil(
                          Icons.privacy_tip,
                          "Política de privacidad",
                        ),
                        _infoAdicional("Teléfono", userData?['phone']),
                        _infoAdicional(
                          "Fecha de registro",
                          userData?['createdAt'] != null
                              ? DateFormat('dd MMM yyyy, h:mm a', 'es').format(
                                (userData?['createdAt'] as Timestamp).toDate(),
                              )
                              : 'Desconocido',
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Cerrar sesión"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _opcionPerfil(IconData icono, String texto) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icono, color: Colors.blue),
      title: Text(texto, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {}, // Acción futura
    );
  }

  Widget _infoAdicional(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$titulo:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              valor ?? 'No disponible',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
