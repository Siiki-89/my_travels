// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'trip_provider.dart';
import 'trip_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. O ChangeNotifierProvider cria e fornece uma instância de TripProvider.
    //    O 'create' garante que a instância seja criada apenas uma vez.
    //    Ele também lida com o 'dispose' do provider automaticamente.
    return ChangeNotifierProvider(
      create: (context) => TripProvider(),
      child: MaterialApp(
        title: 'Planejador de Viagem',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Configuração para usar o formato de data em Português (pt_BR)
        home: const TripScreen(),
      ),
    );
  }
}
