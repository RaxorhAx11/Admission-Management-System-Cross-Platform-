import 'package:flutter/material.dart';

import 'package:admission_management/core/theme/app_theme.dart';

/// Simple theme state: light or dark. Used by Settings and MaterialApp.
class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get theme => _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
