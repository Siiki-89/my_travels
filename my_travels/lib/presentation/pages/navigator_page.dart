import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

class NavigatorPage extends StatelessWidget {
  final _pages = [TravelersPage(), const HomePage(), const SettingsPage()];

  NavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigatorProvider = context.watch<NavigatorProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[navigatorProvider.current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigatorProvider.current,
        onTap: (value) => navigatorProvider.selectTab(value),

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: [
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 0
                  ? 'assets/images/lottie/navigation/person_selected.json'
                  : 'assets/images/lottie/navigation/person_default.json',
              width: 30,
              height: 30,
              repeat: false,
              key: ValueKey('person_${navigatorProvider.tapCounters[0]}'),
              animate: navigatorProvider.current == 0,
            ),
            label: appLocalizations.users,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 1
                  ? 'assets/images/lottie/navigation/home_selected.json'
                  : 'assets/images/lottie/navigation/home_default.json',
              width: 30,
              height: 30,
              repeat: false,
              key: ValueKey('home_${navigatorProvider.tapCounters[1]}'),
              animate: navigatorProvider.current == 1,
            ),
            label: appLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 2
                  ? 'assets/images/lottie/navigation/settings_selected.json'
                  : 'assets/images/lottie/navigation/settings_default.json',
              width: 30,
              height: 30,
              repeat: false,
              key: ValueKey('settings_${navigatorProvider.tapCounters[2]}'),
              animate: navigatorProvider.current == 2,
            ),
            label: appLocalizations.settings,
          ),
        ],
      ),
    );
  }
}
