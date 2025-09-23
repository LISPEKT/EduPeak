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
}