// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Light / Dark / System theme modes and persists the user’s choice.
class ThemeProvider with ChangeNotifier {
  static const String _modeKey = 'themeMode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final int index = prefs.getInt(_modeKey) ?? ThemeMode.system.index;
    _mode = ThemeMode.values[index];
    notifyListeners();
  }

  /// Call this to change the theme mode and persist the selection.
  Future<void> setMode(ThemeMode newMode) async {
    if (newMode == _mode) return;
    _mode = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, newMode.index);
    notifyListeners();
  }
}
