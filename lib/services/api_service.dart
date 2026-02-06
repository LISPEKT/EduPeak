// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'https://edupeak.ru';
  String? _csrfToken;
  String? _sessionCookie;

  // === ВСЕ СТАТИЧЕСКИЕ МЕТОДЫ ДЛЯ СОВМЕСТИМОСТИ ===

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
    return await ApiService()._getUserProgress();
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

  static Future<Map<String, dynamic>> getChatMessages(String friendId) async {
    return await ApiService()._getChatMessages(friendId);
  }

  static Future<Map<String, dynamic>> sendMessage(String friendId, String message) async {
    return await ApiService()._sendMessage(friendId, message);
  }

  static Future<Map<String, dynamic>> getAchievements() async {
    return await ApiService()._getAchievements();
  }

  static Future<Map<String, dynamic>> unlockAchievement(String achievementId) async {
    return await ApiService()._unlockAchievement(achievementId);
  }

  static Future<Map<String, dynamic>> getAchievementProgress() async {
    return await ApiService()._getAchievementProgress();
  }

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

  static Future<bool> checkAuthStatus() async {
    return await ApiService()._checkAuthStatus();
  }

  // === ИНСТАНСНЫЕ МЕТОДЫ (внутренние) ===

  Future<void> initialize() async {
    // Загружаем сохраненные куки
    await _loadCookies();
    print('✅ ApiService initialized');
  }

  Future<void> saveAuthData(String email, String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('username', username);
      await prefs.setString('auth_timestamp', DateTime.now().toIso8601String());
      print('✅ Auth data saved for user: $username');
    } catch (e) {
      print('❌ Error saving auth data: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    print('📡 Получение профиля...');
    try {
      // Локальная заглушка - в реальности делаем HTTP запрос
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'Пользователь';
      final email = prefs.getString('userEmail') ?? '';

      return {
        'name': username,
        'email': email,
        'avatar_url': '',
        'streak': 0,
      };
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    print('📝 Обновление профиля: $name');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', name);

      return {
        'success': true,
        'message': 'Профиль успешно обновлен (локально)'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ошибка обновления профиля: $e'
      };
    }
  }

  Future<String?> downloadAvatar(String avatarUrl) async {
    print('📥 Загрузка аватара: $avatarUrl');
    // Локальная заглушка
    return null;
  }

  // === ОСНОВНЫЕ МЕТОДЫ АВТОРИЗАЦИИ ===

  Future<bool> _checkServerAvailability() async {
    print('🌐 Проверка доступности сервера...');
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse(_baseUrl));
      final response = await request.close();

      final available = response.statusCode == 200;
      print('✅ Сервер ${available ? 'доступен' : 'недоступен'}. Статус: ${response.statusCode}');

      client.close();
      return available;
    } catch (e) {
      print('❌ Ошибка подключения к серверу: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _login(String email, String password) async {
    print('🔄 === НАЧАЛО ЛОГИНА ===');
    print('📧 Email: $email');

    try {
      // 1. Пробуем получить CSRF токен
      print('🔍 Получение CSRF токена...');
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        print('❌ Не удалось получить CSRF токен');
        return {'success': false, 'message': 'Ошибка получения токена безопасности'};
      }

      print('✅ CSRF токен получен');

      // 2. Отправляем POST запрос на логин
      print('📤 Отправка POST запроса на /api/auth/login');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/auth/login'));

      // Устанавливаем заголовки
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36');
      request.headers.set('Accept', 'application/json, text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
      request.headers.set('Accept-Language', 'ru-RU,ru;q=0.9,en;q=0.8');
      request.headers.set('X-Requested-With', 'XMLHttpRequest');
      request.headers.set('Origin', _baseUrl);
      request.headers.set('Referer', '$_baseUrl/login');

      if (_sessionCookie != null) {
        request.headers.set('cookie', _sessionCookie!);
      }

      // Подготавливаем данные
      final formData = 'email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&_token=${Uri.encodeComponent(csrfToken)}';

      print('📝 Данные формы: $formData');
      request.write(formData);

      final response = await request.close();
      final statusCode = response.statusCode;
      print('📡 Статус ответа: $statusCode');

      // Сохраняем куки из ответа
      _saveCookiesFromResponse(response);

      // Читаем тело ответа
      final responseBody = await response.transform(utf8.decoder).join();
      print('📄 Тело ответа: $responseBody');

      // Парсим JSON ответ
      try {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          // Успешный логин
          print('✅ Логин успешен!');
          print('👤 Данные пользователя: ${jsonResponse['user']}');

          // Сохраняем токен если есть
          final token = jsonResponse['token'];
          if (token != null) {
            print('🔐 Токен получен: ${token.toString().substring(0, min(20, token.toString().length))}...');
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token.toString());
          }

          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);

          // Сохраняем имя пользователя если есть
          final userData = jsonResponse['user'];
          if (userData is Map && userData['name'] != null) {
            await prefs.setString('username', userData['name'].toString());
          }

          client.close();
          return {
            'success': true,
            'message': jsonResponse['message']?.toString() ?? 'Вход выполнен успешно',
            'token': token,
            'user': userData
          };
        } else {
          // Ошибка логина
          print('❌ Ошибка логина: ${jsonResponse['message']}');
          client.close();
          return {
            'success': false,
            'message': jsonResponse['message']?.toString() ?? 'Ошибка входа'
          };
        }
      } catch (e) {
        // Если не JSON, анализируем как текст
        print('⚠️ Ответ не JSON, анализируем как текст');

        if (statusCode == 401 || responseBody.contains('Неверные учетные данные')) {
          client.close();
          return {'success': false, 'message': 'Неверный email или пароль'};
        }

        if (statusCode == 200 && responseBody.contains('success')) {
          // Возможно успешный вход
          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);

          print('✅ Логин успешен (по тексту ответа)!');
          client.close();
          return {'success': true, 'message': 'Вход выполнен успешно'};
        }

        client.close();
        return {'success': false, 'message': 'Ошибка входа. Статус: $statusCode'};
      }

    } catch (e) {
      print('❌ Ошибка при логине: $e');
      return {'success': false, 'message': 'Ошибка сети: ${e.toString()}'};
    } finally {
      print('🔚 === КОНЕЦ ЛОГИНА ===');
    }
  }


  Future<Map<String, dynamic>> _register(String name, String email, String password) async {
    print('🔄 === НАЧАЛО РЕГИСТРАЦИИ ===');
    print('👤 Имя: $name, 📧 Email: $email');

    try {
      // 1. Пробуем получить CSRF токен
      print('🔍 Получение CSRF токена...');
      final csrfToken = await _getCsrfToken();

      if (csrfToken == null) {
        print('❌ Не удалось получить CSRF токен');
        return {'success': false, 'message': 'Ошибка получения токена безопасности'};
      }

      print('✅ CSRF токен получен');

      // 2. Отправляем POST запрос на регистрацию
      print('📤 Отправка POST запроса на /api/auth/register');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/auth/register'));

      // Устанавливаем заголовки
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36');
      request.headers.set('Accept', 'application/json, text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
      request.headers.set('Accept-Language', 'ru-RU,ru;q=0.9,en;q=0.8');
      request.headers.set('X-Requested-With', 'XMLHttpRequest');
      request.headers.set('Origin', _baseUrl);
      request.headers.set('Referer', '$_baseUrl/register');

      if (_sessionCookie != null) {
        request.headers.set('cookie', _sessionCookie!);
      }

      // Подготавливаем данные
      final formData = '_token=${Uri.encodeComponent(csrfToken)}&name=${Uri.encodeComponent(name)}&email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&password_confirmation=${Uri.encodeComponent(password)}';

      print('📝 Данные формы: $formData');
      request.write(formData);

      final response = await request.close();
      final statusCode = response.statusCode;
      print('📡 Статус ответа: $statusCode');

      // Сохраняем куки
      _saveCookiesFromResponse(response);

      // Читаем тело ответа
      final responseBody = await response.transform(utf8.decoder).join();
      print('📄 Тело ответа: $responseBody');

      // Парсим JSON ответ
      try {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          // Успешная регистрация
          print('✅ Регистрация успешна!');
          print('👤 Данные пользователя: ${jsonResponse['user']}');

          // Сохраняем токен если есть
          final token = jsonResponse['token'];
          if (token != null) {
            print('🔐 Токен получен: ${token.toString().substring(0, min(20, token.toString().length))}...');
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token.toString());
          }

          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('username', name);

          client.close();
          return {
            'success': true,
            'message': jsonResponse['message']?.toString() ?? 'Регистрация успешна',
            'token': token,
            'user': jsonResponse['user']
          };
        } else {
          // Ошибки валидации
          final errors = jsonResponse['errors'];
          if (errors != null && errors is Map) {
            if (errors['email'] != null && errors['email'].toString().contains('already been taken')) {
              return {'success': false, 'message': 'Email уже используется'};
            }
            if (errors['password'] != null) {
              return {'success': false, 'message': 'Ошибка в пароле'};
            }
          }

          client.close();
          return {
            'success': false,
            'message': jsonResponse['message']?.toString() ?? 'Ошибка регистрации'
          };
        }
      } catch (e) {
        // Если не JSON, анализируем как текст
        print('⚠️ Ответ не JSON, анализируем как текст');

        if (responseBody.contains('email has already been taken') ||
            responseBody.contains('Email уже используется')) {
          client.close();
          return {'success': false, 'message': 'Email уже используется'};
        }

        if (statusCode == 201 || statusCode == 200) {
          // Возможно успешная регистрация
          await _saveCookies();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('username', name);

          print('✅ Регистрация успешна (по статусу)!');
          client.close();
          return {'success': true, 'message': 'Регистрация успешна'};
        }

        client.close();
        return {'success': false, 'message': 'Ошибка регистрации. Статус: $statusCode'};
      }

    } catch (e) {
      print('❌ Ошибка при регистрации: $e');
      return {'success': false, 'message': 'Ошибка сети: ${e.toString()}'};
    } finally {
      print('🔚 === КОНЕЦ РЕГИСТРАЦИИ ===');
    }
  }

  int min(int a, int b) => a < b ? a : b;

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userEmail');
      await prefs.remove('username');

      await _clearCookies();
      print('✅ Логаут выполнен');
    } catch (e) {
      print('❌ Ошибка при логауте: $e');
    }
  }

  // === ЗАГЛУШКИ ДЛЯ ОСТАЛЬНЫХ МЕТОДОВ ===

  Future<void> _updateTopicProgress(String subject, String topicName, int correctAnswers) async {
    print('📚 Прогресс: $subject - $topicName: $correctAnswers');
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'progress_${subject}_$topicName';
    await prefs.setInt(progressKey, correctAnswers);
    print('💾 Прогресс сохранен локально');
  }

  Future<Map<String, dynamic>?> _getUserProgress() async {
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

    return {'progress': progress};
  }

  Future<Map<String, dynamic>> _updateAvatar(String imagePath) async {
    print('🖼️ Обновление аватара: $imagePath');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar_path', imagePath);

    return {
      'success': true,
      'message': 'Аватар сохранен локально',
      'avatar_url': imagePath
    };
  }

  Future<void> _syncAllProgressToServer(Map<String, Map<String, int>> progressData) async {
    print('🔄 Синхронизация прогресса...');
    print('📊 Предметов: ${progressData.length}');

    // Локальное сохранение
    final prefs = await SharedPreferences.getInstance();

    // Очищаем старый прогресс
    final oldKeys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();
    for (final key in oldKeys) {
      await prefs.remove(key);
    }

    // Сохраняем новый прогресс
    for (final subject in progressData.keys) {
      final topics = progressData[subject]!;
      for (final topic in topics.keys) {
        final correctAnswers = topics[topic]!;
        final progressKey = 'progress_${subject}_$topic';
        await prefs.setInt(progressKey, correctAnswers);
      }
    }

    print('✅ Прогресс синхронизирован локально');
  }

  Future<Map<String, dynamic>> _discoverEndpoints() async {
    return {
      'success': true,
      'endpoints': {
        '/': await _checkEndpoint('/'),
        '/login': await _checkEndpoint('/login'),
        '/register': await _checkEndpoint('/register'),
        '/profile': await _checkEndpoint('/profile'),
      },
      'message': 'Проверка эндпоинтов завершена'
    };
  }

  Future<bool> _checkEndpoint(String endpoint) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final request = await client.getUrl(Uri.parse('$_baseUrl$endpoint'));
      final response = await request.close();

      client.close();
      return response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  // === ЗАГЛУШКИ ДЛЯ ЭКРАНОВ ===

  Future<Map<String, dynamic>> _getChatMessages(String friendId) async {
    return {
      'success': true,
      'messages': []
    };
  }

  Future<Map<String, dynamic>> _sendMessage(String friendId, String message) async {
    return {
      'success': true,
      'message': 'Сообщение сохранено локально'
    };
  }

  Future<Map<String, dynamic>> _getAchievements() async {
    return {
      'success': true,
      'achievements': [
        {
          'id': 'first_test',
          'title': 'Первый тест',
          'description': 'Пройдите первый тест',
          'icon': '🎯',
          'xp_reward': 10,
          'unlocked': true
        },
        {
          'id': 'streak_3',
          'title': '3 дня подряд',
          'description': 'Занимайтесь 3 дня подряд',
          'icon': '🔥',
          'xp_reward': 25,
          'unlocked': false
        }
      ]
    };
  }

  Future<Map<String, dynamic>> _unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedKey = 'achievement_$achievementId';
    await prefs.setBool(unlockedKey, true);

    return {
      'success': true,
      'message': 'Достижение разблокировано'
    };
  }

  Future<Map<String, dynamic>> _getAchievementProgress() async {
    return {
      'success': true,
      'progress': {
        'first_test': true,
        'streak_3': false
      }
    };
  }

  Future<Map<String, dynamic>> _getFriends() async {
    return {
      'success': true,
      'friends': [
        {
          'id': '1',
          'username': 'Друг 1',
          'avatar': '👤',
          'status': 'online'
        },
        {
          'id': '2',
          'username': 'Друг 2',
          'avatar': '👤',
          'status': 'offline'
        }
      ],
      'pending_requests': []
    };
  }

  Future<Map<String, dynamic>> _sendFriendRequest(String username) async {
    return {
      'success': true,
      'message': 'Запрос на дружбу отправлен'
    };
  }

  Future<Map<String, dynamic>> _acceptFriendRequest(String requestId) async {
    return {
      'success': true,
      'message': 'Запрос принят'
    };
  }

  Future<Map<String, dynamic>> _declineFriendRequest(String requestId) async {
    return {
      'success': true,
      'message': 'Запрос отклонен'
    };
  }

  Future<Map<String, dynamic>> _removeFriend(String friendId) async {
    return {
      'success': true,
      'message': 'Друг удален'
    };
  }

  Future<Map<String, dynamic>> _searchUsers(String query) async {
    return {
      'success': true,
      'users': []
    };
  }

  Future<Map<String, dynamic>> _getLeagueLeaderboard(String leagueName) async {
    return {
      'success': true,
      'leaderboard': [
        {
          'rank': 1,
          'username': 'Лидер',
          'xp': 1000,
          'avatar': '👑'
        },
        {
          'rank': 2,
          'username': 'Игрок 2',
          'xp': 800,
          'avatar': '🥈'
        }
      ]
    };
  }

  Future<Map<String, dynamic>> _getUserLeagueInfo() async {
    return {
      'success': true,
      'current_league': 'Бронза',
      'weekly_xp': 150,
      'rank': 25,
      'total_users': 100
    };
  }

  Future<Map<String, dynamic>> _addXP(int xp, String source) async {
    print('➕ Добавление XP: $xp за $source');

    final prefs = await SharedPreferences.getInstance();
    final currentXP = prefs.getInt('total_xp') ?? 0;
    final newXP = currentXP + xp;
    await prefs.setInt('total_xp', newXP);

    // Обновляем недельный XP
    final weeklyKey = 'weekly_xp_${DateTime.now().weekday}';
    final currentWeekly = prefs.getInt(weeklyKey) ?? 0;
    await prefs.setInt(weeklyKey, currentWeekly + xp);

    return {
      'success': true,
      'message': 'XP добавлен',
      'new_total': newXP
    };
  }

  Future<Map<String, dynamic>> _getUserXPStats() async {
    final prefs = await SharedPreferences.getInstance();
    final totalXP = prefs.getInt('total_xp') ?? 0;

    // Считаем недельный XP
    int weeklyXP = 0;
    for (int i = 1; i <= 7; i++) {
      weeklyXP += prefs.getInt('weekly_xp_$i') ?? 0;
    }

    return {
      'success': true,
      'total_xp': totalXP,
      'weekly_xp': weeklyXP,
      'current_league': totalXP > 1000 ? 'Серебро' : 'Бронза',
      'league_progress': totalXP > 1000 ? 0.3 : 0.7
    };
  }

  Future<Map<String, dynamic>> _syncAllUserData() async {
    return {
      'success': true,
      'message': 'Данные синхронизированы (локально)',
      'synced': true,
      'stats': {
        'topics_synced': 0,
        'xp_synced': 0,
        'streak_synced': 0,
      }
    };
  }

  Future<Map<String, dynamic>> _getAllUserData() async {
    return {
      'success': true,
      'data': {
        'profile': await getProfile(),
        'topicProgress': (await _getUserProgress())?['progress'] ?? {},
        'xp': {
          'totalXP': 0,
          'weeklyXP': 0,
          'currentLeague': 'Бронза',
        },
        'achievements': {},
        'friends': {
          'friends': [],
          'pending_requests': [],
        },
      },
      'message': 'Данные получены локально'
    };
  }

  Future<Map<String, dynamic>> _uploadAllLocalData() async {
    return {
      'success': true,
      'message': 'Локальные данные сохранены',
      'uploaded': {
        'topics': 0,
        'totalXP': 0,
      }
    };
  }

  Future<Map<String, dynamic>> _checkDataConflicts() async {
    return {
      'success': true,
      'conflicts': {},
      'hasConflicts': false,
      'message': 'Конфликты не обнаружены'
    };
  }

  Future<bool> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ===

  Future<String?> _getCsrfToken() async {
    print('🔍 Поиск CSRF токена...');

    // Пробуем несколько страниц
    final pages = ['/', '/login', '/register'];

    for (final page in pages) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);

        final request = await client.getUrl(Uri.parse('$_baseUrl$page'));
        request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36');

        if (_sessionCookie != null) {
          request.headers.set('cookie', _sessionCookie!);
        }

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        _saveCookiesFromResponse(response);

        // Ищем токен
        final tokenPattern = RegExp(r'name="_token" value="([^"]+)"');
        final match = tokenPattern.firstMatch(responseBody);

        if (match != null) {
          final token = match.group(1)!;
          print('✅ CSRF токен найден на странице $page');
          client.close();
          return token;
        }

        client.close();
      } catch (e) {
        print('⚠️ Ошибка при запросе $page: $e');
      }
    }

    print('❌ CSRF токен не найден, используем заглушку');
    return 'stub_csrf_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _saveCookiesFromResponse(HttpClientResponse response) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      for (final cookie in cookies) {
        if (cookie.contains('laravel-session') || cookie.contains('edupeak-session')) {
          _sessionCookie = cookie.split(';').first;
          print('🍪 Session cookie сохранен');
        } else if (cookie.contains('XSRF-TOKEN')) {
          final tokenMatch = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(cookie);
          if (tokenMatch != null) {
            _csrfToken = Uri.decodeComponent(tokenMatch.group(1)!);
            print('🔐 CSRF токен сохранен');
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
  }

  Future<void> _clearCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    await prefs.remove('csrf_token');
    _sessionCookie = null;
    _csrfToken = null;
  }
}