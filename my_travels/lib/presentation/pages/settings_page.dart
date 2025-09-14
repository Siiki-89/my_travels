// In lib/presentation/pages/settings_page.dart

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';

/// A page for displaying and changing application settings.
class SettingsPage extends StatelessWidget {
  /// Creates an instance of [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          // The main column is now cleaner, using self-contained widgets.
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [_ThemeSettingItem(), _LanguageSettingItem()],
          ),
        ),
      ),
    );
  }
}

/// A private widget for the Theme (Dark Mode) setting.
class _ThemeSettingItem extends StatelessWidget {
  const _ThemeSettingItem();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      title: Text(l10n.darkModeTitle),
      subtitle: Text(l10n.darkModeSubtitle),
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (_) => themeProvider.toggleTheme(),
      secondary: Icon(
        themeProvider.themeMode == ThemeMode.dark
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      // Using theme colors for better consistency.
      activeColor: colorScheme.primary,
    );
  }
}

/// A private widget for the Language setting.
class _LanguageSettingItem extends StatelessWidget {
  const _LanguageSettingItem();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(l10n.language),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton2<Locale>(
          value: localeProvider.locale,
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              localeProvider.setLocale(newLocale);
            }
          },
          items: AppLocalizations.supportedLocales.map((locale) {
            String languageName;
            switch (locale.languageCode) {
              case 'en':
                languageName = l10n.languageNameEnglish;
                break;
              case 'pt':
                languageName = l10n.languageNamePortuguese;
                break;
              case 'es':
                languageName = l10n.languageNameSpanish;
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
    );
  }
}
