// lib/data/user_data_storage.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_stats.dart';
import '../services/secure_prefs.dart';

class UserDataStorage {
  static const String _statsKey = 'user_stats';
  static const String _usernameKey = 'username';
  static const String _avatarKey = 'user_avatar_path';
  static const String _lastSyncKey = 'last_sync';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _authTokenKey = 'auth_token';

  // === ОСНОВНЫЕ МЕТОДЫ ===

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
    } catch (e) {
      print('❌ Error setting login status: $e');
    }
  }

  static Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
    } catch (e) {
      print('❌ Error saving username: $e');
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

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Удаляем все ключи связанные с пользователем
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('progress_') ||
            key.startsWith('user_') ||
            key == 'isLoggedIn' ||
            key == 'username') {
          await prefs.remove(key);
        }
      }

      print('✅ All user data cleared');
    } catch (e) {
      print('❌ Error clearing user data: $e');
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

  static Future<void> saveProgressWithSync(
      String subject,
      String topicName,
      int correctAnswers
      ) async {
    try {
      // 1. Сохраняем локально
      await UserDataStorage.updateTopicProgress(subject, topicName, correctAnswers);

      // 2. Синхронизируем с сервером (если есть интернет)
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

  // Метод для получения прогресса по ID темы
  static Future<int> getTopicProgressById(String topicId) async {
    try {
      final stats = await getUserStats();
      return stats.getTopicProgress(topicId);
    } catch (e) {
      print('❌ Error getting topic progress by ID: $e');
      return 0;
    }
  }

  // Метод для добавления XP с обновлением статистики
  static Future<void> addUserXP(int xp) async {
    try {
      final stats = await getUserStats();
      final oldTotal = stats.totalXP;
      final oldWeekly = stats.weeklyXP;

      stats.addXP(xp, updateDaily: true);

      await saveUserStats(stats);

      print('✅ XP added: +$xp XP, Total: ${stats.totalXP} (was $oldTotal), Weekly: ${stats.weeklyXP} (was $oldWeekly)');

      // Пытаемся синхронизировать с сервером
      if (await isLoggedIn()) {
        try {
          final response = await ApiService.addXP(xp, 'test_completion');
          if (response['success'] == true) {
            print('✅ XP synced to server');
          } else {
            print('⚠️ Server XP sync failed, keeping local data');
          }
        } catch (e) {
          print('❌ Failed to sync XP to server: $e');
        }
      }
    } catch (e) {
      print('❌ Error adding XP: $e');
      rethrow;
    }
  }

  // Метод для получения истории XP за период
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
            start = now.subtract(Duration(days: 7));
            break;
          case TimePeriod.month:
            start = now.subtract(Duration(days: 30));
            break;
          case TimePeriod.year:
            start = DateTime(now.year - 1, now.month, now.day);
            break;
        }
      } else {
        // По умолчанию последние 30 дней
        start = now.subtract(Duration(days: 30));
      }

      return stats.getXpHistory(start, end);
    } catch (e) {
      print('❌ Error getting XP history: $e');
      return {};
    }
  }

  // Метод для получения статистики XP
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
      final stats = await getUserStats();
      return stats.getOverallStatistics();
    } catch (e) {
      print('❌ Error getting league info: $e');
      return {
        'currentLeague': 'Бронзовая',
        'leagueProgress': 0.0,
        'xpToNextLeague': 500,
        'nextLeague': 'Серебряная',
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

  // === МЕТОДЫ ДЛЯ РАБОТЫ С ID ТЕМ ===

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

  // Метод для миграции на систему с ID тем
  static Future<void> migrateToTopicIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrated = prefs.getBool('topic_ids_migrated') ?? false;

      if (migrated) return;

      final stats = await getUserStats();
      // Здесь можно добавить логику миграции

      await prefs.setBool('topic_ids_migrated', true);
      print('✅ Topic IDs migration completed');
    } catch (e) {
      print('❌ Error during topic IDs migration: $e');
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

        // 1. Пытаемся синхронизировать прогресс с сервера
        try {
          print('📥 Downloading progress from server...');
          final serverProgressResponse = await ApiService.getUserProgress();

          if (serverProgressResponse != null && serverProgressResponse['progress'] != null) {
            final progressData = serverProgressResponse['progress'] as Map<String, dynamic>;
            final stats = await getUserStats();
            bool hasUpdates = false;

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

        // 2. Синхронизация XP с сервера
        try {
          print('📥 Downloading XP stats from server...');
          final xpResponse = await ApiService.getUserXPStats();

          if (xpResponse != null && xpResponse['success'] == true) {
            final stats = await getUserStats();
            final serverTotalXP = xpResponse['totalXP'] as int? ?? stats.totalXP;
            final serverWeeklyXP = xpResponse['weeklyXP'] as int? ?? stats.weeklyXP;

            // Используем максимальное значение между сервером и локально
            stats.totalXP = serverTotalXP > stats.totalXP ? serverTotalXP : stats.totalXP;
            stats.weeklyXP = serverWeeklyXP > stats.weeklyXP ? serverWeeklyXP : stats.weeklyXP;

            await saveUserStats(stats);
            print('✅ XP stats synced from server');
          }
        } catch (e) {
          print('⚠️ XP sync error: $e');
        }

        // Сохраняем время последней синхронизации
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

  // lib/data/user_data_storage.dart строка 677:
  static Future<void> updateUsernameOnServer(String newUsername) async {
    if (await isLoggedIn()) {
      try {
        print('👤 Updating username on server: $newUsername');

        final apiService = ApiService();
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

  // Вспомогательный метод для синхронизации
  static Future<void> _syncUserData(UserStats stats) async {
    if (await isLoggedIn()) {
      try {
        await ApiService.syncAllProgressToServer(stats.topicProgress);
        print('✅ User data synced to server');
      } catch (e) {
        print('❌ Error syncing user data: $e');
      }
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

// Enum для периода времени
enum TimePeriod {
  week,
  month,
  year,
}