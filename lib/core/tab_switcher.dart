import 'package:flutter/foundation.dart';

/// Provides a way for child screens to switch tabs in the parent shell.
class TabSwitcher extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void switchTo(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
