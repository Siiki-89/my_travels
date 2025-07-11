// lib/main.dart
import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/data/repository/preferences_repository.dart'; // Importe o PreferencesRepository
import 'package:my_travels/presentation/provider/theme_provider.dart'; // Importe o ThemeProvider
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // Instância do PreferencesRepository criada aqui para ser passada ao ThemeProvider
  final preferencesRepository = PreferencesRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => TravelerProvider()),
        // NOVO: Adicionando o ThemeProvider ao MultiProvider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferencesRepository),
        ),
      ],
      child: const MyApp(), // MyApp agora é constante
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
            brightness: Brightness.dark, // Tema escuro
            primarySwatch:
                Colors.indigo, // Um primarySwatch diferente para o tema escuro
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(
                0xFF2C3E50,
              ), // Cor mais escura para AppBar no tema escuro
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF34495E),
              foregroundColor: Colors.white,
            ),
            // Outras customizações para o tema escuro
          ),
          // NOVO: Usando o themeMode do ThemeProvider
          themeMode: themeProvider.themeMode,
          // Remover `color: Colors.white` pois `brightness` do ThemeData já controla o background.
          // color: Colors.white, // Remova esta linha
          initialRoute: '/navigator',
          routes: {
            '/navigator': (_) => NavigatorPage(), // Torne constante
            '/home': (_) => const HomePage(), // Torne constante
            '/travelers': (_) => const TravelersPage(), // Torne constante
            '/settings': (_) => const SettingsPage(), // Torne constante
          },
        );
      },
    );
  }
}
