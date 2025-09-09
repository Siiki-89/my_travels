import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:provider/provider.dart';

class NavigatorPage extends StatelessWidget {
  const NavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigatorProvider = context.watch<NavigatorProvider>();
    final loc = AppLocalizations.of(context)!;

    final pages = [
      const TravelersPage(),
      const HomePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: PageView(
        controller: navigatorProvider.pageController,
        physics: const BouncingScrollPhysics(),
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
        showUnselectedLabels: false,

        // Define se o texto do item SELECIONADO deve aparecer.
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
            label: loc.users,
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
            label: loc.home,
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
            label: loc.settings,
          ),
        ],
      ),
    );
  }
}
