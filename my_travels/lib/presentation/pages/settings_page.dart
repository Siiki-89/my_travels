import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart'; 
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Ativar ou desativar o tema escuro'),
            value:
                themeProvider.themeMode == ThemeMode.dark, 
            onChanged: (bool value) {
              themeProvider.toggleTheme(); 
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
    );
  }
}
