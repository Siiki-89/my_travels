import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';

/// A widget that handles the main navigation of the app using a PageView
/// and a BottomNavigationBar.
class NavigatorPage extends StatelessWidget {
  /// Creates an instance of [NavigatorPage].
  const NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorProvider = context.watch<NavigatorProvider>();
    final l10n = AppLocalizations.of(context)!;

    // A list of the pages to be displayed in the PageView.
    final pages = [
      const TravelersPage(),
      const HomePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: PageView(
        controller: navigatorProvider.pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: navigatorProvider.selectTab,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigatorProvider.current,
        onTap: (index) {
          navigatorProvider.selectTab(index);
          navigatorProvider.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        // Hides the labels for a cleaner look with Lottie animations.
        showUnselectedLabels: false,
        showSelectedLabels: false,
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
              key: ValueKey('person_${navigatorProvider.current}'),
              animate: navigatorProvider.current == 0,
            ),
            label: l10n.users,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 1
                  ? 'assets/images/lottie/navigation/home_selected.json'
                  : 'assets/images/lottie/navigation/home_default.json',
              width: 30,
              height: 30,
              repeat: false,
              key: ValueKey('home_${navigatorProvider.current}'),
              animate: navigatorProvider.current == 1,
            ),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 2
                  ? 'assets/images/lottie/navigation/settings_selected.json'
                  : 'assets/images/lottie/navigation/settings_default.json',
              width: 30,
              height: 30,
              repeat: false,
              key: ValueKey('settings_${navigatorProvider.current}'),
              animate: navigatorProvider.current == 2,
            ),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
