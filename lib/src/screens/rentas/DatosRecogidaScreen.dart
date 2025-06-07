import 'package:flutter/material.dart';
import 'package:solutions_rent_car/src/screens/rentas/ConfirmacionReservaScreen.dart';

class DatosRecogidaScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculoData;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String nombreCliente;
  final String telefono;

  const DatosRecogidaScreen({
    super.key,
    required this.vehiculoData,
    required this.startDateTime,
    required this.endDateTime,
    required this.nombreCliente,
    required this.telefono,
  });

  @override
  State<DatosRecogidaScreen> createState() => _DatosRecogidaScreenState();
}

class _DatosRecogidaScreenState extends State<DatosRecogidaScreen> {
  String? selectedDeliveryKey;
  String? selectedPickupKey;

  final Map<String, Map<String, String>> opcionesEntrega = {
    'entrega_local': {
      'title': 'Recogida en el local',
      'subtitle': 'Le enviaremos la ubicación exacta una vez reservado',
      'price': 'Gratis',
    },
    'aeropuerto_cibao': {
      'title': 'Aeropuerto Internacional de Cibao',
      'subtitle': 'Airport',
      'price': 'Gratis',
    },
    'aeropuerto_americas': {
      'title': 'Aeropuerto Internacional Las Americas',
      'subtitle': 'Airport',
      'price': '\$100',
    },
  };

  final Map<String, Map<String, String>> opcionesRecogida = {
    'recogida_local': {
      'title': 'Entrega en el local',
      'subtitle': '',
      'price': '\$120',
    },
    'recogida_cibao': {
      'title': 'Aeropuerto Internacional de Cibao',
      'subtitle': 'Airport',
      'price': 'Gratis',
    },
    'recogida_americas': {
      'title': 'Aeropuerto Internacional Las Americas',
      'subtitle': 'Airport',
      'price': '\$100',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Seleccione Recogida y Retorno'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('Mapa aquí')),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lugares de entrega',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...opcionesEntrega.entries.map(
                      (entry) => _buildOptionCard(
                        keyValue: entry.key,
                        isDelivery: true,
                        title: entry.value['title']!,
                        subtitle: entry.value['subtitle']!,
                        price: entry.value['price']!,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lugares de recogida',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...opcionesRecogida.entries.map(
                      (entry) => _buildOptionCard(
                        keyValue: entry.key,
                        isDelivery: false,
                        title: entry.value['title']!,
                        subtitle: entry.value['subtitle']!,
                        price: entry.value['price']!,
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDeliveryKey != null &&
                        selectedPickupKey != null) {
                      final lugarEntrega =
                          opcionesEntrega[selectedDeliveryKey!]!['title']!;
                      final lugarRecogida =
                          opcionesRecogida[selectedPickupKey!]!['title']!;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ConfirmacionReservaScreen(
                                vehiculoData: widget.vehiculoData,
                                startDateTime: widget.startDateTime,
                                endDateTime: widget.endDateTime,
                                deliveryOption: selectedDeliveryKey!,
                                pickupOption: selectedPickupKey!,
                                nombreCliente: widget.nombreCliente,
                                telefono: widget.telefono,
                                lugarEntrega: lugarEntrega,
                                lugarRecogida: lugarRecogida,
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor seleccione las opciones de entrega y recogida',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String keyValue,
    required bool isDelivery,
    required String title,
    required String subtitle,
    required String price,
  }) {
    // Crear identificadores únicos para evitar conflictos entre grupos
    final uniqueValue = isDelivery ? 'delivery_$keyValue' : 'pickup_$keyValue';
    final currentGroupValue =
        isDelivery
            ? (selectedDeliveryKey != null
                ? 'delivery_$selectedDeliveryKey'
                : null)
            : (selectedPickupKey != null ? 'pickup_$selectedPickupKey' : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isDelivery) {
              selectedDeliveryKey = keyValue;
            } else {
              selectedPickupKey = keyValue;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Radio<String>(
                value: uniqueValue,
                groupValue: currentGroupValue,
                onChanged: (value) {
                  setState(() {
                    if (isDelivery) {
                      selectedDeliveryKey = keyValue;
                    } else {
                      selectedPickupKey = keyValue;
                    }
                  });
                },
                activeColor: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
