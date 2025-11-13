import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../localization.dart';
import '../data/subjects_data.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          appLocalizations.statistics,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основные метрики в виде карточек
            _buildMetricsSection(context, appLocalizations),

            const SizedBox(height: 24),

            // Прогресс по предметам
            _buildSubjectsProgressSection(context, appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Общая статистика',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Карточки с метриками
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Дней подряд',
                value: userStats.streakDays.toString(),
                color: Theme.of(context).colorScheme.primary,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.check_circle_rounded,
                title: 'Пройдено тем',
                value: completedTopics.toString(),
                color: Colors.green,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade600,
                    Colors.green.shade800,
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Карточка с правильными ответами
        _MetricCard(
          icon: Icons.psychology_rounded,
          title: 'Правильных ответов',
          value: totalCorrectAnswers.toString(),
          color: Colors.blue,
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSubjectsProgressSection(BuildContext context, AppLocalizations appLocalizations) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              appLocalizations.progressBySubjects,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: userStats.topicProgress.isEmpty
                ? _buildEmptyState(context, appLocalizations)
                : _buildSubjectsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations appLocalizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет статистики',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Начните изучать темы, чтобы увидеть прогресс',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: userStats.topicProgress.entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = userStats.topicProgress.entries.elementAt(index);
        return _SubjectProgressCard(
          subject: entry.key,
          topics: entry.value,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Gradient gradient;
  final bool fullWidth;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.gradient,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final String subject;
  final Map<String, int> topics;

  const _SubjectProgressCard({
    required this.subject,
    required this.topics,
  });

  String _getTopicName(String topicId, BuildContext context) {
    final subjectsData = getSubjectsByGrade(context);
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
    return topicId;
  }

  int _getTopicQuestionCount(String topicId, BuildContext context) {
    final subjectsData = getSubjectsByGrade(context);
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
    return 0;
  }

  double _getOverallProgress(BuildContext context) {
    if (topics.isEmpty) return 0.0;

    int totalQuestions = 0;
    int totalCorrect = 0;

    for (final topic in topics.entries) {
      final questionCount = _getTopicQuestionCount(topic.key, context);
      totalQuestions += questionCount;
      totalCorrect += topic.value;
    }

    return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = _getOverallProgress(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и общий прогресс
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(overallProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Прогресс-бар
            LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 16),

            // Список тем
            ...topics.entries.map((topic) {
              final topicName = _getTopicName(topic.key, context);
              final questionCount = _getTopicQuestionCount(topic.key, context);
              final correctAnswers = topic.value;
              final progress = questionCount > 0 ? correctAnswers / questionCount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$correctAnswers/$questionCount ${_getQuestionWord(questionCount)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getProgressColor(progress).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _getProgressColor(progress),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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

  String _getQuestionWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'вопрос';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'вопроса';
    }
    return 'вопросов';
  }

  Color _getProgressColor(double progress) {
    if (progress == 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.lightGreen;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}