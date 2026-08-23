import 'package:flutter/material.dart';

class FabVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;
  bool get isVisible => _isVisible;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void setVisible(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }
}
