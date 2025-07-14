import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

class NavigatorPage extends StatelessWidget {
  final _pages = [TravelersPage(), const HomePage(), const SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final navigatorProvider = context.watch<NavigatorProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: _pages[navigatorProvider.current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigatorProvider.current,
        onTap: (value) => navigatorProvider.current = value,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: appLocalizations.users,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: appLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: appLocalizations.settings,
          ),
        ],
      ),
    );
  }
}
