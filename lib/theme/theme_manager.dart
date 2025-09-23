import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static const String _useSystemThemeKey = 'use_system_theme';
  static const String _useDarkThemeKey = 'use_dark_theme';

  bool _useSystemTheme = true;
  bool _useDarkTheme = false;

  bool get useSystemTheme => _useSystemTheme;
  bool get useDarkTheme => _useDarkTheme;
  ThemeMode get themeMode {
    if (_useSystemTheme) return ThemeMode.system;
    return _useDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useSystemTheme = prefs.getBool(_useSystemThemeKey) ?? true;
    _useDarkTheme = prefs.getBool(_useDarkThemeKey) ?? false;
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    if (value) {
      _useDarkTheme = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemThemeKey, value);
    if (value) {
      await prefs.setBool(_useDarkThemeKey, false);
    }

    notifyListeners();
  }

  Future<void> setUseDarkTheme(bool value) async {
    _useDarkTheme = value;
    if (value) {
      _useSystemTheme = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDarkThemeKey, value);
    if (value) {
      await prefs.setBool(_useSystemThemeKey, false);
    }

    notifyListeners();
  }

  Future<void> setLightTheme() async {
    _useSystemTheme = false;
    _useDarkTheme = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemThemeKey, false);
    await prefs.setBool(_useDarkThemeKey, false);

    notifyListeners();
  }
}