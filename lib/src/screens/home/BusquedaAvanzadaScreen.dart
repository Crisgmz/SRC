import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solutions_rent_car/src/screens/home/BusquedaScreen.dart';
import 'package:table_calendar/table_calendar.dart';

class BusquedaAvanzadaScreen extends StatefulWidget {
  const BusquedaAvanzadaScreen({super.key});

  @override
  State<BusquedaAvanzadaScreen> createState() => _BusquedaAvanzadaScreenState();
}

class _BusquedaAvanzadaScreenState extends State<BusquedaAvanzadaScreen> {
  DateTimeRange? _rangoFechas;
  TimeOfDay _horaRecogida = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaRetorno = const TimeOfDay(hour: 18, minute: 0);
  String _transmision = 'Todos';
  String _combustible = 'Todos';
  String _tipoVehiculo = 'Todos';
  String _lugarRecogida = 'Recogida en el local';
  String _lugarRetorno = 'Recogida en el local';
  String _pasajeros = '2 o más';

  final List<String> _transmisiones = ['Todos', 'Automática', 'Manual'];
  final List<String> _combustibles = [
    'Todos',
    'Gasolina',
    'Diésel',
    'Eléctrico',
  ];
  final List<String> _tiposVehiculo = [
    'Todos',
    'SUV',
    'Sedán',
    'Camioneta',
    'Deportivo',
  ];
  final List<String> _lugares = [
    'Recogida en el local',
    'Aeropuerto Internacional de Cibao',
    'Aeropuerto Internacional Las Americas',
  ];
  final List<String> _opcionesPasajeros = ['2 o más', '5 o más', '7 o más'];

  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;

  String get _fechaTexto {
    if (_startDate == null || _endDate == null) return 'Selecciona fechas';
    final format = DateFormat('dd MMM', 'es');
    return '${format.format(_startDate!)} - ${format.format(_endDate!)}';
  }

  int get _diasRenta {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _fechasValidas => _startDate != null && _endDate != null;

  bool get _esAeropuertoAmericas {
    return _lugarRecogida == 'Aeropuerto Internacional Las Americas' ||
        _lugarRetorno == 'Aeropuerto Internacional Las Americas';
  }

  double get _costoAeropuerto {
    return _esAeropuertoAmericas ? 100.0 : 0.0;
  }

  String get _formatoHora {
    return '${_horaRecogida.format(context)} - ${_horaRetorno.format(context)}';
  }

  void _seleccionarFechas() async {
    final now = DateTime.now();

    final rango = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale(
        'es',
      ), // Asegura que estás usando `MaterialApp` con `supportedLocales`
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _seleccionarHoraRecogida() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaRecogida,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hora != null) {
      setState(() => _horaRecogida = hora);
    }
  }

