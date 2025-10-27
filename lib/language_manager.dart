import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager with ChangeNotifier {
  // Singleton pattern
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal() {
    _init();
  }

  // Constants
  static const String _languageKey = 'app_language';
  static const List<String> supportedLanguages = ['ru', 'en', 'de'];
  static const Map<String, String> languageNames = {
    'ru': 'Русский',
    'en': 'English',
    'de': 'Deutsch',
  };
  static const Map<String, String> languageFlags = {
    'ru': '🇷🇺',
    'en': '🇬🇧',
    'de': '🇩🇪',
  };

  // State
  Locale _currentLocale = const Locale('ru', 'RU');
  bool _isLoading = false;
  bool _isInitialized = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  // Getters
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Future<void> get initializationComplete => _initializationCompleter.future;

  // Public methods
  Future<void> _init() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null && supportedLanguages.contains(savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
      } else {
        // Default to Russian
        _currentLocale = const Locale('ru', 'RU');
        await prefs.setString(_languageKey, 'ru');
      }

      _isInitialized = true;
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }

      print('LanguageManager initialized with: ${_currentLocale.languageCode}');
    } catch (e) {
      print('Error initializing LanguageManager: $e');
      _currentLocale = const Locale('ru', 'RU');
      _isInitialized = true;
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_isLoading || !supportedLanguages.contains(languageCode)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      _currentLocale = Locale(languageCode);

      print('Language changed to: $languageCode');
    } catch (e) {
      print('Error changing language: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRussian() async => await setLanguage('ru');
  Future<void> setEnglish() async => await setLanguage('en');
  Future<void> setGerman() async => await setLanguage('de');

  // Utility methods
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🏳️';
  }

  String getCurrentLanguageName() {
    return getLanguageName(currentLanguageCode);
  }

  String getCurrentLanguageFlag() {
    return getLanguageFlag(currentLanguageCode);
  }

  bool isCurrentLanguage(String languageCode) {
    return currentLanguageCode == languageCode;
  }

  // Static methods for easy access
  static String get currentLanguage => _instance.currentLanguageCode;
  static Locale get currentLocaleStatic => _instance.currentLocale; // Изменили имя

  static Future<void> changeLanguage(String languageCode) async {
    await _instance.setLanguage(languageCode);
  }

  static Future<void> changeToRussian() async => await _instance.setRussian();
  static Future<void> changeToEnglish() async => await _instance.setEnglish();
  static Future<void> changeToGerman() async => await _instance.setGerman();

  // For use in data files without context
  static List<String> get supportedLanguageCodes => supportedLanguages;

  static Map<String, String> get availableLanguages {
    return Map.fromEntries(
      supportedLanguages.map(
            (code) => MapEntry(code, '${languageNames[code]} ${languageFlags[code]}'),
      ),
    );
  }

  // Reset to default
  Future<void> resetToDefault() async {
    await setLanguage('ru');
  }

  // Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }
}

// Extension for easy access in widgets
extension LanguageManagerExtension on BuildContext {
  LanguageManager get languageManager => LanguageManager();
  String get currentLanguageCode => LanguageManager.currentLanguage;
  Locale get currentLocale => LanguageManager.currentLocaleStatic; // Используем исправленное имя
}