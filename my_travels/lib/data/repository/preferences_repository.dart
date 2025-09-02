import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const _themeKey = 'app_theme';
  static const _languageKey = 'app_language';

  Future<bool> getThemeMode() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getBool(_themeKey) ?? false;
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setBool(_themeKey, isDarkMode);
  }

  Future<String> getLanguageCode() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(_languageKey) ?? 'pt';
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setString(_languageKey, languageCode);
  }
}
