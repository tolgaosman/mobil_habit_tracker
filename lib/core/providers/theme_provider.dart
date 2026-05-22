import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode => ThemeMode.light;
  bool get isDarkMode => false;

  void toggleTheme() {}
}
