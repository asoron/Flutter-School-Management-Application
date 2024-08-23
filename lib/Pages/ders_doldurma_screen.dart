import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '/Settings/ders_ogretmen_model.dart';
import '/Settings/theme_notifier.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DersDoldurmaScreen extends StatefulWidget {
  @override
  _DersDoldurmaScreenState createState() => _DersDoldurmaScreenState();
}

class _DersDoldurmaScreenState extends State<DersDoldurmaScreen> {
  List<String> _branslar = [];
  List<Ogretmen> _ogretmenler = [];
  Ogretmen? _selectedOgretmen;
  String? _selectedBrans;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DersProgrami> _filteredDersler = [];

  @override
  void initState() {
    super.initState();
    _loadBranslar();
  }

  void _loadBranslar() async {
    final ogretmenler = await loadOgretmenler();
    setState(() {
      _branslar =
          ogretmenler.map((ogretmen) => ogretmen.brans).toSet().toList();
      _branslar.sort();
    });
  }

  Future<List<Ogretmen>> _getOgretmenlerByBrans(String? brans) async {
    if (brans == null) return [];
    final ogretmenler = await loadOgretmenler();
    return ogretmenler.where((ogretmen) => ogretmen.brans == brans).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _filterDersler();
    });
  }

  void _filterDersler() {
    if (_selectedOgretmen != null && _selectedDay != null) {
      String selectedGun = DateFormat('EEEE', 'tr_TR').format(_selectedDay!);
      setState(() {
        _filteredDersler = _selectedOgretmen!.dersProgrami
            .where((ders) => ders.gun == selectedGun)
            .toList();
      });
    } else {
      setState(() {
        _filteredDersler = [];
      });
    }
  }

  Future<void> _onDoldurmaButtonPressed(DersProgrami ders) async {
    final musaitOgretmenler = await _getBosOgretmenler(ders.gun, ders.saat);
    if (musaitOgretmenler.isEmpty) {
      // Boş öğretmen yoksa uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Bu saatte boşta olan öğretmen bulunmamaktadır.')),
      );
    } else {
      // Öğretmen seçimi yap
      Ogretmen? secilenOgretmen = await showDialog<Ogretmen>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Öğretmen Seçin'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: musaitOgretmenler.map((ogretmen) {
                  return ListTile(
                    title: Text(ogretmen.adSoyad),
                    onTap: () {
                      Navigator.of(context).pop(ogretmen);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      if (secilenOgretmen != null) {
        // XML dosyasını güncelle
        await _updateOgretmenInXml(ders, secilenOgretmen);

        // Sayfayı yenile ve XML'i yeniden yükle
        await _refreshPage();

        // Kullanıcıya başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ders başarıyla güncellendi.')),
        );
      }
    }
  }

  Future<void> _updateOgretmenInXml(
      DersProgrami ders, Ogretmen yeniOgretmen) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/ders.xml');

      if (!await file.exists()) return; // Dosya yoksa çık

      final document = xml.XmlDocument.parse(await file.readAsString());

      final dersElements =
          document.findAllElements('dersler').single.findAllElements('ders');
      for (var element in dersElements) {
        final gun = element.findElements('gun').single.text;
        final saat = element.findElements('saat').single.text;

        if (gun == ders.gun && saat == ders.saat) {
          element.findElements('ogretmen').single.innerText =
              yeniOgretmen.adSoyad;
          break;
        }
      }

      await file.writeAsString(document.toXmlString(pretty: true));
    } catch (e) {
      print('XML dosyasını güncellerken hata oluştu: $e');
    }
  }

  Future<void> _refreshPage() async {
    // Ders programını yeniden yükle ve sayfayı baştan inşa et
    await _loadDersProgrami();
    setState(() {
      _filterDersler(); // Dersleri filtrele ve güncel halini göster
    });
  }

  Future<void> _loadDersProgrami() async {
    final dersler =
        await loadDersProgrami(); // XML'den güncellenmiş ders programını yükle
    if (_selectedOgretmen != null && _selectedDay != null) {
      String selectedGun = DateFormat('EEEE', 'tr_TR').format(_selectedDay!);
      setState(() {
        _filteredDersler = dersler
            .where((ders) =>
                ders.ogretmen?.adSoyad == _selectedOgretmen!.adSoyad &&
                ders.gun == selectedGun)
            .toList();
      });
    }
  }

  Future<List<Ogretmen>> _getBosOgretmenler(String gun, String saat) async {
    if (_selectedBrans == null) return [];
    final ogretmenler = await _getOgretmenlerByBrans(_selectedBrans);
    return ogretmenler
        .where((ogretmen) => ogretmen.musaitMi(gun, saat))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ders Doldurma',
          style: TextStyle(
            fontSize: themeNotifier.fontSize,
          ),
        ),
        backgroundColor: themeNotifier.themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildBransOgretmenDropdown(themeNotifier),
          _buildCustomTakvim(themeNotifier),
          _buildDersListesi(themeNotifier),
        ],
      ),
    );
  }

  Widget _buildBransOgretmenDropdown(ThemeNotifier themeNotifier) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Branş Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedBrans,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBrans = newValue;
                  _selectedOgretmen = null;
                  _ogretmenler = [];
                  _filteredDersler = [];
                  _selectedDay = null;
                });
                _getOgretmenlerByBrans(_selectedBrans).then((ogretmenler) {
                  setState(() {
                    _ogretmenler = ogretmenler;
                  });
                });
              },
              items: _branslar.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<Ogretmen>(
              decoration: InputDecoration(
                labelText: 'Öğretmen Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedOgretmen,
              onChanged: (Ogretmen? newValue) {
                setState(() {
                  _selectedOgretmen = newValue;
                  _filteredDersler = [];
                  _selectedDay = null;
                });
              },
              items: _ogretmenler
                  .map<DropdownMenuItem<Ogretmen>>((Ogretmen value) {
                return DropdownMenuItem<Ogretmen>(
                  value: value,
                  child: Text(value.adSoyad),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTakvim(ThemeNotifier themeNotifier) {
    return Column(
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
                DateFormat('MMMM yyyy', 'tr_TR').format(_focusedDay),
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
        // Calendar Days
        TableCalendar(
          locale: 'tr_TR',
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: false, // Hide the built-in header
          daysOfWeekVisible: false, // Hide the built-in weekday names
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: themeNotifier.themeColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: themeNotifier.themeColor,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
            cellMargin: const EdgeInsets.symmetric(vertical: 8.0),
            defaultTextStyle: TextStyle(
              fontSize: themeNotifier.fontSize,
              color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDersListesi(ThemeNotifier themeNotifier) {
    if (_selectedDay == null) {
      return Expanded(
        child: Center(
          child: Text(
            'Bir gün seçiniz.',
            style: TextStyle(
              fontSize: themeNotifier.fontSize,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else if (_filteredDersler.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Seçilen gün için ders bulunmamaktadır.',
            style: TextStyle(
              fontSize: themeNotifier.fontSize,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _filteredDersler.length,
          itemBuilder: (context, index) {
            final ders = _filteredDersler[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 3,
              child: ListTile(
                leading: Icon(
                  Icons.book,
                  color: themeNotifier.themeColor,
                ),
                title: Text(
                  ders.dersAdi,
                  style: TextStyle(
                    fontSize: themeNotifier.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Saat: ${ders.saat}\nSınıf: ${ders.sinif}',
                  style: TextStyle(
                    fontSize: themeNotifier.fontSize - 2,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _onDoldurmaButtonPressed(ders),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeNotifier.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Doldur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: themeNotifier.fontSize - 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
