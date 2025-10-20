// lib/data/user_data_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../services/api_service.dart';

class UserDataStorage {
  static const String _statsKey = 'user_stats';
  static const String _usernameKey = 'username';
  static const String _lastSyncKey = 'last_sync';

  static Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));

    await _syncProgressToServer(stats);
  }

  static Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_statsKey);

    if (data != null) {
      try {
        final jsonData = json.decode(data);
        return UserStats.fromJson(jsonData);
      } catch (e) {
        print('Error loading user stats: $e');
        return _getDefaultStats();
      }
    }

    final serverStats = await _loadProgressFromServer();
    if (serverStats != null) {
      return serverStats;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);

    final stats = await getUserStats();
    stats.username = username;
    await saveUserStats(stats);
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }

  static Future<void> updateDailyCompletion() async {
    final stats = await getUserStats();
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (!stats.dailyCompletion.containsKey(today)) {
      stats.dailyCompletion[today] = true;
      stats.lastActivity = DateTime.now();

      final yesterday = DateTime.now().subtract(Duration(days: 1)).toIso8601String().split('T')[0];
      if (stats.dailyCompletion.containsKey(yesterday)) {
        stats.streakDays++;
      } else {
        stats.streakDays = 1;
      }

      await saveUserStats(stats);
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
      stats.topicProgress[subject]![topic] = safeCorrectAnswers;

      await saveUserStats(stats);

      await ApiService.updateTopicProgress(
        subject: subject,
        topic: topic,
        correctAnswers: safeCorrectAnswers,
      );
    } catch (e) {
      print('Error updating topic progress: $e');
    }
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
    await prefs.remove(_usernameKey);
    await prefs.remove('user_avatar_path');
    await prefs.remove('last_sync');

    await ApiService.logout();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> _syncProgressToServer(UserStats stats) async {
    try {
      for (final subjectEntry in stats.topicProgress.entries) {
        final subject = subjectEntry.key;
        for (final topicEntry in subjectEntry.value.entries) {
          final topic = topicEntry.key;
          final correctAnswers = topicEntry.value;

          await ApiService.updateTopicProgress(
            subject: subject,
            topic: topic,
            correctAnswers: correctAnswers,
          );
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    } catch (e) {
      print('Error syncing progress to server: $e');
    }
  }

  static Future<UserStats?> _loadProgressFromServer() async {
    try {
      final response = await ApiService.getUserProgress();
      if (response['success'] == true && response['progress'] != null) {
        final progressData = response['progress'];
        final stats = _getDefaultStats();

        return stats;
      }
    } catch (e) {
      print('Error loading progress from server: $e');
    }
    return null;
  }
}