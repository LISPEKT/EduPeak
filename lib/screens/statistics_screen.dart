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
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            title: Text(
              appLocalizations.statistics,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            centerTitle: true,
            floating: true,
            snap: true,
          ),

          // Основной контент
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Основные метрики в карточках
                _buildMetricsSection(context, theme, isDark),

                const SizedBox(height: 24),

                // Прогресс по предметам
                _buildSubjectsProgressSection(context, theme, appLocalizations),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _MetricCard(
              icon: Icons.local_fire_department_rounded,
              title: 'Дней подряд',
              value: userStats.streakDays.toString(),
              iconColor: Colors.orange,
              cardColor: isDark
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.1),
            ),
            _MetricCard(
              icon: Icons.check_circle_rounded,
              title: 'Пройдено тем',
              value: completedTopics.toString(),
              iconColor: Colors.green,
              cardColor: isDark
                  ? Colors.green.withOpacity(0.15)
                  : Colors.green.withOpacity(0.1),
            ),
            _MetricCard(
              icon: Icons.psychology_rounded,
              title: 'Правильных ответов',
              value: totalCorrectAnswers.toString(),
              iconColor: Colors.blue,
              cardColor: isDark
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.1),
            ),
            _MetricCard(
              icon: Icons.trending_up_rounded,
              title: 'Активность',
              value: '${userStats.dailyCompletion.length} дней',
              iconColor: Colors.purple,
              cardColor: isDark
                  ? Colors.purple.withOpacity(0.15)
                  : Colors.purple.withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectsProgressSection(BuildContext context, ThemeData theme, AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.progressBySubjects,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        userStats.topicProgress.isEmpty
            ? _buildEmptyState(context, appLocalizations)
            : _buildSubjectsList(context, theme),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations appLocalizations) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет статистики',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Начните изучать темы, чтобы увидеть прогресс',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context, ThemeData theme) {
    return Column(
      children: userStats.topicProgress.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SubjectProgressCard(
            subject: entry.key,
            topics: entry.value,
          ),
        );
      }).toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final Color cardColor;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final overallProgress = _getOverallProgress(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Прогресс-бар
            LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: _getProgressColor(overallProgress),
              borderRadius: BorderRadius.circular(8),
              minHeight: 10,
            ),

            const SizedBox(height: 20),

            // Список тем
            Column(
              children: topics.entries.map((topic) {
                final topicName = _getTopicName(topic.key, context);
                final questionCount = _getTopicQuestionCount(topic.key, context);
                final correctAnswers = topic.value;
                final progress = questionCount > 0 ? correctAnswers / questionCount : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Иконка темы
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getProgressColor(progress).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTopicIcon(progress),
                          size: 20,
                          color: _getProgressColor(progress),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Информация о теме
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topicName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '$correctAnswers/$questionCount ${_getQuestionWord(questionCount)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
    if (progress >= 0.8) return Colors.lightGreen;
    if (progress >= 0.6) return Colors.orange;
    if (progress >= 0.4) return Colors.amber;
    return Colors.red;
  }

  IconData _getTopicIcon(double progress) {
    if (progress == 1.0) return Icons.check_circle_rounded;
    if (progress >= 0.7) return Icons.task_alt_rounded;
    if (progress >= 0.4) return Icons.timelapse_rounded;
    return Icons.pending_rounded;
  }
}