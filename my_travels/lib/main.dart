// lib/main.dart
import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/pages/create_travel_page.dart';
import 'package:my_travels/presentation/pages/info_travel_page.dart';
import 'package:my_travels/presentation/pages/map_page.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/provider/travel_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/data/repository/preferences_repository.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  final preferencesRepository = PreferencesRepository();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => TravelerProvider()),
        ChangeNotifierProvider(create: (_) => TravelProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferencesRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(preferencesRepository),
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
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppLocalizations.of(context)?.appName ?? 'My Travels',
          theme: ThemeData(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.black,
              scrolledUnderElevation: 0.0, // <-- Adicione esta linha
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF176FF2),
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedIconTheme: IconThemeData(color: Color(0xFF176FF2)),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2C3E50),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF34495E),
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,

          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],

          initialRoute: '/navigator',
          routes: {
            '/navigator': (_) => NavigatorPage(),
            '/home': (_) => const HomePage(),
            '/travelers': (_) => TravelersPage(),
            '/settings': (_) => const SettingsPage(),
            '/addTravel': (_) => const CreateTravelPage(),
            '/mappage': (_) => const MapPage(),
            '/infoTravel': (_) => const InfoTravelPage(),
          },
        );
      },
    );
  }
}
