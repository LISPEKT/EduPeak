import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_stats.dart';

class UserDataStorage {
  static const String _statsKey = 'user_stats';
  static const String _usernameKey = 'username';
  static const String _avatarKey = 'user_avatar_path';
  static const String _lastSyncKey = 'last_sync';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _authTokenKey = 'auth_token';

  // === ОСНОВНЫЕ МЕТОДЫ ===

  static Future<void> saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, json.encode(stats.toJson()));
      print('💾 User stats saved: ${stats.topicProgress.length} subjects, streak: ${stats.streakDays} days');
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
          print('📊 Loaded user stats: ${stats.topicProgress.length} subjects, streak: ${stats.streakDays} days');
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
    return UserStats(
      streakDays: 0,
      lastActivity: DateTime.now(),
      topicProgress: {},
      dailyCompletion: {},
      username: '',
      totalXP: 0,
      weeklyXP: 0,
      lastWeeklyReset: DateTime.now(),
    );
  }

  static Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);

      final stats = await getUserStats();
      stats.username = username;
      await saveUserStats(stats);

      print('👤 Username saved: $username');
    } catch (e) {
      print('❌ Error saving username: $e');
    }
  }

  static Future<String> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey) ?? '';
    } catch (e) {
      print('❌ Error getting username: $e');
      return '';
    }
  }

  static Future<void> saveAvatar(String avatarPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final file = File(avatarPath);
      if (await file.exists()) {
        if (avatarPath.contains('/tmp/')) {
          final permanentPath = await _copyToPermanentStorage(avatarPath);
          await prefs.setString(_avatarKey, permanentPath);
          print('🖼️ Avatar copied to permanent storage: $permanentPath');
        } else {
          await prefs.setString(_avatarKey, avatarPath);
          print('🖼️ Avatar saved: $avatarPath');
        }
      } else {
        print('⚠️ Avatar file does not exist: $avatarPath');
        await prefs.setString(_avatarKey, avatarPath);
      }
    } catch (e) {
      print('❌ Error saving avatar: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, avatarPath);
    }
  }

  static Future<String> getAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatarPath = prefs.getString(_avatarKey);

      if (avatarPath != null) {
        final file = File(avatarPath);
        if (await file.exists()) {
          return avatarPath;
        } else {
          print('⚠️ Avatar file not found: $avatarPath');
          await prefs.remove(_avatarKey);
          return '👤';
        }
      }

      return '👤';
    } catch (e) {
      print('❌ Error getting avatar: $e');
      return '👤';
    }
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

  static Future<void> updateDailyCompletion() async {
    try {
      final stats = await getUserStats();
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (!stats.dailyCompletion.containsKey(today)) {
        stats.dailyCompletion[today] = true;
        stats.lastActivity = DateTime.now();

        final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
        if (stats.dailyCompletion.containsKey(yesterday)) {
          stats.streakDays++;
          print('🔥 Streak increased to: ${stats.streakDays} days');
        } else {
          stats.streakDays = 1;
          print('🎯 New streak started: 1 day');
        }

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

      // Сохраняем по ID темы
      stats.saveTopicProgress(subjectName, topicId, correctAnswers);

      await saveUserStats(stats);
      print('💾 Progress saved - Subject: $subjectName, Topic ID: $topicId, Correct: $correctAnswers');

      // Пытаемся синхронизировать с сервером
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

  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_avatarKey);
      await prefs.remove(_lastSyncKey);
      await prefs.remove(_authTokenKey);
      await prefs.setBool(_isLoggedInKey, false);

      try {
        final appDir = await getApplicationDocumentsDirectory();
        final avatarDir = Directory('${appDir.path}/avatars');
        if (await avatarDir.exists()) {
          await avatarDir.delete(recursive: true);
          print('🗑️ Avatar directory cleared');
        }
      } catch (e) {
        print('⚠️ Error clearing avatar directory: $e');
      }

      print('🗑️ All user data cleared from local storage');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final token = prefs.getString('auth_token');

      print('🔐 Checking login status: isLoggedIn=$isLoggedIn, hasToken=${token != null}');

      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
      print(value ? '🔐 User marked as logged in' : '🚪 User marked as logged out');
    } catch (e) {
      print('❌ Error setting login status: $e');
    }
  }

  static Future<void> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
      await prefs.setBool(_isLoggedInKey, true);
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

  static Future<void> syncFromServer() async {
    final loggedIn = await isLoggedIn();
    print('🔄 Starting sync, isLoggedIn: $loggedIn');

    if (loggedIn) {
      try {
        print('🔄 Starting FULL server sync...');

        // 1. Создаем экземпляр ApiService для нестатических методов
        final apiService = ApiService();
        await apiService.initialize();

        // 2. Синхронизация профиля
        print('📥 Downloading profile from server...');
        final serverProfile = await apiService.getProfile();

        if (serverProfile != null) {
          final serverName = serverProfile['name'] ?? '';
          final serverAvatarUrl = serverProfile['avatar_url'] ?? '';

          print('👤 Server profile - Name: "$serverName", Avatar: "$serverAvatarUrl"');

          // Синхронизация имени - всегда обновляем с сервера
          if (serverName.isNotEmpty && serverName != 'Пользователь') {
            await saveUsername(serverName);
            print('✅ Name synced from server: $serverName');
          } else {
            print('⚠️ Server name is empty or default');
          }

          // Синхронизация аватара
          if (serverAvatarUrl.isNotEmpty && serverAvatarUrl != '') {
            try {
              print('🖼️ Downloading avatar from: $serverAvatarUrl');
              final downloadedPath = await apiService.downloadAvatar(serverAvatarUrl);
              if (downloadedPath != null) {
                await saveAvatar(downloadedPath);
                print('✅ Avatar downloaded and saved: $downloadedPath');
              } else {
                print('❌ Failed to download avatar');
              }
            } catch (e) {
              print('⚠️ Avatar download error: $e');
            }
          } else {
            print('⚠️ No avatar URL on server');
          }
        } else {
          print('❌ Failed to get profile from server');
        }

        // 3. Синхронизация прогресса с сервера
        try {
          print('📥 Downloading progress from server...');
          final serverProgressResponse = await ApiService.getUserProgress();

          if (serverProgressResponse != null && serverProgressResponse['progress'] != null) {
            final progressData = serverProgressResponse['progress'] as Map<String, dynamic>;
            final stats = await getUserStats();
            bool hasUpdates = false;

            print('📊 Server progress data: ${progressData.keys.length} subjects');

            // Обновляем локальный прогресс данными с сервера
            for (final subject in progressData.keys) {
              final topics = progressData[subject] as Map<String, dynamic>;
              if (!stats.topicProgress.containsKey(subject)) {
                stats.topicProgress[subject] = {};
              }

              for (final topic in topics.keys) {
                final serverValue = topics[topic];
                final localValue = stats.topicProgress[subject]![topic] ?? 0;

                if (serverValue is int) {
                  // Берем максимальное значение между сервером и локальным
                  final newValue = serverValue > localValue ? serverValue : localValue;
                  if (newValue != localValue) {
                    stats.topicProgress[subject]![topic] = newValue;
                    hasUpdates = true;
                    print('🔄 Progress updated: $subject - $topic: $localValue → $newValue');
                  }
                }
              }
            }

            if (hasUpdates) {
              await saveUserStats(stats);
              print('✅ Server progress applied to local storage');
            } else {
              print('📊 Local progress is up to date');
            }
          } else {
            print('⚠️ No progress data from server, keeping local data');
          }
        } catch (e) {
          print('⚠️ Progress sync error: $e');
          // При ошибке продолжаем с локальными данными
        }

        // Сохраняем время последней синхронизации
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        print('✅ FULL server sync completed');
      } catch (e) {
        print('❌ Server sync failed: $e');
      }
    } else {
      print('⚠️ User not logged in, skipping sync');
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
      };
    } catch (e) {
      print('❌ Error getting progress stats: $e');
      return {
        'streakDays': 0,
        'completedTopics': 0,
        'totalCorrectAnswers': 0,
        'lastActivity': DateTime.now(),
      };
    }
  }

  static Future<void> updateUsernameOnServer(String newUsername) async {
    if (await isLoggedIn()) {
      try {
        print('👤 Updating username on server: $newUsername');

        // Используем экземпляр ApiService для нестатического метода
        final apiService = ApiService();
        await apiService.initialize();

        final response = await apiService.updateProfile(newUsername, '');

        if (response['success'] == true) {
          print('✅ Username updated on server');
        } else {
          print('⚠️ Server username update failed: ${response['message']}');
        }
      } catch (e) {
        print('❌ Error updating username on server: $e');
      }
    }
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

  // === МЕТОДЫ ДЛЯ XP И ЛИГ ===

  static Future<void> addUserXP(int xp) async {
    try {
      final stats = await getUserStats();
      stats.addXP(xp);
      await saveUserStats(stats);
      print('✅ XP added: +$xp XP, Total: ${stats.totalXP}, Weekly: ${stats.weeklyXP}');

      // Пытаемся синхронизировать с сервером
      if (await isLoggedIn()) {
        try {
          await ApiService.addXP(xp, 'test_completion');
          print('✅ XP synced to server');
        } catch (e) {
          print('❌ Failed to sync XP to server: $e');
        }
      }
    } catch (e) {
      print('❌ Error adding XP: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserLeagueInfo() async {
    try {
      final stats = await getUserStats();
      return stats.getOverallStatistics();
    } catch (e) {
      print('❌ Error getting league info: $e');
      return {
        'currentLeague': 'Бронза',
        'leagueProgress': 0.0,
        'xpToNextLeague': 100,
        'nextLeague': 'Серебро',
        'totalXP': 0,
        'weeklyXP': 0,
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
        'currentLeague': 'Бронза',
        'username': '',
      };
    }
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С ID ТЕМ ===

  static Future<void> saveTopicProgress(String subjectName, String topicId, int correctAnswers) async {
    try {
      final stats = await getUserStats();

      // Создаем копию текущего прогресса
      final updatedProgress = Map<String, Map<String, int>>.from(stats.topicProgress);

      // Добавляем или обновляем прогресс для предмета
      if (!updatedProgress.containsKey(subjectName)) {
        updatedProgress[subjectName] = {};
      }

      updatedProgress[subjectName]![topicId] = correctAnswers;

      // Создаем обновленную статистику
      final updatedStats = UserStats(
        streakDays: stats.streakDays,
        lastActivity: DateTime.now(),
        topicProgress: updatedProgress,
        dailyCompletion: stats.dailyCompletion,
        username: stats.username,
        totalXP: stats.totalXP,
        weeklyXP: stats.weeklyXP,
        lastWeeklyReset: stats.lastWeeklyReset,
      );

      await saveUserStats(updatedStats);

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

  static Future<int> getTopicProgressById(String topicId) async {
    try {
      final stats = await getUserStats();

      for (final subjectProgress in stats.topicProgress.values) {
        if (subjectProgress.containsKey(topicId)) {
          return subjectProgress[topicId]!;
        }
      }

      return 0;
    } catch (e) {
      print('Error getting topic progress by ID: $e');
      return 0;
    }
  }

  // Метод для миграции на систему с ID тем
  static Future<void> migrateToTopicIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrated = prefs.getBool('topic_ids_migrated') ?? false;

      if (migrated) return;

      final stats = await getUserStats();
      final newProgress = <String, Map<String, int>>{};

      // Здесь нужно добавить логику для сопоставления старых названий с новыми ID
      // Это временное решение - в будущем все темы будут иметь ID

      final migratedStats = UserStats(
        streakDays: stats.streakDays,
        lastActivity: stats.lastActivity,
        topicProgress: newProgress,
        dailyCompletion: stats.dailyCompletion,
        username: stats.username,
        totalXP: stats.totalXP,
        weeklyXP: stats.weeklyXP,
        lastWeeklyReset: stats.lastWeeklyReset,
      );

      await saveUserStats(migratedStats);
      await prefs.setBool('topic_ids_migrated', true);

      print('✅ Topic IDs migration completed');
    } catch (e) {
      print('❌ Error during topic IDs migration: $e');
    }
  }

  // Вспомогательный метод для синхронизации (для совместимости)
  static Future<void> _syncUserData(UserStats stats) async {
    if (await isLoggedIn()) {
      try {
        // Используем существующий метод для синхронизации всего прогресса
        await ApiService.syncAllProgressToServer(stats.topicProgress);
        print('✅ User data synced to server');
      } catch (e) {
        print('❌ Error syncing user data: $e');
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
}