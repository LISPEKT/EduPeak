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

  // Проверка завершённости темы
  bool get _isTopicCompleted {
    final topicName = widget.topic.name; // Временно используем имя, пока нет ID
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

  // Получение прогресса по теме
  int get _topicProgress {
    final topicName = widget.topic.name; // Временно используем имя, пока нет ID
    for (final subjectName in _userStats.topicProgress.keys) {
      final subjectProgress = _userStats.topicProgress[subjectName];
      if (subjectProgress != null && subjectProgress.containsKey(topicName)) {
        return subjectProgress[topicName] ?? 0;
      }
    }
    return 0;
  }

  // Получение процента выполнения
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
      // Обновляем статистику после возвращения с урока
      _loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой и названием
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      widget.topic.imageAsset,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.currentGrade != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${widget.currentGrade} ${appLocalizations.gradeClass}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Прогресс выполнения (если есть прогресс)
            if (_topicProgress > 0 && !_isLoading) ...[
              _buildProgressSection(appLocalizations),
              const SizedBox(height: 16),
            ],

            // Описание темы
            Text(
              appLocalizations.topicDescription,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.topic.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 16),

            // Объяснение темы (если есть)
            if (widget.topic.explanation != null && widget.topic.explanation.isNotEmpty) ...[
              Text(
                appLocalizations.lessonExplanation,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.topic.explanation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Статистика темы
            _buildTopicStats(appLocalizations),

            const SizedBox(height: 24),

            // Кнопка действия
            _buildActionButton(appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(AppLocalizations appLocalizations) {
    final totalQuestions = widget.topic.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isTopicCompleted
                  ? '🎉 ${_getLocalizedCompletionText(appLocalizations)}'
                  : '${_getLocalizedProgressText(appLocalizations)}:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isTopicCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '$_topicProgress/$totalQuestions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isTopicCompleted
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _completionPercentage / 100,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          color: _isTopicCompleted
              ? Colors.green
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        if (_completionPercentage > 0 && _completionPercentage < 100) ...[
          const SizedBox(height: 4),
          Text(
            '${_completionPercentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  String _getLocalizedCompletionText(AppLocalizations appLocalizations) {
    // Временное решение - добавим эти тексты вручную
    switch (appLocalizations.locale.languageCode) {
      case 'ru':
        return 'Тема завершена';
      case 'en':
        return 'Topic completed';
      case 'de':
        return 'Thema abgeschlossen';
      default:
        return 'Topic completed';
    }
  }

  String _getLocalizedProgressText(AppLocalizations appLocalizations) {
    // Временное решение
    switch (appLocalizations.locale.languageCode) {
      case 'ru':
        return 'Прогресс';
      case 'en':
        return 'Progress';
      case 'de':
        return 'Fortschritt';
      default:
        return 'Progress';
    }
  }

  Widget _buildTopicStats(AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.question_answer,
            '${widget.topic.questions.length}',
            _getLocalizedQuestionsText(appLocalizations),
          ),
          _buildStatItem(
            Icons.timer,
            '${widget.topic.questions.length}',
            _getLocalizedMinutesText(appLocalizations),
          ),
          _buildStatItem(
            Icons.emoji_events,
            _isTopicCompleted ? '100%' : '${_completionPercentage.toStringAsFixed(0)}%',
            appLocalizations.success,
          ),
        ],
      ),
    );
  }

  String _getLocalizedQuestionsText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru':
        return 'вопросов';
      case 'en':
        return 'questions';
      case 'de':
        return 'Fragen';
      default:
        return 'questions';
    }
  }

  String _getLocalizedMinutesText(AppLocalizations appLocalizations) {
    switch (appLocalizations.locale.languageCode) {
      case 'ru':
        return 'минут';
      case 'en':
        return 'minutes';
      case 'de':
        return 'Minuten';
      default:
        return 'minutes';
    }
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(AppLocalizations appLocalizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startLesson,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isTopicCompleted
              ? appLocalizations.startTestButton
              : appLocalizations.startLessonButton,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}