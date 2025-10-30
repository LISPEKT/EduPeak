import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../localization.dart';
import '../data/subjects_data.dart'; // Добавьте этот импорт

class StatisticsScreen extends StatelessWidget {
  final UserStats userStats;

  const StatisticsScreen({super.key, required this.userStats});

  int get completedTopics {
    int completed = 0;
    for (final subject in userStats.topicProgress.values) {
      completed += subject.length;
    }
    return completed;
  }

  int get totalCorrectAnswers {
    int total = 0;
    for (final subject in userStats.topicProgress.values) {
      for (final progress in subject.values) {
        total += progress;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.statistics),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatCard(
              icon: Icons.local_fire_department,
              title: appLocalizations.daysInRow,
              value: '${userStats.streakDays}',
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _StatCard(
              icon: Icons.check_circle,
              title: appLocalizations.completedTopicsCount,
              value: '$completedTopics',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _StatCard(
              icon: Icons.psychology,
              title: appLocalizations.correctAnswersCount,
              value: '$totalCorrectAnswers',
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.progressBySubjects,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userStats.topicProgress.isEmpty
                  ? Center(
                child: Text(
                  appLocalizations.noCompletedTopics,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
                  : ListView(
                children: userStats.topicProgress.entries.map((entry) {
                  final subject = entry.key;
                  final topics = entry.value;
                  return _SubjectProgress(
                    subject: subject,
                    topics: topics,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectProgress extends StatelessWidget {
  final String subject;
  final Map<String, int> topics;

  const _SubjectProgress({
    required this.subject,
    required this.topics,
  });

  // Метод для получения названия темы по её ID
  String _getTopicName(String topicId, BuildContext context) {
    // Получаем данные предметов
    final subjectsData = getSubjectsByGrade(context);

    // Ищем тему по ID во всех предметах и классах
    for (final grade in subjectsData.keys) {
      final subjects = subjectsData[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        for (final topic in topics) {
          if (topic.id == topicId) {
            return topic.name;
          }
        }
      }
    }

    // Если не нашли, возвращаем ID как fallback
    return topicId;
  }

  // Метод для получения количества вопросов в теме
  int _getTopicQuestionCount(String topicId, BuildContext context) {
    // Получаем данные предметов
    final subjectsData = getSubjectsByGrade(context);

    // Ищем тему по ID во всех предметах и классах
    for (final grade in subjectsData.keys) {
      final subjects = subjectsData[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        for (final topic in topics) {
          if (topic.id == topicId) {
            return topic.questions.length;
          }
        }
      }
    }

    // Если не нашли, возвращаем 0
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...topics.entries.map((topic) {
              final topicName = _getTopicName(topic.key, context);
              final questionCount = _getTopicQuestionCount(topic.key, context);
              final correctAnswers = topic.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topicName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$correctAnswers/$questionCount${questionCount == 1 ? ' вопрос' : _getQuestionWord(questionCount)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getProgressColor(correctAnswers, questionCount).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getProgressColor(correctAnswers, questionCount).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$correctAnswers/$questionCount',
                        style: TextStyle(
                          color: _getProgressColor(correctAnswers, questionCount),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для получения правильной формы слова "вопрос"
  String _getQuestionWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return ' вопрос';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return ' вопроса';
    }
    return ' вопросов';
  }

  // Метод для определения цвета прогресса
  Color _getProgressColor(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return Colors.grey;

    final percentage = correctAnswers / totalQuestions;
    if (percentage == 1) return Colors.green;
    if (percentage >= 0.8 && percentage < 1) return Colors.lightGreenAccent;
    if (percentage >= 0.6) return Colors.yellow;
    if (percentage >= 0.4) return Colors.orange;
    return Colors.red;
  }
}