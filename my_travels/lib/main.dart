import 'package:flutter/material.dart';
import 'package:my_travels/provider/navigator_provider.dart';
import 'package:my_travels/provider/user_provider.dart';
import 'package:my_travels/view/page/add_user_page.dart';
import 'package:my_travels/view/page/home_page.dart';
import 'package:my_travels/view/page/navigator_page.dart';
import 'package:my_travels/view/page/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
        '/addUser': (_) => AddUserPage(),
        '/settings': (_) => SettingsPage(),
      },
    );
  }
}
