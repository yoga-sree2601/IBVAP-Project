import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  AppColors get colors => _isDark ? AppColors.dark : AppColors.light;
  Brightness get brightness => _isDark ? Brightness.dark : Brightness.light;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
