import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static const String _useSystemThemeKey = 'use_system_theme';
  static const String _useDarkThemeKey = 'use_dark_theme';

  bool _useSystemTheme = true;
  bool _useDarkTheme = false;
  bool _isLoading = false;

  bool get useSystemTheme => _useSystemTheme;
  bool get useDarkTheme => _useDarkTheme;
  bool get isLoading => _isLoading;

  ThemeMode get themeMode {
    if (_useSystemTheme) return ThemeMode.system;
    return _useDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _useSystemTheme = prefs.getBool(_useSystemThemeKey) ?? true;
      _useDarkTheme = prefs.getBool(_useDarkThemeKey) ?? false;
    } catch (e) {
      print('Error loading theme settings: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setUseSystemTheme(bool value) async {
    if (_isLoading || _useSystemTheme == value) return;

    _isLoading = true;
    _useSystemTheme = value;
    if (value) {
      _useDarkTheme = false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemThemeKey, value);
      if (value) {
        await prefs.setBool(_useDarkThemeKey, false);
      }
      notifyListeners();
    } catch (e) {
      print('Error saving system theme: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setUseDarkTheme(bool value) async {
    if (_isLoading || _useDarkTheme == value) return;

    _isLoading = true;
    _useDarkTheme = value;
    if (value) {
      _useSystemTheme = false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useDarkThemeKey, value);
      if (value) {
        await prefs.setBool(_useSystemThemeKey, false);
      }
      notifyListeners();
    } catch (e) {
      print('Error saving dark theme: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setLightTheme() async {
    if (_isLoading || (!_useSystemTheme && !_useDarkTheme)) return;

    _isLoading = true;
    _useSystemTheme = false;
    _useDarkTheme = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemThemeKey, false);
      await prefs.setBool(_useDarkThemeKey, false);
      notifyListeners();
    } catch (e) {
      print('Error saving light theme: $e');
    } finally {
      _isLoading = false;
    }
  }
}