import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:teacher/Pages/etkinlik_takvimi_screen.dart';
import 'Settings/theme_notifier.dart';
import 'home_screen.dart';
import 'Pages/ders_programi_screen.dart';
import 'Pages/ders_doldurma_screen.dart';
import 'Settings/ders_ogretmen_model.dart'; // checkAndResetDatabase fonksiyonunu kullanmak için import edin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Veritabanı resetleme kontrolü
  await checkAndResetDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: themeNotifier.themeColor,
            brightness: Brightness.light,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: themeNotifier.fontSize),
              bodyMedium: TextStyle(fontSize: themeNotifier.fontSize),
            ),
          ),
          darkTheme: ThemeData(
            primaryColor: themeNotifier.themeColor,
            brightness: Brightness.dark,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: themeNotifier.fontSize),
              bodyMedium: TextStyle(fontSize: themeNotifier.fontSize),
            ),
          ),
          themeMode:
              themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale('tr', 'TR'), // Set locale to Turkish
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('tr', 'TR'), // Turkish locale
            const Locale('en', 'US'), // English locale for fallback
          ],
          home: HomeScreen(),
          routes: {
            '/dersProgrami': (context) => DersTakvimiScreen(),
            '/dersDoldurma': (context) => DersDoldurmaScreen(),
            '/etkinlikTakvimi': (context) => EtkinlikTakvimiScreen(),
          },
        );
      },
    );
  }
}
