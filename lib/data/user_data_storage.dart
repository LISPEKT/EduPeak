// lib/data/user_data_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../services/api_service.dart';

class UserDataStorage {
  static const String _statsKey = 'user_stats';
  static const String _usernameKey = 'username';

  static Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));
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

    // Обновляем статистику с новым именем
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
    } catch (e) {
      print('Error updating topic progress: $e');
    }
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
    await prefs.remove(_usernameKey);
    await prefs.remove('user_avatar_path');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}