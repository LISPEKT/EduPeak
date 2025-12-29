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

  int get _fullXPForTest {
    final totalQuestions = widget.topic.questions.length;
    if (totalQuestions == 0) return 0;

    final baseXP = totalQuestions * 10;
    return baseXP + 100;
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

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    color: primaryColor.withOpacity(0.1),
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
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
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
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: theme.hintColor,
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isTopicCompleted
                              ? '🎉 ${appLocalizations.topicCompleted}'
                              : '${appLocalizations.progress}:',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: _isTopicCompleted
                                ? Colors.green
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isTopicCompleted
                                ? Colors.green.withOpacity(0.1)
                                : primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_topicProgress/${widget.topic.questions.length}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: _isTopicCompleted
                                  ? Colors.green
                                  : primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    LinearProgressIndicator(
                      value: _completionPercentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: _isTopicCompleted
                          ? Colors.green
                          : primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: isSmallScreen ? 8 : 10,
                    ),
                    if (_completionPercentage > 0 && _completionPercentage < 100) ...[
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            '${_completionPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: _isTopicCompleted
                                  ? Colors.green
                                  : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],

            // Описание темы
            Text(
              appLocalizations.topicDescription,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.topic.description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: theme.hintColor,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Статистика темы
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика темы',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.quiz_rounded,
                        '${widget.topic.questions.length}',
                        appLocalizations.questions,
                        isSmallScreen,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        Icons.bolt_rounded,
                        '$_remainingXP',
                        appLocalizations.experience,
                        isSmallScreen,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        Icons.check_circle_rounded,
                        '$_earnedXP',
                        appLocalizations.earnedXP,
                        isSmallScreen,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Кнопка действия
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTopicCompleted
                      ? Colors.green
                      : primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isTopicCompleted ? Icons.restart_alt_rounded : Icons.play_arrow_rounded,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isTopicCompleted
                          ? appLocalizations.retakeTestButton
                          : appLocalizations.startTestButton,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_remainingXP > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+$_remainingXP XP',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
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
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, bool isSmallScreen, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: color,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: theme.hintColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}