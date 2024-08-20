//theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  Color _themeColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  Color get themeColor => _themeColor;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  void toggleDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _saveToPrefs();
    notifyListeners();
  }

  void changeFontSize(double size) {
    _fontSize = size;
    _saveToPrefs();
    notifyListeners();
  }

  void changeThemeColor(Color color) {
    _themeColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  void _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _themeColor = Color(prefs.getInt('themeColor') ?? Colors.blue.value);
    notifyListeners();
  }

  void _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setInt('themeColor', _themeColor.value);
  }
}
