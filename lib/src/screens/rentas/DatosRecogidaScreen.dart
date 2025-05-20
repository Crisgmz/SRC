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
  int? selectedDeliveryOption;
  int? selectedPickupOption;

  final List<String> opcionesEntrega = [
    'Recogida en el lugar del coche',
    'Aeropuerto Internacional de Cibao',
    'Aeropuerto Internacional Las Americas',
    'Entrega a Domicilio',
  ];

  final List<String> opcionesRecogida = ['Introduzca su Lugar de recogida'];

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
          // Mapa
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('Mapa aquí')),
          ),

          // Contenido scrollable
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

                    // Opciones de entrega
                    _buildOptionCard(
                      index: 0,
                      isDelivery: true,
                      title: 'Recogida en el lugar del coche',
                      subtitle:
                          'Le enviaremos la ubicación exacta una vez reservado',
                      price: 'Free',
                    ),
                    _buildOptionCard(
                      index: 1,
                      isDelivery: true,
                      title: 'Aeropuerto Internacional de Cibao',
                      subtitle: 'Airport',
                      price: '\$120',
                    ),
                    _buildOptionCard(
                      index: 2,
                      isDelivery: true,
                      title: 'Aeropuerto Internacional Las Americas',
                      subtitle: 'Airport',
                      price: '\$120',
                    ),
                    _buildOptionCard(
                      index: 3,
                      isDelivery: true,
                      title: 'Entrega a Domicilio',
                      subtitle: 'Casa del cliente',
                      price: '\$120',
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

                    // Opciones de recogida
                    _buildOptionCard(
                      index: 0,
                      isDelivery: false,
                      title: 'Introduzca su Lugar de recogida',
                      subtitle: '',
                      price: '\$120',
                    ),

                    const SizedBox(
                      height: 80,
                    ), // Espacio para evitar que el contenido tape el botón
                  ],
                ),
              ),
            ),
          ),

          // Botón fijo en la parte inferior
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDeliveryOption != null &&
                        selectedPickupOption != null) {
                      final lugarEntrega =
                          opcionesEntrega[selectedDeliveryOption!];
                      final lugarRecogida =
                          opcionesRecogida[selectedPickupOption!];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ConfirmacionReservaScreen(
                                vehiculoData: widget.vehiculoData,
                                startDateTime: widget.startDateTime,
                                endDateTime: widget.endDateTime,
                                deliveryOption: selectedDeliveryOption!,
                                pickupOption: selectedPickupOption!,
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
    required int index,
    required bool isDelivery,
    required String title,
    required String subtitle,
    required String price,
  }) {
    final isSelected =
        isDelivery
            ? selectedDeliveryOption == index
            : selectedPickupOption == index;

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
              selectedDeliveryOption = index;
            } else {
              selectedPickupOption = index;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Radio(
                value: index,
                groupValue:
                    isDelivery ? selectedDeliveryOption : selectedPickupOption,
                onChanged: (value) {
                  setState(() {
                    if (isDelivery) {
                      selectedDeliveryOption = value as int;
                    } else {
                      selectedPickupOption = value as int;
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
