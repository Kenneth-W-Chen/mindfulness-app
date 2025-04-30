import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  // Custom gradients for reuse
  static const List<Color> darkGradient = [Color(0xFF141E30), Color(0xFF1A237E)];
  static const List<Color> lightGradient = [Color(0xFFFAD0C4), Color(0xFFFFD1FF)];
}






