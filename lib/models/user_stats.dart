// lib/models/user_stats.dart
import 'package:flutter/material.dart';

class UserStats {
  int streakDays;
  DateTime lastActivity;
  Map<String, Map<String, int>> topicProgress;
  Map<String, bool> dailyCompletion;
  Map<String, int> dailyXP; // Хранит XP по дням в формате '2024-01-01': 100
  String username;
  int totalXP;
  int weeklyXP;
  DateTime lastWeeklyReset;

  UserStats({
    required this.streakDays,
    required this.lastActivity,
    required this.topicProgress,
    required this.dailyCompletion,
    Map<String, int>? dailyXP,
    required this.username,
    this.totalXP = 0,
    this.weeklyXP = 0,
    DateTime? lastWeeklyReset,
  }) :
        dailyXP = dailyXP ?? {},
        lastWeeklyReset = lastWeeklyReset ?? DateTime.now();

  // Копирующий конструктор для обновления
  UserStats copyWith({
    int? streakDays,
    DateTime? lastActivity,
    Map<String, Map<String, int>>? topicProgress,
    Map<String, bool>? dailyCompletion,
    Map<String, int>? dailyXP,
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
      dailyXP: dailyXP ?? Map.from(this.dailyXP),
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
      'dailyXP': dailyXP,
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

    // Безопасный парсинг dailyXP
    Map<String, int> dailyXP = {};
    try {
      final dailyXPData = json['dailyXP'];
      if (dailyXPData is Map) {
        dailyXPData.forEach((date, value) {
          if (value is int) {
            dailyXP[date.toString()] = value;
          }
        });
      }
    } catch (e) {
      print('Error parsing dailyXP: $e');
      dailyXP = {};
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
      dailyXP: dailyXP,
      username: (json['username'] as String?) ?? '',
      totalXP: (json['totalXP'] as int?) ?? 0,
      weeklyXP: (json['weeklyXP'] as int?) ?? 0,
      lastWeeklyReset: lastWeeklyReset,
    );
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С XP ===

  // Добавление XP с сохранением ежедневного и недельного
  void addXP(int xp, {bool updateDaily = true}) {
    totalXP += xp;
    weeklyXP += xp;
    lastActivity = DateTime.now();

    if (updateDaily) {
      // Сохраняем в ежедневный XP
      addDailyXP(xp);
    }

    // Проверяем, нужно ли сбросить недельный XP
    _checkWeeklyReset();
  }

  // Добавление XP в конкретный день
  void addDailyXP(int xp) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    dailyXP[today] = (dailyXP[today] ?? 0) + xp;
  }

  // Получение XP за конкретный день
  int getDailyXP(DateTime date) {
    final dateKey = date.toIso8601String().split('T')[0];
    return dailyXP[dateKey] ?? 0;
  }

  // Получение XP за неделю (с понедельника по воскресенье)
  int getWeeklyXP({DateTime? forDate}) {
    final targetDate = forDate ?? DateTime.now();
    final monday = _findMonday(targetDate);

    int weeklySum = 0;
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      weeklySum += getDailyXP(date);
    }

    return weeklySum;
  }

  // Получение XP за месяц
  int getMonthlyXP({DateTime? forDate}) {
    final targetDate = forDate ?? DateTime.now();
    final firstDay = DateTime(targetDate.year, targetDate.month, 1);
    final lastDay = DateTime(targetDate.year, targetDate.month + 1, 0);

    int monthlySum = 0;
    for (int i = 0; i <= lastDay.difference(firstDay).inDays; i++) {
      final date = firstDay.add(Duration(days: i));
      monthlySum += getDailyXP(date);
    }

    return monthlySum;
  }

  // Получение истории XP за период
  Map<DateTime, int> getXpHistory(DateTime startDate, DateTime endDate) {
    final history = <DateTime, int>{};

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      history[DateTime(date.year, date.month, date.day)] = getDailyXP(date);
    }

