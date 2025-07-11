import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const String _themeKey = 'app_theme';

  Future<bool> getThemeMode() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getBool(_themeKey) ?? false;
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setBool(_themeKey, isDarkMode);
  }
}
