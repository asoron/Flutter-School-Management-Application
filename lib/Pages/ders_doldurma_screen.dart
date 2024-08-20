import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '/Settings/ders_ogretmen_model.dart';

class DersDoldurmaScreen extends StatefulWidget {
  @override
  _DersDoldurmaScreenState createState() => _DersDoldurmaScreenState();
}

class _DersDoldurmaScreenState extends State<DersDoldurmaScreen> {
  DersProgrami? _secilenDers;
  late Future<List<DersProgrami>> _dersProgramiFuture;

  @override
  void initState() {
    super.initState();
    _dersProgramiFuture = loadDersProgrami();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Doldurma'),
      ),
      body: FutureBuilder<List<DersProgrami>>(
        future: _dersProgramiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Veriler yüklenemedi'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Öğretmensiz ders bulunamadı'),
            );
          }

          final dersProgramiListesi = snapshot.data!;
          final ogretmensizDersler = dersProgramiListesi
              .where((ders) =>
                  ders.ogretmen == null || ders.ogretmen!.adSoyad.isEmpty)
              .toList();

          if (ogretmensizDersler.isEmpty) {
            return const Center(
              child: Text('Atanacak öğretmen bekleyen ders bulunamadı'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Boş Ders:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButton<DersProgrami>(
                  hint: const Text('Bir ders seçin'),
                  value: _secilenDers,
                  isExpanded: true,
                  items: ogretmensizDersler.map((DersProgrami ders) {
                    return DropdownMenuItem<DersProgrami>(
                      value: ders,
                      child: Text(
                          '${ders.dersAdi} - ${ders.sinif}, ${ders.gun}, ${ders.saat}'),
                    );
                  }).toList(),
                  onChanged: (DersProgrami? yeniDers) {
                    setState(() {
                      _secilenDers = yeniDers;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_secilenDers != null) ...[
                  const Text(
                    'Mevcut Ders:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text(
                          '${_secilenDers!.dersAdi} - ${_secilenDers!.sinif}'),
                      subtitle:
                          Text('${_secilenDers!.gun}, ${_secilenDers!.saat}'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dersi Doldurabilecek Öğretmenler:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView(
                      children: _buildMusaitOgretmenListesi(
                          _secilenDers!, dersProgramiListesi),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMusaitOgretmenListesi(
      DersProgrami mevcutDers, List<DersProgrami> dersProgramiListesi) {
    // Load all teachers from the dersProgramiListesi
    final ogretmenler = dersProgramiListesi
        .where((ders) => ders.ogretmen != null)
        .map((ders) => ders.ogretmen!)
        .toSet()
        .toList();

    final musaitOgretmenler = ogretmenler.where((ogretmen) {
      // Check if the teacher is available and if their branch matches the lesson
      final musait = ogretmen.musaitMi(mevcutDers.gun, mevcutDers.saat);
      final bransUyumlu = ogretmen.brans == mevcutDers.dersAdi;
      return musait && bransUyumlu;
    }).toList();

    // Sort by teacher's name for consistent ordering
    musaitOgretmenler.sort((a, b) => a.adSoyad.compareTo(b.adSoyad));

    if (musaitOgretmenler.isEmpty) {
      return [
        const Center(
          child: Text('Bu ders için uygun öğretmen bulunamadı'),
        ),
      ];
    }

    return musaitOgretmenler.map((ogretmen) {
      return Card(
        child: ListTile(
          title: Text(ogretmen.adSoyad),
          subtitle: Text('Branş: ${ogretmen.brans}'),
          trailing: ElevatedButton(
            onPressed: () async {
              setState(() {
                mevcutDers.ogretmen = ogretmen;
                ogretmen.dersProgrami.add(mevcutDers);
                _secilenDers = null;
              });
              await saveDersProgrami(dersProgramiListesi);
              _dersProgramiFuture = loadDersProgrami();
            },
            child: const Text('Dersi Doldur'),
          ),
        ),
      );
    }).toList();
  }
}
