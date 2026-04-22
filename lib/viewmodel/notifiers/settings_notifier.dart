import 'package:flutter/material.dart';

class SettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }
}

