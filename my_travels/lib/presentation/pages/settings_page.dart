import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';
import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.settings), centerTitle: true),
      body: ListView(
        children: [
          SizedBox(height: 20),
          SwitchListTile(
            title: Text(appLocalizations.darkModeTitle),
            subtitle: Text(appLocalizations.darkModeSubtitle),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: ListTile(
              title: Text(appLocalizations.language),
              trailing: DropdownButton<Locale>(
                value: localeProvider.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localeProvider.setLocale(newLocale);
                  }
                },
                items: AppLocalizations.supportedLocales.map((Locale locale) {
                  String languageName;
                  switch (locale.languageCode) {
                    case 'en':
                      languageName = 'English';
                      break;
                    case 'pt_BR':
                      languageName = 'Português';
                      break;
                    case 'es':
                      languageName = 'Español';
                      break;
                    default:
                      languageName = locale.languageCode;
                  }
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(languageName),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
