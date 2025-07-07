import 'package:flutter/material.dart';
import 'package:my_travels/view/page/travelers_page.dart';
import 'package:my_travels/view/page/home_page.dart';
import 'package:my_travels/view/page/settings_page.dart';

class NavigatorProvider extends ChangeNotifier {
  int _current = 1;
  int get current => _current;

  set current(int i) {
    _current = i;
    notifyListeners();
  }
}
