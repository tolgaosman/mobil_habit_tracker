import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'theme_settings';
  static const String _keyThemeMode = 'is_dark_mode';
  Box? _box;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    final isDark = _box!.get(_keyThemeMode, defaultValue: false) as bool;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    if (_box != null) {
      await _box!.put(_keyThemeMode, _themeMode == ThemeMode.dark);
    }
    notifyListeners();
  }
}
