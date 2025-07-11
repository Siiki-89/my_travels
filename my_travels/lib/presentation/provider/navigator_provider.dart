import 'package:flutter/material.dart';

class NavigatorProvider extends ChangeNotifier {
  int _current = 1;
  int get current => _current;

  set current(int i) {
    _current = i;
    notifyListeners();
  }
}
