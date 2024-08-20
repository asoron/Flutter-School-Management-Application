//home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/settings_screen.dart';
import 'Settings/theme_notifier.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ana Ekran',
          style: TextStyle(
            color: themeNotifier.isDarkMode ? Colors.white : Colors.white,
            fontSize: themeNotifier.fontSize,
          ),
        ),
        backgroundColor: themeNotifier.themeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(
                context,
                title: 'Ders Programı',
                icon: Icons.menu_book,
                route: '/dersProgrami',
              ),
              const SizedBox(height: 20.0),
              _buildMenuButton(
                context,
                title: 'Ders Doldurma',
                icon: Icons.edit,
                route: '/dersDoldurma',
              ),
              const SizedBox(height: 20.0),
              _buildMenuButton(
                context,
                title: 'Etkinlik Takvimi',
                icon: Icons.calendar_today,
                route: '/etkinlikTakvimi',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title, required IconData icon, required String route}) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeNotifier.themeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60.0,
            color: Colors.white,
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
