// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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

  static Future<Map<String, dynamic>> updateTopicProgress(String subject, String topicName, int correctAnswers) async {
    return await ApiService()._updateTopicProgress(subject, topicName, correctAnswers);
  }

  static Future<Map<String, dynamic>?> getUserProgress() async {
    return await ApiService()._getUserProgress();
  }

  static Future<Map<String, dynamic>> updateAvatar(String imagePath) async {
    return await ApiService()._updateAvatar(imagePath);
  }

  static Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    return await ApiService()._updateProfile(name, email);
  }

  static Future<Map<String, dynamic>> discoverEndpoints() async {
    return await ApiService()._discoverEndpoints();
  }

  static Future<Map<String, dynamic>> getCurrentLeague() async {
    return await ApiService()._getCurrentLeague();
  }

  static Future<Map<String, dynamic>> getLeagueLeaderboard(String league) async {
    return await ApiService()._getLeagueLeaderboard(league);
  }

  static Future<Map<String, dynamic>> getLeagueHistory() async {
    return await ApiService()._getLeagueHistory();
  }

  static Future<Map<String, dynamic>> getAvailableLeagues() async {
    return await ApiService()._getAvailableLeagues();
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

  static Future<Map<String, dynamic>> getUserLeagueInfo() async {
    return await ApiService()._getUserLeagueInfo();
  }

  static Future<Map<String, dynamic>> addXP(int xp, String source) async {
    return await ApiService()._addXP(xp, source);
  }

  static Future<Map<String, dynamic>> getUserXPStats() async {
    return await ApiService()._getUserXPStats();
  }

  static Future<Map<String, dynamic>> getXpHistory(int days) async {
    return await ApiService()._getXpHistory(days);
  }

  static Future<Map<String, dynamic>> syncAllUserData() async {
    return await ApiService()._syncAllUserData();
  }

  static Future<Map<String, dynamic>> getAllUserData() async {
    return await ApiService()._getAllUserData();
  }

  static Future<Map<String, dynamic>> uploadAllLocalData(Map<String, dynamic> data) async {
    return await ApiService()._uploadAllLocalData(data);
  }

  static Future<Map<String, dynamic>> checkDataConflicts(Map<String, dynamic> localData) async {
    return await ApiService()._checkDataConflicts(localData);
  }

  static Future<bool> checkAuthStatus() async {
    return await ApiService()._checkAuthStatus();
  }

  // Методы для сброса прогресса
  static Future<Map<String, dynamic>> resetUserProgress() async {
    return await ApiService()._resetUserProgress();
  }

  static Future<Map<String, dynamic>> resetUserProgressWithConfirmation(bool confirm) async {
    return await ApiService()._resetUserProgressWithConfirmation(confirm);
  }

  static Future<Map<String, dynamic>> getUserResetStats() async {
    return await ApiService()._getUserResetStats();
  }

  // Проверка, является ли пользователь администратором
  static Future<bool> isAdmin() async {
    try {
      final token = await _getTokenStatic();
      if (token == null) return false;

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('https://edupeak.ru/api/auth/me'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['user']['is_admin'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Ошибка проверки админа: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> _getTokenStatic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // === ИНСТАНСНЫЕ МЕТОДЫ (внутренние) ===

  Future<void> initialize() async {
    await _loadCookies();
    print('✅ ApiService initialized');
  }

  Future<Map<String, dynamic>> _getAvailableLeagues() async {
    print('📊 Получение списка доступных лиг...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/leagues/available'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения списка лиг'};
    } catch (e) {
      print('❌ Ошибка получения списка лиг: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getCurrentLeague() async {
    print('📊 Получение текущей лиги и группы...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/leagues/current'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        print('✅ Данные лиги получены');
        return jsonResponse;
      }
      return {'success': false, 'message': 'Ошибка получения данных лиги'};
    } catch (e) {
      print('❌ Ошибка получения данных лиги: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  static Future<List<dynamic>> getNews() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/content/news'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки новостей: $e');
      return [];
    }
  }

  // Получить баннеры с сервера
  static Future<List<dynamic>> getBanners() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/content/banners'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки баннеров: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _getLeagueHistory() async {
    print('📊 Получение истории лиг...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/leagues/history'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения истории'};
    } catch (e) {
      print('❌ Ошибка получения истории: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
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
      final token = await _getToken();
      if (token == null) return null;

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/profile'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          return jsonResponse['profile'];
        }
      }
      client.close();
      return null;
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _updateProfile(String name, String email) async {
    print('📝 Обновление профиля: $name');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.putUrl(Uri.parse('$_baseUrl/api/profile'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'name': name});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody) as Map<String, dynamic>;
        print('✅ Профиль обновлен на сервере: $result');
        return result;
      }
      return {'success': false, 'message': 'Ошибка обновления профиля'};
    } catch (e) {
      print('❌ Ошибка обновления профиля: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }


  static Future<bool> checkTokenValidity(String token) async {
    try {
      // Используем существующий маршрут /api/profile вместо /api/me
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('🔍 Token validity check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Token check error: $e');
      return false;
    }
  }

  Future<String?> downloadAvatar(String avatarUrl) async {
    print('📥 Загрузка аватара: $avatarUrl');
    return null;
  }

  // === НОВЫЕ МЕТОДЫ ДЛЯ ЛИГ ===

  Future<Map<String, dynamic>> _getLeagueLeaderboard(String league) async {
    print('📊 Получение лидерборда лиги: $league');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final encodedLeague = Uri.encodeComponent(league);
      final request = await client.getUrl(Uri.parse('$_baseUrl/api/leagues/$encodedLeague/leaderboard'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения лидерборда'};
    } catch (e) {
      print('❌ Ошибка получения лидерборда: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getUserLeagueInfo() async {
    print('📊 Получение информации о лиге пользователя');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/xp/league'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения информации о лиге'};
    } catch (e) {
      print('❌ Error getting user league info: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _addXP(int xp, String source) async {
    print('➕ Добавление XP: $xp за $source');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/xp/add'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'xp': xp, 'source': source});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка добавления XP'};
    } catch (e) {
      print('❌ Error adding XP: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getUserXPStats() async {
    print('📊 Получение статистики XP через sync/all');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      // Используем рабочий эндпоинт /api/sync/all
      final request = await client.getUrl(Uri.parse('$_baseUrl/api/sync/all'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ sync/all: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final data = jsonResponse['data'] ?? {};
        final xpData = data['xp'] ?? {};
        final profileData = data['profile'] ?? {};

        return {
          'success': true,
          'total_xp': xpData['totalXP'] ?? 0,
          'weekly_xp': xpData['weeklyXP'] ?? 0,
          'streak_days': xpData['streakDays'] ?? 0,
          'last_7_days': xpData['statistics']?['last7DaysXP'] ?? 0,
          'last_30_days': xpData['statistics']?['last30DaysXP'] ?? 0,
          'league': {
            'current_league': xpData['currentLeague'] ?? 'Бронзовая',
            'league_progress': 0.0,
          },
          'daily_xp': xpData['dailyXP'] ?? {},
        };
      }

      return {'success': false, 'message': 'Ошибка получения статистики XP'};
    } catch (e) {
      print('❌ Error getting XP stats: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getXpHistory(int days) async {
    print('📊 Получение истории XP за $days дней');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/xp/history?days=$days'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения истории XP'};
    } catch (e) {
      print('❌ Error getting XP history: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _syncAllUserData() async {
    print('🔄 Получение всех данных пользователя через sync/all');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/sync/all'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ sync/all получен, длина: ${responseBody.length}');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final data = jsonResponse['data'] ?? {};

        // Сохраняем XP в кэш
        final xpData = data['xp'] ?? {};
        final prefs = await SharedPreferences.getInstance();

        if (xpData['totalXP'] != null) {
          await prefs.setInt('cached_total_xp', xpData['totalXP']);
          await prefs.setInt('cached_weekly_xp', xpData['weeklyXP'] ?? 0);
          await prefs.setInt('cached_streak_days', xpData['streakDays'] ?? 0);
          print('✅ XP сохранены в кэш: total=${xpData['totalXP']}');
        }

        // Сохраняем профиль
        final profileData = data['profile'] ?? {};
        if (profileData['name'] != null) {
          await prefs.setString('username', profileData['name']);
          print('✅ Имя сохранено: ${profileData['name']}');
        }

        return jsonResponse;
      }

      return {'success': false, 'message': 'Ошибка получения данных'};
    } catch (e) {
      print('❌ Error syncing user data: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getAllUserData() async {
    print('📥 Получение всех данных пользователя');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/sync/data'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения данных'};
    } catch (e) {
      print('❌ Error getting all user data: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _uploadAllLocalData(Map<String, dynamic> data) async {
    print('📤 Загрузка локальных данных на сервер');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/sync/upload'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode(data);
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка загрузки данных'};
    } catch (e) {
      print('❌ Error uploading local data: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _checkDataConflicts(Map<String, dynamic> localData) async {
    print('⚡ Проверка конфликтов данных');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/sync/check-conflicts'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode(localData);
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка проверки конфликтов'};
    } catch (e) {
      print('❌ Error checking data conflicts: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Методы для сброса прогресса
  Future<Map<String, dynamic>> _resetUserProgress() async {
    print('🔄 Сброс прогресса пользователя на сервере...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/sync/reset-progress'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка сброса прогресса'};
    } catch (e) {
      print('❌ Ошибка сброса прогресса на сервере: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _resetUserProgressWithConfirmation(bool confirm) async {
    print('🔄 Сброс прогресса с подтверждением...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/sync/reset-progress-confirm'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'confirm': confirm});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка сброса прогресса'};
    } catch (e) {
      print('❌ Ошибка: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _getUserResetStats() async {
    print('📊 Получение статистики для сброса...');
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/sync/reset-stats'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Ошибка получения статистики'};
    } catch (e) {
      print('❌ Ошибка: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
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
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/auth/login'));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'email': email, 'password': password});

      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        print('✅ Логин успешен!');
        final token = jsonResponse['token'];
        if (token != null) {
          await _saveToken(token);

          // Сохраняем данные пользователя в SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final user = jsonResponse['user'];

          if (user != null) {
            await prefs.setString('username', user['name'] ?? '');
            await prefs.setInt('cached_total_xp', user['total_xp'] ?? 0);
            await prefs.setInt('cached_weekly_xp', user['weekly_xp'] ?? 0);
            await prefs.setInt('cached_streak_days', user['streak'] ?? 0);
            await prefs.setString('current_league', user['current_league'] ?? 'Бронзовая');
            await prefs.setBool('is_admin', user['is_admin'] ?? false);
            await prefs.setBool('isLoggedIn', true);

            print('✅ Данные пользователя сохранены: XP=${user['total_xp']}, Лига=${user['current_league']}');
          }

          // 📱 ОТПРАВКА FCM ТОКЕНА НА СЕРВЕР ПОСЛЕ ЛОГИНА
          await _sendFCMTokenToServer();

          // Принудительная синхронизация после логина
          await _syncAllUserData();
        }
        return jsonResponse;
      } else {
        print('❌ Ошибка логина: ${jsonResponse['message']}');
        return jsonResponse;
      }
    } catch (e) {
      print('❌ Ошибка при логине: $e');
      return {'success': false, 'message': 'Ошибка сети: ${e.toString()}'};
    }
  }

  Future<void> _sendFCMTokenToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');

      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ FCM токен не найден, пропускаем отправку');
        return;
      }

      final token = await _getToken();
      if (token == null) {
        print('⚠️ Токен авторизации не найден');
        return;
      }

      print('📱 Отправка FCM токена на сервер...');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/notifications/register-token'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'fcm_token': fcmToken});
      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        print('✅ FCM токен успешно зарегистрирован на сервере');
      } else {
        print('❌ Ошибка регистрации FCM токена: $responseBody');
      }
    } catch (e) {
      print('❌ Ошибка отправки FCM токена: $e');
    }
  }

  Future<Map<String, dynamic>> _register(String name, String email, String password) async {
    print('🔄 === НАЧАЛО РЕГИСТРАЦИИ ===');
    print('👤 Имя: $name, 📧 Email: $email');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/auth/register'));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password
      });

      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ сервера: $responseBody');
      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        print('✅ Регистрация успешна!');
        final token = jsonResponse['token'];
        if (token != null) {
          await _saveToken(token);
        }
        return jsonResponse;
      } else {
        print('❌ Ошибка регистрации: ${jsonResponse['message']}');
        return jsonResponse;
      }
    } catch (e) {
      print('❌ Ошибка при регистрации: $e');
      return {'success': false, 'message': 'Ошибка сети: ${e.toString()}'};
    }
  }

  Future<void> _logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);

        final request = await client.postUrl(Uri.parse('$_baseUrl/api/auth/logout'));
        request.headers.set('Authorization', 'Bearer $token');
        request.headers.set('Accept', 'application/json');

        await request.close();
        client.close();
      }
    } catch (e) {
      print('❌ Ошибка при логауте: $e');
    } finally {
      await _clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userEmail');
      await prefs.remove('username');
      print('✅ Логаут выполнен');
    }
  }

  // === ЗАГЛУШКИ ДЛЯ ОСТАЛЬНЫХ МЕТОДОВ ===

  Future<Map<String, dynamic>> _updateTopicProgress(String subject, String topicName, int correctAnswers) async {
    print('📚 Прогресс: $subject - $topicName: $correctAnswers');
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'progress_${subject}_$topicName';
    await prefs.setInt(progressKey, correctAnswers);
    print('💾 Прогресс сохранен локально');
    return {'success': true, 'message': 'Прогресс сохранен локально'};
  }

  Future<Map<String, dynamic>> registerFCMToken(String token) async {
    print('📱 Регистрация FCM токена на сервере...');
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        print('⚠️ Нет токена авторизации');
        return {'success': false, 'message': 'Не авторизован'};
      }

      print('📡 URL: $_baseUrl/api/notifications/register-token');
      print('📤 Token: $token');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/notifications/register-token'));
      request.headers.set('Authorization', 'Bearer $authToken');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'fcm_token': token});
      print('📦 Body: $body');

      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ FCM токен зарегистрирован на сервере');
        return {'success': true};
      }

      print('❌ Ошибка регистрации токена: $responseBody');
      return {'success': false, 'message': responseBody};
    } catch (e) {
      print('❌ Ошибка регистрации FCM токена: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
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
    print('✅ Аватар сохранен локально: $imagePath');

    final token = await _getToken();
    if (token == null) {
      return {
        'success': true,
        'message': 'Аватар сохранен локально',
        'avatar_url': imagePath,
        'is_local': true
      };
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return {
          'success': true,
          'message': 'Аватар сохранен локально (файл не найден на сервере)',
          'avatar_url': imagePath,
          'is_local': true
        };
      }

      final client = HttpClient();
      final uri = Uri.parse('$_baseUrl/api/profile/avatar');
      final request = await client.postUrl(uri);

      request.headers.set('Authorization', 'Bearer $token');

      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');

      final data = await file.readAsBytes();
      final filename = file.path.split('/').last;

      final body = StringBuffer();
      body.write('--$boundary\r\n');
      body.write('Content-Disposition: form-data; name="avatar"; filename="$filename"\r\n');
      body.write('Content-Type: image/jpeg\r\n\r\n');

      final header = body.toString();
      final footer = '\r\n--$boundary--\r\n';

      request.write(header);
      request.add(data);
      request.write(footer);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ от сервера: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          final serverAvatarUrl = jsonResponse['avatar_url'];

          await prefs.setString('user_avatar_path', imagePath);
          await prefs.setString('user_avatar_url', serverAvatarUrl);

          print('✅ Аватар сохранен:');
          print('   - Локально: $imagePath');
          print('   - Сервер: $serverAvatarUrl');

          return {
            'success': true,
            'message': 'Аватар обновлен на сервере',
            'avatar_url': serverAvatarUrl,
            'local_path': imagePath,
            'is_local': false
          };
        }
      }

      return {
        'success': true,
        'message': 'Аватар сохранен локально (ошибка сервера)',
        'avatar_url': imagePath,
        'is_local': true
      };
    } catch (e) {
      print('❌ Ошибка загрузки аватара: $e');
      return {
        'success': true,
        'message': 'Аватар сохранен локально (офлайн)',
        'avatar_url': imagePath,
        'is_local': true
      };
    }
  }

  Future<void> _syncAllProgressToServer(Map<String, Map<String, int>> progressData) async {
    print('🔄 Синхронизация прогресса...');
    print('📊 Предметов: ${progressData.length}');

    final prefs = await SharedPreferences.getInstance();

    final oldKeys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();
    for (final key in oldKeys) {
      await prefs.remove(key);
    }

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
    return {'success': true, 'messages': []};
  }

  Future<Map<String, dynamic>> _sendMessage(String friendId, String message) async {
    return {'success': true, 'message': 'Сообщение сохранено локально'};
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
    return {'success': true, 'message': 'Достижение разблокировано'};
  }

  Future<Map<String, dynamic>> _getAchievementProgress() async {
    return {'success': true, 'progress': {'first_test': true, 'streak_3': false}};
  }

  Future<Map<String, dynamic>> _getFriends() async {
    return {
      'success': true,
      'friends': [
        {'id': '1', 'username': 'Друг 1', 'avatar': '👤', 'status': 'online'},
        {'id': '2', 'username': 'Друг 2', 'avatar': '👤', 'status': 'offline'}
      ],
      'pending_requests': []
    };
  }

  Future<Map<String, dynamic>> _sendFriendRequest(String username) async {
    return {'success': true, 'message': 'Запрос на дружбу отправлен'};
  }

  Future<Map<String, dynamic>> _acceptFriendRequest(String requestId) async {
    return {'success': true, 'message': 'Запрос принят'};
  }

  Future<Map<String, dynamic>> _declineFriendRequest(String requestId) async {
    return {'success': true, 'message': 'Запрос отклонен'};
  }

  Future<Map<String, dynamic>> _removeFriend(String friendId) async {
    return {'success': true, 'message': 'Друг удален'};
  }

  Future<Map<String, dynamic>> _searchUsers(String query) async {
    return {'success': true, 'users': []};
  }

  Future<bool> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // === ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ТОКЕНОВ ===

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _saveCookies() async {}
  Future<void> _loadCookies() async {}
  void _saveCookiesFromResponse(HttpClientResponse response) {}
}