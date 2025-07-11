import 'package:flutter/material.dart';
import 'package:my_travels/presentation/provider/theme_provider.dart'; // Importe o ThemeProvider
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para observar as mudanças no ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Ativar ou desativar o tema escuro'),
            value:
                themeProvider.themeMode == ThemeMode.dark, // true se for dark
            onChanged: (bool value) {
              themeProvider.toggleTheme(); // Alterna o tema
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          // Adicione outras configurações aqui (ex: idioma)
        ],
      ),
    );
  }
}
