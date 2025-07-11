import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
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
