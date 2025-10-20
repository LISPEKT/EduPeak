// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://46.254.19.119:8000/api/';
  static final CookieJar _cookieJar = CookieJar();
  static String? _csrfToken;

  static void _setupDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.validateStatus = (status) => true;

    // Добавляем менеджер cookies
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Добавляем интерцептор для логирования
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }

  // Получение CSRF токена
  static Future<String?> _getCsrfToken() async {
    if (_csrfToken != null) return _csrfToken;

    try {
      // Получаем страницу регистрации чтобы извлечь CSRF токен
      final response = await _dio.get('/register');
      if (response.statusCode == 200) {
        final html = response.data as String;

        // Ищем CSRF токен в HTML
        final regex = RegExp(r'name="_token" value="([^"]+)"');
        final match = regex.firstMatch(html);
        if (match != null) {
          _csrfToken = match.group(1);
          print('🔑 CSRF Token found: $_csrfToken');
          return _csrfToken;
        }

        // Альтернативный поиск
        final regex2 = RegExp(r'csrf-token" content="([^"]+)"');
        final match2 = regex2.firstMatch(html);
        if (match2 != null) {
          _csrfToken = match2.group(1);
          print('🔑 CSRF Token found (alt): $_csrfToken');
          return _csrfToken;
        }
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
    }

    print('❌ CSRF Token not found');
    return null;
  }

  // Инициализация API
  static Future<void> initialize() async {
    _setupDio();
    await _getCsrfToken();
  }

  // ============ АУТЕНТИФИКАЦИЯ ============

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await initialize();

    print('🔐 Attempting registration for: $email');

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/register',
        data: {
          '_token': csrfToken,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      print('📡 Registration response: ${response.statusCode}');
      print('📡 Registration data: ${response.data}');

      if (response.statusCode == 302) {
        // Успешная регистрация - редирект на профиль
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', name);

        return {
          'success': true,
          'message': 'Регистрация успешна',
        };
      } else if (response.statusCode == 200) {
        // Проверяем HTML ответ на наличие ошибок
        if (response.data is String) {
          final html = response.data as String;

          // Ищем ошибки в HTML
          if (html.contains('Ошибка') ||
              html.contains('error') ||
              html.contains('Уже существует') ||
              html.contains('already exists') ||
              html.contains('Учетная запись')) {
            return {
              'success': false,
              'message': 'Аккаунт с таким email уже существует',
            };
          }

          // Если нет ошибок, считаем успехом
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('user_email', email);
          await prefs.setString('user_name', name);

          return {
            'success': true,
            'message': 'Регистрация успешна',
          };
        }

        // Если это JSON с ошибками
        if (response.data is Map) {
          final data = response.data as Map;

          // Ошибки валидации Laravel
          if (data.containsKey('errors')) {
            final errors = data['errors'];
            String errorMessage = 'Ошибка регистрации';

            if (errors['email'] != null) {
              final emailErrors = errors['email'] as List;
              if (emailErrors.isNotEmpty) {
                if (emailErrors[0].toString().contains('уже') ||
                    emailErrors[0].toString().contains('already') ||
                    emailErrors[0].toString().contains('taken')) {
                  errorMessage = 'Аккаунт с таким email уже существует';
                } else {
                  errorMessage = emailErrors[0].toString();
                }
              }
            } else if (errors['name'] != null) {
              final nameErrors = errors['name'] as List;
              if (nameErrors.isNotEmpty) {
                errorMessage = nameErrors[0].toString();
              }
            } else if (errors['password'] != null) {
              final passwordErrors = errors['password'] as List;
              if (passwordErrors.isNotEmpty) {
                errorMessage = passwordErrors[0].toString();
              }
            }

            return {
              'success': false,
              'message': errorMessage,
            };
          }

          // Общая ошибка
          if (data.containsKey('message')) {
            return {
              'success': false,
              'message': data['message'].toString(),
            };
          }
        }

        // Если дошли сюда без ошибок, считаем успехом
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', name);

        return {
          'success': true,
          'message': 'Регистрация успешна',
        };
      } else if (response.statusCode == 422) {
        // Ошибки валидации
        final data = response.data;
        String errorMessage = 'Ошибка регистрации';

        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'];

          if (errors['email'] != null) {
            final emailErrors = errors['email'] as List;
            if (emailErrors.isNotEmpty) {
              if (emailErrors[0].toString().contains('уже') ||
                  emailErrors[0].toString().contains('already') ||
                  emailErrors[0].toString().contains('taken')) {
                errorMessage = 'Аккаунт с таким email уже существует';
              } else {
                errorMessage = emailErrors[0].toString();
              }
            }
          } else if (errors['name'] != null) {
            final nameErrors = errors['name'] as List;
            if (nameErrors.isNotEmpty) {
              errorMessage = nameErrors[0].toString();
            }
          } else if (errors['password'] != null) {
            final passwordErrors = errors['password'] as List;
            if (passwordErrors.isNotEmpty) {
              errorMessage = passwordErrors[0].toString();
            }
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка регистрации (код: ${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения с сервером',
      };
    }
  }

  // Вход
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await initialize();

    print('🔐 Attempting login for: $email');

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/login',
        data: {
          '_token': csrfToken,
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      print('📡 Login response: ${response.statusCode}');
      print('📡 Login data: ${response.data}');

      if (response.statusCode == 302) {
        // Успешный вход - редирект на профиль
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': 'Вход успешен',
        };
      } else if (response.statusCode == 200) {
        // Проверяем HTML ответ на наличие ошибок
        if (response.data is String) {
          final html = response.data as String;

          // Ищем ошибки входа в HTML
          if (html.contains('Неверные учетные данные') ||
              html.contains('Неверный email или пароль') ||
              html.contains('Invalid credentials') ||
              html.contains('Ошибка входа') ||
              html.contains('login error')) {
            return {
              'success': false,
              'message': 'Неверный email или пароль',
            };
          }

          // Если нет ошибок, считаем успехом
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('user_email', email);

          return {
            'success': true,
            'message': 'Вход успешен',
          };
        }

        // Если это JSON с ошибками
        if (response.data is Map) {
          final data = response.data as Map;

          // Ошибки валидации Laravel
          if (data.containsKey('errors')) {
            final errors = data['errors'];
            String errorMessage = 'Ошибка входа';

            if (errors['email'] != null) {
              final emailErrors = errors['email'] as List;
              if (emailErrors.isNotEmpty) {
                errorMessage = emailErrors[0].toString();
              }
            }
          }

          // Общая ошибка
          if (data.containsKey('message')) {
            String message = data['message'].toString();
            if (message.contains('Неверные учетные данные') ||
                message.contains('Invalid credentials')) {
              message = 'Неверный email или пароль';
            }
            return {
              'success': false,
              'message': message,
            };
          }
        }

        // Если дошли сюда без ошибок, считаем успехом
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': 'Вход успешен',
        };
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        // Неверные учетные данные
        String errorMessage = 'Неверный email или пароль';

        if (response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('message')) {
            final message = data['message'].toString();
            if (message.isNotEmpty) {
              errorMessage = message;
            }
          } else if (data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors['email'] != null) {
              final emailErrors = errors['email'] as List;
              if (emailErrors.isNotEmpty) {
                errorMessage = emailErrors[0].toString();
              }
            }
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка входа (код: ${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения с сервером',
      };
    }
  }

  // Выход
  static Future<Map<String, dynamic>> logout() async {
    await initialize();

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/logout',
        data: {
          '_token': csrfToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        await _clearAuthData();
        return {
          'success': true,
          'message': 'Выход выполнен',
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка выхода',
        };
      }
    } catch (e) {
      print('❌ Logout error: $e');
      await _clearAuthData();
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // ============ ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ ============

  // Получение профиля
  static Future<Map<String, dynamic>> getProfile() async {
    await initialize();

    try {
      final response = await _dio.get('/profile');

      if (response.statusCode == 200) {
        // Парсим HTML профиля
        final html = response.data as String;
        final user = _parseUserFromHtml(html);

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения профиля',
        };
      }
    } catch (e) {
      print('❌ Get profile error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // Обновление аватара
  static Future<Map<String, dynamic>> updateAvatar(String imagePath) async {
    await initialize();

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final formData = FormData.fromMap({
        '_token': csrfToken,
        'avatar': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '/profile/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return {
          'success': true,
          'message': 'Аватар успешно обновлен',
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка обновления аватара',
        };
      }
    } catch (e) {
      print('❌ Update avatar error: $e');
      return {
        'success': false,
        'message': 'Ошибка загрузки',
      };
    }
  }

  // Удаление аватара
  static Future<Map<String, dynamic>> deleteAvatar() async {
    await initialize();

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/profile/avatar/delete',
        data: {
          '_token': csrfToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return {
          'success': true,
          'message': 'Аватар успешно удален',
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка удаления аватара',
        };
      }
    } catch (e) {
      print('❌ Delete avatar error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // ============ ПРОГРЕСС ОБУЧЕНИЯ ============

  // Обновление прогресса темы
  static Future<Map<String, dynamic>> updateTopicProgress({
    required String subject,
    required String topic,
    required int correctAnswers,
  }) async {
    await initialize();

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/api/progress',
        data: {
          '_token': csrfToken,
          'subject': subject,
          'topic': topic,
          'correct_answers': correctAnswers,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Прогресс сохранен',
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка сохранения прогресса',
        };
      }
    } catch (e) {
      print('❌ Update progress error: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации',
      };
    }
  }

  // Получение прогресса пользователя
  static Future<Map<String, dynamic>> getUserProgress() async {
    await initialize();

    try {
      final response = await _dio.get('/api/progress');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'progress': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения прогресса',
        };
      }
    } catch (e) {
      print('❌ Get progress error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // Обновление ежедневного прогресса
  static Future<Map<String, dynamic>> updateDailyProgress() async {
    await initialize();

    try {
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        return {
          'success': false,
          'message': 'Не удалось получить CSRF токен',
        };
      }

      final response = await _dio.post(
        '/api/daily-progress',
        data: {
          '_token': csrfToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Ежедневный прогресс обновлен',
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка обновления прогресса',
        };
      }
    } catch (e) {
      print('❌ Update daily progress error: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации',
      };
    }
  }

  // ============ СТАТИСТИКА ============

  // Получение статистики
  static Future<Map<String, dynamic>> getStats() async {
    await initialize();

    try {
      final response = await _dio.get('/api/stats');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения статистики',
        };
      }
    } catch (e) {
      print('❌ Get stats error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // Получение стрика (дней подряд)
  static Future<Map<String, dynamic>> getStreak() async {
    await initialize();

    try {
      final response = await _dio.get('/api/streak');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'streak': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения стрика',
        };
      }
    } catch (e) {
      print('❌ Get streak error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // ============ ПРЕДМЕТЫ И ТЕМЫ ============

  // Получение списка предметов
  static Future<Map<String, dynamic>> getSubjects() async {
    await initialize();

    try {
      final response = await _dio.get('/api/subjects');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'subjects': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения предметов',
        };
      }
    } catch (e) {
      print('❌ Get subjects error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // Получение тем по предмету
  static Future<Map<String, dynamic>> getTopics(String subject) async {
    await initialize();

    try {
      final response = await _dio.get('/api/topics/$subject');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'topics': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения тем',
        };
      }
    } catch (e) {
      print('❌ Get topics error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // Получение вопросов по теме
  static Future<Map<String, dynamic>> getQuestions(String topicId) async {
    await initialize();

    try {
      final response = await _dio.get('/api/questions/$topicId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'questions': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Ошибка получения вопросов',
        };
      }
    } catch (e) {
      print('❌ Get questions error: $e');
      return {
        'success': false,
        'message': 'Ошибка соединения',
      };
    }
  }

  // ============ УТИЛИТЫ ============

  // Проверка доступности сервера
  static Future<bool> checkServerAvailability() async {
    try {
      await initialize();
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      print('Server availability check failed: $e');
      return false;
    }
  }

  // Проверка статуса авторизации
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Очистка данных авторизации
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_avatar_path');
    await _cookieJar.deleteAll();
    _csrfToken = null;
  }

  // Парсинг пользователя из HTML
  static Map<String, dynamic> _parseUserFromHtml(String html) {
    try {
      final nameRegex = RegExp(r'<h1[^>]*>([^<]+)</h1>');
      final emailRegex = RegExp(r'<p[^>]*>Email:\s*([^<]+)</p>');
      final avatarRegex = RegExp(r'<img[^>]*src="([^"]+)"[^>]*alt="Avatar"');
      final streakRegex = RegExp(r'<p[^>]*>Streak:\s*(\d+)</p>');

      final nameMatch = nameRegex.firstMatch(html);
      final emailMatch = emailRegex.firstMatch(html);
      final avatarMatch = avatarRegex.firstMatch(html);
      final streakMatch = streakRegex.firstMatch(html);

      return {
        'name': nameMatch?.group(1)?.trim() ?? '',
        'email': emailMatch?.group(1)?.trim() ?? '',
        'avatar_url': avatarMatch?.group(1) ?? '',
        'streak': int.tryParse(streakMatch?.group(1) ?? '0') ?? 0,
      };
    } catch (e) {
      print('Error parsing user from HTML: $e');
      return {
        'name': '',
        'email': '',
        'avatar_url': '',
        'streak': 0,
      };
    }
  }

  // Discovery endpoints для отладки
  static Future<Map<String, dynamic>> discoverEndpoints() async {
    await initialize();

    final results = <String, dynamic>{};
    final endpointsToTest = [
      '/',
      '/register',
      '/login',
      '/logout',
      '/profile',
      '/api/register',
      '/api/login',
      '/api/logout',
      '/api/profile',
      '/api/progress',
      '/api/stats',
      '/api/streak',
      '/api/subjects',
    ];

    for (final endpoint in endpointsToTest) {
      try {
        final response = await _dio.get(endpoint);
        results[endpoint] = {
          'status': response.statusCode,
          'exists': response.statusCode != 404,
        };
      } catch (e) {
        results[endpoint] = {
          'status': 'error',
          'exists': false,
          'error': e.toString(),
        };
      }
    }

    return results;
  }
}