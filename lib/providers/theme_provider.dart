import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/dao/preferencias_dao.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Modo Claro por defecto

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final val = await PreferenciasDao(db).get('theme_mode');
      if (val == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {
      _themeMode = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await PreferenciasDao(db).set('theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}
