// lib/main.dart
import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/data/repository/preferences_repository.dart'; 
import 'package:my_travels/presentation/provider/theme_provider.dart'; 
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  final preferencesRepository = PreferencesRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => TravelerProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferencesRepository),
        ),
      ],
      child: const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF176FF2),
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            brightness: Brightness.dark, 
            primarySwatch:
                Colors.indigo, 
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(
                0xFF2C3E50,
              ), 
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF34495E),
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/navigator',
          routes: {
            '/navigator': (_) => NavigatorPage(),
            '/home': (_) => const HomePage(),
            '/travelers': (_) => const TravelersPage(),
            '/settings': (_) => const SettingsPage(), 
          },
        );
      },
    );
  }
}
