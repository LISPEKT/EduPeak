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

class _SubjectInfoScreenState extends State<SubjectInfoScreen> with SingleTickerProviderStateMixin {
  UserStats? _userStats;
  bool _isLoading = true;
  bool _hasError = false;

  // Кэшированные данные
  List<int> _grades = [];
  int _totalTopics = 0;
  int _completedTopics = 0;
  double _progress = 0.0;

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Статические карты цветов и иконок
  static const Map<String, Color> _subjectColors = {
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
    'Статистика и вероятность': Color(0xFF00BCD4),
    'Информатика': Color(0xFF607D8B),
  };

  static const Map<String, IconData> _subjectIcons = {
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
    'Информатика': Icons.computer_rounded,
    'Статистика и вероятность': Icons.trending_up_rounded,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final stats = await UserDataStorage.getUserStats();
      final subjectData = _calculateSubjectData(stats);

      if (mounted) {
        setState(() {
          _userStats = stats;
          _grades = subjectData.grades;
          _totalTopics = subjectData.totalTopics;
          _completedTopics = subjectData.completedTopics;
          _progress = subjectData.progress;
          _isLoading = false;
        });

        // Анимация прогресса
        _progressAnimation = Tween<double>(begin: 0.0, end: _progress).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  ({List<int> grades, int totalTopics, int completedTopics, double progress})
  _calculateSubjectData(UserStats stats) {
    final grades = <int>{};
    int totalTopics = 0;

    final allSubjects = getSubjectsByGrade(context);

    for (final grade in allSubjects.keys) {
      final subjects = allSubjects[grade] ?? [];
      for (final subject in subjects) {
        if (subject.name == widget.subjectName) {
          grades.add(grade);
          totalTopics += subject.topicsByGrade[grade]?.length ?? 0;
        }
      }
    }

    final completed = stats.topicProgress[widget.subjectName]?.length ?? 0;
    final progressVal = totalTopics > 0 ? completed / totalTopics : 0.0;

    return (
    grades: grades.toList()..sort(),
    totalTopics: totalTopics,
    completedTopics: completed,
    progress: progressVal,
    );
  }

  Color _getSubjectColor() {
    return _subjectColors[widget.subjectName] ?? const Color(0xFF9E9E9E);
  }

  IconData _getSubjectIcon() {
    return _subjectIcons[widget.subjectName] ?? Icons.subject_rounded;
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
    final subjectColor = _getSubjectColor();
    final completedPercent = (_progress * 100).round();

    // Состояние загрузки
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [subjectColor.withOpacity(0.15), theme.scaffoldBackgroundColor]
                  : [subjectColor.withOpacity(0.08), Colors.white],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              subjectColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ]
                : [
              subjectColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
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
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: subjectColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
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

              // Основной контент в скролле
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная информация о предмете
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
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
                              const SizedBox(width: 20),
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
                                    const SizedBox(height: 8),
                                    AnimatedBuilder(
                                      animation: _progressAnimation,
                                      builder: (context, child) {
                                        return LinearProgressIndicator(
                                          value: _progressAnimation.value,
                                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                          color: subjectColor,
                                          borderRadius: BorderRadius.circular(4),
                                          minHeight: 10,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_completedTopics/$_totalTopics тем завершено',
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
                                title: 'Тем',
                                value: '$_totalTopics',
                                subtitle: 'всего',
                                color: subjectColor,
                                icon: Icons.library_books_rounded,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Завершено',
                                value: '$_completedTopics',
                                subtitle: 'тем',
                                color: Colors.green,
                                icon: Icons.check_circle_rounded,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Классов',
                                value: '${_grades.length}',
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
                      if (_grades.isNotEmpty) ...[
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_grades.length} класса',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: _grades.length,
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  itemBuilder: (context, index) {
                                    final grade = _grades[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
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
                                        stops: const [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
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
                                        stops: const [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Пустое состояние
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_off_rounded,
                                  size: 64,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Нет доступных классов',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Для этого предмета пока нет доступных классов',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Информация о классах
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                                  const SizedBox(width: 8),
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
                              const SizedBox(height: 12),
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

                      const SizedBox(height: 20),
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
            offset: const Offset(0, 2),
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
          const SizedBox(height: 8),
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
            offset: const Offset(0, 3),
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      const SizedBox(width: 4),
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