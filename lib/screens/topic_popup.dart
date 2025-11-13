// topic_popup.dart - РЕДИЗАЙН В MD3
import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import '../localization.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';

class TopicPopup extends StatefulWidget {
  final dynamic topic;
  final int? currentGrade;
  final String? currentSubject;

  const TopicPopup({
    required this.topic,
    this.currentGrade,
    this.currentSubject,
    super.key,
  });

  @override
  State<TopicPopup> createState() => _TopicPopupState();
}

class _TopicPopupState extends State<TopicPopup> {
  UserStats _userStats = UserStats(
    streakDays: 0,
    lastActivity: DateTime.now(),
    topicProgress: {},
    dailyCompletion: {},
    username: '',
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _isTopicCompleted {
    final topicName = widget.topic.name;
    for (final subjectName in _userStats.topicProgress.keys) {
      final subjectProgress = _userStats.topicProgress[subjectName];
      if (subjectProgress != null && subjectProgress.containsKey(topicName)) {
        final topicCorrectAnswers = subjectProgress[topicName] ?? 0;
        final totalQuestions = widget.topic.questions.length;
        return topicCorrectAnswers >= totalQuestions;
      }
    }
    return false;
  }

  int get _topicProgress {
    final topicName = widget.topic.name;
    for (final subjectName in _userStats.topicProgress.keys) {
      final subjectProgress = _userStats.topicProgress[subjectName];
      if (subjectProgress != null && subjectProgress.containsKey(topicName)) {
        return subjectProgress[topicName] ?? 0;
      }
    }
    return 0;
  }

  double get _completionPercentage {
    final totalQuestions = widget.topic.questions.length;
    if (totalQuestions == 0) return 0.0;
    return (_topicProgress / totalQuestions) * 100;
  }

  void _startLesson() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          topic: widget.topic,
          currentGrade: widget.currentGrade,
          currentSubject: widget.currentSubject,
        ),
      ),
    ).then((_) {
      _loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 600;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой и названием
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 50 : 60,
                  height: isSmallScreen ? 50 : 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.topic.imageAsset,
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: isSmallScreen ? 50 : 60,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.topic.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: isSmallScreen ? 18 : 20,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ),
                      if (widget.currentGrade != null) ...[
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        Text(
                          '${widget.currentGrade} ${appLocalizations.gradeClass}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: isSmallScreen ? 12 : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Прогресс выполнения
            if (_topicProgress > 0 && !_isLoading) ...[
              _buildProgressSection(appLocalizations, isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],

            // Описание темы
            Text(
              appLocalizations.topicDescription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 16 : null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              widget.topic.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
                fontSize: isSmallScreen ? 14 : null,
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Статистика темы
            _buildTopicStats(appLocalizations, isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Кнопка действия
            _buildActionButton(appLocalizations, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(AppLocalizations appLocalizations, bool isSmallScreen) {
    final totalQuestions = widget.topic.questions.length;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isTopicCompleted
                      ? '🎉 ${_getLocalizedCompletionText(appLocalizations)}'
                      : '${_getLocalizedProgressText(appLocalizations)}:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isTopicCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: isSmallScreen ? 14 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$_topicProgress/$totalQuestions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isTopicCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                  fontSize: isSmallScreen ? 14 : null,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          LinearProgressIndicator(
            value: _completionPercentage / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: _isTopicCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
            minHeight: isSmallScreen ? 6 : 8,
          ),
          if (_completionPercentage > 0 && _completionPercentage < 100) ...[
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              '${_completionPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: isSmallScreen ? 11 : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLocalizedCompletionText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru': return 'Тема завершена';
      case 'en': return 'Topic completed';
      case 'de': return 'Thema abgeschlossen';
      default: return 'Topic completed';
    }
  }

  String _getLocalizedProgressText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru': return 'Прогресс';
      case 'en': return 'Progress';
      case 'de': return 'Fortschritt';
      default: return 'Progress';
    }
  }

  Widget _buildTopicStats(AppLocalizations appLocalizations, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.quiz_rounded,
            '${widget.topic.questions.length}',
            _getLocalizedQuestionsText(appLocalizations),
            isSmallScreen,
          ),
          _buildStatItem(
            Icons.schedule_rounded,
            '${widget.topic.questions.length}',
            _getLocalizedMinutesText(appLocalizations),
            isSmallScreen,
          ),
          _buildStatItem(
            Icons.emoji_events_rounded,
            _isTopicCompleted ? '100%' : '${_completionPercentage.toStringAsFixed(0)}%',
            appLocalizations.success,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  String _getLocalizedQuestionsText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru': return 'вопросов';
      case 'en': return 'questions';
      case 'de': return 'Fragen';
      default: return 'questions';
    }
  }

  String _getLocalizedMinutesText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru': return 'минут';
      case 'en': return 'minutes';
      case 'de': return 'Minuten';
      default: return 'minutes';
    }
  }

  Widget _buildStatItem(IconData icon, String value, String label, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 14 : null,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: isSmallScreen ? 10 : null,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton(AppLocalizations appLocalizations, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _startLesson,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isTopicCompleted
              ? appLocalizations.startTestButton
              : appLocalizations.startLessonButton,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}