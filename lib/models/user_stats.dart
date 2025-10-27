import 'package:flutter/material.dart';

class UserStats {
  int streakDays;
  DateTime lastActivity;
  Map<String, Map<String, int>> topicProgress;
  Map<String, bool> dailyCompletion;
  String username;
  int totalXP;
  int weeklyXP;
  DateTime lastWeeklyReset;

  UserStats({
    required this.streakDays,
    required this.lastActivity,
    required this.topicProgress,
    required this.dailyCompletion,
    required this.username,
    this.totalXP = 0,
    this.weeklyXP = 0,
    DateTime? lastWeeklyReset,
  }) : lastWeeklyReset = lastWeeklyReset ?? DateTime.now();

  // Копирующий конструктор для обновления
  UserStats copyWith({
    int? streakDays,
    DateTime? lastActivity,
    Map<String, Map<String, int>>? topicProgress,
    Map<String, bool>? dailyCompletion,
    String? username,
    int? totalXP,
    int? weeklyXP,
    DateTime? lastWeeklyReset,
  }) {
    return UserStats(
      streakDays: streakDays ?? this.streakDays,
      lastActivity: lastActivity ?? this.lastActivity,
      topicProgress: topicProgress ?? Map.from(this.topicProgress),
      dailyCompletion: dailyCompletion ?? Map.from(this.dailyCompletion),
      username: username ?? this.username,
      totalXP: totalXP ?? this.totalXP,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      lastWeeklyReset: lastWeeklyReset ?? this.lastWeeklyReset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streakDays': streakDays,
      'lastActivity': lastActivity.toIso8601String(),
      'topicProgress': topicProgress,
      'dailyCompletion': dailyCompletion,
      'username': username,
      'totalXP': totalXP,
      'weeklyXP': weeklyXP,
      'lastWeeklyReset': lastWeeklyReset.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    // Безопасный парсинг topicProgress
    Map<String, Map<String, int>> topicProgress = {};
    try {
      final progressData = json['topicProgress'];
      if (progressData is Map) {
        progressData.forEach((subject, topics) {
          if (topics is Map) {
            final topicMap = <String, int>{};
            topics.forEach((topic, value) {
              if (value is int) {
                topicMap[topic.toString()] = value;
              }
            });
            topicProgress[subject.toString()] = topicMap;
          }
        });
      }
    } catch (e) {
      print('Error parsing topicProgress: $e');
      topicProgress = {};
    }

    // Безопасный парсинг dailyCompletion
    Map<String, bool> dailyCompletion = {};
    try {
      final completionData = json['dailyCompletion'];
      if (completionData is Map) {
        completionData.forEach((date, value) {
          if (value is bool) {
            dailyCompletion[date.toString()] = value;
          }
        });
      }
    } catch (e) {
      print('Error parsing dailyCompletion: $e');
      dailyCompletion = {};
    }

    // Парсинг даты сброса недельного XP
    DateTime lastWeeklyReset;
    try {
      lastWeeklyReset = DateTime.parse(json['lastWeeklyReset'] as String? ?? DateTime.now().toIso8601String());
    } catch (e) {
      print('Error parsing lastWeeklyReset: $e');
      lastWeeklyReset = DateTime.now();
    }

    return UserStats(
      streakDays: (json['streakDays'] as int?) ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] as String? ?? DateTime.now().toIso8601String()),
      topicProgress: topicProgress,
      dailyCompletion: dailyCompletion,
      username: (json['username'] as String?) ?? '',
      totalXP: (json['totalXP'] as int?) ?? 0,
      weeklyXP: (json['weeklyXP'] as int?) ?? 0,
      lastWeeklyReset: lastWeeklyReset,
    );
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С XP ===

  // Добавление XP с автоматическим сбросом недельного XP при необходимости
  void addXP(int xp) {
    totalXP += xp;
    weeklyXP += xp;
    lastActivity = DateTime.now();

    // Проверяем, нужно ли сбросить недельный XP
    _checkWeeklyReset();
  }

  // Проверка и сброс недельного XP если прошла неделя
  void _checkWeeklyReset() {
    final now = DateTime.now();
    final daysSinceReset = now.difference(lastWeeklyReset).inDays;

    if (daysSinceReset >= 7) {
      weeklyXP = 0;
      lastWeeklyReset = now;
    }
  }