  void _seleccionarHoraRetorno() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaRetorno,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hora != null) {
      setState(() => _horaRetorno = hora);
    }
  }

  void _validarYCambiarLugar(String nuevoLugar, bool esRecogida) {
    setState(() {
      if (esRecogida) {
        _lugarRecogida = nuevoLugar;
      } else {
        _lugarRetorno = nuevoLugar;
      }
    });
  }

  void _buscarVehiculos() {
    if (_rangoFechas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona las fechas de renta'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    print('Recogida: $_lugarRecogida');
    print('Retorno: $_lugarRetorno');
    print('Fechas: $_rangoFechas');
    print('Hora recogida: ${_horaRecogida.format(context)}');
    print('Hora retorno: ${_horaRetorno.format(context)}');
    print('Días de renta: $_diasRenta');
    print('Pasajeros: $_pasajeros');
    print('Transmisión: $_transmision');
    print('Combustible: $_combustible');
    print('Tipo de Vehículo: $_tipoVehiculo');
    print('Costo aeropuerto: \$${_costoAeropuerto}');

    // Aquí navegarías a la pantalla de resultados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BusquedaScreen(),
        settings: RouteSettings(
          arguments: {
            'rangoFechas': _rangoFechas, // tipo DateTimeRange
          },
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool esLugar = false,
    bool esRecogida = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange[600], size: 22),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        isExpanded: true,
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged:
            esLugar
                ? (val) => _validarYCambiarLugar(val!, esRecogida)
                : onChanged,
        dropdownColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    IconData icon,
    TimeOfDay time,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                time.format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _mostrarCalendario = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Text(
            'Buscar vehículo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de sección
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fechas de Renta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card seleccionable que expande calendario
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mostrarCalendario = !_mostrarCalendario;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: Colors.orange[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _rangoFechas == null
                                  ? 'Seleccionar fechas'
                                  : '${_rangoFechas!.start.day}/${_rangoFechas!.start.month}/${_rangoFechas!.start.year} - ${_rangoFechas!.end.day}/${_rangoFechas!.end.month}/${_rangoFechas!.end.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),

                            if (_rangoFechas != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${_rangoFechas!.duration.inDays + 1} días de renta',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        _mostrarCalendario
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              // Calendario (visible solo si está expandido)
              if (_mostrarCalendario)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _rangoFechas?.start ?? DateTime.now(),
                    selectedDayPredicate: (day) {
                      if (_rangoFechas == null) return false;
                      // Verificar si el día está dentro del rango seleccionado
                      return day.isAtSameMomentAs(_rangoFechas!.start) ||
                          day.isAtSameMomentAs(_rangoFechas!.end) ||
                          (day.isAfter(_rangoFechas!.start) &&
                              day.isBefore(_rangoFechas!.end));
                    },
                    rangeStartDay: _rangoFechas?.start,
                    rangeEndDay: _rangoFechas?.end,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _rangoFechas = DateTimeRange(
                          start: selectedDay,
                          end:
                              selectedDay, // Asegurar que inicio y final sean el mismo día
                        );
                      });
                    },
                    onRangeSelected: (start, end, focusedDay) {
                      if (start != null) {
                        // Si solo hay fecha de inicio (sin final), crear rango de un día
                        if (end == null) {
                          setState(() {
                            _rangoFechas = DateTimeRange(
                              start: start,
                              end: start,
                            );
                          });
                          return;
                        }

                        setState(() {
                          _rangoFechas = DateTimeRange(start: start, end: end);
                          _mostrarCalendario = false;
                        });
                      }
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                    },
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.orange,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.orange,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.orange[400]),
                      weekdayStyle: const TextStyle(color: Colors.black54),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.orange[200],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      rangeStartDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      withinRangeDecoration: BoxDecoration(
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(color: Colors.black87),
                      weekendTextStyle: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),

              // Horarios
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Horarios',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTimeSelector(
                    'Hora de recogida',
                    Icons.schedule,
                    _horaRecogida,
                    _seleccionarHoraRecogida,
                  ),
                  const SizedBox(width: 12),
                  _buildTimeSelector(
                    'Hora de retorno',
                    Icons.schedule_outlined,
                    _horaRetorno,
                    _seleccionarHoraRetorno,
                  ),
                ],
              ),

              // Lugares
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Lugar de Recogida y Retorno',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildDropdown(
                'Lugar de recogida',
                Icons.location_on,
                _lugarRecogida,
                _lugares,
                (String? _) {}, // ✅
                esLugar: true,
                esRecogida: true,
              ),

              _buildDropdown(
                'Lugar de retorno',
                Icons.location_on_outlined,
                _lugarRetorno,
                _lugares,
                (String? _) {}, // ✅
                esLugar: true,
                esRecogida: false,
              ),

              // Advertencia aeropuerto
              if (_esAeropuertoAmericas) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aeropuerto Las Américas',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mínimo 15 días • Cargo: \$${_costoAeropuerto.toInt()} USD',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Filtros de vehículo
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.tune, color: Colors.orange[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtros de Vehículo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildDropdown(
                'Tipo de Vehículo',
                Icons.directions_car,
                _tipoVehiculo,
                _tiposVehiculo,
                (val) => setState(() => _tipoVehiculo = val!),
              ),
              _buildDropdown(
                'Pasajeros',
                Icons.people,
                _pasajeros,
                _opcionesPasajeros,
                (val) => setState(() => _pasajeros = val!),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _buscarVehiculos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.orange.withOpacity(0.3),
                  ),
                  icon: const Icon(Icons.search, size: 22),
                  label: const Text(
                    'Buscar vehículos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
