import 'package:shared_preferences/shared_preferences.dart';

/// Manages user preferences stored locally on the device. ⚙️
///
/// This class provides a simple interface to save and retrieve
/// settings like theme mode and language code using `SharedPreferences`.
class PreferencesRepository {
  /// The key used to store the theme mode preference (true for dark mode).
  static const _themeKey = 'app_theme';

  /// The key used to store the language code preference (e.g., 'en', 'pt').
  static const _languageKey = 'app_language';

  /// Retrieves the saved theme mode.
  ///
  /// Returns `true` if dark mode is enabled.
  /// Defaults to `false` (light mode) if no preference is set.
  Future<bool> getThemeMode() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getBool(_themeKey) ?? false;
  }

  /// Saves the user's theme mode preference.
  ///
  /// [isDarkMode] should be `true` to enable dark mode, `false` for light mode.
  Future<void> saveThemeMode(bool isDarkMode) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setBool(_themeKey, isDarkMode);
  }

  /// Retrieves the saved language code.
  ///
  /// Defaults to `'pt'` (Portuguese) if no language code is set.
  Future<String> getLanguageCode() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(_languageKey) ?? 'pt';
  }

  /// Saves the user's language code preference.
  ///
  /// [languageCode] should be a two-letter language code (e.g., 'en', 'es').
  Future<void> saveLanguageCode(String languageCode) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setString(_languageKey, languageCode);
  }
}