  // Получение текущей лиги на основе недельного XP
  String getCurrentLeague() {
    _checkWeeklyReset(); // Сначала проверяем актуальность weeklyXP

    if (weeklyXP >= 1001) return 'Бриллиант';
    if (weeklyXP >= 501) return 'Платина';
    if (weeklyXP >= 301) return 'Золото';
    if (weeklyXP >= 101) return 'Серебро';
    return 'Бронза';
  }

  // Получение цвета лиги
  Color getLeagueColor() {
    final league = getCurrentLeague();
    switch (league) {
      case 'Бронза': return Color(0xFFCD7F32);
      case 'Серебро': return Color(0xFFC0C0C0);
      case 'Золото': return Color(0xFFFFD700);
      case 'Платина': return Color(0xFFE5E4E2);
      case 'Бриллиант': return Color(0xFFB9F2FF);
      default: return Color(0xFFCD7F32);
    }
  }

  // Получение прогресса до следующей лиги (0.0 - 1.0)
  double getLeagueProgress() {
    _checkWeeklyReset();

    final currentXP = weeklyXP;
    if (currentXP >= 1001) return 1.0;
    if (currentXP >= 501) return (currentXP - 501) / 500.0;
    if (currentXP >= 301) return (currentXP - 301) / 200.0;
    if (currentXP >= 101) return (currentXP - 101) / 200.0;
    return currentXP / 100.0;
  }

  // Получение XP до следующей лиги
  int getXPToNextLeague() {
    _checkWeeklyReset();

    final currentXP = weeklyXP;
    if (currentXP < 101) return 101 - currentXP;
    if (currentXP < 301) return 301 - currentXP;
    if (currentXP < 501) return 501 - currentXP;
    if (currentXP < 1001) return 1001 - currentXP;
    return 0;
  }

  // Получение названия следующей лиги
  String getNextLeague() {
    final currentLeague = getCurrentLeague();
    switch (currentLeague) {
      case 'Бронза': return 'Серебро';
      case 'Серебро': return 'Золото';
      case 'Золото': return 'Платина';
      case 'Платина': return 'Бриллиант';
      case 'Бриллиант': return 'Бриллиант';
      default: return 'Серебро';
    }
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С ТЕМАМИ ===

  // Метод для получения прогресса по ID темы
  int getTopicProgress(String topicId) {
    for (final subjectProgress in topicProgress.values) {
      if (subjectProgress.containsKey(topicId)) {
        return subjectProgress[topicId]!;
      }
    }
    return 0;
  }

  // Метод для проверки завершения темы по ID
  bool isTopicCompleted(String topicId, int totalQuestions) {
    final progress = getTopicProgress(topicId);
    return progress >= totalQuestions;
  }

  // Метод для сохранения прогресса по ID темы
  void saveTopicProgress(String subjectName, String topicId, int correctAnswers) {
    if (!topicProgress.containsKey(subjectName)) {
      topicProgress[subjectName] = {};
    }
    topicProgress[subjectName]![topicId] = correctAnswers;
    lastActivity = DateTime.now();
  }

  // Метод для получения всех завершённых тем по их ID
  List<String> getCompletedTopicIds() {
    final completedIds = <String>[];

    for (final subjectProgress in topicProgress.values) {
      for (final entry in subjectProgress.entries) {
        completedIds.add(entry.key);
      }
    }

    return completedIds;
  }

  // Метод для получения количества завершённых тем
  int getCompletedTopicsCount() {
    int count = 0;
    for (final subjectProgress in topicProgress.values) {
      count += subjectProgress.length;
    }
    return count;
  }

  // Метод для получения прогресса по предмету
  Map<String, int> getSubjectProgress(String subjectName) {
    return topicProgress[subjectName] ?? {};
  }

  // === МЕТОДЫ ДЛЯ ЕЖЕДНЕВНОЙ АКТИВНОСТИ ===

  // Метод для проверки ежедневного выполнения
  bool isDailyCompleted() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyCompletion[today] ?? false;
  }

  // Метод для отметки ежедневного выполнения
  void markDailyCompleted() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    dailyCompletion[today] = true;

