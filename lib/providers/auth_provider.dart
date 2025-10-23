import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  bool _serverAvailable = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  bool get serverAvailable => _serverAvailable;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkServerAvailability();
    await _checkLoginStatus();
  }

  Future<void> _checkServerAvailability() async {
    try {
      _serverAvailable = await _apiService.checkServerAvailability();
      notifyListeners();
    } catch (e) {
      _serverAvailable = false;
      notifyListeners();
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Проверяем локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      final localLogin = prefs.getBool('isLoggedIn') ?? false;

      if (localLogin && _serverAvailable) {
        // Проверяем серверный статус
        final serverLoggedIn = await _apiService.checkServerLoginStatus();

        if (serverLoggedIn) {
          _userData = await _apiService.getProfile();
          _isLoggedIn = true;
        } else {
          // Серверная сессия истекла, выходим
          await _logout();
        }
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      print('❌ Error checking login status: $e');
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _apiService.login(email, password);

      if (result['success'] == true) {
        _isLoggedIn = true;

        // Получаем данные профиля
        _userData = await _apiService.getProfile();

        notifyListeners();
        return {'success': true, 'message': 'Вход выполнен успешно'};
      } else {
        return result;
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Ошибка входа: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _apiService.register(name, email, password);

      if (result['success'] == true) {
        _isLoggedIn = true;

        // Получаем данные профиля
        _userData = await _apiService.getProfile();

        notifyListeners();
        return {'success': true, 'message': 'Регистрация успешна'};
      } else {
        return result;
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return {'success': false, 'message': 'Ошибка регистрации: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.logout();
      await _logout();
    } catch (e) {
      print('❌ Logout error: $e');
      await _logout(); // Все равно очищаем локальные данные
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _logout() async {
    _isLoggedIn = false;
    _userData = null;

    notifyListeners();
  }

  Future<void> refreshServerStatus() async {
    await _checkServerAvailability();
    if (_serverAvailable && _isLoggedIn) {
      await _checkLoginStatus();
    }
  }
}