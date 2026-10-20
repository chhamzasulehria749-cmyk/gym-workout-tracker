import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String boxName = 'settingsBox';
  static const String darkModeKey = 'darkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final box = Hive.box(boxName);

    _isDarkMode = box.get(darkModeKey, defaultValue: false);

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final box = Hive.box(boxName);

    await box.put(darkModeKey, _isDarkMode);

    notifyListeners();
  }
}
