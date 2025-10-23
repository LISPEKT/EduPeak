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

        final yesterday = DateTime.now().subtract(Duration(days: 1)).toIso8601String().split('T')[0];
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
      String subject,
      String topic,
      int correctAnswers,
      ) async {
    try {
      final stats = await getUserStats();
      if (!stats.topicProgress.containsKey(subject)) {
        stats.topicProgress[subject] = {};
      }

      final safeCorrectAnswers = correctAnswers.clamp(0, 100);
      final previousProgress = stats.topicProgress[subject]![topic] ?? 0;
      stats.topicProgress[subject]![topic] = safeCorrectAnswers;

      await saveUserStats(stats);

      print('📚 Topic progress updated: $subject - $topic: $previousProgress → $safeCorrectAnswers');

      if (await isLoggedIn()) {
        try {
          // Используем статический метод напрямую
          await ApiService.updateTopicProgress(
            subject,
            topic,
            safeCorrectAnswers,
          );
          print('☁️ Progress synced to server');
        } catch (e) {
          print('⚠️ Failed to sync progress to server: $e');
        }
      }
    } catch (e) {
      print('❌ Error updating topic progress: $e');
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
      final token = prefs.getString(_authTokenKey);
      return token != null && (prefs.getBool(_isLoggedInKey) ?? false);
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
      print('🔐 Auth token saved');
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

  static Future<void> syncFromServer() async {
    if (await isLoggedIn()) {
      try {
        print('☁️ Starting server sync...');

        final apiService = ApiService();
        await apiService.initialize();

        final serverProfile = await apiService.getProfile();
        if (serverProfile != null) {
          final serverName = serverProfile['name'] ?? '';
          final serverAvatarUrl = serverProfile['avatar_url'] ?? '';

          if (serverName.isNotEmpty) {
            final currentName = await getUsername();
            if (currentName.isEmpty || currentName == 'Пользователь') {
              await saveUsername(serverName);
              print('👤 Name synced from server: $serverName');
            }
          }

          if (serverAvatarUrl.isNotEmpty) {
            try {
              final downloadedPath = await apiService.downloadAvatar(serverAvatarUrl);
              if (downloadedPath != null) {
                await saveAvatar(downloadedPath);
                print('🖼️ Avatar synced from server: $downloadedPath');
              }
            } catch (e) {
              print('⚠️ Failed to download avatar: $e');
            }
          }
        }

        // УБРАН проблемный вызов getUserProgress
        print('📊 Progress sync completed (local only)');

        // Сохраняем время последней синхронизации
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

        print('✅ Server sync completed');
      } catch (e) {
        print('⚠️ Server sync failed: $e');
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
}