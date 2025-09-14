import 'package:flutter/widgets.dart';

import 'package:my_travels/data/repository/preferences_repository.dart';

/// Manages the application's current locale (language).
class LocaleProvider with ChangeNotifier {
  final PreferencesRepository _preferencesRepository;
  Locale _locale = const Locale('en'); // Default to English.

  /// The currently active locale for the application.
  Locale get locale => _locale;

  /// Creates an instance of [LocaleProvider].
  ///
  /// Requires a [PreferencesRepository] to load and save the language setting.
  /// The initial locale is loaded asynchronously upon creation.
  LocaleProvider({required PreferencesRepository preferencesRepository})
    : _preferencesRepository = preferencesRepository {
    _loadLocale();
  }

  /// Loads the saved locale from preferences.
  Future<void> _loadLocale() async {
    try {
      final languageCode = await _preferencesRepository.getLanguageCode();
      _locale = Locale(languageCode);
    } catch (e) {
      _locale = const Locale('en'); // Fallback to English on error.
      // debugPrint('Error loading locale: $e');
    }
    notifyListeners();
  }

  /// Sets a new locale for the application and persists it.
  ///
  /// If the [newLocale] is different from the current one, it updates the state,
  /// notifies listeners immediately for a responsive UI, and then saves the
  /// new language code to preferences.
  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      notifyListeners(); // Notify UI first for instant feedback.
      await _preferencesRepository.saveLanguageCode(newLocale.languageCode);
    }
  }
}