    return history;
  }

  // Вспомогательный метод для поиска понедельника
  DateTime _findMonday(DateTime date) {
    int daysFromMonday = date.weekday - 1; // Monday is 1
    return date.subtract(Duration(days: daysFromMonday));
  }

  // Проверка и сброс недельного XP если прошла неделя
  void _checkWeeklyReset() {
    final now = DateTime.now();
    final daysSinceReset = now.difference(lastWeeklyReset).inDays;

    if (daysSinceReset >= 7) {
      weeklyXP = getWeeklyXP(forDate: now); // Текущая неделя
      lastWeeklyReset = now;
    }
  }

  // Получение текущей лиги на основе недельного XP
  String getCurrentLeague() {
    _checkWeeklyReset(); // Сначала проверяем актуальность weeklyXP

    final currentWeeklyXP = weeklyXP;

    if (currentWeeklyXP >= 5000) return 'Нереальная';
    if (currentWeeklyXP >= 4000) return 'Легендарная';
    if (currentWeeklyXP >= 3000) return 'Элитная';
    if (currentWeeklyXP >= 2000) return 'Бриллиантовая';
    if (currentWeeklyXP >= 1500) return 'Платиновая';
    if (currentWeeklyXP >= 1000) return 'Золотая';
    if (currentWeeklyXP >= 500) return 'Серебряная';
    return 'Бронзовая';
  }

  // Получение цвета лиги
  Color getLeagueColor() {
    final league = getCurrentLeague();
    switch (league) {
      case 'Бронзовая': return Color(0xFFCD7F32);
      case 'Серебряная': return Color(0xFFC0C0C0);
      case 'Золотая': return Color(0xFFFFD700);
      case 'Платиновая': return Color(0xFFE5E4E2);
      case 'Бриллиантовая': return Color(0xFFB9F2FF);
      case 'Элитная': return Color(0xFF7F7F7F);
      case 'Легендарная': return Color(0xFFFF4500);
      case 'Нереальная': return Color(0xFFE6E6FA);
      default: return Color(0xFFCD7F32);
    }
  }

  // Получение прогресса до следующей лиги (0.0 - 1.0)
  double getLeagueProgress() {
    _checkWeeklyReset();

    final currentXP = weeklyXP;

    if (currentXP >= 5000) return 1.0;
    if (currentXP >= 4000) return (currentXP - 4000) / 1000.0;
    if (currentXP >= 3000) return (currentXP - 3000) / 1000.0;
    if (currentXP >= 2000) return (currentXP - 2000) / 1000.0;
    if (currentXP >= 1500) return (currentXP - 1500) / 500.0;
    if (currentXP >= 1000) return (currentXP - 1000) / 500.0;
    if (currentXP >= 500) return (currentXP - 500) / 500.0;
    return currentXP / 500.0;
  }

  // Получение XP до следующей лиги
  int getXPToNextLeague() {
    _checkWeeklyReset();

    final currentXP = weeklyXP;

    if (currentXP < 500) return 500 - currentXP;
    if (currentXP < 1000) return 1000 - currentXP;
    if (currentXP < 1500) return 1500 - currentXP;
    if (currentXP < 2000) return 2000 - currentXP;
    if (currentXP < 3000) return 3000 - currentXP;
    if (currentXP < 4000) return 4000 - currentXP;
    if (currentXP < 5000) return 5000 - currentXP;
    return 0;
  }

  // Получение названия следующей лиги
  String getNextLeague() {
    final currentLeague = getCurrentLeague();
    switch (currentLeague) {
      case 'Бронзовая': return 'Серебряная';
      case 'Серебряная': return 'Золотая';
      case 'Золотая': return 'Платиновая';
      case 'Платиновая': return 'Бриллиантовая';
      case 'Бриллиантовая': return 'Элитная';
      case 'Элитная': return 'Легендарная';
      case 'Легендарная': return 'Нереальная';
      case 'Нереальная': return 'Нереальная';
      default: return 'Серебряная';
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
        if (entry.value > 0) {
          completedIds.add(entry.key);
        }
      }
    }

    return completedIds;
  }

  // Метод для получения количества завершённых тем
  int getCompletedTopicsCount() {
    int count = 0;
    for (final subjectProgress in topicProgress.values) {
      for (final progress in subjectProgress.values) {
        if (progress > 0) {
          count++;
        }
      }
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
      int totalTopics = topicProgressMap.length;

      for (final progress in topicProgressMap.values) {
        totalCorrectAnswers += progress;
        if (progress > 0) {
          completedTopics++;
        }
      }

      statistics[subjectName] = {
        'completedTopics': completedTopics,
        'totalCorrectAnswers': totalCorrectAnswers,
        'totalTopics': totalTopics,
        'completionPercentage': totalTopics > 0 ? (completedTopics / totalTopics * 100).round() : 0,
      };
    }

    return statistics;
  }

  // Получение статистики по XP
  Map<String, dynamic> getXpStatistics() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final monthAgo = now.subtract(Duration(days: 30));

    // Считаем XP за последние 7 дней и 30 дней
    int last7DaysXP = 0;
    int last30DaysXP = 0;
    int activeDaysLast7 = 0;
    int activeDaysLast30 = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      final xp = dailyXP[dateKey] ?? 0;

      if (i < 7) {
        last7DaysXP += xp;
        if (xp > 0) activeDaysLast7++;
      }

      last30DaysXP += xp;
      if (xp > 0) activeDaysLast30++;
    }

    final avg7Days = activeDaysLast7 > 0 ? (last7DaysXP / activeDaysLast7).round() : 0;
    final avg30Days = activeDaysLast30 > 0 ? (last30DaysXP / activeDaysLast30).round() : 0;

    // Находим максимальный дневной XP
    int maxDailyXP = dailyXP.values.fold(0, (max, xp) => xp > max ? xp : max);

    return {
      'totalXP': totalXP,
      'weeklyXP': weeklyXP,
      'last7DaysXP': last7DaysXP,
      'last30DaysXP': last30DaysXP,
      'avg7Days': avg7Days,
      'avg30Days': avg30Days,
      'maxDailyXP': maxDailyXP,
      'activeDaysLast7': activeDaysLast7,
      'activeDaysLast30': activeDaysLast30,
    };
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
      ...getXpStatistics(),
    };
  }

  // === МЕТОДЫ ДЛЯ СБРОСА ===

  // Метод для сброса прогресса
  void resetProgress() {
    streakDays = 0;
    topicProgress.clear();
    dailyCompletion.clear();
    dailyXP.clear();
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
      dailyXP: {},
      username: '',
      totalXP: 0,
      weeklyXP: 0,
      lastWeeklyReset: DateTime.now(),
    );
  }
}