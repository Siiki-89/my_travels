import 'package:flutter/widgets.dart';
import 'package:my_travels/data/repository/preferences_repository.dart';

class LocaleProvider with ChangeNotifier {
  final PreferencesRepository _preferencesRepository;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider(this._preferencesRepository) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _preferencesRepository.getLanguageCode();
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _preferencesRepository.saveLanguageCode(newLocale.languageCode);
      notifyListeners();
    }
  }
}
