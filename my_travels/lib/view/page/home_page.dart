import 'package:flutter/material.dart';
import 'package:my_travels/provider/navigator_provider.dart';
import 'package:my_travels/view/page/add_user_page.dart';
import 'package:my_travels/view/page/settings_page.dart';
import 'package:my_travels/view/page/teste_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final _pages = [AddUserPage(), TestePage(), SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigatorProvider>(
      builder: (context, nav, _) => Scaffold(
        body: _pages[nav.current],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: nav.current,
          onTap: (value) => nav.current = value,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Travelers',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
