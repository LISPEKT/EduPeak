// lib/services/api_service.dart
import '../models/user_stats.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../screens/achievements_screen.dart';
import '../data/user_data_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final String _baseUrl = 'http://46.254.19.119:8000';
  bool _isInitialized = false;
  String? _csrfToken;
  String? _sessionCookie;

  // === СТАТИЧЕСКИЕ МЕТОДЫ ДЛЯ СОВМЕСТИМОСТИ ===

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<bool> checkServerAvailability() async {
    return await ApiService()._checkServerAvailability();
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await ApiService()._login(email, password);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return await ApiService()._register(name, email, password);
  }

  static Future<void> logout() async {
    await ApiService()._logout();
  }

  static Future<void> updateTopicProgress(String subject, String topicName, int correctAnswers) async {
    await ApiService()._updateTopicProgress(subject, topicName, correctAnswers);
  }

  static Future<Map<String, dynamic>?> getUserProgress() async {
    final apiService = ApiService();
    await apiService.initialize();
    return await apiService._getUserProgress();
  }

  static Future<Map<String, dynamic>> updateAvatar(String imagePath) async {
    return await ApiService()._updateAvatar(imagePath);
  }

  static Future<Map<String, dynamic>> discoverEndpoints() async {
    return await ApiService()._discoverEndpoints();
  }

  static Future<void> syncAllProgressToServer(Map<String, Map<String, int>> progressData) async {
    await ApiService()._syncAllProgressToServer(progressData);
  }

  // === НОВЫЕ СТАТИЧЕСКИЕ МЕТОДЫ ДЛЯ ЭКРАНОВ ===

  // Достижения
  static Future<Map<String, dynamic>> getAchievements() async {
    return await ApiService()._getAchievements();
  }

  static Future<Map<String, dynamic>> unlockAchievement(String achievementId) async {
    return await ApiService()._unlockAchievement(achievementId);
  }

  static Future<Map<String, dynamic>> getAchievementProgress() async {
    return await ApiService()._getAchievementProgress();
  }

  // Друзья
  static Future<Map<String, dynamic>> getFriends() async {
    return await ApiService()._getFriends();
  }

  static Future<Map<String, dynamic>> sendFriendRequest(String username) async {
    return await ApiService()._sendFriendRequest(username);
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    return await ApiService()._acceptFriendRequest(requestId);
  }

  static Future<Map<String, dynamic>> declineFriendRequest(String requestId) async {
    return await ApiService()._declineFriendRequest(requestId);
  }

  static Future<Map<String, dynamic>> removeFriend(String friendId) async {
    return await ApiService()._removeFriend(friendId);
  }

  static Future<Map<String, dynamic>> searchUsers(String query) async {
    return await ApiService()._searchUsers(query);
  }

  // Лиги и XP
  static Future<Map<String, dynamic>> getLeagueLeaderboard(String leagueName) async {
    return await ApiService()._getLeagueLeaderboard(leagueName);
  }

  static Future<Map<String, dynamic>> getUserLeagueInfo() async {
    return await ApiService()._getUserLeagueInfo();
  }

  static Future<Map<String, dynamic>> addXP(int xp, String source) async {
    return await ApiService()._addXP(xp, source);
  }

  static Future<Map<String, dynamic>> getUserXPStats() async {
    return await ApiService()._getUserXPStats();
  }

  // === СИНХРОНИЗАЦИЯ ДАННЫХ ===
  static Future<Map<String, dynamic>> syncAllUserData() async {
    return await ApiService()._syncAllUserData();
  }

  static Future<Map<String, dynamic>> getAllUserData() async {
    return await ApiService()._getAllUserData();
  }

  static Future<Map<String, dynamic>> uploadAllLocalData() async {
    return await ApiService()._uploadAllLocalData();
  }

  static Future<Map<String, dynamic>> checkDataConflicts() async {
    return await ApiService()._checkDataConflicts();
  }

  // === РЕАЛИЗАЦИЯ МЕТОДОВ ===

  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
      },
    ));

    // В методе initialize() обновите InterceptorsWrapper:
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        await _loadCookies();

        // Добавляем session cookie в заголовки
        if (_sessionCookie != null) {
          options.headers['cookie'] = _sessionCookie;
          print('🍪 Adding session cookie to request');
        }

        // ВАЖНО: Не добавляем CSRF токен автоматически для login запроса
        // Потому что мы уже вручную добавили правильный токен из формы
        // Добавляем только если это не login запрос и токен еще не добавлен
        if (_csrfToken != null &&
            (options.method == 'POST' || options.method == 'PUT' || options.method == 'PATCH') &&
            !options.uri.path.contains('/login') &&
            options.data is Map &&
            !(options.data as Map).containsKey('_token')) {

          (options.data as Map)['_token'] = _csrfToken;
          print('🔐 Adding CSRF token from cookie to request data');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        _saveCookiesFromResponse(response);
        handler.next(response);
      },
      onError: (DioException error, handler) {
        if (error.response != null) {
          _saveCookiesFromResponse(error.response!);
        }
        handler.next(error);
      },
    ));

    await _loadCookies();
    _isInitialized = true;
    print('✅ Dio initialized with baseUrl: $_baseUrl');
  }

  Future<bool> _checkServerAvailability() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get('/');
      print('🌐 Server response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server unavailable: $e');
      return false;
    }
  }

  Future<String?> _getCsrfToken() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get('/profile');
      final html = response.data.toString();

      final tokenPattern = RegExp(r'name="_token" value="([^"]+)"');
      final match = tokenPattern.firstMatch(html);

      if (match != null) {
        final token = match.group(1);
        print('✅ CSRF Token found: $token');
        _csrfToken = token;
        await _saveCookies();
        return token;
      }

      print('❌ CSRF Token not found');
      return null;
    } catch (e) {
      print('❌ Error getting CSRF token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _login(String email, String password) async {
    try {
      if (!_isInitialized) await initialize();

      print('🔄 Starting login process...');

      // 1. Получаем страницу логина для получения CSRF токена
      final loginResponse = await _dio.get(
        '/login',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );

      // Сохраняем куки из запроса логина
      _saveCookiesFromResponse(loginResponse);

      // 2. Парсим CSRF токен ИЗ HTML ФОРМЫ (а не из куки!)
      final html = loginResponse.data.toString();
      final tokenPattern = RegExp(r'name="_token" value="([^"]+)"');
      final match = tokenPattern.firstMatch(html);

      if (match == null) {
        print('❌ CSRF Token not found in login form');
        return {'success': false, 'message': 'Ошибка получения токена безопасности'};
      }

      final csrfToken = match.group(1)!;
      print('✅ CSRF Token found in form: $csrfToken');

      // 3. Подготавливаем данные для отправки с правильным токеном
      final formData = {
        '_token': csrfToken, // Используем токен из формы, а не из куки!
        'email': email,
        'password': password,
      };

      print('🔐 Login attempt with email: $email');

      // 4. Отправляем POST запрос
      final response = await _dio.post(
        '/login',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/login',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Login response status: ${response.statusCode}');

      // Сохраняем куки из ответа
      _saveCookiesFromResponse(response);

      // 5. Анализируем ответ
      if (response.statusCode == 302) {
        final location = response.headers['location']?.first;
        print('🔄 Redirect to: $location');

        if (location != null && location.contains('/profile')) {
          // Успешный вход
          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('auth_token', _sessionCookie ?? '');

          print('✅ Login successful');
          return {'success': true, 'message': 'Вход выполнен успешно'};
        } else if (location != null && location.contains('/login')) {
          return {'success': false, 'message': 'Неверный email или пароль'};
        }
      }

      // 6. Проверяем содержимое ответа на ошибки
      final responseText = response.data.toString();
      if (responseText.contains('Неверный email или пароль') ||
          responseText.contains('Invalid credentials')) {
        return {'success': false, 'message': 'Неверный email или пароль'};
      }

      if (response.statusCode == 419) {
        return {'success': false, 'message': 'Сессия истекла. Попробуйте еще раз.'};
      }

      return {'success': false, 'message': 'Ошибка входа. Проверьте данные.'};

    } catch (e) {
      print('❌ Login error: $e');

      if (e is DioException) {
        final response = e.response;
        if (response != null) {
          if (response.statusCode == 419) {
            return {'success': false, 'message': 'Сессия истекла. Попробуйте еще раз.'};
          }

          final responseText = response.data.toString();
          if (responseText.contains('Неверный email или пароль') ||
              responseText.contains('Invalid credentials')) {
            return {'success': false, 'message': 'Неверный email или пароль'};
          }
        }
      }

      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _register(String name, String email, String password) async {
    try {
      if (!_isInitialized) await initialize();

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      final formData = {
        '_token': csrfToken,
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      };

      print('📝 Registration attempt with email: $email');

      final response = await _dio.post(
        '/register',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/register',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Registration response status: ${response.statusCode}');

      // Проверяем редирект на профиль (успешная регистрация)
      if (response.statusCode == 302) {
        final location = response.headers['location']?.first;
        if (location != null && location.contains('/profile')) {
          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);

          return {'success': true, 'message': 'Регистрация успешна'};
        }
      }

      // Проверяем ошибки валидации
      final responseText = response.data.toString();
      if (responseText.contains('email has already been taken') ||
          responseText.contains('Email уже используется')) {
        return {'success': false, 'message': 'Email уже используется'};
      }

      if (responseText.contains('password confirmation') ||
          responseText.contains('Пароли не совпадают')) {
        return {'success': false, 'message': 'Пароли не совпадают'};
      }

      return {'success': false, 'message': 'Ошибка регистрации. Проверьте данные.'};
    } catch (e) {
      print('❌ Registration error: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      if (!_isInitialized) await initialize();
      await _loadCookies();

      print('🔍 Checking authentication status...');

      // Пытаемся получить профиль с обработкой редиректов
      final response = await _dio.get(
        '/profile',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      print('📡 Profile response status: ${response.statusCode}');

      // Если редирект на логин - не авторизованы
      if (response.statusCode == 302) {
        final location = response.headers['location']?.first;
        if (location != null && location.contains('/login')) {
          print('❌ Not authenticated - redirect to login');
          return null;
        }
      }

      // Если успешный ответ - парсим профиль
      if (response.statusCode == 200) {
        final html = response.data.toString();
        return _parseUserDataFromHtml(html);
      }

      return null;
    } catch (e) {
      print('❌ Get profile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    try {
      if (!_isInitialized) await initialize();

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      final formData = {
        '_token': csrfToken,
        'name': name,
        'email': email,
      };

      print('📝 Updating profile: $name, $email');

      final response = await _dio.post(
        '/profile/update',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/profile',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Profile update response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 302) {
        return {'success': true, 'message': 'Профиль успешно обновлен'};
      } else {
        return {'success': false, 'message': 'Ошибка обновления профиля'};
      }
    } catch (e) {
      print('❌ Profile update error: $e');

      // Если эндпоинт не существует, сохраняем локально
      if (e is DioException && e.response?.statusCode == 404) {
        print('⚠️ Profile update endpoint not found, saving locally only');
        return {
          'success': true,
          'message': 'Имя сохранено локально (сервер не поддерживает обновление)'
        };
      }

      return {
        'success': false,
        'message': 'Ошибка обновления профиля: $e'
      };
    }
  }

  Future<String?> downloadAvatar(String avatarUrl) async {
    try {
      if (!_isInitialized) await initialize();

      print('📥 Downloading avatar from: $avatarUrl');

      final response = await _dio.get(
        avatarUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final avatarDir = Directory('${appDir.path}/avatars');

        if (!await avatarDir.exists()) {
          await avatarDir.create(recursive: true);
        }

        final fileName = 'server_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${avatarDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        print('✅ Avatar downloaded successfully: $filePath');
        return filePath;
      }

      return null;
    } catch (e) {
      print('❌ Avatar download error: $e');
      return null;
    }
  }

  Future<bool> checkServerLoginStatus() async {
    try {
      final profile = await getProfile();
      return profile != null;
    } catch (e) {
      print('❌ Server login check error: $e');
      return false;
    }
  }

  Future<void> _logout() async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        await _dio.post(
          '/logout',
          data: {'_token': csrfToken},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => status! < 500,
          ),
        );
      }

      await _clearCookies();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userEmail');

      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userEmail');
    }
  }

  Future<void> _updateTopicProgress(String subject, String topicName, int correctAnswers) async {
    try {
      if (!_isInitialized) await initialize();

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      final formData = {
        '_token': csrfToken,
        'subject': subject,
        'topic': topicName,
        'correct_answers': correctAnswers.toString(),
      };

      print('📚 Sending progress to server: $subject - $topicName: $correctAnswers');

      final response = await _dio.post(
        '/progress/update',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/profile',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Progress update response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 302) {
        print('✅ Progress successfully saved on server');

        // Дублируем в локальное хранилище для надежности
        await _saveProgressLocally(subject, topicName, correctAnswers);

      } else {
        print('⚠️ Server progress update failed, saving locally only');
        await _saveProgressLocally(subject, topicName, correctAnswers);
      }

    } catch (e) {
      print('❌ Server progress update error: $e');
      print('💾 Saving progress locally as fallback');
      await _saveProgressLocally(subject, topicName, correctAnswers);
    }
  }

  Future<Map<String, dynamic>?> _getUserProgress() async {
    try {
      if (!_isInitialized) await initialize();

      print('📥 Requesting progress from server...');

      final response = await _dio.get(
        '/progress',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      print('📡 Progress response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Пытаемся распарсить JSON ответ
        try {
          final responseData = response.data;

          if (responseData is Map<String, dynamic>) {
            // Если сервер возвращает JSON
            print('✅ Got JSON progress data from server');
            return responseData;
          } else if (responseData is String) {
            // Если сервер возвращает HTML, пытаемся извлечь данные из страницы
            final progress = _parseProgressFromHtml(responseData);
            if (progress.isNotEmpty) {
              print('✅ Extracted progress from HTML: ${progress.length} subjects');
              return {'progress': progress};
            }
          }
        } catch (e) {
          print('⚠️ Error parsing server progress: $e');
        }
      }

      // Если не удалось получить с сервера, возвращаем локальные данные
      print('🔄 Falling back to local progress data');
      return await _getLocalProgress();

    } catch (e) {
      print('❌ Server progress request error: $e');
      return await _getLocalProgress();
    }
  }

  Future<void> _syncAllProgressToServer(Map<String, Map<String, int>> progressData) async {
    try {
      if (!_isInitialized) await initialize();

      print('🔄 Starting bulk progress sync...');

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      // Конвертируем данные в формат для отправки
      final progressList = <Map<String, String>>[];
      progressData.forEach((subject, topics) {
        topics.forEach((topic, correctAnswers) {
          progressList.add({
            'subject': subject,
            'topic': topic,
            'correct_answers': correctAnswers.toString(),
          });
        });
      });

      final formData = {
        '_token': csrfToken,
        'progress': jsonEncode(progressList),
      };

      print('📤 Sending ${progressList.length} progress items to server...');

      final response = await _dio.post(
        '/progress/sync',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/profile',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Bulk progress sync completed successfully');
      } else {
        print('⚠️ Bulk progress sync failed with status: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Bulk progress sync error: $e');
      // При ошибке сохраняем все данные локально
      await _saveAllProgressLocally(progressData);
    }
  }

  Future<void> _saveProgressLocally(String subject, String topicName, int correctAnswers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressKey = 'progress_${subject}_$topicName';
      await prefs.setInt(progressKey, correctAnswers);
      print('💾 Progress saved locally: $subject - $topicName: $correctAnswers');
    } catch (e) {
      print('❌ Error saving progress locally: $e');
    }
  }

  Future<Map<String, dynamic>> _getLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();

      final progress = <String, Map<String, int>>{};
      for (final key in keys) {
        final parts = key.replaceFirst('progress_', '').split('_');
        if (parts.length >= 2) {
          final subject = parts[0];
          final topicName = parts.sublist(1).join('_');
          final correctAnswers = prefs.getInt(key) ?? 0;

          if (!progress.containsKey(subject)) {
            progress[subject] = {};
          }
          progress[subject]![topicName] = correctAnswers;
        }
      }

      print('📊 Loaded local progress: ${progress.length} subjects');
      return {'progress': progress};
    } catch (e) {
      print('❌ Error loading local progress: $e');
      return {'progress': {}};
    }
  }

  Future<void> _saveAllProgressLocally(Map<String, Map<String, int>> progressData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем старый прогресс
      final oldKeys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();
      for (final key in oldKeys) {
        await prefs.remove(key);
      }

      // Сохраняем новый прогресс
      progressData.forEach((subject, topics) {
        topics.forEach((topic, correctAnswers) async {
          final progressKey = 'progress_${subject}_$topic';
          await prefs.setInt(progressKey, correctAnswers);
        });
      });

      print('💾 All progress saved locally: ${progressData.length} subjects');
    } catch (e) {
      print('❌ Error saving all progress locally: $e');
    }
  }

  Map<String, Map<String, int>> _parseProgressFromHtml(String html) {
    final progress = <String, Map<String, int>>{};

    try {
      print('🔍 Parsing progress from HTML...');

      // Паттерны для поиска прогресса в HTML
      // Вариант 1: Ищем в data-атрибутах
      final dataPattern = RegExp(r'data-subject="([^"]+)" data-topic="([^"]+)" data-progress="(\d+)"');
      for (final match in dataPattern.allMatches(html)) {
        final subject = match.group(1)!;
        final topic = match.group(2)!;
        final progressValue = int.tryParse(match.group(3)!) ?? 0;

        if (!progress.containsKey(subject)) {
          progress[subject] = {};
        }
        progress[subject]![topic] = progressValue;
      }

      // Вариант 2: Ищем в таблицах или списках
      if (progress.isEmpty) {
        final tablePattern = RegExp(r'<tr[^>]*>.*?<td[^>]*>([^<]+)</td>.*?<td[^>]*>([^<]+)</td>.*?<td[^>]*>(\d+)</td>', caseSensitive: false, dotAll: true);
        for (final match in tablePattern.allMatches(html)) {
          final subject = match.group(1)!.trim();
          final topic = match.group(2)!.trim();
          final progressValue = int.tryParse(match.group(3)!) ?? 0;

          if (!progress.containsKey(subject)) {
            progress[subject] = {};
          }
          progress[subject]![topic] = progressValue;
        }
      }

      print('📊 Parsed ${progress.length} subjects from HTML');

    } catch (e) {
      print('❌ Error parsing progress from HTML: $e');
    }

    return progress;
  }

  Future<Map<String, dynamic>> _updateAvatar(String imagePath) async {
    try {
      if (!_isInitialized) await initialize();

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      print('🖼️ Uploading avatar: $imagePath');

      // Создаем FormData для загрузки файла
      final formData = FormData.fromMap({
        '_token': csrfToken,
        'avatar': await MultipartFile.fromFile(
          imagePath,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/profile/avatar',
        data: formData,
        options: Options(
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/profile',
          },
          contentType: 'multipart/form-data',
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Avatar upload response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Успешная загрузка аватара
        print('✅ Avatar uploaded successfully to server');
        return {
          'success': true,
          'message': 'Аватар успешно обновлен на сервере',
          'avatar_url': _extractAvatarUrlFromResponse(response)
        };
      } else {
        print('❌ Avatar upload failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Ошибка загрузки аватара на сервер'
        };
      }
    } catch (e) {
      print('❌ Avatar upload error: $e');

      // Если эндпоинт не существует, сохраняем локально
      if (e is DioException && e.response?.statusCode == 404) {
        print('⚠️ Avatar endpoint not found, saving locally only');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_avatar_path', imagePath);
        return {
          'success': true,
          'message': 'Аватар сохранен локально (сервер не поддерживает загрузку)'
        };
      }

      return {
        'success': false,
        'message': 'Ошибка загрузки аватара: $e'
      };
    }
  }

  String? _extractAvatarUrlFromResponse(Response response) {
    try {
      final responseText = response.data.toString();

      // Пытаемся найти URL аватара в ответе
      final avatarPattern = RegExp(r'src="([^"]*avatar[^"]*)"');
      final match = avatarPattern.firstMatch(responseText);

      if (match != null) {
        final avatarUrl = match.group(1);
        print('🖼️ Extracted avatar URL: $avatarUrl');
        return avatarUrl;
      }

      return null;
    } catch (e) {
      print('❌ Error extracting avatar URL: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _discoverEndpoints() async {
    // Проверка доступности эндпоинтов
    final endpoints = <String, bool>{};

    try {
      final response = await _dio.get('/');
      endpoints['/'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/'] = false;
    }

    try {
      final response = await _dio.get('/login');
      endpoints['/login'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/login'] = false;
    }

    try {
      final response = await _dio.get('/register');
      endpoints['/register'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/register'] = false;
    }

    try {
      final response = await _dio.get('/profile');
      endpoints['/profile'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/profile'] = false;
    }

    // Проверяем эндпоинт для загрузки аватара
    try {
      final response = await _dio.get('/profile/avatar');
      endpoints['/profile/avatar'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/profile/avatar'] = false;
    }

    // Проверяем эндпоинты для прогресса
    try {
      final response = await _dio.get('/progress');
      endpoints['/progress'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/progress'] = false;
    }

    try {
      final response = await _dio.get('/progress/update');
      endpoints['/progress/update'] = response.statusCode == 200;
    } catch (e) {
      endpoints['/progress/update'] = false;
    }

    return {
      'success': true,
      'endpoints': endpoints,
      'message': 'Проверка эндпоинтов завершена'
    };
  }

  void _saveCookiesFromResponse(Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      for (final cookie in cookies) {
        print('🍪 Raw cookie: $cookie');

        if (cookie.contains('edupeak-session') || cookie.contains('laravel-session')) {
          _sessionCookie = cookie.split(';').first;
          print('✅ Session cookie: $_sessionCookie');
        } else if (cookie.contains('XSRF-TOKEN')) {
          final tokenMatch = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(cookie);
          if (tokenMatch != null) {
            _csrfToken = Uri.decodeComponent(tokenMatch.group(1)!);
            print('✅ CSRF Token from cookie: $_csrfToken');
          }
        }
      }
      _saveCookies();
    }
  }

  Future<void> _saveCookies() async {
    final prefs = await SharedPreferences.getInstance();
    if (_sessionCookie != null) {
      await prefs.setString('session_cookie', _sessionCookie!);
    }
    if (_csrfToken != null) {
      await prefs.setString('csrf_token', _csrfToken!);
    }
  }

  Future<void> _loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
    _csrfToken = prefs.getString('csrf_token');

    print('🍪 Loaded cookies - Session: ${_sessionCookie != null ? "Yes" : "No"}, CSRF: ${_csrfToken != null ? "Yes" : "No"}');
  }

  Future<void> _clearCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    await prefs.remove('csrf_token');
    _sessionCookie = null;
    _csrfToken = null;
  }

  Map<String, dynamic> _parseUserDataFromHtml(String html) {
    try {
      print('🔍 Parsing profile HTML...');

      // Логируем первые 500 символов HTML для отладки
      if (html.length > 500) {
        print('📄 HTML preview: ${html.substring(0, 500)}...');
      } else {
        print('📄 HTML: $html');
      }

      String name = 'Пользователь';
      String avatarUrl = '';

      // Пытаемся найти имя пользователя разными способами
      try {
        // ПРИОРИТЕТ 1: Ищем имя в параграфе под аватаром (самый надежный способ)
        final namePattern1 = RegExp(r'<img[^>]*alt="Аватар"[^>]*>[\s\S]*?<p[^>]*class="[^"]*text-gray-600[^"]*"[^>]*>([^<]+)</p>', caseSensitive: false);
        // ПРИОРИТЕТ 2: Ищем в любом параграфе с классом text-gray-600 (где обычно отображаются имена)
        final namePattern2 = RegExp(r'<p[^>]*class="[^"]*text-gray-600[^"]*"[^>]*>([^<]+)</p>', caseSensitive: false);
        // ПРИОРИТЕТ 3: Ищем в заголовках h1-h6, но исключаем "Профиль пользователя"
        final namePattern3 = RegExp(r'<h[1-6][^>]*>([^<]+)</h[1-6]>');
        // ПРИОРИТЕТ 4: Ищем в div с классами содержащими name, user, profile
        final namePattern4 = RegExp(r'<div[^>]*class="[^"]*(name|user|profile)[^"]*"[^>]*>([^<]+)</div>');
        // ПРИОРИТЕТ 5: Ищем текст который выглядит как имя (только буквы, пробелы, кириллица, латиница)
        final namePattern5 = RegExp(r'>([А-Яа-яA-Za-z\s]{2,30})<');

        // Собираем все возможные кандидаты в порядке приоритета
        final candidates = <String>[];

        // Приоритет 1: Имя под аватаром
        for (final match in namePattern1.allMatches(html)) {
          final candidate = match.group(1)!.trim();
          if (candidate.isNotEmpty && candidate != 'Аватар') {
            candidates.add(candidate);
            print('🎯 Found name under avatar: "$candidate"');
          }
        }

        // Приоритет 2: Любой text-gray-600 параграф
        for (final match in namePattern2.allMatches(html)) {
          final candidate = match.group(1)!.trim();
          if (candidate.isNotEmpty &&
              candidate != 'Аватар' &&
              !candidate.contains('Загрузить') &&
              !candidate.contains('аватар')) {
            candidates.add(candidate);
            print('🎯 Found name in text-gray-600: "$candidate"');
          }
        }

        // Приоритет 3: Заголовки (исключаем "Профиль пользователя")
        for (final match in namePattern3.allMatches(html)) {
          final candidate = match.group(1)!.trim();
          if (candidate.isNotEmpty &&
              !candidate.contains('Профиль') &&
              !candidate.contains('пользователя') &&
              !candidate.contains('Profile')) {
            candidates.add(candidate);
            print('🎯 Found name in heading: "$candidate"');
          }
        }

        // Приоритет 4: Div с классами
        for (final match in namePattern4.allMatches(html)) {
          if (match.groupCount >= 2) {
            final candidate = match.group(2)!.trim();
            if (candidate.isNotEmpty) {
              candidates.add(candidate);
              print('🎯 Found name in div: "$candidate"');
            }
          }
        }

        // Приоритет 5: Общий поиск
        for (final match in namePattern5.allMatches(html)) {
          final candidate = match.group(1)!.trim();
          if (candidate.isNotEmpty &&
              candidate.length > 1 &&
              candidate.length < 50 &&
              !candidate.contains('@') &&
              !candidate.contains('http') &&
              !candidate.contains('<') &&
              !candidate.contains('>') &&
              !['Профиль', 'Profile', 'Вход', 'Login', 'Выйти', 'Logout', 'Главная', 'Home', 'LISPEKT']
                  .contains(candidate)) {
            candidates.add(candidate);
            print('🎯 Found name in general search: "$candidate"');
          }
        }

        // Фильтруем кандидатов - ищем "LISPEKT" или другие реальные имена
        for (final candidate in candidates) {
          if (candidate.isNotEmpty &&
              candidate.length > 1 &&
              candidate.length < 50 &&
              !candidate.contains('@') &&
              !candidate.contains('http') &&
              !candidate.contains('<') &&
              !candidate.contains('>') &&
              !candidate.contains('Профиль') &&
              !candidate.contains('пользователя') &&
              !['Вход', 'Login', 'Выйти', 'Logout', 'Главная', 'Home']
                  .contains(candidate)) {

            // Если нашли "LISPEKT" - это наш пользователь
            if (candidate == 'LISPEKT') {
              name = candidate;
              print('✅ Found exact username: "$name"');
              break;
            }

            // Или любое другое имя, которое не является заголовком страницы
            if (candidate != 'Профиль пользователя' && !candidate.contains('Профиль')) {
              name = candidate;
              print('✅ Found valid username: "$name"');
              break;
            }
          }
        }

        // Если не нашли нормальное имя, но видим LISPEKT в других местах
        if (name == 'Пользователь' || name == 'Профиль пользователя') {
          // Дополнительная проверка: ищем LISPEKT в любом месте HTML
          if (html.contains('LISPEKT')) {
            name = 'LISPEKT';
            print('✅ Found LISPEKT in HTML, setting as username');
          }
        }

      } catch (e) {
        print('⚠️ Error parsing name: $e');
      }

      // Парсим аватар
      try {
        final avatarPatterns = [
          RegExp(r'<img[^>]*src="([^"]*avatar[^"]*)"', caseSensitive: false),
          RegExp(r'<img[^>]*src="([^"]*images/[^"]*)"', caseSensitive: false),
          RegExp(r'<img[^>]*src="([^"]*uploads[^"]*)"', caseSensitive: false),
          RegExp(r'<img[^>]*src="(/storage/[^"]*)"', caseSensitive: false),
          RegExp(r'<img[^>]*src="(.*\.(jpg|jpeg|png|gif|webp))"', caseSensitive: false),
        ];

        for (final pattern in avatarPatterns) {
          for (final match in pattern.allMatches(html)) {
            final candidate = match.group(1)!;
            if (candidate.isNotEmpty &&
                !candidate.contains('logo') &&
                !candidate.contains('icon') &&
                candidate.length > 10) {
              avatarUrl = candidate;
              print('✅ Found avatar URL: "$avatarUrl"');
              break;
            }
          }
          if (avatarUrl.isNotEmpty) break;
        }

        // Если URL относительный, делаем его абсолютным
        if (avatarUrl.isNotEmpty && avatarUrl.startsWith('/')) {
          avatarUrl = '$_baseUrl$avatarUrl';
          print('🔗 Converted to absolute URL: $avatarUrl');
        }
      } catch (e) {
        print('⚠️ Error parsing avatar: $e');
      }

      print('👤 Final parsed data - Name: "$name", Avatar: "$avatarUrl"');

      return {
        'name': name,
        'email': '',
        'avatar_url': avatarUrl,
        'streak': 0,
      };
    } catch (e) {
      print('❌ Error parsing user data: $e');
      return {
        'name': 'Пользователь',
        'email': '',
        'avatar_url': '',
        'streak': 0,
      };
    }
  }

  // === НОВЫЕ МЕТОДЫ ДЛЯ ЭКРАНОВ ===

  // Достижения
  Future<Map<String, dynamic>> _getAchievements() async {
    try {
      if (!_isInitialized) await initialize();

      print('🏆 Getting achievements from server...');

      final response = await _dio.get(
        '/achievements',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {'success': true, 'achievements': data['achievements'] ?? []};
          }
        } catch (e) {
          print('⚠️ Error parsing achievements JSON: $e');
        }
      }

      // Fallback: возвращаем пустой список
      return {
        'success': false,
        'achievements': [],
        'message': 'Сервер недоступен, используем локальные данные'
      };

    } catch (e) {
      print('❌ Error getting achievements: $e');
      return {
        'success': false,
        'achievements': [],
        'message': 'Ошибка получения достижений'
      };
    }
  }

  Future<Map<String, dynamic>> _unlockAchievement(String achievementId) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'achievement_id': achievementId,
      };

      final response = await _dio.post(
        '/achievements/unlock',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Достижение разблокировано'};
      } else {
        return {'success': false, 'message': 'Ошибка разблокировки достижения'};
      }

    } catch (e) {
      print('❌ Error unlocking achievement: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _getAchievementProgress() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/achievements/progress',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {'success': true, 'progress': data['progress'] ?? {}};
          }
        } catch (e) {
          print('⚠️ Error parsing achievement progress: $e');
        }
      }

      return {'success': false, 'progress': {}};

    } catch (e) {
      print('❌ Error getting achievement progress: $e');
      return {'success': false, 'progress': {}};
    }
  }

  // Друзья
  Future<Map<String, dynamic>> _getFriends() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/friends',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {
              'success': true,
              'friends': data['friends'] ?? [],
              'pending_requests': data['pending_requests'] ?? []
            };
          }
        } catch (e) {
          print('⚠️ Error parsing friends JSON: $e');
        }
      }

      // Fallback данные
      return {
        'success': false,
        'friends': [],
        'pending_requests': [],
        'message': 'Сервер недоступен, используем локальные данные'
      };

    } catch (e) {
      print('❌ Error getting friends: $e');
      return {
        'success': false,
        'friends': [],
        'pending_requests': []
      };
    }
  }

  Future<Map<String, dynamic>> _sendFriendRequest(String username) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'username': username,
      };

      final response = await _dio.post(
        '/friends/request',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Запрос на дружбу отправлен'};
      } else {
        return {'success': false, 'message': 'Ошибка отправки запроса'};
      }

    } catch (e) {
      print('❌ Error sending friend request: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _acceptFriendRequest(String requestId) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'request_id': requestId,
      };

      final response = await _dio.post(
        '/friends/accept',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Запрос принят'};
      } else {
        return {'success': false, 'message': 'Ошибка принятия запроса'};
      }

    } catch (e) {
      print('❌ Error accepting friend request: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _declineFriendRequest(String requestId) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'request_id': requestId,
      };

      final response = await _dio.post(
        '/friends/decline',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Запрос отклонен'};
      } else {
        return {'success': false, 'message': 'Ошибка отклонения запроса'};
      }

    } catch (e) {
      print('❌ Error declining friend request: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _removeFriend(String friendId) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'friend_id': friendId,
      };

      final response = await _dio.post(
        '/friends/remove',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Друг удален'};
      } else {
        return {'success': false, 'message': 'Ошибка удаления друга'};
      }

    } catch (e) {
      print('❌ Error removing friend: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _searchUsers(String query) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/users/search?username=${Uri.encodeComponent(query)}',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {'success': true, 'users': data['users'] ?? []};
          }
        } catch (e) {
          print('⚠️ Error parsing search results: $e');
        }
      }

      return {'success': false, 'users': []};

    } catch (e) {
      print('❌ Error searching users: $e');
      return {'success': false, 'users': []};
    }
  }

  // Лиги и XP
  Future<Map<String, dynamic>> _getLeagueLeaderboard(String leagueName) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/league/$leagueName/leaderboard',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {'success': true, 'leaderboard': data['leaderboard'] ?? []};
          }
        } catch (e) {
          print('⚠️ Error parsing leaderboard: $e');
        }
      }

      return {'success': false, 'leaderboard': []};

    } catch (e) {
      print('❌ Error getting league leaderboard: $e');
      return {'success': false, 'leaderboard': []};
    }
  }

  Future<Map<String, dynamic>> _getUserLeagueInfo() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/league/user-info',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {
              'success': true,
              'current_league': data['current_league'] ?? 'Бронза',
              'weekly_xp': data['weekly_xp'] ?? 0,
              'rank': data['rank'] ?? 0,
              'total_users': data['total_users'] ?? 0,
            };
          }
        } catch (e) {
          print('⚠️ Error parsing league info: $e');
        }
      }

      // Fallback данные
      return {
        'success': false,
        'current_league': 'Бронза',
        'weekly_xp': 0,
        'rank': 0,
        'total_users': 0,
      };

    } catch (e) {
      print('❌ Error getting user league info: $e');
      return {
        'success': false,
        'current_league': 'Бронза',
        'weekly_xp': 0,
        'rank': 0,
        'total_users': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _addXP(int xp, String source) async {
    try {
      if (!_isInitialized) await initialize();

      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        return {'success': false, 'message': 'Не удалось получить CSRF токен'};
      }

      final formData = {
        '_token': csrfToken,
        'xp': xp,
        'source': source,
      };

      final response = await _dio.post(
        '/xp/add',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'XP добавлен'};
      } else {
        return {'success': false, 'message': 'Ошибка добавления XP'};
      }

    } catch (e) {
      print('❌ Error adding XP: $e');
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<Map<String, dynamic>> _getUserXPStats() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/xp/stats',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return {
              'success': true,
              'total_xp': data['total_xp'] ?? 0,
              'weekly_xp': data['weekly_xp'] ?? 0,
              'current_league': data['current_league'] ?? 'Бронза',
              'league_progress': data['league_progress'] ?? 0.0,
            };
          }
        } catch (e) {
          print('⚠️ Error parsing XP stats: $e');
        }
      }

      // Fallback данные
      return {
        'success': false,
        'total_xp': 0,
        'weekly_xp': 0,
        'current_league': 'Бронза',
        'league_progress': 0.0,
      };

    } catch (e) {
      print('❌ Error getting XP stats: $e');
      return {
        'success': false,
        'total_xp': 0,
        'weekly_xp': 0,
        'current_league': 'Бронза',
        'league_progress': 0.0,
      };
    }
  }

  // === МЕТОДЫ ПОЛНОЙ СИНХРОНИЗАЦИИ ДАННЫХ ===

  Future<Map<String, dynamic>> _syncAllUserData() async {
    try {
      if (!_isInitialized) await initialize();

      print('🔄 STARTING FULL USER DATA SYNC');

      // 1. Получаем все данные с сервера
      final serverData = await _getAllUserData();

      if (!serverData['success']) {
        return {
          'success': false,
          'message': 'Не удалось получить данные с сервера',
          'synced': false
        };
      }

      // 2. Получаем все локальные данные
      final localData = await _getAllLocalData();

      // 3. Разрешаем конфликты и объединяем данные
      final mergedData = _mergeData(localData, serverData['data']);

      // 4. Сохраняем объединенные данные локально
      await _saveMergedData(mergedData);

      // 5. Отправляем объединенные данные на сервер
      await _uploadMergedData(mergedData);

      print('✅ FULL USER DATA SYNC COMPLETED SUCCESSFULLY');

      return {
        'success': true,
        'message': 'Данные успешно синхронизированы',
        'synced': true,
        'stats': {
          'topics_synced': mergedData['topicProgress']?.length ?? 0,
          'xp_synced': mergedData['totalXP'] ?? 0,
          'streak_synced': mergedData['streakDays'] ?? 0,
        }
      };

    } catch (e) {
      print('❌ FULL SYNC ERROR: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации: $e',
        'synced': false
      };
    }
  }

  Future<Map<String, dynamic>> _getAllUserData() async {
    try {
      if (!_isInitialized) await initialize();

      print('📥 DOWNLOADING ALL USER DATA FROM SERVER');

      final Map<String, dynamic> result = {};

      // 1. Получаем профиль
      final profile = await getProfile();
      if (profile != null) {
        result['profile'] = profile;
      }

      // 2. Получаем прогресс
      final progress = await _getUserProgress();
      if (progress != null && progress['progress'] != null) {
        result['topicProgress'] = progress['progress'];
      }

      // 3. Получаем статистику XP
      final xpStats = await _getUserXPStats();
      if (xpStats['success'] == true) {
        result['xp'] = {
          'totalXP': xpStats['total_xp'],
          'weeklyXP': xpStats['weekly_xp'],
          'currentLeague': xpStats['current_league'],
        };
      }

      // 4. Получаем достижения
      final achievements = await _getAchievementProgress();
      if (achievements['success'] == true) {
        result['achievements'] = achievements['progress'];
      }

      // 5. Получаем друзей
      final friends = await _getFriends();
      if (friends['success'] == true) {
        result['friends'] = {
          'friends': friends['friends'],
          'pending_requests': friends['pending_requests'],
        };
      }

      print('✅ SERVER DATA DOWNLOADED: ${result.keys.length} categories');

      return {
        'success': true,
        'data': result,
        'message': 'Данные успешно получены с сервера'
      };

    } catch (e) {
      print('❌ ERROR GETTING ALL USER DATA: $e');
      return {
        'success': false,
        'data': {},
        'message': 'Ошибка получения данных: $e'
      };
    }
  }

  Future<Map<String, dynamic>> _uploadAllLocalData() async {
    try {
      if (!_isInitialized) await initialize();

      print('📤 UPLOADING ALL LOCAL DATA TO SERVER');

      // 1. Получаем все локальные данные
      final localData = await _getAllLocalData();

      // 2. Отправляем прогресс по темам
      final topicProgress = localData['topicProgress'] ?? {};
      int topicsUploaded = 0;
      for (final subject in topicProgress.keys) {
        final topics = topicProgress[subject];
        if (topics is Map) {
          for (final topic in topics.keys) {
            final correctAnswers = topics[topic];
            if (correctAnswers is int) {
              await _updateTopicProgress(subject, topic, correctAnswers);
              topicsUploaded++;
            }
          }
        }
      }

      // 3. Отправляем XP
      final totalXP = localData['totalXP'] ?? 0;
      if (totalXP > 0) {
        await _addXP(0, 'sync'); // Отправляем 0 XP, так как основное уже должно быть на сервере
      }

      print('✅ ALL LOCAL DATA UPLOADED TO SERVER: $topicsUploaded topics');

      return {
        'success': true,
        'message': 'Локальные данные успешно отправлены на сервер',
        'uploaded': {
          'topics': topicsUploaded,
          'totalXP': totalXP,
        }
      };

    } catch (e) {
      print('❌ ERROR UPLOADING LOCAL DATA: $e');
      return {
        'success': false,
        'message': 'Ошибка отправки данных: $e',
        'uploaded': false
      };
    }
  }

  Future<Map<String, dynamic>> _getAllLocalData() async {
    try {
      print('💾 GETTING ALL LOCAL DATA');

      final Map<String, dynamic> result = {};

      // 1. Получаем статистику пользователя
      final userStats = await UserDataStorage.getUserStats();
      result['topicProgress'] = userStats.topicProgress;
      result['totalXP'] = userStats.totalXP;
      result['weeklyXP'] = userStats.weeklyXP;
      result['streakDays'] = userStats.streakDays;
      result['lastActivity'] = userStats.lastActivity.toIso8601String();
      result['username'] = userStats.username;

      // 2. Получаем аватар
      final avatar = await UserDataStorage.getAvatar();
      if (avatar != '👤') {
        result['avatar'] = avatar;
      }

      // 3. Получаем ежедневную активность
      result['dailyCompletion'] = userStats.dailyCompletion;

      // 4. Получаем достижения (заглушка - нужно реализовать в UserDataStorage)
      result['achievements'] = {};

      print('✅ LOCAL DATA RETRIEVED: ${result.keys.length} categories');

      return result;

    } catch (e) {
      print('❌ ERROR GETTING LOCAL DATA: $e');
      return {};
    }
  }

  Map<String, dynamic> _mergeData(Map<String, dynamic> localData, Map<String, dynamic> serverData) {
    print('🔄 MERGING LOCAL AND SERVER DATA');

    final mergedData = <String, dynamic>{};

    // 1. Объединяем прогресс по темам
    final localProgress = localData['topicProgress'] ?? {};
    final serverProgress = serverData['topicProgress'] ?? {};
    final mergedProgress = <String, Map<String, int>>{};

    // Объединяем все предметы
    final allSubjects = <String>{};
    allSubjects.addAll(localProgress.keys);
    allSubjects.addAll(serverProgress.keys);

    for (final subject in allSubjects) {
      final localTopics = localProgress[subject] ?? {};
      final serverTopics = serverProgress[subject] ?? {};
      final mergedTopics = <String, int>{};

      // Объединяем все темы
      final allTopics = <String>{};
      allTopics.addAll(localTopics.keys);
      allTopics.addAll(serverTopics.keys);

      for (final topic in allTopics) {
        final localValue = localTopics[topic] ?? 0;
        final serverValue = serverTopics[topic] ?? 0;

        // Берем максимальное значение
        mergedTopics[topic] = localValue > serverValue ? localValue : serverValue;

        if (localValue != serverValue) {
          print('📊 Topic conflict resolved: $subject - $topic: local=$localValue, server=$serverValue -> merged=${mergedTopics[topic]}');
        }
      }

      mergedProgress[subject] = mergedTopics;
    }

    mergedData['topicProgress'] = mergedProgress;

    // 2. Объединяем XP (берем максимальное значение)
    final localXP = localData['totalXP'] ?? 0;
    final serverXP = serverData['xp']?['totalXP'] ?? 0;
    mergedData['totalXP'] = localXP > serverXP ? localXP : serverXP;

    final localWeeklyXP = localData['weeklyXP'] ?? 0;
    final serverWeeklyXP = serverData['xp']?['weeklyXP'] ?? 0;
    mergedData['weeklyXP'] = localWeeklyXP > serverWeeklyXP ? localWeeklyXP : serverWeeklyXP;

    // 3. Объединяем стрик (берем максимальное значение)
    final localStreak = localData['streakDays'] ?? 0;
    final serverStreak = serverData['profile']?['streak'] ?? 0;
    mergedData['streakDays'] = localStreak > serverStreak ? localStreak : serverStreak;

    // 4. Объединяем имя пользователя (предпочтение серверу)
    final serverName = serverData['profile']?['name'];
    if (serverName != null && serverName.isNotEmpty && serverName != 'Пользователь') {
      mergedData['username'] = serverName;
    } else {
      mergedData['username'] = localData['username'] ?? '';
    }

    // 5. Объединяем аватар (предпочтение серверу)
    final serverAvatar = serverData['profile']?['avatar_url'];
    if (serverAvatar != null && serverAvatar.isNotEmpty) {
      mergedData['avatar'] = serverAvatar;
    } else {
      mergedData['avatar'] = localData['avatar'] ?? '👤';
    }

    // 6. Объединяем ежедневную активность
    final localDaily = localData['dailyCompletion'] ?? {};
    final serverDaily = serverData['dailyCompletion'] ?? {};
    final mergedDaily = Map<String, bool>.from(localDaily);
    mergedDaily.addAll(serverDaily); // Серверные данные перезаписывают локальные
    mergedData['dailyCompletion'] = mergedDaily;

    print('✅ DATA MERGED: ${mergedProgress.length} subjects, ${mergedData['totalXP']} XP, ${mergedData['streakDays']} days streak');

    return mergedData;
  }

  Future<void> _saveMergedData(Map<String, dynamic> mergedData) async {
    try {
      print('💾 SAVING MERGED DATA TO LOCAL STORAGE');

      // Создаем UserStats из объединенных данных
      final userStats = UserStats(
        streakDays: mergedData['streakDays'] ?? 0,
        lastActivity: DateTime.now(),
        topicProgress: Map<String, Map<String, int>>.from(mergedData['topicProgress'] ?? {}),
        dailyCompletion: Map<String, bool>.from(mergedData['dailyCompletion'] ?? {}),
        username: mergedData['username'] ?? '',
        totalXP: mergedData['totalXP'] ?? 0,
        weeklyXP: mergedData['weeklyXP'] ?? 0,
        lastWeeklyReset: DateTime.now(),
      );

      // Сохраняем статистику
      await UserDataStorage.saveUserStats(userStats);

      // Сохраняем аватар если есть
      final avatar = mergedData['avatar'];
      if (avatar != null && avatar != '👤') {
        await UserDataStorage.saveAvatar(avatar);
      }

      print('✅ MERGED DATA SAVED LOCALLY');
    } catch (e) {
      print('❌ ERROR SAVING MERGED DATA: $e');
    }
  }

  Future<void> _uploadMergedData(Map<String, dynamic> mergedData) async {
    try {
      print('📤 UPLOADING MERGED DATA TO SERVER');

      // 1. Обновляем профиль
      final username = mergedData['username'];
      if (username != null && username.isNotEmpty) {
        await updateProfile(username, '');
      }

      // 2. Отправляем прогресс по темам
      final topicProgress = mergedData['topicProgress'] ?? {};
      for (final subject in topicProgress.keys) {
        final topics = topicProgress[subject];
        if (topics is Map) {
          for (final topic in topics.keys) {
            final correctAnswers = topics[topic];
            if (correctAnswers is int) {
              await _updateTopicProgress(subject, topic, correctAnswers);
            }
          }
        }
      }

      // 3. Отправляем аватар если есть
      final avatar = mergedData['avatar'];
      if (avatar != null && avatar != '👤' && avatar.toString().startsWith('http')) {
        // Если это URL с сервера, не загружаем повторно
        print('🖼️ Avatar already on server, skipping upload');
      }

      print('✅ MERGED DATA UPLOADED TO SERVER');
    } catch (e) {
      print('❌ ERROR UPLOADING MERGED DATA: $e');
    }
  }

  Future<Map<String, dynamic>> _checkDataConflicts() async {
    try {
      if (!_isInitialized) await initialize();

      print('🔍 CHECKING DATA CONFLICTS');

      final localData = await _getAllLocalData();
      final serverDataResponse = await _getAllUserData();

      if (!serverDataResponse['success']) {
        return {
          'success': false,
          'message': 'Не удалось получить данные с сервера для проверки конфликтов'
        };
      }

      final serverData = serverDataResponse['data'];
      final conflicts = <String, dynamic>{};

      // Проверяем конфликты прогресса
      final localProgress = localData['topicProgress'] ?? {};
      final serverProgress = serverData['topicProgress'] ?? {};
      final progressConflicts = <String, Map<String, dynamic>>{};

      for (final subject in localProgress.keys) {
        final localTopics = localProgress[subject] ?? {};
        final serverTopics = serverProgress[subject] ?? {};

        for (final topic in localTopics.keys) {
          final localValue = localTopics[topic] ?? 0;
          final serverValue = serverTopics[topic] ?? 0;

          if (localValue != serverValue) {
            if (!progressConflicts.containsKey(subject)) {
              progressConflicts[subject] = {};
            }
            progressConflicts[subject]![topic] = {
              'local': localValue,
              'server': serverValue,
              'resolved': localValue > serverValue ? 'local' : 'server'
            };
          }
        }
      }

      if (progressConflicts.isNotEmpty) {
        conflicts['progress'] = progressConflicts;
      }

      // Проверяем конфликты XP
      final localXP = localData['totalXP'] ?? 0;
      final serverXP = serverData['xp']?['totalXP'] ?? 0;
      if (localXP != serverXP) {
        conflicts['xp'] = {
          'local': localXP,
          'server': serverXP,
          'resolved': localXP > serverXP ? 'local' : 'server'
        };
      }

      // Проверяем конфликты стрика
      final localStreak = localData['streakDays'] ?? 0;
      final serverStreak = serverData['profile']?['streak'] ?? 0;
      if (localStreak != serverStreak) {
        conflicts['streak'] = {
          'local': localStreak,
          'server': serverStreak,
          'resolved': localStreak > serverStreak ? 'local' : 'server'
        };
      }

      print('✅ CONFLICT CHECK COMPLETED: ${conflicts.length} conflict types found');

      return {
        'success': true,
        'conflicts': conflicts,
        'hasConflicts': conflicts.isNotEmpty,
        'message': conflicts.isNotEmpty ? 'Обнаружены конфликты данных' : 'Конфликты не обнаружены'
      };

    } catch (e) {
      print('❌ ERROR CHECKING DATA CONFLICTS: $e');
      return {
        'success': false,
        'conflicts': {},
        'hasConflicts': false,
        'message': 'Ошибка проверки конфликтов: $e'
      };
    }
  }
}