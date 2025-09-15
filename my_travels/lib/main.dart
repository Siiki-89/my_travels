import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/data/repository/preferences_repository.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/use_cases/comment/save_comment_use_case.dart';
import 'package:my_travels/domain/use_cases/travel/save_travel_use_case.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/domain/use_cases/travel/delete_travel_use_case.dart';
import 'package:my_travels/domain/use_cases/travel/update_travel_status_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/delete_traveler_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/get_travelers_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/save_traveler_use_case.dart';
import 'package:my_travels/presentation/pages/create_travel_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/info_travel_page.dart';
import 'package:my_travels/presentation/pages/map_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/new_comment_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/services/google_maps_service.dart';

/// The main entry point of the application.
void main() async {
  // Ensures that Flutter bindings are initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // Loads environment variables from the .env file.
  await dotenv.load();

  // 1. Build Dependencies (Singletons) that will be provided to the app.
  final preferencesRepository = PreferencesRepository();
  final googleMapsService = GoogleMapsService();
  final travelerRepository = TravelerRepository();
  final travelRepository = TravelRepository();
  final commentRepository = CommentRepository();

  runApp(
    // MultiProvider injects all app-level providers into the widget tree.
    MultiProvider(
      providers: [
        // Providing existing instances of repositories and services.
        Provider.value(value: travelerRepository),
        Provider.value(value: travelRepository),
        Provider.value(value: commentRepository),
        Provider.value(value: googleMapsService),

        Provider(create: (_) => SaveCommentUseCase(commentRepository)),

        // Global UI Providers
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(
          create: (context) => TravelerProvider(
            getTravelersUseCase: GetTravelersUseCase(travelerRepository),
            saveTravelerUseCase: SaveTravelerUseCase(travelerRepository),
            deleteTravelerUseCase: DeleteTravelerUseCase(travelerRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CreateTravelProvider(
            saveTravelUseCase: SaveTravelUseCase(travelRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(repository: travelRepository),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MapProvider(googleMapsService: googleMapsService),
        ),
        ChangeNotifierProvider(
          create: (context) => InfoTravelProvider(
            travelRepository: travelRepository,
            commentRepository: commentRepository,
            deleteTravelUseCase: DeleteTravelUseCase(travelRepository),
            updateTravelStatusUseCase: UpdateTravelStatusUseCase(
              travelRepository,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ThemeProvider(preferencesRepository: preferencesRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocaleProvider(preferencesRepository: preferencesRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer2 listens to two providers and rebuilds when either of them changes.
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Travels',
          theme: _lightMode(),
          darkTheme: _darkMode(),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales, // More robust
          initialRoute: '/navigator',
          routes: {
            '/navigator': (_) => const NavigatorPage(),
            '/home': (_) => const HomePage(),
            '/travelers': (_) => const TravelersPage(),
            '/settings': (_) => const SettingsPage(),
            '/addTravel': (_) => const CreateTravelPage(),
            '/mappage': (_) => const MapPage(),
            '/infoTravel': (_) => const InfoTravelPage(),
            '/newcomment': (_) => const NewCommentPage(),
          },
        );
      },
    );
  }

  /// Defines the light theme for the application.
  ThemeData _lightMode() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  /// Defines the dark theme for the application.
  ThemeData _darkMode() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
