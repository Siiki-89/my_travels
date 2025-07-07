import 'package:flutter/material.dart';
import 'package:my_travels/provider/navigator_provider.dart';
import 'package:my_travels/view/page/travelers_page.dart';
import 'package:my_travels/view/page/home_page.dart';
import 'package:my_travels/view/page/navigator_page.dart';
import 'package:my_travels/view/page/settings_page.dart';
import 'package:my_travels/view/provider/traveler_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => TravelerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: GoogleFonts.notoSans().fontFamily),
      color: Colors.white,
      initialRoute: '/navigator',
      routes: {
        '/navigator': (_) => NavigatorPage(),
        '/home': (_) => HomePage(),
        '/travelers': (_) => TravelersPage(),
        '/settings': (_) => SettingsPage(),
      },
    );
  }
}
