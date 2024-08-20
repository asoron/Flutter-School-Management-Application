import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:xml/xml.dart' as xml;

// Öğretmen sınıfı tanımı
class Ogretmen {
  final String adSoyad; // Öğretmenin adı ve soyadı
  final String brans; // Öğretmenin branşı
  List<DersProgrami> dersProgrami = []; // Öğretmenin ders programı listesi

  // Yapıcı metot (constructor)
  Ogretmen({
    required this.adSoyad,
    required this.brans,
  });

  // Eşitlik operatörünün yeniden tanımlanması
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ogretmen &&
          runtimeType == other.runtimeType &&
          adSoyad == other.adSoyad &&
          brans == other.brans;

  // Hash kodunun yeniden tanımlanması
  @override
  int get hashCode => adSoyad.hashCode ^ brans.hashCode;

  // Belirli bir gün ve saatte öğretmenin müsait olup olmadığını kontrol eden metot
  bool musaitMi(String gun, String saat) {
    return !dersProgrami.any((ders) => ders.gun == gun && ders.saat == saat);
  }

  // XML elemanından Ogretmen nesnesi oluşturan metot
  factory Ogretmen.fromXml(xml.XmlElement element) {
    return Ogretmen(
      adSoyad: element.findElements('adSoyad').isNotEmpty
          ? element.findElements('adSoyad').single.text
          : '', // Default to empty string if not found
      brans: element.findElements('brans').isNotEmpty
          ? element.findElements('brans').single.text
          : '', // Default to empty string if not found
    );
  }
}

// DersProgrami sınıfı tanımı
class DersProgrami {
  final String gun;
  final String saat;
  final String sinif;
  final String dersAdi;
  final String? tarih; // Dersin tarihi
  Ogretmen? ogretmen;

  // Yapıcı metot (constructor)
  DersProgrami({
    required this.gun,
    required this.saat,
    required this.sinif,
    required this.dersAdi,
    this.tarih,
    this.ogretmen,
  });

  // XML elemanından DersProgrami nesnesi oluşturan fabrika metodu
  factory DersProgrami.fromXml(
      xml.XmlElement element, List<Ogretmen> ogretmenler) {
    final ogretmenAd = element.findElements('ogretmen').isNotEmpty
        ? element.findElements('ogretmen').single.text
        : null;
    final ogretmen = ogretmenAd != null
        ? ogretmenler.firstWhere(
            (ogretmen) => ogretmen.adSoyad == ogretmenAd,
            orElse: () => Ogretmen(adSoyad: '', brans: ''),
          )
        : null;

    return DersProgrami(
      gun: element.findElements('gun').isNotEmpty
          ? element.findElements('gun').single.text
          : '', // Default to empty string if not found
      saat: element.findElements('saat').isNotEmpty
          ? element.findElements('saat').single.text
          : '', // Default to empty string if not found
      sinif: element.findElements('sinif').isNotEmpty
          ? element.findElements('sinif').single.text
          : '', // Default to empty string if not found
      dersAdi: element.findElements('dersAdi').isNotEmpty
          ? element.findElements('dersAdi').single.text
          : '', // Default to empty string if not found
      tarih: element.findElements('tarih').isNotEmpty
          ? element.findElements('tarih').single.text
          : null,
      ogretmen: ogretmen,
    );
  }
}

// XML dosyasını sıfırlayan fonksiyon
Future<void> resetXmlFile() async {
  try {
    await Firebase.initializeApp(); // Initialize Firebase

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    print('Firebase Firestore başarıyla başlatıldı.');

    // Initialize empty lists to hold the QuerySnapshots
    List<QuerySnapshot> ogretmenSnapshots = [];
    List<QuerySnapshot> dersSnapshots = [];

    // Automatically detect subcollections based on a pattern
    for (int i = 1; i <= 10; i++) {
      // You might adjust the upper bound (10) based on your data.
      String ogretmenCollectionName = 'ogretmenID$i';
      String dersCollectionName = 'dersID$i';

      // Fetch ogretmen subcollection documents
      CollectionReference ogretmenRef = firestore
          .collection('okul')
          .doc('okul')
          .collection('ogretmenler')
          .doc('ogretmenler')
          .collection(ogretmenCollectionName);
      QuerySnapshot ogretmenSnapshot = await ogretmenRef.get();
      if (ogretmenSnapshot.docs.isNotEmpty) {
        ogretmenSnapshots.add(ogretmenSnapshot);
      }

      // Fetch ders subcollection documents
      CollectionReference dersRef = firestore
          .collection('okul')
          .doc('okul')
          .collection('dersler')
          .doc('dersler')
          .collection(dersCollectionName);
      QuerySnapshot dersSnapshot = await dersRef.get();
      if (dersSnapshot.docs.isNotEmpty) {
        dersSnapshots.add(dersSnapshot);
      }
    }

    final builder = xml.XmlBuilder();
    print('XML dosyası sıfırlanıyor...');
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('okul', nest: () {
      // Add all ogretmenler
      builder.element('ogretmenler', nest: () {
        print('Öğretmenler yükleniyor...');
        for (var ogretmenSnapshot in ogretmenSnapshots) {
          ogretmenSnapshot.docs.forEach((doc) {
            print("Processing Ogretmen Document: ${doc.id}");
            print("Ogretmen data: ${doc.data()}");
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            builder.element('ogretmen', nest: () {
              builder.element('adSoyad', nest: data['adSoyad']);
              builder.element('brans', nest: data['brans']);
            });
          });
        }
      });

      // Add all dersler
      builder.element('dersler', nest: () {
        print('Dersler yükleniyor...');
        for (var dersSnapshot in dersSnapshots) {
          dersSnapshot.docs.forEach((doc) {
            print("Processing Ders Document: ${doc.id}");
            print("Ders data: ${doc.data()}");
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            builder.element('ders', nest: () {
              builder.element('gun', nest: data['gun']);
              builder.element('saat', nest: data['saat']);
              builder.element('sinif', nest: data['sinif']);
              builder.element('dersAdi', nest: data['dersAdi']);
              builder.element('ogretmen', nest: data['ogretmen'] ?? '');
              builder.element('tarih', nest: data['tarih'] ?? '');
            });
          });
        }
      });
    });

    final xmlDocument = builder.buildDocument();
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/ders.xml');
    await file
        .writeAsString(xmlDocument.toXmlString(pretty: true, indent: '  '));

    print('XML dosyası başarıyla sıfırlandı. Dosya yolu: $path/ders.xml');
  } catch (e) {
    print('Veri yükleme hatası: $e');
  }
}

