import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_travels/data/local/database_service.dart';
import 'package:my_travels/data/repository/comment_repository.dart';
import 'package:my_travels/data/repository/preferences_repository.dart';
import 'package:my_travels/data/repository/travel_repository.dart';
import 'package:my_travels/data/repository/traveler_repository.dart';
import 'package:my_travels/domain/use_cases/traveler/delete_traveler_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/get_travelers_use_case.dart';
import 'package:my_travels/domain/use_cases/traveler/save_traveler_use_case.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/pages/create_travel_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/info_travel_page.dart';
import 'package:my_travels/presentation/pages/map_page.dart';
import 'package:my_travels/presentation/pages/navigator_page.dart';
import 'package:my_travels/presentation/pages/new_comment_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:my_travels/presentation/provider/locale_provider.dart';
import 'package:my_travels/presentation/provider/map_provider.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart';
import 'package:my_travels/presentation/provider/create_travel_provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/services/google_maps_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // 1. Construir Dependências (Singletons)
  // final dbService = DatabaseService.instance; // Não precisa ser uma variável local
  final preferencesRepository = PreferencesRepository();
  final googleMapsService = GoogleMapsService();

  final travelerRepository = TravelerRepository();
  final travelRepository = TravelRepository();
  final commentRepository = CommentRepository();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider.value(value: travelerRepository),
        Provider.value(value: travelRepository),
        Provider.value(value: commentRepository),
        Provider.value(value: googleMapsService),

        // UseCases
        Provider(
          create: (context) =>
              GetTravelersUseCase(context.read<TravelerRepository>()),
        ),
        Provider(
          create: (context) =>
              SaveTravelerUseCase(context.read<TravelerRepository>()),
        ),
        Provider(
          create: (context) =>
              DeleteTravelerUseCase(context.read<TravelerRepository>()),
        ),

        // Providers de UI globais
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),

        ChangeNotifierProvider<TravelerProvider>(
          create: (context) => TravelerProvider(
            getTravelersUseCase: context.read<GetTravelersUseCase>(),
            saveTravelerUseCase: context.read<SaveTravelerUseCase>(),
            deleteTravelerUseCase: context.read<DeleteTravelerUseCase>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => CreateTravelProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              HomeProvider(repository: context.read<TravelRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              MapProvider(googleMapsService: context.read<GoogleMapsService>()),
        ),

        ChangeNotifierProvider(
          create: (context) => InfoTravelProvider(
            travelRepository: context.read<TravelRepository>(),
            commentRepository: context.read<CommentRepository>(),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Travels',
          theme: lightMode(),
          darkTheme: darkMode(),
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

  // MODO CLARO
  ThemeData lightMode() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        onSurface: Colors.black,
        onSurfaceVariant: Colors.grey.shade800,
      ),
    );
  }

  // MODO ESCURO
  ThemeData darkMode() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.grey.shade300,
      ),
    );
  }
}
