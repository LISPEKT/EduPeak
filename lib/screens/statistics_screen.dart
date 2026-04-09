// lib/screens/statistics_screen.dart
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Раздел', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                          Text(appLocalizations.statistics, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSubjectsProgressSection(context, theme, isDark, appLocalizations),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String value, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, color: theme.hintColor, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildSubjectsProgressSection(BuildContext context, ThemeData theme, bool isDark, AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appLocalizations.progressBySubjects, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 16),
          userStats.topicProgress.isEmpty
              ? _buildEmptyState(theme, isDark, appLocalizations)
              : Column(children: userStats.topicProgress.entries.map((entry) => _buildSubjectCard(context, entry.key, entry.value, theme, isDark)).toList()),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, Map<String, int> topics, ThemeData theme, bool isDark) {
    int totalQuestions = 0;
    int totalCorrect = 0;
    for (final topic in topics.entries) {
      final questionCount = _getTopicQuestionCount(context, topic.key);
      totalQuestions += questionCount;
      totalCorrect += topic.value;
    }
    final progress = totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getProgressColor(progress).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(subject, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _getProgressColor(progress).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getProgressColor(progress))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200], color: _getProgressColor(progress), borderRadius: BorderRadius.circular(8), minHeight: 8),
          const SizedBox(height: 12),
          ...topics.entries.map((topic) => _buildTopicItem(context, topic.key, topic.value, theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, String topicId, int correctAnswers, ThemeData theme, bool isDark) {
    final questionCount = _getTopicQuestionCount(context, topicId);
    final progress = questionCount > 0 ? correctAnswers / questionCount : 0.0;
    final topicName = _getTopicName(context, topicId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: _getProgressColor(progress).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_getTopicIcon(progress), size: 16, color: _getProgressColor(progress))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topicName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.textTheme.titleMedium?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('$correctAnswers/$questionCount вопросов', style: TextStyle(fontSize: 11, color: theme.hintColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _getProgressColor(progress).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getProgressColor(progress))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, AppLocalizations appLocalizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.analytics_rounded, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('Пока нет статистики', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
            const SizedBox(height: 8),
            Text('Начните изучать темы, чтобы увидеть прогресс', style: TextStyle(fontSize: 14, color: theme.hintColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  String _getTopicName(BuildContext context, String topicId) {
    final subjectsData = getSubjectsByGrade(context);
    for (final grade in subjectsData.keys) {
      for (final subject in subjectsData[grade] ?? []) {
        for (final topic in subject.topicsByGrade[grade] ?? []) {
          if (topic.id == topicId) return topic.name;
        }
      }
    }
    return topicId;
  }

  int _getTopicQuestionCount(BuildContext context, String topicId) {
    final subjectsData = getSubjectsByGrade(context);
    for (final grade in subjectsData.keys) {
      for (final subject in subjectsData[grade] ?? []) {
        for (final topic in subject.topicsByGrade[grade] ?? []) {
          if (topic.id == topicId) return topic.questions.length;
        }
      }
    }
    return 0;
  }

  Color _getProgressColor(double progress) {
    if (progress == 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.lightGreen;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getTopicIcon(double progress) {
    if (progress == 1.0) return Icons.check_circle_rounded;
    if (progress >= 0.7) return Icons.task_alt_rounded;
    if (progress >= 0.3) return Icons.timelapse_rounded;
    return Icons.pending_rounded;
  }
}