import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'theme_settings';
  static const String _keyDark = 'is_dark_mode';

  Box? _box;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _isDarkMode = _box!.get(_keyDark, defaultValue: false) as bool;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    if (_box != null) {
      await _box!.put(_keyDark, _isDarkMode);
    }
    notifyListeners();
  }
}
