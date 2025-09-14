import 'package:flutter/material.dart';

/// Manages the state for the main navigation, like a PageView or BottomNavigationBar.
class NavigatorProvider with ChangeNotifier {
  int _current = 1; // Default to the home screen (index 1)

  /// The index of the currently selected page or tab.
  int get current => _current;

  /// A controller to manage the page view, allowing for programmatic navigation.
  final PageController pageController = PageController(initialPage: 1);

  /// A map that tracks how many times each tab has been tapped.
  ///
  /// This can be used for features like "tap tab again to scroll to top".
  final Map<int, int> _tapCounters = {0: 0, 1: 0, 2: 0};
  Map<int, int> get tapCounters => _tapCounters;

  /// Selects a new tab or page.
  ///
  /// Updates the current index, increments the tap counter for that index,
  /// and notifies listeners to rebuild the UI.
  void selectTab(int index) {
    _current = index;
    _tapCounters[index] = _tapCounters[index]! + 1;
    notifyListeners();
  }
}
