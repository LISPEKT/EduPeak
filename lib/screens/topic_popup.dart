import 'package:flutter/material.dart';
import 'test_screen.dart';
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
    totalXP: 0,
    weeklyXP: 0,
    lastWeeklyReset: DateTime.now(),
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
    final topicId = widget.topic.id;
    final progress = _userStats.getTopicProgress(topicId);
    final totalQuestions = widget.topic.questions.length;
    return progress >= totalQuestions;
  }

  int get _topicProgress {
    final topicId = widget.topic.id;
    return _userStats.getTopicProgress(topicId);
  }

  double get _completionPercentage {
    final totalQuestions = widget.topic.questions.length;
    if (totalQuestions == 0) return 0.0;
    return (_topicProgress / totalQuestions) * 100;
  }

  int get _earnedXP {
    final totalQuestions = widget.topic.questions.length;
    if (totalQuestions == 0) return 0;

    int earned = _topicProgress * 10;
    if (_isTopicCompleted) {
      earned += 100;
    }

    return earned;
  }

  int get _remainingXP {
    final totalQuestions = widget.topic.questions.length;
    if (totalQuestions == 0) return 0;

    final remainingQuestions = totalQuestions - _topicProgress;
    int remaining = remainingQuestions * 10;

    if (!_isTopicCompleted && remainingQuestions > 0) {
      remaining += 100;
    }

    return remaining;
  }

  void _startTest() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestScreen(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.height < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 55 : 65,
                            height: isSmallScreen ? 55 : 65,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                widget.topic.imageAsset,
                                style: TextStyle(fontSize: isSmallScreen ? 28 : 32),
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
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                if (widget.currentGrade != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.currentGrade} ${appLocalizations.gradeClass}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 13 : 14,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Прогресс
                      if (_topicProgress > 0 && !_isLoading) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isTopicCompleted
                                        ? '✅ ${appLocalizations.topicCompleted}'
                                        : appLocalizations.progress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isTopicCompleted ? Colors.green : theme.hintColor,
                                    ),
                                  ),
                                  Text(
                                    '$_topicProgress/${widget.topic.questions.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _completionPercentage / 100,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                                color: _isTopicCompleted ? Colors.green : primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Описание
                      Text(
                        appLocalizations.topicDescription,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.topic.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Статистика
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              Icons.quiz_rounded,
                              '${widget.topic.questions.length}',
                              appLocalizations.questions,
                              Colors.blue,
                            ),
                            _buildStatColumn(
                              Icons.bolt_rounded,
                              '$_remainingXP',
                              appLocalizations.experience,
                              Colors.orange,
                            ),
                            _buildStatColumn(
                              Icons.check_circle_rounded,
                              '$_earnedXP',
                              appLocalizations.earnedXP,
                              Colors.green,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Кнопка
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTopicCompleted ? Colors.green : primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isTopicCompleted ? Icons.refresh_rounded : Icons.play_arrow_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isTopicCompleted
                                    ? appLocalizations.retakeTestButton
                                    : appLocalizations.startTestButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_remainingXP > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+$_remainingXP XP',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildStatColumn(IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.hintColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}