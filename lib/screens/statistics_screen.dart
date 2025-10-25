import 'package:flutter/material.dart';
import '../models/user_stats.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Статистика'),
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
              title: 'Дней подряд',
              value: '${userStats.streakDays}',
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _StatCard(
              icon: Icons.check_circle,
              title: 'Пройдено тем',
              value: '$completedTopics',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _StatCard(
              icon: Icons.psychology,
              title: 'Правильных ответов',
              value: '$totalCorrectAnswers',
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Прогресс по предметам:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userStats.topicProgress.isEmpty
                  ? Center(
                child: Text(
                  'Пока нет пройденных тем',
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${topic.value}%',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
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
}