import 'package:flutter/material.dart';

class NavigatorProvider extends ChangeNotifier {
  int _current = 1;
  int get current => _current;

  // 1. Criamos um "mapa" para contar os cliques de cada aba
  final Map<int, int> _tapCounters = {0: 0, 1: 0, 2: 0};
  Map<int, int> get tapCounters => _tapCounters;

  // 2. Substituímos o "setter" por um método para ter mais controle
  void selectTab(int index) {
    _current = index;
    // 3. Incrementamos o contador da aba que foi tocada
    _tapCounters[index] = _tapCounters[index]! + 1;
    notifyListeners();
  }
}
