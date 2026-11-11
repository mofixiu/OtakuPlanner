import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light or dark pages, remembered between launches.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const _key = 'dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_key) == true) {
      _themeMode = ThemeMode.dark;
      notifyListeners();
    }
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setBool(_key, isDarkMode));
  }
}
