// lib/data/user_data_storage.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_stats.dart';
import '../services/secure_prefs.dart';
import 'package:flutter/services.dart';

class UserDataStorage {
  static const String _statsKey = 'user_stats';
  static const String _usernameKey = 'username';
  static const String _avatarKey = 'user_avatar_path';
  static const String _avatarUrlKey = 'user_avatar_url';
  static const String _lastSyncKey = 'last_sync';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _authTokenKey = 'auth_token';

  // === КЭШ В ПАМЯТИ ДЛЯ МГНОВЕННОГО ДОСТУПА ===
  static String? _cachedUsername;
  static String? _cachedAvatarPath;
  static bool _isInitialized = false;
  static bool _isSyncing = false;

  // === ИНИЦИАЛИЗАЦИЯ КЭША ===
  static Future<void> initializeCache() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUsername = prefs.getString(_usernameKey);
      _cachedAvatarPath = prefs.getString(_avatarKey);

      // Проверяем, существует ли файл аватара
      if (_cachedAvatarPath != null && _cachedAvatarPath != '👤') {
        final file = File(_cachedAvatarPath!);
        if (!await file.exists()) {
          _cachedAvatarPath = null;
        }
      }

      _isInitialized = true;
      print('✅ Кэш пользователя инициализирован');
    } catch (e) {
      print('❌ Ошибка инициализации кэша: $e');
    }
  }

  // === БЫСТРЫЙ ПОЛУЧЕНИЕ ДАННЫХ ИЗ КЭША ===
  static Future<Map<String, dynamic>> getCachedUserData() async {
    await initializeCache();

    return {
      'username': _cachedUsername ?? '',
      'avatar': _cachedAvatarPath ?? '👤',
      'hasAvatar': _cachedAvatarPath != null && _cachedAvatarPath != '👤',
    };
  }

  // === ОСНОВНЫЕ МЕТОДЫ С КЭШИРОВАНИЕМ ===

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
      if (!value) {
        _cachedUsername = null;
        _cachedAvatarPath = null;
        _isInitialized = false;
      }
    } catch (e) {
      print('❌ Error setting login status: $e');
    }
  }

  static Future<void> saveUsername(String username) async {
    try {
      _cachedUsername = username;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      print('✅ Username saved: $username');
    } catch (e) {
      print('❌ Error saving username: $e');
    }
  }

  static Future<String> getUsername() async {
    if (_cachedUsername != null) return _cachedUsername!;

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUsername = prefs.getString(_usernameKey) ?? '';
      return _cachedUsername!;
    } catch (e) {
      print('❌ Error getting username: $e');
      return '';
    }
  }

  static Future<void> saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, json.encode(stats.toJson()));
      print('💾 User stats saved: ${stats.topicProgress.length} subjects, total XP: ${stats.totalXP}');
    } catch (e) {
      print('❌ Error saving user stats: $e');
    }
  }

  static Future<UserStats> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_statsKey);

      if (data != null) {
        try {
          final jsonData = json.decode(data);
          final stats = UserStats.fromJson(jsonData);
          print('📊 Loaded user stats: ${stats.totalXP} XP, ${stats.topicProgress.length} subjects');
          return stats;
        } catch (e) {
          print('❌ Error loading user stats: $e');
          return _getDefaultStats();
        }
      }
    } catch (e) {
      print('❌ Error accessing shared preferences: $e');
    }

    return _getDefaultStats();
  }

  static UserStats _getDefaultStats() {
    return UserStats.defaultStats();
  }

  static Future<void> saveAvatar(String avatarPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final file = File(avatarPath);
      if (await file.exists()) {
        if (avatarPath.contains('/tmp/')) {
          final permanentPath = await _copyToPermanentStorage(avatarPath);
          _cachedAvatarPath = permanentPath;
          await prefs.setString(_avatarKey, permanentPath);
          print('🖼️ Avatar copied to permanent storage: $permanentPath');
        } else {
          _cachedAvatarPath = avatarPath;
          await prefs.setString(_avatarKey, avatarPath);
          print('🖼️ Avatar saved: $avatarPath');
        }
      } else {
        print('⚠️ Avatar file does not exist: $avatarPath');
        _cachedAvatarPath = avatarPath;
        await prefs.setString(_avatarKey, avatarPath);
      }
    } catch (e) {
      print('❌ Error saving avatar: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, avatarPath);
    }
  }

  static Future<String> getAvatar() async {
    // Сначала пробуем кэш в памяти
    if (_cachedAvatarPath != null && _cachedAvatarPath != '👤') {
      final file = File(_cachedAvatarPath!);
      if (await file.exists()) {
        return _cachedAvatarPath!;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Если пользователь авторизован, пробуем получить свежий аватар с сервера
      if (await isLoggedIn()) {
        // Пробуем получить URL с сервера
        final serverUrl = prefs.getString(_avatarUrlKey);
        if (serverUrl != null && serverUrl.isNotEmpty) {
          // Проверяем, есть ли локальная копия
          final localPath = prefs.getString(_avatarKey);
          if (localPath != null && await File(localPath).exists()) {
            _cachedAvatarPath = localPath;
            return localPath;
          } else {
            // Если локальной копии нет, загружаем в фоне и возвращаем иконку
            _downloadAndSaveAvatar(serverUrl);
            return '👤';
          }
        }
      }

      // Если нет аватара с сервера, пробуем локальный путь
      final localPath = prefs.getString(_avatarKey);
      if (localPath != null && !localPath.startsWith('http')) {
        final file = File(localPath);
        if (await file.exists()) {
          _cachedAvatarPath = localPath;
          return localPath;
        } else {
          print('⚠️ Локальный файл аватара не найден: $localPath');
        }
      }

      // Если ничего не найдено, возвращаем дефолтный аватар
      _cachedAvatarPath = '👤';
      return '👤';
    } catch (e) {
      print('❌ Error getting avatar: $e');
      return '👤';
    }
  }

  static Future<String?> getAvatarUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatarUrlKey);
    } catch (e) {
      print('❌ Error getting avatar URL: $e');
      return null;
    }
  }

  // === ФОНОВАЯ СИНХРОНИЗАЦИЯ ===
  static Future<void> syncProfileInBackground() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      if (!await isLoggedIn()) {
        _isSyncing = false;
        return;
      }

      print('🔄 Фоновая синхронизация профиля...');

      final profile = await ApiService().getProfile();

      if (profile != null) {
        bool hasChanges = false;

        // Обновляем имя если изменилось
        if (profile['name'] != null && profile['name'] != _cachedUsername) {
          await saveUsername(profile['name']);
          hasChanges = true;
          print('✅ Имя обновлено: ${profile['name']}');
        }

        // Обновляем аватар если есть URL
        if (profile['avatar_url'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_avatarUrlKey, profile['avatar_url']);

          // Проверяем, нужно ли обновлять аватар
          final currentPath = await getAvatar();
          if (currentPath == '👤' || currentPath.contains('/tmp/')) {
            await _downloadAndSaveAvatar(profile['avatar_url']);
            hasChanges = true;
          }
        }

        if (profile['email'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', profile['email']);
        }

        if (hasChanges) {
          print('✅ Профиль обновлен в фоне');
        }
      }
    } catch (e) {
      print('❌ Ошибка фоновой синхронизации: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> forceRefreshProfile() async {
    print('🔄 Принудительное обновление профиля...');
    await syncProfileFromServer();
  }

  static Future<void> syncProfileFromServer() async {
    await syncProfileInBackground();
  }

  static Future<void> forceSyncProfile() async {
    print('🔄 Принудительная синхронизация профиля...');
    await syncProfileInBackground();
  }

  static Future<String> _copyToPermanentStorage(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/avatars');

      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = '${avatarDir.path}/$fileName';

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.copy(permanentPath);
        print('✅ Avatar copied from $tempPath to $permanentPath');
        return permanentPath;
      } else {
        throw Exception('Temporary file does not exist');
      }
    } catch (e) {
      print('❌ Error copying avatar to permanent storage: $e');
      rethrow;
    }
  }

  static Future<void> _downloadAndSaveAvatar(String avatarUrl) async {
    try {
      print('📥 Загрузка аватара с сервера: $avatarUrl');

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(avatarUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = <int>[];
        await response.forEach((List<int> chunk) {
          bytes.addAll(chunk);
        });
        client.close();

        final appDir = await getApplicationDocumentsDirectory();
        final avatarDir = Directory('${appDir.path}/avatars');

        if (!await avatarDir.exists()) {
          await avatarDir.create(recursive: true);
        }

        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final localPath = '${avatarDir.path}/$fileName';

        final file = File(localPath);
        await file.writeAsBytes(bytes);

        await saveAvatar(localPath);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_avatarUrlKey, avatarUrl);

        print('✅ Аватар сохранен локально: $localPath');
      } else {
        client.close();
        print('❌ Ошибка загрузки аватара: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка при загрузке аватара: $e');
    }
  }

  // === ОСТАЛЬНЫЕ СУЩЕСТВУЮЩИЕ МЕТОДЫ (БЕЗ ИЗМЕНЕНИЙ) ===

  static Future<void> updateDailyCompletion() async {
    try {
      final stats = await getUserStats();
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (!stats.dailyCompletion.containsKey(today)) {
        stats.markDailyCompleted();
        await saveUserStats(stats);
        print('✅ Daily completion updated for: $today');
      } else {
        print('📅 Daily completion already exists for: $today');
      }
    } catch (e) {
      print('❌ Error updating daily completion: $e');
    }
  }

  static Future<void> updateTopicProgress(
      String subjectName,
      String topicId,
      int correctAnswers
      ) async {
    try {
      final stats = await getUserStats();

      stats.saveTopicProgress(subjectName, topicId, correctAnswers);

      await saveUserStats(stats);
      print('💾 Progress saved - Subject: $subjectName, Topic ID: $topicId, Correct: $correctAnswers');

      if (await isLoggedIn()) {
        try {
          await ApiService.updateTopicProgress(subjectName, topicId, correctAnswers);
          print('✅ Progress synced to server');
        } catch (e) {
          print('❌ Failed to sync progress to server: $e');
        }
      }
    } catch (e) {
      print('❌ Error updating topic progress: $e');
      rethrow;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('progress_') ||
            key.startsWith('user_') ||
            key == 'isLoggedIn' ||
            key == 'username') {
          await prefs.remove(key);
        }
      }

      _cachedUsername = null;
      _cachedAvatarPath = null;
      _isInitialized = false;

      print('✅ All user data cleared');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  static Future<void> clearUserData() async {
    try {
      print('🗑️ Очистка всех пользовательских данных...');

      final prefs = await SharedPreferences.getInstance();

      final keysToRemove = [
        _statsKey,
        _usernameKey,
        _avatarKey,
        _lastSyncKey,
        _authTokenKey,
        _avatarUrlKey,
        'userEmail',
        'user_password',
        'auth_method',
        'auth_timestamp',
        'selectedSubjects',
        'isLoggedIn',
        'device_token',
        'show_developer_options',
        'registrationDate',
        'last_weekly_reset',
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('progress_') ||
            key.startsWith('cached_') ||
            key.startsWith('last_xp_') ||
            key.startsWith('achievement_') ||
            key.startsWith('daily_')) {
          await prefs.remove(key);
        }
      }

      try {
        final appDir = await getApplicationDocumentsDirectory();
        final avatarDir = Directory('${appDir.path}/avatars');
        if (await avatarDir.exists()) {
          await avatarDir.delete(recursive: true);
          print('🗑️ Директория аватаров удалена');
        }
      } catch (e) {
        print('⚠️ Ошибка при удалении директории аватаров: $e');
      }

      _cachedUsername = null;
      _cachedAvatarPath = null;
      _isInitialized = false;

      print('✅ Все пользовательские данные очищены');
    } catch (e) {
      print('❌ Ошибка при очистке пользовательских данных: $e');
    }
  }

  static Future<void> saveProgressWithSync(
      String subject,
      String topicName,
      int correctAnswers
      ) async {
    try {
      await UserDataStorage.updateTopicProgress(subject, topicName, correctAnswers);

      try {
        await ApiService.updateTopicProgress(subject, topicName, correctAnswers);
        print('✅ Progress synced with server');
      } catch (e) {
        print('⚠️ Server sync failed, saved locally only: $e');
      }
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  static Future<void> saveAuthToken(String token) async {
    try {
      await SecurePrefs.saveAuthToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_authTokenKey, token);
      print('🔐 Auth token saved, login status: true');
    } catch (e) {
      print('❌ Error saving auth token: $e');
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  static Future<void> syncAllProgressToServer() async {
    if (await isLoggedIn()) {
      try {
        final stats = await getUserStats();
        print('🔄 Syncing all progress to server: ${stats.topicProgress.length} subjects');
        await ApiService.syncAllProgressToServer(stats.topicProgress);
        print('✅ All progress synced to server');
      } catch (e) {
        print('❌ Error syncing all progress to server: $e');
      }
    }
  }

  // === МЕТОДЫ ДЛЯ XP И ЛИГ ===

  static Future<int> getTopicProgressById(String topicId) async {
    try {
      final stats = await getUserStats();
      return stats.getTopicProgress(topicId);
    } catch (e) {
      print('❌ Error getting topic progress by ID: $e');
      return 0;
    }
  }

  static Future<void> addUserXP(int xp) async {
    try {
      final stats = await getUserStats();
      final oldTotal = stats.totalXP;
      final oldWeekly = stats.weeklyXP;

      stats.addXP(xp, updateDaily: true);

      await saveUserStats(stats);

      print('✅ XP added: +$xp XP, Total: ${stats.totalXP} (was $oldTotal), Weekly: ${stats.weeklyXP} (was $oldWeekly)');
    } catch (e) {
      print('❌ Error adding XP: $e');
      rethrow;
    }
  }

  static Future<Map<DateTime, int>> getXpHistory({
    DateTime? startDate,
    DateTime? endDate,
    TimePeriod? period,
  }) async {
    try {
      final stats = await getUserStats();
      final now = DateTime.now();

      DateTime start;
      DateTime end = now;

      if (startDate != null && endDate != null) {
        start = startDate;
        end = endDate;
      } else if (period != null) {
        switch (period) {
          case TimePeriod.week:
            start = now.subtract(const Duration(days: 7));
            break;
          case TimePeriod.month:
            start = now.subtract(const Duration(days: 30));
            break;
          case TimePeriod.year:
            start = DateTime(now.year - 1, now.month, now.day);
            break;
        }
      } else {
        start = now.subtract(const Duration(days: 30));
      }

      return stats.getXpHistory(start, end);
    } catch (e) {
      print('❌ Error getting XP history: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getXpStatistics() async {
    try {
      final stats = await getUserStats();
      return stats.getXpStatistics();
    } catch (e) {
      print('❌ Error getting XP statistics: $e');
      return {
        'totalXP': 0,
        'weeklyXP': 0,
        'last7DaysXP': 0,
        'last30DaysXP': 0,
        'avg7Days': 0,
        'avg30Days': 0,
        'maxDailyXP': 0,
        'activeDaysLast7': 0,
        'activeDaysLast30': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getUserLeagueInfo() async {
    try {
      if (await isLoggedIn()) {
        try {
          final response = await ApiService.getUserLeagueInfo();
          if (response['success'] == true) {
            return response;
          }
        } catch (e) {
          print('⚠️ Failed to get league info from server: $e');
        }
      }

      final stats = await getUserStats();
      return stats.getOverallStatistics();
    } catch (e) {
      print('❌ Error getting league info: $e');
      return {
        'current_league': 'Бронзовая',
        'league_progress': 0.0,
        'xp_to_next_league': 500,
        'next_league': 'Серебряная',
        'total_xp': 0,
        'weekly_xp': 0,
        'rank': 0,
        'total_users': 0,
      };
    }
  }

  static Future<void> resetWeeklyXP() async {
    try {
      final stats = await getUserStats();
      stats.resetWeeklyXP();
      await saveUserStats(stats);
      print('✅ Weekly XP reset');
    } catch (e) {
      print('❌ Error resetting weekly XP: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserStatsOverview() async {
    try {
      final stats = await getUserStats();
      return {
        'streakDays': stats.streakDays,
        'totalXP': stats.totalXP,
        'weeklyXP': stats.weeklyXP,
        'completedTopics': stats.getCompletedTopicsCount(),
        'totalCorrectAnswers': stats.getTotalCorrectAnswers(),
        'currentLeague': stats.getCurrentLeague(),
        'leagueProgress': stats.getLeagueProgress(),
        'xpToNextLeague': stats.getXPToNextLeague(),
        'nextLeague': stats.getNextLeague(),
        'username': stats.username,
      };
    } catch (e) {
      print('❌ Error getting user stats overview: $e');
      return {
        'streakDays': 0,
        'totalXP': 0,
        'weeklyXP': 0,
        'completedTopics': 0,
        'totalCorrectAnswers': 0,
        'currentLeague': 'Бронзовая',
        'leagueProgress': 0.0,
        'xpToNextLeague': 500,
        'nextLeague': 'Серебряная',
        'username': '',
      };
    }
  }

  static Future<void> saveTopicProgress(String subjectName, String topicId, int correctAnswers) async {
    try {
      final stats = await getUserStats();

      stats.saveTopicProgress(subjectName, topicId, correctAnswers);
      await saveUserStats(stats);

      if (await isLoggedIn()) {
        try {
          await ApiService.updateTopicProgress(subjectName, topicId, correctAnswers);
          print('✅ Progress synced to server');
        } catch (e) {
          print('❌ Failed to sync progress to server: $e');
        }
      }

      print('✅ Progress saved: $subjectName - $topicId: $correctAnswers correct answers');
    } catch (e) {
      print('Error saving topic progress: $e');
      rethrow;
    }
  }

  static Future<void> migrateToTopicIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrated = prefs.getBool('topic_ids_migrated') ?? false;

      if (migrated) return;

      final stats = await getUserStats();

      await prefs.setBool('topic_ids_migrated', true);
      print('✅ Topic IDs migration completed');
    } catch (e) {
      print('❌ Error during topic IDs migration: $e');
    }
  }

  static Future<void> updateUsernameOnServer(String newUsername) async {
    if (await isLoggedIn()) {
      try {
        print('👤 Updating username on server: $newUsername');

        final response = await ApiService.updateProfile(newUsername, '');

        if (response['success'] == true) {
          print('✅ Username updated on server');

          final profile = await ApiService().getProfile();
          if (profile != null && profile['name'] == newUsername) {
            print('✅ Profile verified on server');
          }
        } else {
          print('⚠️ Server username update failed: ${response['message']}');
        }
      } catch (e) {
        print('❌ Error updating username on server: $e');
      }
    }
  }

  // === МЕТОДЫ ДЛЯ СИНХРОНИЗАЦИИ ===

  static Future<Map<String, dynamic>> forceSync() async {
    try {
      print('🔄 FORCE SYNC REQUESTED');

      if (await isLoggedIn()) {
        final result = await ApiService.syncAllUserData();
        return result;
      } else {
        return {
          'success': false,
          'message': 'Пользователь не авторизован',
          'synced': false
        };
      }
    } catch (e) {
      print('❌ Error during force sync: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации: $e',
        'synced': false
      };
    }
  }

  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_sync_time');
      final lastSyncTime = lastSync != null ? DateTime.parse(lastSync) : null;

      final now = DateTime.now();
      final timeSinceLastSync = lastSyncTime != null ? now.difference(lastSyncTime) : null;

      return {
        'lastSync': lastSyncTime,
        'timeSinceLastSync': timeSinceLastSync,
        'isRecent': timeSinceLastSync != null && timeSinceLastSync.inMinutes < 10,
        'needsSync': lastSyncTime == null || now.difference(lastSyncTime).inHours > 1
      };
    } catch (e) {
      print('❌ Error getting sync status: $e');
      return {
        'lastSync': null,
        'timeSinceLastSync': null,
        'isRecent': false,
        'needsSync': true
      };
    }
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', time.toIso8601String());
      print('✅ Last sync time updated: $time');
    } catch (e) {
      print('❌ Error setting last sync time: $e');
    }
  }

  static Future<void> syncFromServer() async {
    final loggedIn = await isLoggedIn();
    print('🔄 Starting sync, isLoggedIn: $loggedIn');

    if (loggedIn) {
      try {
        print('🔄 Starting server sync...');

        try {
          print('📥 Downloading progress from server...');
          final serverProgressResponse = await ApiService.getUserProgress();

          if (serverProgressResponse != null && serverProgressResponse['progress'] != null) {
            final progressData = serverProgressResponse['progress'] as Map<String, dynamic>;
            final stats = await getUserStats();
            bool hasUpdates = false;

            for (final subject in progressData.keys) {
              final topics = progressData[subject] as Map<String, dynamic>;
              if (!stats.topicProgress.containsKey(subject)) {
                stats.topicProgress[subject] = {};
              }

              for (final topic in topics.keys) {
                final serverValue = topics[topic];
                final localValue = stats.topicProgress[subject]![topic] ?? 0;

                if (serverValue is int) {
                  final newValue = serverValue > localValue ? serverValue : localValue;
                  if (newValue != localValue) {
                    stats.topicProgress[subject]![topic] = newValue;
                    hasUpdates = true;
                  }
                }
              }
            }

            if (hasUpdates) {
              await saveUserStats(stats);
              print('✅ Server progress applied to local storage');
            }
          }
        } catch (e) {
          print('⚠️ Progress sync error: $e');
        }

        try {
          print('📥 Downloading XP stats from server...');
          final xpResponse = await ApiService.getUserXPStats();

          if (xpResponse != null && xpResponse['success'] == true) {
            final stats = await getUserStats();
            final serverTotalXP = xpResponse['total_xp'] as int? ?? stats.totalXP;
            final serverWeeklyXP = xpResponse['weekly_xp'] as int? ?? stats.weeklyXP;

            stats.totalXP = serverTotalXP > stats.totalXP ? serverTotalXP : stats.totalXP;
            stats.weeklyXP = serverWeeklyXP > stats.weeklyXP ? serverWeeklyXP : stats.weeklyXP;

            await saveUserStats(stats);
            print('✅ XP stats synced from server');
          }
        } catch (e) {
          print('⚠️ XP sync error: $e');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        print('✅ Server sync completed');
      } catch (e) {
        print('❌ Server sync failed: $e');
      }
    } else {
      print('⚠️ User not logged in, skipping sync');
    }
  }

  static Future<Map<String, dynamic>> syncXpAndProgress() async {
    print('🔄 Синхронизация XP и прогресса с сервером...');

    if (!await isLoggedIn()) {
      return {'success': false, 'message': 'Не авторизован'};
    }

    try {
      bool hasUpdates = false;

      // 1. Синхронизируем XP
      final xpResponse = await ApiService.getUserXPStats();
      if (xpResponse != null && xpResponse['success'] == true) {
        final stats = await getUserStats();
        final serverTotalXP = xpResponse['total_xp'] as int? ?? 0;
        final serverWeeklyXP = xpResponse['weekly_xp'] as int? ?? 0;
        final serverStreakDays = xpResponse['streak_days'] as int? ?? 0;

        if (serverTotalXP > stats.totalXP) {
          stats.totalXP = serverTotalXP;
          hasUpdates = true;
          print('✅ XP обновлено: ${stats.totalXP} (было ${stats.totalXP}, стало $serverTotalXP)');
        }

        if (serverWeeklyXP > stats.weeklyXP) {
          stats.weeklyXP = serverWeeklyXP;
          hasUpdates = true;
          print('✅ Недельный XP обновлен: $serverWeeklyXP');
        }

        if (serverStreakDays > stats.streakDays) {
          stats.streakDays = serverStreakDays;
          hasUpdates = true;
          print('✅ Стрик обновлен: $serverStreakDays дней');
        }

        if (hasUpdates) {
          await saveUserStats(stats);
        }
      }

      // 2. Синхронизируем прогресс тем
      final progressResponse = await ApiService.getUserProgress();
      if (progressResponse != null && progressResponse['progress'] != null) {
        final stats = await getUserStats();
        final serverProgress = progressResponse['progress'] as Map<String, dynamic>;
        bool progressUpdated = false;

        for (final subject in serverProgress.keys) {
          final topics = serverProgress[subject] as Map<String, dynamic>;

          if (!stats.topicProgress.containsKey(subject)) {
            stats.topicProgress[subject] = {};
          }

          for (final topic in topics.keys) {
            final serverValue = topics[topic];
            int serverCorrectAnswers;

            if (serverValue is Map) {
              serverCorrectAnswers = serverValue['correct_answers'] ?? 0;
            } else {
              serverCorrectAnswers = serverValue;
            }

            final localValue = stats.topicProgress[subject]![topic] ?? 0;

            if (serverCorrectAnswers > localValue) {
              stats.topicProgress[subject]![topic] = serverCorrectAnswers;
              progressUpdated = true;
              print('✅ Прогресс обновлен: $subject - $topic: $serverCorrectAnswers (было $localValue)');
            }
          }
        }

        if (progressUpdated) {
          await saveUserStats(stats);
          hasUpdates = true;
        }
      }

      // 3. Сохраняем время последней синхронизации
      await setLastSyncTime(DateTime.now());

      print('✅ Синхронизация XP и прогресса завершена');
      return {
        'success': true,
        'hasUpdates': hasUpdates,
        'message': hasUpdates ? 'Данные обновлены' : 'Данные актуальны'
      };

    } catch (e) {
      print('❌ Ошибка синхронизации XP и прогресса: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации: $e'
      };
    }
  }

  // === ПОЛНАЯ СИНХРОНИЗАЦИЯ ПРИ ВХОДЕ ===
  static Future<Map<String, dynamic>> fullSyncOnLogin() async {
    print('🔄 ПОЛНАЯ СИНХРОНИЗАЦИЯ ПРИ ВХОДЕ...');

    if (!await isLoggedIn()) {
      return {'success': false, 'message': 'Не авторизован'};
    }

    try {
      // 1. Синхронизируем профиль (имя и аватар)
      await syncProfileInBackground();

      // 2. Синхронизируем XP и прогресс
      final xpResult = await syncXpAndProgress();

      // 3. Синхронизируем достижения
      await _syncAchievements();

      // 4. Синхронизируем статистику
      await _syncStatistics();

      print('✅ Полная синхронизация завершена');
      return {
        'success': true,
        'xpUpdated': xpResult['hasUpdates'] ?? false,
        'message': 'Данные синхронизированы'
      };

    } catch (e) {
      print('❌ Ошибка полной синхронизации: $e');
      return {
        'success': false,
        'message': 'Ошибка синхронизации: $e'
      };
    }
  }

  static Future<void> _syncAchievements() async {
    try {
      final response = await ApiService.getAchievementProgress();
      if (response['success'] == true && response['progress'] != null) {
        final prefs = await SharedPreferences.getInstance();

        response['progress'].forEach((key, value) {
          if (value == true) {
            prefs.setBool('achievement_$key', true);
          }
        });

        print('✅ Достижения синхронизированы');
      }
    } catch (e) {
      print('⚠️ Ошибка синхронизации достижений: $e');
    }
  }

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  static Future<void> setAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin', isAdmin);
  }

  static Future<void> _syncStatistics() async {
    try {
      final response = await ApiService.getUserXPStats();
      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // Сохраняем кэшированные значения
        await prefs.setInt('cached_total_xp', response['total_xp'] ?? 0);
        await prefs.setInt('cached_weekly_xp', response['weekly_xp'] ?? 0);

        print('✅ Статистика синхронизирована');
      }
    } catch (e) {
      print('⚠️ Ошибка синхронизации статистики: $e');
    }
  }

  // === МЕТОД ДЛЯ ПРОВЕРКИ НЕОБХОДИМОСТИ СИНХРОНИЗАЦИИ ===
  static Future<bool> needsSync() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final diff = DateTime.now().difference(lastSync);
    return diff.inHours > 1; // Синхронизируем раз в час
  }

  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);
      return lastSync != null ? DateTime.parse(lastSync) : null;
    } catch (e) {
      print('❌ Error getting last sync time: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final stats = await getUserStats();
      int completedTopics = 0;
      int totalCorrectAnswers = 0;

      for (final subject in stats.topicProgress.values) {
        for (final topicProgress in subject.values) {
          if (topicProgress > 0) {
            completedTopics++;
            totalCorrectAnswers += topicProgress;
          }
        }
      }

      return {
        'streakDays': stats.streakDays,
        'completedTopics': completedTopics,
        'totalCorrectAnswers': totalCorrectAnswers,
        'lastActivity': stats.lastActivity,
        'totalXP': stats.totalXP,
        'weeklyXP': stats.weeklyXP,
      };
    } catch (e) {
      print('❌ Error getting progress stats: $e');
      return {
        'streakDays': 0,
        'completedTopics': 0,
        'totalCorrectAnswers': 0,
        'lastActivity': DateTime.now(),
        'totalXP': 0,
        'weeklyXP': 0,
      };
    }
  }
}

enum TimePeriod {
  week,
  month,
  year,
}