import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';
import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.settings), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),

          width: double.infinity,
          height: 180,
          child: Column(
            children: [
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(appLocalizations.darkModeTitle),
                subtitle: Text(appLocalizations.darkModeSubtitle),
                hoverColor: Colors.white,
                thumbColor: WidgetStateProperty.all(Colors.black),
                trackColor: WidgetStateProperty.all(Colors.blue.shade100),
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
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<Locale>(
                      value: localeProvider.locale,
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          localeProvider.setLocale(newLocale);
                        }
                      },
                      items: AppLocalizations.supportedLocales.map((
                        Locale locale,
                      ) {
                        String languageName;
                        switch (locale.languageCode) {
                          case 'en':
                            languageName = 'English';
                            break;
                          case 'pt':
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
