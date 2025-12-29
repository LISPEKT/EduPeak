import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/review_item.dart';
import '../localization.dart';
import 'topic_popup.dart';

class ReviewScreen extends StatefulWidget {
  final Function(int) onBottomNavTap;
  final int currentIndex;

  const ReviewScreen({
    Key? key,
    required this.onBottomNavTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewItem> _reviewItems = [];
  List<ReviewItem> _startedTopicsItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final subjectsData = getSubjectsByGrade(context);

      List<ReviewItem> startedTopicsItems = [];
      Set<String> usedQuestionIds = {};

      for (final grade in subjectsData.keys) {
        final subjects = subjectsData[grade] ?? [];
        for (final subject in subjects) {
          final topics = subject.topicsByGrade[grade] ?? [];
          for (final topic in topics) {
            final topicProgress = stats.topicProgress[subject.name]?[topic.id] ?? 0;

            if (topicProgress > 0) {
              for (int i = topicProgress; i < topic.questions.length; i++) {
                final questionId = '${subject.name}_${topic.id}_$i';

                if (!usedQuestionIds.contains(questionId) && i < topic.questions.length) {
                  startedTopicsItems.add(ReviewItem(
                    question: topic.questions[i],
                    topic: topic,
                    subject: subject.name,
                    grade: grade,
                    questionIndex: i,
                  ));
                  usedQuestionIds.add(questionId);

                  final questionsInThisTopic = startedTopicsItems.where((item) =>
                  item.topic.id == topic.id && item.subject == subject.name).length;
                  if (questionsInThisTopic >= 5) {
                    break;
                  }
                }
              }
            }
          }
        }
      }

      setState(() {
        _reviewItems = startedTopicsItems;
        _startedTopicsItems = startedTopicsItems;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading review data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openTopic(ReviewItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicPopup(
        topic: item.topic,
        currentGrade: item.grade,
        currentSubject: item.subject,
      ),
    );
  }

  String _getQuestionText(dynamic question) {
    try {
      if (question is Map<String, dynamic>) {
        return question['text'] ?? 'Вопрос';
      } else {
        return 'Вопрос из темы';
      }
    } catch (e) {
      return 'Вопрос';
    }
  }

  Color _getSubjectColor(String subjectName) {
    final colors = {
      'Математика': Color(0xFF4285F4),
      'Алгебра': Color(0xFF2196F3),
      'Геометрия': Color(0xFF3F51B5),
      'Русский язык': Color(0xFFEA4335),
      'Литература': Color(0xFFFBBC05),
      'История': Color(0xFF34A853),
      'Обществознание': Color(0xFF8E44AD),
      'География': Color(0xFF00BCD4),
      'Биология': Color(0xFF4CAF50),
      'Физика': Color(0xFF9C27B0),
      'Химия': Color(0xFFFF9800),
      'Английский язык': Color(0xFFE91E63),
    };
    return colors[subjectName] ?? Color(0xFF9E9E9E);
  }

  IconData _getSubjectIcon(String subjectName) {
    final icons = {
      'Математика': Icons.calculate_rounded,
      'Алгебра': Icons.functions_rounded,
      'Геометрия': Icons.shape_line_rounded,
      'Русский язык': Icons.menu_book_rounded,
      'Литература': Icons.book_rounded,
      'История': Icons.history_rounded,
      'Обществознание': Icons.people_rounded,
      'География': Icons.public_rounded,
      'Биология': Icons.eco_rounded,
      'Физика': Icons.science_rounded,
      'Химия': Icons.science_rounded,
      'Английский язык': Icons.language_rounded,
    };
    return icons[subjectName] ?? Icons.subject_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Загружаем темы для повторения...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

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
            stops: [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок (как на profile screen - Row с кнопкой справа)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Раздел',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          appLocalizations.review,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    // Иконка-заглушка для симметрии (как на profile screen)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.info_outline_rounded),
                        color: primaryColor,
                        onPressed: () {
                          // TODO: Добавить информацию о повторении
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Остальной контент в скролле
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная карточка статистики
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Иконка повторения
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  color: primaryColor,
                                  size: 36,
                                ),
                              ),
                              SizedBox(width: 20),

                              // Информация
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Темы для повторения',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.titleMedium?.color,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _startedTopicsItems.isNotEmpty
                                          ? '${_startedTopicsItems.length} вопросов из начатых тем'
                                          : 'Начните изучение тем',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Статистика в ряд
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          'Статистика',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Вопросов',
                                value: '${_reviewItems.length}',
                                subtitle: 'всего',
                                color: primaryColor,
                                icon: Icons.question_answer_rounded,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Темы',
                                value: '${_startedTopicsItems.length}',
                                subtitle: 'начаты',
                                color: Colors.green,
                                icon: Icons.play_lesson_rounded,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Классы',
                                value: '${Set.from(_startedTopicsItems.map((e) => e.grade)).length}',
                                subtitle: 'активно',
                                color: Colors.amber,
                                icon: Icons.school_rounded,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Список начатых тем
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Начатые темы',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_startedTopicsItems.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            if (_startedTopicsItems.isEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: _buildEmptyState(),
                              )
                            else
                              Column(
                                children: [
                                  for (int index = 0; index < _startedTopicsItems.length; index++)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: index < _startedTopicsItems.length - 1 ? 12 : 0),
                                      child: _buildTopicCard(
                                        item: _startedTopicsItems[index],
                                        subjectColor: _getSubjectColor(_startedTopicsItems[index].subject),
                                        questionText: _getQuestionText(_startedTopicsItems[index].question),
                                        isDark: isDark,
                                      ),
                                    ),
                                ],
                              ),
                          ],
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard({
    required ReviewItem item,
    required Color subjectColor,
    required String questionText,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? theme.cardColor : Colors.white,
        border: Border.all(
          color: subjectColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openTopic(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка предмета
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(item.subject),
                    color: subjectColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),

                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.topic.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        questionText,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: subjectColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.subject,
                              style: TextStyle(
                                fontSize: 11,
                                color: subjectColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.grade} класс',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Стрелка
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.hintColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_lesson_rounded,
            color: primaryColor,
            size: 48,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Пока нет начатых тем',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          'Начните изучать темы, и они появятся здесь для повторения',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.hintColor,
          ),
        ),
        SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            widget.onBottomNavTap(0);
          },
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Начать изучение',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}