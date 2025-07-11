import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_travels/data/repository/preferences_repository.dart';

class ThemeProvider with ChangeNotifier {
  final PreferencesRepository _preferencesRepository;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider(this._preferencesRepository) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDarkMode = await _preferencesRepository.getThemeMode();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _preferencesRepository.saveThemeMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      _preferencesRepository.saveThemeMode(_themeMode == ThemeMode.dark);
      notifyListeners();
    }
  }
}
