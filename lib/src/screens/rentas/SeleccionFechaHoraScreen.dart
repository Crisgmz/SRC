import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solutions_rent_car/src/screens/rentas/DatosRecogidaScreen.dart';

class SeleccionFechaHoraScreen extends StatefulWidget {
  final String idVehiculo;
  final String nombre;
  final String marca;
  final String modelo;
  final int anio;
  final double precioPorDia;
  final List<dynamic> imagenes;
  final String nombreCliente;
  final String telefono;

  const SeleccionFechaHoraScreen({
    super.key,
    required this.idVehiculo,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.precioPorDia,
    required this.imagenes,
    required this.nombreCliente,
    required this.telefono,
  });

  @override
  State<SeleccionFechaHoraScreen> createState() =>
      _SeleccionFechaHoraScreenState();
}

class _SeleccionFechaHoraScreenState extends State<SeleccionFechaHoraScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay startTime = const TimeOfDay(hour: 5, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);
  String nombreCliente = '';
  String telefono = '';

  // For slider values
  double startSliderValue = 5.0; // Initial hours for pickup
  double endSliderValue = 22.0; // Initial hours for return

  // Current month and year for calendar
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  final int _selectedMonthIndex = 0; // 0 for current month

  // Selected days
  int? _startDay;
  int? _endDay;

  List<Map<String, DateTime>> _fechasReservadas = [];

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Spanish locale
    initializeDateFormatting('es_ES', null);
    _cargarFechasReservadas();

    _startDay = DateTime.now().day;
    _endDay = DateTime.now().add(const Duration(days: 7)).day;

    startDate = DateTime(
      _currentYear,
      _currentMonth,
      _startDay!,
      startTime.hour,
      startTime.minute,
    );

    endDate = DateTime(
      _currentYear,
      _currentMonth,
      _endDay!,
      endTime.hour,
      endTime.minute,
    );
  }

  Future<void> _cargarFechasReservadas() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('rentas')
            .where('vehiculoId', isEqualTo: widget.idVehiculo)
            .where('estado', whereIn: ['Pre-agendada', 'confirmada'])
            .get();

    final reservas =
        snapshot.docs.map((doc) {
          final inicio = (doc['fechaInicio'] as Timestamp).toDate();
          final fin = (doc['fechaFin'] as Timestamp).toDate();
          return {'inicio': inicio, 'fin': fin};
        }).toList();

    setState(() {
      _fechasReservadas = reservas;
    });
  }

  void _selectDay(int day) {
    setState(() {
      if (_startDay == null || (_startDay != null && _endDay != null)) {
        // Comenzar nueva selección
        _startDay = day;
        _endDay = null;
      } else {
        // Completar la selección
        if (day < _startDay!) {
          _endDay = _startDay;
          _startDay = day;
        } else {
          _endDay = day;
        }
      }

      // Actualizar objetos DateTime
      if (_startDay != null) {
        startDate = DateTime(
          _currentYear,
          _currentMonth,
          _startDay!,
          startTime.hour,
          startTime.minute,
        );
      }

      if (_endDay != null) {
        endDate = DateTime(
          _currentYear,
          _currentMonth,
          _endDay!,
          endTime.hour,
          endTime.minute,
        );
      }

      // Validar si hay días rentados dentro del rango seleccionado
      if (_startDay != null && _endDay != null) {
        final DateTime nuevaFechaInicio = DateTime(
          _currentYear,
          _currentMonth,
          _startDay!,
          startTime.hour,
          startTime.minute,
        );

        final DateTime nuevaFechaFin = DateTime(
          _currentYear,
          _currentMonth,
          _endDay!,
          endTime.hour,
          endTime.minute,
        );

        if (_rangoTieneConflicto(nuevaFechaInicio, nuevaFechaFin)) {
          // Resetear selección y mostrar mensaje
          _startDay = null;
          _endDay = null;
          startDate = DateTime.now();
          endDate = DateTime.now().add(const Duration(days: 7));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No puedes seleccionar un rango que contenga días ocupados.',
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    });
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  // Format date for display (e.g., "10 Abr, Jue")
  String _formatDate(DateTime date) {
    final DateFormat dayFormat = DateFormat('d');
    final DateFormat monthFormat = DateFormat('MMM', 'es_ES');
    final DateFormat weekdayFormat = DateFormat('E', 'es_ES');

    String day = dayFormat.format(date);
    String month = monthFormat.format(date).substring(0, 3);
    String weekday = weekdayFormat.format(date).substring(0, 3);

    // Capitalize first letter of month and weekday
    month = month[0].toUpperCase() + month.substring(1);
    weekday = weekday[0].toUpperCase() + weekday.substring(1);

    return '$day $month, $weekday';
  }

  // Format time for display (e.g., "5:00 AM")
  String _formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Get the month name in Spanish
  String _getMonthName(int month) {
    List<String> months = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE',
    ];
    return months[month - 1];
  }

  // Check if a day is selected (either start or end date)
  bool _isDaySelected(int day) {
    return day == _startDay || day == _endDay;
  }

  // Check if a day is in the range between start and end date
  bool _isDayInRange(int day) {
    if (_startDay == null || _endDay == null) return false;
    return day > _startDay! && day < _endDay!;
  }

  bool _esDiaReservado(DateTime dia) {
    for (final reserva in _fechasReservadas) {
      if (dia.isAfter(reserva['inicio']!.subtract(const Duration(days: 1))) &&
          dia.isBefore(reserva['fin']!.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  bool _rangoTieneConflicto(DateTime inicio, DateTime fin) {
    for (final reserva in _fechasReservadas) {
      final inicioOcupado = reserva['inicio']!;
      final finOcupado = reserva['fin']!;

      final haySolapamiento =
          inicio.isBefore(finOcupado) && fin.isAfter(inicioOcupado);
      if (haySolapamiento) return true;
    }
    return false;
  }

  // Generate calendar for the current month
  List<Widget> _buildCalendar() {
    List<Widget> calendar = [];

    // Add weekday headers
    List<String> weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sat'];
    List<Widget> weekdayHeaders =
        weekdays
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
            .toList();

    calendar.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdayHeaders,
      ),
    );

    calendar.add(const SizedBox(height: 20));

    // Calculate first day of month and number of days
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;

    // Calculate the starting position based on the weekday of the first day
    int startPosition = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Previous month's days
    final daysInPreviousMonth = DateTime(_currentYear, _currentMonth, 0).day;

    List<Widget> calendarDays = [];

    // Add days from previous month to fill the first row
    for (int i = 0; i < startPosition; i++) {
      final prevMonthDay = daysInPreviousMonth - startPosition + i + 1;
      calendarDays.add(
        Expanded(
          child: Center(
            child: Text(
              '$prevMonthDay',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ),
      );
    }

    // Add days for current month
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(_currentYear, _currentMonth, day);
      final reservado = _esDiaReservado(currentDate);
      final isToday =
          DateTime.now().day == day &&
          DateTime.now().month == _currentMonth &&
          DateTime.now().year == _currentYear;

      calendarDays.add(
        Expanded(
          child: GestureDetector(
            onTap: reservado ? null : () => _selectDay(day),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    reservado
                        ? Colors.grey[200]
                        : _isDaySelected(day)
                        ? const Color(0xFFF9A825)
                        : _isDayInRange(day)
                        ? const Color(0xFFFFF3E0)
                        : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontWeight:
                        isToday || _isDaySelected(day)
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color:
                        reservado
                            ? Colors.grey
                            : _isDaySelected(day)
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add days from next month to complete the grid
    int remainingDays = 7 - (calendarDays.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        calendarDays.add(
          Expanded(
            child: Center(
              child: Text('$i', style: TextStyle(color: Colors.grey[300])),
            ),
          ),
        );
      }
    }

    // Arrange days in rows of 7
    for (int i = 0; i < calendarDays.length; i += 7) {
      List<Widget> rowChildren = calendarDays.sublist(
        i,
        i + 7 > calendarDays.length ? calendarDays.length : i + 7,
      );

      calendar.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren,
          ),
        ),
      );
    }

    return calendar;
  }

  @override
  Widget build(BuildContext context) {
    // Update time of day objects from slider values
    startTime = TimeOfDay(
      hour: startSliderValue.floor(),
      minute: ((startSliderValue - startSliderValue.floor()) * 60).round(),
    );

    endTime = TimeOfDay(
      hour: endSliderValue.floor(),
      minute: ((endSliderValue - endSliderValue.floor()) * 60).round(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Seleccione la fecha y hora',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Selected range display
          Container(
            color: const Color(0xFFFFF8E1),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatDate(startDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatTime(startTime),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatDate(endDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatTime(endTime),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          '${_getMonthName(_currentMonth)} $_currentYear',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFF9A825),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Calendar grid
                    ..._buildCalendar(),

                    const SizedBox(height: 24),

                    // Time selection
                    Column(
                      children: [
                        // Pickup time tooltip
                        if (_startDay != null)
                          Align(
                            alignment:
                                Alignment.lerp(
                                  Alignment.centerLeft,
                                  Alignment.centerRight,
                                  startSliderValue / 24,
                                )!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(startTime),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Hora de Recogida',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Pickup slider
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            const Text(
                              'Recogida',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6.0,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10.0,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20.0,
                                  ),
                                  thumbColor: const Color(0xFFF9A825),
                                  activeTrackColor: const Color(0xFFF9A825),
                                  inactiveTrackColor: const Color(0xFFFFE0B2),
                                ),
                                child: Slider(
                                  min: 0.0,
                                  max: 24.0,
                                  value: startSliderValue,
                                  divisions: 48, // ← 30 minutos
                                  onChanged: (value) {
                                    setState(() {
                                      startSliderValue = double.parse(
                                        value.toStringAsFixed(1),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Return slider
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            const Text(
                              'Regreso',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6.0,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10.0,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20.0,
                                  ),
                                  thumbColor: const Color(0xFFF9A825),
                                  activeTrackColor: const Color(0xFFF9A825),
                                  inactiveTrackColor: const Color(0xFFFFE0B2),
                                ),
                                child: Slider(
                                  min: 0.0,
                                  max: 24.0,
                                  value: endSliderValue,
                                  divisions: 48, // ← también 30 minutos
                                  onChanged: (value) {
                                    setState(() {
                                      endSliderValue = double.parse(
                                        value.toStringAsFixed(1),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Return time tooltip
                        Align(
                          alignment:
                              Alignment.lerp(
                                Alignment.centerLeft,
                                Alignment.centerRight,
                                endSliderValue / 24,
                              )!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              _formatTime(endTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          Container(
            color: Colors.white, // ← Asegura fondo blanco
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24,
                ), // espacio cómodo
                child: SizedBox(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final startDateTime = DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          startTime.hour,
                          startTime.minute,
                        );

                        final endDateTime = DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        );

                        final vehiculoData = {
                          'idVehiculo': widget.idVehiculo,
                          'nombre': widget.nombre,
                          'marca': widget.marca,
                          'modelo': widget.modelo,
                          'anio': widget.anio,
                          'precioPorDia': widget.precioPorDia,
                          'imagenes': widget.imagenes,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DatosRecogidaScreen(
                                  vehiculoData: vehiculoData,
                                  startDateTime: startDateTime,
                                  endDateTime: endDateTime,
                                  nombreCliente: widget.nombreCliente,
                                  telefono: widget.telefono,
                                ),
                          ),
                        );
                      },

                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
