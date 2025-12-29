import 'package:flutter/material.dart';
import '../data/subjects_data.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import 'subject_screen.dart';

class SubjectInfoScreen extends StatefulWidget {
  final String subjectName;

  const SubjectInfoScreen({Key? key, required this.subjectName}) : super(key: key);

  @override
  State<SubjectInfoScreen> createState() => _SubjectInfoScreenState();
}

class _SubjectInfoScreenState extends State<SubjectInfoScreen> {
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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      if (mounted) {
        setState(() {
          _userStats = stats;
        });
      }
    } catch (e) {
      print('❌ Error loading user stats: $e');
    }
  }

  List<int> _getGradesForSubject() {
    final grades = <int>{};
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) {
        if (subject.name == widget.subjectName) {
          grades.add(grade);
        }
      }
    }
    return grades.toList()..sort();
  }

  int _getTotalTopicsForSubject() {
    int totalTopics = 0;
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) {
        if (subject.name == widget.subjectName) {
          totalTopics += subject.topicsByGrade[grade]?.length ?? 0;
        }
      }
    }
    return totalTopics;
  }

  int _getCompletedTopics() {
    return _userStats.topicProgress[widget.subjectName]?.length ?? 0;
  }

  double _calculateProgress() {
    final totalTopics = _getTotalTopicsForSubject();
    final completedTopics = _getCompletedTopics();
    return totalTopics > 0 ? completedTopics / totalTopics : 0.0;
  }

  Color _getSubjectColor() {
    final colors = {
      'Математика': Color(0xFF4285F4), // Синий Google
      'Алгебра': Color(0xFF2196F3), // Голубой
      'Геометрия': Color(0xFF3F51B5), // Индиго
      'Русский язык': Color(0xFFEA4335), // Красный Google
      'Литература': Color(0xFFFBBC05), // Желтый Google
      'История': Color(0xFF34A853), // Зеленый Google
      'Обществознание': Color(0xFF8E44AD), // Фиолетовый
      'География': Color(0xFF00BCD4), // Бирюзовый
      'Биология': Color(0xFF4CAF50), // Зеленый
      'Физика': Color(0xFF9C27B0), // Пурпурный
      'Химия': Color(0xFFFF9800), // Оранжевый
      'Английский язык': Color(0xFFE91E63), // Розовый
    };
    return colors[widget.subjectName] ?? Color(0xFF9E9E9E); // Серый
  }

  IconData _getSubjectIcon() {
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
    return icons[widget.subjectName] ?? Icons.subject_rounded;
  }

  void _openSubjectScreen(int grade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectScreen(
          subjectName: widget.subjectName,
          grade: grade,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = _calculateProgress();
    final completedPercent = (progress * 100).round();
    final subjectColor = _getSubjectColor();
    final grades = _getGradesForSubject();
    final totalTopics = _getTotalTopicsForSubject();
    final completedTopics = _getCompletedTopics();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              subjectColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              subjectColor.withOpacity(0.08),
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
              // Верхняя панель с заголовком
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Кнопка назад
                    Container(
                      width: 44,
                      height: 44,
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
                        icon: Icon(Icons.arrow_back_rounded),
                        color: subjectColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Предмет',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            widget.subjectName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основная информация о предмете
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                      // Иконка предмета
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getSubjectIcon(),
                          color: subjectColor,
                          size: 36,
                        ),
                      ),
                      SizedBox(width: 20),

                      // Информация
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Прогресс',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.hintColor,
                                  ),
                                ),
                                Text(
                                  '$completedPercent%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: subjectColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                              color: subjectColor,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 10,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$completedTopics/$totalTopics тем завершено',
                              style: TextStyle(
                                fontSize: 12,
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

              // Статистика
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        title: 'Тем',
                        value: '$totalTopics',
                        subtitle: 'всего',
                        color: subjectColor,
                        icon: Icons.library_books_rounded,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Завершено',
                        value: '$completedTopics',
                        subtitle: 'тем',
                        color: Colors.green,
                        icon: Icons.check_circle_rounded,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Классов',
                        value: '${grades.length}',
                        subtitle: 'доступно',
                        color: Colors.amber,
                        icon: Icons.school_rounded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Доступные классы
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Доступные классы',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${grades.length} класса',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subjectColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Горизонтальный список классов с затемнениями
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    height: 200, // Увеличил высоту для избежания переполнения
                    child: Stack(
                      children: [
                        // Горизонтальный список классов
                        ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: grades.length,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final grade = grades[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: _buildOriginalGradeCard(grade, subjectColor, isDark: isDark),
                            );
                          },
                        ),

                        // Затемнение слева
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(1.0),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.8),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.6),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.4),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.2),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.1),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                stops: [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                              ),
                            ),
                          ),
                        ),

                        // Затемнение справа
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(1.0),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.8),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.6),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.4),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.2),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.1),
                                  (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                stops: [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Информация о классах
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: subjectColor,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Информация о классах',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Каждый класс содержит уникальный набор тем, соответствующий школьной программе.',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
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

  Widget _buildOriginalGradeCard(int grade, Color subjectColor, {required bool isDark}) {
    final theme = Theme.of(context);
    final isHighGrade = grade >= 9;
    final icon = isHighGrade ? Icons.auto_stories_rounded : Icons.school_rounded;
    final subtitle = isHighGrade ? 'Старшая школа' : 'Средняя школа';

    return Container(
      width: 140,
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
          onTap: () => _openSubjectScreen(grade),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Верхняя часть с номером класса
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$grade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: subjectColor,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: subjectColor,
                      size: 20,
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Название класса
                Text(
                  '$grade класс',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2),

                // Подзаголовок
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8),

                // Кнопка в одну строку
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Начать',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subjectColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: subjectColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}