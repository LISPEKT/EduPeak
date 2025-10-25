import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager with ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _currentLocale = const Locale('ru', 'RU');
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  LanguageManager() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'ru';
      _currentLocale = Locale(languageCode);
    } catch (e) {
      print('Error loading language: $e');
      _currentLocale = const Locale('ru', 'RU');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      _currentLocale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      print('Error saving language: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setRussian() async => await setLanguage('ru');
  Future<void> setEnglish() async => await setLanguage('en');
  Future<void> setGerman() async => await setLanguage('de');
}