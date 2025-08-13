import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/navigator_provider.dart';
import 'package:my_travels/presentation/pages/travelers_page.dart';
import 'package:my_travels/presentation/pages/home_page.dart';
import 'package:my_travels/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

// 1. O widget agora é um StatefulWidget
class NavigatorPage extends StatefulWidget {
  const NavigatorPage({Key? key}) : super(key: key);

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

// 2. A classe de State usa o "mixin" TickerProviderStateMixin para poder controlar animações
class _NavigatorPageState extends State<NavigatorPage>
    with TickerProviderStateMixin {
  final _pages = [TravelersPage(), const HomePage(), const SettingsPage()];

  // 3. Criamos uma lista de controladores, um para cada ícone Lottie
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NavigatorProvider>();

    // 4. Inicializamos os controladores no initState
    _controllers = List.generate(_pages.length, (index) {
      return AnimationController(
        vsync: this,
        // AQUI VOCÊ DEFINE A DURAÇÃO DESEJADA PARA AS ANIMAÇÕES
        duration: const Duration(milliseconds: 1500), // Ex: 1.5 segundos
      );
    });

    // Dispara a animação do item inicial assim que a tela carrega
    _controllers[provider.current].forward();
  }

  @override
  void dispose() {
    // 5. É crucial descartar os controladores para liberar memória
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigatorProvider = context.watch<NavigatorProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[navigatorProvider.current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigatorProvider.current,
        onTap: (value) {
          // 6. O onTap agora tem duas responsabilidades:
          // a) Atualizar o estado no provider
          navigatorProvider.selectTab(value);
          // b) Comandar a animação para tocar desde o início
          _controllers[value].forward(from: 0.0);
        },
        // Todas as suas personalizações visuais são mantidas
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: [
          // Repetimos o padrão para cada item, agora usando o 'controller'
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 0
                  ? 'assets/images/lottie/navigation/person_selected.json'
                  : 'assets/images/lottie/navigation/person_default.json',
              width: 30,
              height: 30,
              // 7. Usamos o controlador dedicado em vez de 'animate' e 'key'
              controller: _controllers[0],
            ),
            label: appLocalizations.users,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 1
                  ? 'assets/images/lottie/navigation/home_selected.json'
                  : 'assets/images/lottie/navigation/home_default.json',
              width: 30,
              height: 30,
              controller: _controllers[1],
            ),
            label: appLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: Lottie.asset(
              navigatorProvider.current == 2
                  ? 'assets/images/lottie/navigation/settings_selected.json'
                  : 'assets/images/lottie/navigation/settings_default.json',
              width: 30,
              height: 30,
              controller: _controllers[2],
            ),
            label: appLocalizations.settings,
          ),
        ],
      ),
    );
  }
}
