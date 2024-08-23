import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/Settings/ders_ogretmen_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/Settings/theme_notifier.dart'; // Import ThemeNotifier

class DersTakvimiScreen extends StatefulWidget {
  @override
  _DersTakvimiScreenState createState() => _DersTakvimiScreenState();
}

class _DersTakvimiScreenState extends State<DersTakvimiScreen> {
  final List<String> _daysOfWeek = ['Saat', 'Pzt', 'Sal', 'Çrş', 'Prş', 'Cum'];
  final List<String> _timeSlots = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  List<String> _branslar = [];
  List<Ogretmen> _ogretmenler = [];
  Ogretmen? _selectedOgretmen;
  String? _selectedBrans;

  @override
  void initState() {
    super.initState();
    _loadBranslar(); // Load branches when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ders Programı',
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
          Expanded(
            child: FutureBuilder<List<DersProgrami>>(
              future: loadDersProgrami(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Veriler yüklenemedi'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Ders programı bulunamadı'));
                }

                final List<DersProgrami> dersProgrami = snapshot.data
                    as List<DersProgrami>; // Casting to correct type

                // Filter the lessons based on the selected teacher
                final filteredDersProgrami = _selectedOgretmen != null
                    ? dersProgrami
                        .where((ders) => ders.ogretmen == _selectedOgretmen)
                        .toList()
                    : dersProgrami;

                return _buildDersTakvimi(filteredDersProgrami, themeNotifier);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadBranslar() async {
    final ogretmenler = await loadOgretmenler();
    setState(() {
      _branslar = ogretmenler
          .map((ogretmen) => ogretmen.brans)
          .toSet()
          .toList(); // Extract unique branches
      _branslar.sort(); // Optionally sort the list of branches
    });
  }

  Widget _buildDersTakvimi(
      List<DersProgrami> dersProgrami, ThemeNotifier themeNotifier) {
    return Column(
      children: [
        _buildDaysOfWeekHeader(themeNotifier),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: _daysOfWeek.length,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(
                  _daysOfWeek.length * _timeSlots.length,
                  (index) {
                    final dayIndex = index % _daysOfWeek.length;
                    final timeSlotIndex = index ~/ _daysOfWeek.length;

                    // Determine the maximum number of lessons for this time slot across all days
                    final maxLessons = _getMaxLessonsForTimeSlot(
                        dersProgrami, _timeSlots[timeSlotIndex]);

                    // Set the height based on the maximum number of lessons
                    final cellHeight = 1;

                    if (dayIndex == 0) {
                      // This is the first column where time slots are shown
                      return StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: cellHeight, // Same height as lessons
                        child: _buildTimeSlotCell(
                            _timeSlots[timeSlotIndex], themeNotifier),
                      );
                    } else {
                      // The remaining columns show the lessons
                      String switchDay(String day) {
                        switch (day) {
                          case 'Pzt':
                            return 'Pazartesi';
                          case 'Sal':
                            return 'Salı';
                          case 'Çrş':
                            return 'Çarşamba';
                          case 'Prş':
                            return 'Perşembe';
                          case 'Cum':
                            return 'Cuma';
                          default:
                            return 'Pazartesi';
                        }
                      }

                      final day = switchDay(_daysOfWeek[dayIndex]);
                      final timeSlot = _timeSlots[timeSlotIndex];

                      // Get all lessons for this day and time slot
                      final dersler = dersProgrami
                          .where(
                            (ders) => ders.gun == day && ders.saat == timeSlot,
                          )
                          .toList();

                      return StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount:
                            cellHeight, // Same height as time slots
                        child: _buildDersCell(dersler, themeNotifier),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBransOgretmenDropdown(ThemeNotifier themeNotifier) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              hint: Text('Branş Seçin'),
              value: _selectedBrans,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBrans = newValue;
                  _selectedOgretmen = null;
                  _getOgretmenlerByBrans(_selectedBrans).then((ogretmenler) {
                    setState(() {
                      _ogretmenler = ogretmenler;
                    });
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
            child: DropdownButton<Ogretmen>(
              hint: Text('Öğretmen Seçin'),
              value: _selectedOgretmen,
              onChanged: _selectedBrans != null
                  ? (Ogretmen? newValue) {
                      setState(() {
                        _selectedOgretmen = newValue;
                      });
                    }
                  : null,
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

  Future<List<Ogretmen>> _getOgretmenlerByBrans(String? brans) async {
    // This function should return a filtered list of teachers based on the selected branch
    if (brans == null) return [];
    final ogretmenler = await loadOgretmenler(); // Load all teachers
    return ogretmenler.where((ogretmen) => ogretmen.brans == brans).toList();
  }

  int _getMaxLessonsForTimeSlot(
      List<DersProgrami> dersProgrami, String timeSlot) {
    int maxLessons = 1;

    for (final day in _daysOfWeek.skip(1)) {
      final dayName = _getFullDayName(day);
      final lessons = dersProgrami
          .where((ders) => ders.gun == dayName && ders.saat == timeSlot)
          .length;
      if (lessons > maxLessons) {
        maxLessons = lessons;
      }
    }

    return maxLessons;
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case 'Pzt':
        return 'Pazartesi';
      case 'Sal':
        return 'Salı';
      case 'Çrş':
        return 'Çarşamba';
      case 'Prş':
        return 'Perşembe';
      case 'Cum':
        return 'Cuma';
      default:
        return 'Pazartesi';
    }
  }

  Widget _buildDaysOfWeekHeader(ThemeNotifier themeNotifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: themeNotifier.themeColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _daysOfWeek
            .map(
              (day) => Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      color: themeNotifier.isDarkMode
                          ? Colors.white70
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: themeNotifier.fontSize,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTimeSlotCell(String timeSlot, ThemeNotifier themeNotifier) {
    return Container(
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode
            ? Colors.grey[700]
            : themeNotifier.themeColor.withOpacity(0.1),
        border: Border.all(color: themeNotifier.themeColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          timeSlot,
          style: TextStyle(
            color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: themeNotifier.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDersCell(
      List<DersProgrami> dersler, ThemeNotifier themeNotifier) {
    final isEmpty = (dersler.isEmpty || _selectedOgretmen == null || _selectedBrans == null);

    return Container(
      decoration: BoxDecoration(
        color: isEmpty
            ? themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[200]
            : themeNotifier.themeColor.withOpacity(0.1),
        border: Border.all(color: themeNotifier.themeColor),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: isEmpty
              ? [
                  Text(
                    '-',
                    style: TextStyle(
                      color: themeNotifier.isDarkMode ? Colors.white70 : Colors.grey,
                      fontSize: themeNotifier.fontSize - 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]
              : dersler.map((ders) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Column(
                      children: [
                        _buildTextWithFitting(ders.sinif, 10, 12, themeNotifier),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextWithFitting(String text, double minFontSize,
      double maxFontSize, ThemeNotifier themeNotifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = maxFontSize;
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        );

        while (fontSize > minFontSize) {
          textPainter.layout(maxWidth: constraints.maxWidth);
          if (textPainter.didExceedMaxLines) {
            fontSize--;
            textPainter.text = TextSpan(
              text: text,
              style: TextStyle(
                fontSize: fontSize,
                color: themeNotifier.themeColor,
              ),
            );
          } else {
            break;
          }
        }

        return Text(  //kutucukların sınıf 
          text,
          style: TextStyle(
            fontSize: 1.4*fontSize,
            fontWeight: FontWeight.bold,
            color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