    // Проверяем и обновляем streak
    _updateStreak();
  }

  // Приватный метод для обновления стрика
  void _updateStreak() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = yesterday.toIso8601String().split('T')[0];

    if (dailyCompletion[yesterdayKey] == true) {
      streakDays++;
    } else {
      // Если вчера не было активности, начинаем новый стрик
      streakDays = 1;
    }

    lastActivity = today;
  }

  // === СТАТИСТИЧЕСКИЕ МЕТОДЫ ===

  // Метод для получения общего количества правильных ответов
  int getTotalCorrectAnswers() {
    int total = 0;
    for (final subjectProgress in topicProgress.values) {
      for (final correctAnswers in subjectProgress.values) {
        total += correctAnswers;
      }
    }
    return total;
  }

  // Метод для получения статистики по предметам
  Map<String, Map<String, dynamic>> getSubjectStatistics() {
    final statistics = <String, Map<String, dynamic>>{};

    for (final entry in topicProgress.entries) {
      final subjectName = entry.key;
      final topicProgressMap = entry.value;

      int completedTopics = 0;
      int totalCorrectAnswers = 0;
      int totalQuestions = 0;

      for (final progress in topicProgressMap.values) {
        totalCorrectAnswers += progress;
        // Считаем тему завершённой если есть хотя бы один правильный ответ
        if (progress > 0) {
          completedTopics++;
        }
      }

      statistics[subjectName] = {
        'completedTopics': completedTopics,
        'totalCorrectAnswers': totalCorrectAnswers,
        'totalTopics': topicProgressMap.length,
        'completionPercentage': topicProgressMap.isEmpty ? 0 : (completedTopics / topicProgressMap.length * 100).round(),
      };
    }

    return statistics;
  }

  // Получение общей статистики
  Map<String, dynamic> getOverallStatistics() {
    return {
      'streakDays': streakDays,
      'totalXP': totalXP,
      'weeklyXP': weeklyXP,
      'completedTopics': getCompletedTopicsCount(),
      'totalCorrectAnswers': getTotalCorrectAnswers(),
      'currentLeague': getCurrentLeague(),
      'leagueProgress': getLeagueProgress(),
      'xpToNextLeague': getXPToNextLeague(),
      'nextLeague': getNextLeague(),
    };
  }

  // === МЕТОДЫ ДЛЯ СБРОСА ===

  // Метод для сброса прогресса
  void resetProgress() {
    streakDays = 0;
    topicProgress.clear();
    dailyCompletion.clear();
    totalXP = 0;
    weeklyXP = 0;
    lastActivity = DateTime.now();
    lastWeeklyReset = DateTime.now();
  }

  // Метод для сброса только недельного XP
  void resetWeeklyXP() {
    weeklyXP = 0;
    lastWeeklyReset = DateTime.now();
  }

  // === МЕТОДЫ ДЛЯ МИГРАЦИИ ===

  // Метод для миграции старых данных (по названиям) на новые (по ID)
  void migrateToTopicIds(Map<String, String> topicNameToIdMap) {
    final migratedProgress = <String, Map<String, int>>{};

    for (final subjectEntry in topicProgress.entries) {
      final subjectName = subjectEntry.key;
      final oldProgress = subjectEntry.value;
      final newProgress = <String, int>{};

      for (final topicEntry in oldProgress.entries) {
        final topicName = topicEntry.key;
        final correctAnswers = topicEntry.value;

        // Пытаемся найти ID по названию темы
        final topicId = topicNameToIdMap[topicName];
        if (topicId != null) {
          newProgress[topicId] = correctAnswers;
        } else {
          // Если ID не найден, оставляем по старому названию
          newProgress[topicName] = correctAnswers;
        }
      }

      migratedProgress[subjectName] = newProgress;
    }

    topicProgress = migratedProgress;
  }

  @override
  String toString() {
    return 'UserStats('
        'streakDays: $streakDays, '
        'totalXP: $totalXP, '
        'weeklyXP: $weeklyXP, '
        'completedTopics: ${getCompletedTopicsCount()}, '
        'totalCorrectAnswers: ${getTotalCorrectAnswers()}, '
        'currentLeague: ${getCurrentLeague()}'
        ')';
  }

  // Метод для создания дефолтного экземпляра
  factory UserStats.defaultStats() {
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
}