// Öğretmenleri yükleyen fonksiyon
Future<List<Ogretmen>> loadOgretmenler() async {
  final dersler = await loadDersProgrami();
  final ogretmenler = dersler
      .where((ders) => ders.ogretmen != null)
      .map((ders) => ders.ogretmen!)
      .toSet()
      .toList();

  return ogretmenler;
}

// Ders programını yükleyen fonksiyon
Future<List<DersProgrami>> loadDersProgrami() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/ders.xml');

    if (!await file.exists()) {
      await resetXmlFile(); // Dosya yoksa XML dosyasını sıfırla
    }

    final String response = await file.readAsString();
    final document = xml.XmlDocument.parse(response);

    final ogretmenElements = document
        .findAllElements('ogretmenler')
        .single
        .findAllElements('ogretmen');
    final ogretmenler =
        ogretmenElements.map((e) => Ogretmen.fromXml(e)).toList();

    final dersElements =
        document.findAllElements('dersler').single.findAllElements('ders');
    final dersler =
        dersElements.map((e) => DersProgrami.fromXml(e, ogretmenler)).toList();

    for (final ogretmen in ogretmenler) {
      ogretmen.dersProgrami = dersler
          .where((ders) => ders.ogretmen?.adSoyad == ogretmen.adSoyad)
          .toList();
    }

    return dersler;
  } catch (e) {
    print('Veri yükleme hatası: $e');
    rethrow;
  }
}

// Ders programını kaydeden fonksiyon
Future<void> saveDersProgrami(List<DersProgrami> dersProgramiListesi) async {
  try {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('okul', nest: () {
      builder.element('ogretmenler', nest: () {
        for (var ogretmen in dersProgramiListesi
            .where((ders) => ders.ogretmen != null)
            .map((ders) => ders.ogretmen!)
            .toSet()) {
          builder.element('ogretmen', nest: () {
            builder.element('adSoyad', nest: ogretmen.adSoyad);
            builder.element('brans', nest: ogretmen.brans);
          });
        }
      });
      builder.element('dersler', nest: () {
        for (var ders in dersProgramiListesi) {
          builder.element('ders', nest: () {
            builder.element('gun', nest: ders.gun);
            builder.element('saat', nest: ders.saat);
            builder.element('sinif', nest: ders.sinif);
            builder.element('dersAdi', nest: ders.dersAdi);
            builder.element('tarih', nest: ders.tarih ?? ''); // Tarihi ekle
            if (ders.ogretmen != null) {
              builder.element('ogretmen', nest: ders.ogretmen!.adSoyad);
            }
          });
        }
      });
    });

    final xmlDocument = builder.buildDocument();

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/ders.xml');
    await file.writeAsString(xmlDocument.toXmlString(pretty: true));

    print('Veriler başarıyla kaydedildi: $path/ders.xml');
  } catch (e) {
    print('Veri kaydetme hatası: $e');
  }
}

// Ana fonksiyon
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize bindings
  await resetXmlFile(); // Reset XML file after initialization

  final ogretmenler = await loadOgretmenler(); // Öğretmenleri yükle
  final dersler = await loadDersProgrami(); // Ders programını yükle

  // Demo amaçlı: öğretmen ve dersleri yazdır
  ogretmenler.forEach((ogretmen) {
    print('Öğretmen: ${ogretmen.adSoyad}, Branş: ${ogretmen.brans}');
    ogretmen.dersProgrami.forEach((ders) {
      print(
          'Ders: ${ders.dersAdi}, Tarih: ${ders.tarih}, Saat: ${ders.saat}, Sınıf: ${ders.sinif}');
    });
  });
}
