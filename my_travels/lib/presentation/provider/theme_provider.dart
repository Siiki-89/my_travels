import 'package:flutter/material.dart';

import 'package:my_travels/data/repository/preferences_repository.dart';

/// Manages the application's current theme (light or dark mode).
class ThemeProvider with ChangeNotifier {
  final PreferencesRepository _preferencesRepository;
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode.

  /// The currently active theme mode for the application.
  ThemeMode get themeMode => _themeMode;

  /// Creates an instance of [ThemeProvider].
  ///
  /// Requires a [PreferencesRepository] to load and save the theme setting.
  /// The initial theme is loaded asynchronously upon creation.
  ThemeProvider({required PreferencesRepository preferencesRepository})
    : _preferencesRepository = preferencesRepository {
    _loadTheme();
  }

  /// Loads the saved theme from preferences.
  Future<void> _loadTheme() async {
    try {
      final isDarkMode = await _preferencesRepository.getThemeMode();
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      _themeMode = ThemeMode.light; // Fallback to light mode on error.
      // debugPrint('Error loading theme: $e');
    }
    notifyListeners();
  }

  /// Toggles the current theme between light and dark mode and persists the change.
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // Notify UI first for instant feedback.
    await _preferencesRepository.saveThemeMode(_themeMode == ThemeMode.dark);
  }

  /// Sets the theme to a specific [ThemeMode] and persists the change.
  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners(); // Notify UI first for instant feedback.
      await _preferencesRepository.saveThemeMode(_themeMode == ThemeMode.dark);
    }
  }
}
