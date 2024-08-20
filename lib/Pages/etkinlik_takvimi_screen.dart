import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Settings/theme_notifier.dart'; // Import your ThemeNotifier

class Etkinlik {
  final String tarih;
  final String adi;
  final String duzenleyen;
  final String yeri;
  final String saati;

  Etkinlik({
    required this.tarih,
    required this.adi,
    required this.duzenleyen,
    required this.yeri,
    required this.saati,
  });

  factory Etkinlik.fromFirestore(Map<String, dynamic> data) {
    return Etkinlik(
      tarih: data['tarih'] ?? '',
      adi: data['etkinlik_adi'] ?? '',
      duzenleyen: data['etkinlik_duzenleyen'] ?? '',
      yeri: data['etkinlik_yeri'] ?? '',
      saati: data['etkinlik_saati'] ?? '',
    );
  }
}

Future<List<Etkinlik>> loadEtkinlikler() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Initialize an empty list to hold all events
  List<Etkinlik> allEtkinlikler = [];

  // Assume subcollections follow a known pattern, like 'etkinlikID1', 'etkinlikID2', etc.
  List<String> subCollectionNames = [
    'etkinlikID1',
    'etkinlikID2'
  ]; // Dynamically retrieve if possible

  // Fetch data from each subcollection
  for (var subCollectionName in subCollectionNames) {
    CollectionReference subCollectionRef = firestore
        .collection('okul')
        .doc('okul')
        .collection('etkinlikler')
        .doc('etkinlikler')
        .collection(subCollectionName);

    QuerySnapshot snapshot = await subCollectionRef.get();
    for (var doc in snapshot.docs) {
      allEtkinlikler
          .add(Etkinlik.fromFirestore(doc.data() as Map<String, dynamic>));
    }
  }

  return allEtkinlikler;
}

class EtkinlikTakvimiScreen extends StatefulWidget {
  @override
  _EtkinlikTakvimiScreenState createState() => _EtkinlikTakvimiScreenState();
}

class _EtkinlikTakvimiScreenState extends State<EtkinlikTakvimiScreen> {
  late Map<DateTime, List<Etkinlik>> _etkinliklerMap;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<Etkinlik> _selectedEtkinlikler;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _etkinliklerMap = {};
    _selectedEtkinlikler = [];
    _loadEtkinlikler();
  }

  Future<void> _loadEtkinlikler() async {
    List<Etkinlik> etkinlikler = await loadEtkinlikler();
    setState(() {
      _etkinliklerMap = {};
      for (var etkinlik in etkinlikler) {
        DateTime eventDate = DateFormat('dd/MM/yyyy').parse(etkinlik.tarih);
        if (_etkinliklerMap[eventDate] == null) {
          _etkinliklerMap[eventDate] = [];
        }
        _etkinliklerMap[eventDate]!.add(etkinlik);
      }
      _selectedEtkinlikler = _getEtkinliklerForDay(_selectedDay);
    });
  }

  List<Etkinlik> _getEtkinliklerForDay(DateTime day) {
    return _etkinliklerMap.entries
        .where((entry) => _isSameDate(entry.key, day))
        .map((entry) => entry.value)
        .expand((eventList) => eventList)
        .toList();
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEtkinlikler = _getEtkinliklerForDay(selectedDay);
    });
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme settings from the notifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Takvimi'),
        backgroundColor: themeNotifier.themeColor,
      ),
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: themeNotifier.themeColor,
                  onPressed: () {
                    setState(() {
                      _focusedDay =
                          DateTime(_focusedDay.year, _focusedDay.month - 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: themeNotifier.themeColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  color: themeNotifier.themeColor,
                  onPressed: () {
                    setState(() {
                      _focusedDay =
                          DateTime(_focusedDay.year, _focusedDay.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // Weekday Names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Pzt",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Sal",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Çrş",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Prş",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Cum",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Cmt",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
              Text("Paz",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.themeColor)),
            ],
          ),
          const SizedBox(height: 8.0),
          // Calendar Days
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: _onFormatChanged,
            eventLoader: (day) {
              return _getEtkinliklerForDay(
                  day); // This will display markers on days with events
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: themeNotifier.themeColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: themeNotifier.themeColor,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              cellAlignment: Alignment.center,
              cellMargin: const EdgeInsets.symmetric(vertical: 8.0),
              defaultTextStyle: TextStyle(
                fontSize: themeNotifier.fontSize,
                color:
                    themeNotifier.isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
            daysOfWeekVisible: false, // Hide the built-in weekday names
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEtkinlikler.length,
              itemBuilder: (context, index) {
                final etkinlik = _selectedEtkinlikler[index];
                return Card(
                  color: themeNotifier.isDarkMode
                      ? Colors.grey[800]
                      : Colors.white,
                  child: ListTile(
                    title: Text(
                      etkinlik.adi,
                      style: TextStyle(
                        fontSize: themeNotifier.fontSize,
                        color: themeNotifier.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tarih: ${etkinlik.tarih}',
                            style: TextStyle(
                              fontSize: themeNotifier.fontSize,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        Text('Düzenleyen: ${etkinlik.duzenleyen}',
                            style: TextStyle(
                              fontSize: themeNotifier.fontSize,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        Text('Yer: ${etkinlik.yeri}',
                            style: TextStyle(
                              fontSize: themeNotifier.fontSize,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        Text('Saat: ${etkinlik.saati}',
                            style: TextStyle(
                              fontSize: themeNotifier.fontSize,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
