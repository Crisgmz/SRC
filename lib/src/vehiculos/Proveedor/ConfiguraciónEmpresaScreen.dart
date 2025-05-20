import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionEmpresaScreen extends StatelessWidget {
  final String userId;

  const ConfiguracionEmpresaScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FD),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('usuarios').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró información del vendedor.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['name'] ?? 'Nombre del vendedor',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['phone'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTile(
                context,
                Icons.lock_outline,
                "Cambiar contraseña",
                onTap: () {},
              ),
              _buildTile(
                context,
                Icons.person_outline,
                "Editar perfil",
                onTap: () {},
              ),
              _buildTile(
                context,
                Icons.support_agent,
                "Contactar soporte",
                onTap: () {},
              ),
              _buildTile(context, Icons.language, "Idioma", onTap: () {}),
              _buildTile(
                context,
                Icons.delete_forever_outlined,
                "Eliminar cuenta",
                color: Colors.red,
                onTap: () {},
              ),
              const Divider(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () {
                    // Aquí pones tu lógica de logout
                  },
                  icon: const Icon(Icons.logout, color: Colors.deepPurple),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.deepPurple),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
