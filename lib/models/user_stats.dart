class UserStats {
  int streakDays;
  DateTime lastActivity;
  Map<String, Map<String, int>> topicProgress;
  Map<String, bool> dailyCompletion;
  String username;

  UserStats({
    required this.streakDays,
    required this.lastActivity,
    required this.topicProgress,
    required this.dailyCompletion,
    required this.username,
  });

  // Копирующий конструктор для обновления
  UserStats copyWith({
    int? streakDays,
    DateTime? lastActivity,
    Map<String, Map<String, int>>? topicProgress,
    Map<String, bool>? dailyCompletion,
    String? username,
  }) {
    return UserStats(
      streakDays: streakDays ?? this.streakDays,
      lastActivity: lastActivity ?? this.lastActivity,
      topicProgress: topicProgress ?? Map.from(this.topicProgress),
      dailyCompletion: dailyCompletion ?? Map.from(this.dailyCompletion),
      username: username ?? this.username,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streakDays': streakDays,
      'lastActivity': lastActivity.toIso8601String(),
      'topicProgress': topicProgress,
      'dailyCompletion': dailyCompletion,
      'username': username,
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

    return UserStats(
      streakDays: (json['streakDays'] as int?) ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] as String? ?? DateTime.now().toIso8601String()),
      topicProgress: topicProgress,
      dailyCompletion: dailyCompletion,
      username: (json['username'] as String?) ?? '',
    );
  }

  // Метод для сброса прогресса
  void resetProgress() {
    streakDays = 0;
    topicProgress.clear();
    dailyCompletion.clear();
    lastActivity = DateTime.now();
  }

  // === НОВЫЕ МЕТОДЫ ДЛЯ РАБОТЫ С ID ТЕМ ===

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
      // Если вчера не было активности, сбрасываем стрик
      streakDays = 1;
    }

    lastActivity = today;
  }

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
        // Здесь нужно получить общее количество вопросов для каждой темы
        // Пока считаем что тема завершена если правильных ответов >= 1
        if (progress > 0) {
          completedTopics++;
        }
      }

      statistics[subjectName] = {
        'completedTopics': completedTopics,
        'totalCorrectAnswers': totalCorrectAnswers,
        'totalTopics': topicProgressMap.length,
      };
    }

    return statistics;
  }

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
    return 'UserStats(streakDays: $streakDays, completedTopics: ${getCompletedTopicsCount()}, totalCorrectAnswers: ${getTotalCorrectAnswers()})';
  }
}