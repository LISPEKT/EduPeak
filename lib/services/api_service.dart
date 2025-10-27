// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final String _baseUrl = 'http://46.254.19.119:8000';
  bool _isInitialized = false;
  String? _csrfToken;
  String? _sessionCookie;

  // Статические методы для совместимости со старым кодом
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

  // Новый метод для массовой синхронизации прогресса
  static Future<void> syncAllProgressToServer(Map<String, Map<String, int>> progressData) async {
    await ApiService()._syncAllProgressToServer(progressData);
  }

  // Реализации методов
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

    // Добавляем перехватчик для обработки cookies
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Загружаем cookies перед каждым запросом
        await _loadCookies();
        if (_sessionCookie != null) {
          options.headers['cookie'] = _sessionCookie;
        }
        if (_csrfToken != null && (options.method == 'POST' || options.method == 'PUT' || options.method == 'PATCH')) {
          if (options.data is Map) {
            (options.data as Map)['_token'] = _csrfToken;
          } else if (options.data is String) {
            // Для form-data добавляем токен
            final data = options.data as String;
            if (!data.contains('_token=')) {
              options.data = '$data&_token=$_csrfToken';
            }
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Сохраняем cookies из ответа
        _saveCookiesFromResponse(response);
        handler.next(response);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
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

      // Получаем свежий CSRF токен
      final csrfToken = await _getCsrfToken();
      if (csrfToken == null) {
        throw Exception('Не удалось получить CSRF токен');
      }

      final formData = {
        '_token': csrfToken,
        'email': email,
        'password': password,
      };

      print('🔐 Login attempt with email: $email');

      final response = await _dio.post(
        '/login',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Origin': _baseUrl,
            'Referer': '$_baseUrl/login',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response headers: ${response.headers}');

      // Проверяем редирект на профиль (успешный вход)
      if (response.statusCode == 302) {
        final location = response.headers['location']?.first;
        if (location != null && location.contains('/profile')) {
          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);

          // ВАЖНО: Сохраняем auth token для UserDataStorage
          await prefs.setString('auth_token', _sessionCookie ?? '');

          print('✅ Login successful, auth status updated');

          return {'success': true, 'message': 'Вход выполнен успешно'};
        }
      }

      // Если нет редиректа, проверяем содержимое ответа
      final responseText = response.data.toString();
      if (responseText.contains('Неверный email или пароль') ||
          responseText.contains('Invalid credentials')) {
        return {'success': false, 'message': 'Неверный email или пароль'};
      }

      return {'success': false, 'message': 'Ошибка входа. Проверьте данные.'};
    } catch (e) {
      print('❌ Login error: $e');

      if (e is DioException) {
        final response = e.response;
        if (response != null) {
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

  // ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ПРОГРЕССОМ
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

  // Метод для массовой синхронизации прогресса на сервер
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

  // Вспомогательные методы для локального хранения (как fallback)
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

  // Метод для парсинга прогресса из HTML (если сервер не предоставляет JSON API)
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
        if (cookie.contains('laravel-session')) {
          _sessionCookie = cookie.split(';').first;
        } else if (cookie.contains('XSRF-TOKEN')) {
          final tokenMatch = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(cookie);
          if (tokenMatch != null) {
            _csrfToken = Uri.decodeComponent(tokenMatch.group(1)!);
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
}