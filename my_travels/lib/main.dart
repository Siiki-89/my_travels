import 'package:flutter/material.dart';
import 'package:my_travels/provider/navigator_provider.dart';
import 'package:my_travels/view/page/add_user_page.dart';
import 'package:my_travels/view/page/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NavigatorProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      initialRoute: '/home',
      routes: {'/home': (_) => HomePage(), '/addUser': (_) => AddUserPage()},
    );
  }
}
