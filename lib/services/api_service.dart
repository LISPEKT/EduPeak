// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://46.254.19.119';

  // Получаем CSRF токен
  static Future<String?> _getCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanctum/csrf-cookie'),
      );

      print('🛡️ CSRF Response status: ${response.statusCode}');
      print('🛡️ CSRF Cookies: ${response.headers['set-cookie']}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          // Ищем XSRF-TOKEN в cookies
          final xsrfMatch = RegExp('XSRF-TOKEN=([^;]+)').firstMatch(cookies);
          if (xsrfMatch != null) {
            final token = Uri.decodeComponent(xsrfMatch.group(1)!);
            print('🛡️ CSRF Token received: $token');
            return token;
          }

          // Также проверяем laravel_session
          final sessionMatch = RegExp('laravel_session=([^;]+)').firstMatch(cookies);
          if (sessionMatch != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('laravel_session', sessionMatch.group(1)!);
            print('🛡️ Laravel session saved');
          }
        }
      }
    } catch (e) {
      print('❌ Error getting CSRF token: $e');
    }
    return null;
  }

  // Универсальный метод запроса
  static Future<Map<String, dynamic>> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🚀 Making $method request to: $endpoint');

      // Получаем CSRF токен
      final csrfToken = await _getCsrfToken();
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('laravel_session');

      final url = Uri.parse('$baseUrl$endpoint');

      // Формируем заголовки
      final headers = {
        'Accept': 'application/json, text/plain, */*',
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/x-www-form-urlencoded',
        if (csrfToken != null) 'X-XSRF-TOKEN': csrfToken,
      };

      // Формируем cookies
      final cookieParts = <String>[];
      if (sessionCookie != null) cookieParts.add('laravel_session=$sessionCookie');
      if (csrfToken != null) cookieParts.add('XSRF-TOKEN=$csrfToken');
      if (cookieParts.isNotEmpty) {
        headers['Cookie'] = cookieParts.join('; ');
      }

      print('📋 Headers: $headers');
      if (data != null) print('📦 Data: $data');

      http.Response response;

      // Преобразуем данные в form-urlencoded
      String? body;
      if (data != null) {
        body = data.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
      }

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      // Сохраняем cookies из ответа
      _saveCookies(response.headers, prefs);

      // Обрабатываем ответ
      return _handleResponse(response, endpoint);
    } catch (e) {
      print('❌ Request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Сохраняем cookies из ответа
  static void _saveCookies(Map<String, String> headers, SharedPreferences prefs) {
    final cookies = headers['set-cookie'];
    if (cookies != null) {
      print('🍪 Received cookies: $cookies');

      final sessionMatch = RegExp('laravel_session=([^;]+)').firstMatch(cookies);
      if (sessionMatch != null) {
        prefs.setString('laravel_session', sessionMatch.group(1)!);
        print('🍪 Laravel session saved: ${sessionMatch.group(1)}');
      }

      final xsrfMatch = RegExp('XSRF-TOKEN=([^;]+)').firstMatch(cookies);
      if (xsrfMatch != null) {
        final token = Uri.decodeComponent(xsrfMatch.group(1)!);
        print('🍪 XSRF Token received: $token');
      }
    }
  }

  // Обрабатываем ответ сервера
  static Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    final body = response.body.trim();

    print('🔍 Response analysis for $endpoint:');
    print('🔍 Status: ${response.statusCode}');
    print('🔍 Body starts with: ${body.length > 50 ? body.substring(0, 50) + '...' : body}');

    // Проверяем, это HTML страница ошибки
    if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
      if (response.statusCode == 404) {
        throw Exception('Endpoint $endpoint not found (404)');
      } else if (response.statusCode == 419) {
        throw Exception('CSRF token mismatch (419)');
      } else if (response.statusCode == 500) {
        throw Exception('Server error (500)');
      } else {
        throw Exception('Server returned HTML. Status: ${response.statusCode}');
      }
    }

    // Пробуем распарсить JSON
    try {
      if (body.isEmpty) {
        return {'success': true, 'message': 'Empty response'};
      }

      final jsonResponse = json.decode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {...jsonResponse, 'success': true};
      } else {
        final error = jsonResponse['message'] ??
            jsonResponse['error'] ??
            'Server error: ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      // Если не JSON, но статус успешный - возвращаем успех
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Operation completed'};
      }
      throw Exception('Invalid response format: $e');
    }
  }

  // === АУТЕНТИФИКАЦИЯ ===

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');

      final result = await _makeRequest(
        method: 'POST',
        endpoint: '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Сохраняем статус авторизации
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        await saveUsername(email.split('@').first);
        print('✅ Login successful');
      }

      return result;
    } catch (e) {
      print('❌ Login failed: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('👤 Attempting registration for: $email');

      final result = await _makeRequest(
        method: 'POST',
        endpoint: '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      // Сохраняем статус авторизации
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        await saveUsername(name);
        print('✅ Registration successful');
      }

      return result;
    } catch (e) {
      print('❌ Registration failed: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logout() async {
    try {
      print('🚪 Attempting logout');
      await _makeRequest(method: 'POST', endpoint: '/logout');
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_email');
      await prefs.remove('laravel_session');
      print('🧹 User data cleared');
    }
  }

  // === ПРОФИЛЬ ===

  static Future<Map<String, dynamic>> updateAvatar(String imagePath) async {
    try {
      final csrfToken = await _getCsrfToken();
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('laravel_session');

      final url = Uri.parse('$baseUrl/profile/avatar');
      final request = http.MultipartRequest('POST', url);

      request.headers['X-Requested-With'] = 'XMLHttpRequest';
      if (csrfToken != null) request.headers['X-XSRF-TOKEN'] = csrfToken;

      final cookieParts = <String>[];
      if (sessionCookie != null) cookieParts.add('laravel_session=$sessionCookie');
      if (csrfToken != null) cookieParts.add('XSRF-TOKEN=$csrfToken');
      if (cookieParts.isNotEmpty) {
        request.headers['Cookie'] = cookieParts.join('; ');
      }

      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));
      request.fields['_token'] = csrfToken ?? '';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(responseBody);
        return {'success': true, ...jsonResponse};
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // === ЛОКАЛЬНОЕ ХРАНЕНИЕ ===

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('username');
    await prefs.remove('laravel_session');
    await prefs.remove('user_avatar_path');
  }

  // === УТИЛИТЫ ===

  static Future<bool> checkServerAvailability() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      final available = response.statusCode == 200;
      print('🌐 Server available: $available (${response.statusCode})');
      return available;
    } catch (e) {
      print('❌ Server not available: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> checkEndpoints() async {
    final endpoints = ['/', '/login', '/register', '/logout', '/sanctum/csrf-cookie'];
    final results = <String, bool>{};

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        results[endpoint] = response.statusCode != 404;
        print('🔍 $endpoint: ${response.statusCode}');
      } catch (e) {
        results[endpoint] = false;
        print('❌ $endpoint: ERROR');
      }
    }

    return results;
  }
}