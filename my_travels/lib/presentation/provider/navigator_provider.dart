import 'package:flutter/material.dart';

class NavigatorProvider extends ChangeNotifier {
  int _current = 1;
  int get current => _current;

  final Map<int, int> _tapCounters = {0: 0, 1: 0, 2: 0};
  Map<int, int> get tapCounters => _tapCounters;

  void selectTab(int index) {
    _current = index;

    _tapCounters[index] = _tapCounters[index]! + 1;
    notifyListeners();
  }
}
