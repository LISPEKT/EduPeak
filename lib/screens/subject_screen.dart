import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../data/subjects_data.dart';
import '../models/topic.dart';
import 'topic_popup.dart';
import '../localization.dart';
import '../data/user_data_storage.dart';

class SubjectScreen extends StatefulWidget {
  final String subjectName;
  final int grade;

  const SubjectScreen({
    Key? key,
    required this.subjectName,
    required this.grade,
  }) : super(key: key);

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  String _searchQuery = '';
  final Map<String, bool> _expandedChapters = {};
  final ScrollController _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _topicStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadTopicStatuses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  IconData _getSubjectIcon() {
    final icons = {
      'Математика': Icons.calculate_rounded,
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

  // В subject_screen.dart нужно исправить метод _loadTopicStatuses
  Future<void> _loadTopicStatuses() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final newStatuses = <String, Map<String, dynamic>>{};

      final subjectsData = getSubjectsByGrade(context);
      final subjects = subjectsData[widget.grade] ?? [];

      for (final subject in subjects) {
        if (subject.name == widget.subjectName) {
          final topics = subject.topicsByGrade[widget.grade] ?? [];

          for (final topic in topics) {
            // Используем getTopicProgress вместо поиска по Map
            final topicProgress = stats.getTopicProgress(topic.id);
            final totalQuestions = topic.questions.length;
            final isCompleted = totalQuestions > 0 && topicProgress >= totalQuestions;

            // Вычисляем процент выполнения
            final percentage = totalQuestions > 0 ? topicProgress / totalQuestions : 0;

            newStatuses[topic.id] = {
              'isCompleted': isCompleted,
              'correctAnswers': topicProgress,
              'totalQuestions': totalQuestions,
              'percentage': percentage,
              'isStarted': topicProgress > 0,
            };
          }
          break;
        }
      }

      if (mounted) {
        setState(() {
          _topicStatuses.clear();
          _topicStatuses.addAll(newStatuses);
        });
      }
    } catch (e) {
      print('❌ Error loading topic statuses: $e');
    }
  }

  List<Topic> get _filteredTopics {
    final subjectsData = getSubjectsByGrade(context);
    final subjects = subjectsData[widget.grade] ?? [];

    for (final subject in subjects) {
      if (subject.name == widget.subjectName) {
        final topics = subject.topicsByGrade[widget.grade] ?? [];

        if (_searchQuery.isNotEmpty) {
          return topics.where((topic) {
            return topic.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                topic.description.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        return topics;
      }
    }

    return [];
  }

  Map<String, List<Topic>> get _topicsByChapter {
    final Map<String, List<Topic>> chapters = {};

    for (final topic in _filteredTopics) {
      final chapter = topic.paragraph.isNotEmpty ? topic.paragraph : 'Без главы';
      if (!chapters.containsKey(chapter)) {
        chapters[chapter] = [];
      }
      chapters[chapter]!.add(topic);
    }

    return chapters;
  }

  void _showTopicPopup(Topic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicPopup(
        topic: topic,
        currentGrade: widget.grade,
        currentSubject: widget.subjectName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _topicsByChapter;
    final subjectIcon = _getSubjectIcon();
    final backgroundColor = Theme.of(context).colorScheme.background;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 1,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                subjectIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subjectName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${widget.grade} класс',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Список глав (с отступом сверху для плашки поиска)
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapterTitle = chapters.keys.toList()[index];
                final topics = chapters[chapterTitle]!;
                final isExpanded = _expandedChapters[chapterTitle] ?? true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChapterSection(
                    title: chapterTitle,
                    topics: topics,
                    isExpanded: isExpanded,
                    onToggle: () {
                      setState(() {
                        _expandedChapters[chapterTitle] = !isExpanded;
                      });
                    },
                    onTopicTap: _showTopicPopup,
                    topicStatuses: _topicStatuses,
                  ),
                );
              },
            ),
          ),

          // Фиксированная верхняя часть с поиском
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Плашка поиска
                Container(
                  padding: const EdgeInsets.all(20),
                  color: surfaceColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _expandedChapters.clear();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Поиск тем...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 15,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            size: 22,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: surfaceVariant.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Градиент за счет уменьшения прозрачности серого цвета
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        surfaceColor.withOpacity(1.0),
                        surfaceColor.withOpacity(0.8),
                        surfaceColor.withOpacity(0.6),
                        surfaceColor.withOpacity(0.4),
                        surfaceColor.withOpacity(0.2),
                        surfaceColor.withOpacity(0.1),
                        surfaceColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Виджет главы с темами
class _ChapterSection extends StatelessWidget {
  final String title;
  final List<Topic> topics;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(Topic) onTopicTap;
  final Map<String, Map<String, dynamic>> topicStatuses;

  const _ChapterSection({
    required this.title,
    required this.topics,
    required this.isExpanded,
    required this.onToggle,
    required this.onTopicTap,
    required this.topicStatuses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок главы
          ListTile(
            onTap: onToggle,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.bookmark_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${topics.length} тем',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),

          // Темы в главе
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: topics.map((topic) {
                  final status = topicStatuses[topic.id] ?? {
                    'isCompleted': false,
                    'correctAnswers': 0,
                    'totalQuestions': topic.questions.length,
                  };

                  return _TopicItem(
                    topic: topic,
                    onTap: () => onTopicTap(topic),
                    isCompleted: status['isCompleted'] ?? false,
                    correctAnswers: status['correctAnswers'] ?? 0,
                    totalQuestions: status['totalQuestions'] ?? topic.questions.length,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Виджет темы
// Виджет темы
class _TopicItem extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;
  final bool isCompleted;
  final int correctAnswers;
  final int totalQuestions;

  const _TopicItem({
    required this.topic,
    required this.onTap,
    this.isCompleted = false,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
  });

  // Метод для определения цвета плашки в зависимости от процента правильных ответов
  Color _getProgressColor(BuildContext context, double percentage) {
    if (percentage >= 1.0) return Colors.green; // 100%
    if (percentage >= 0.8) return Colors.lightGreen; // 80-99%
    if (percentage >= 0.6) return Colors.orange; // 60-79%
    if (percentage >= 0.4) return Colors.amber; // 40-59%
    if (percentage > 0.0) return Colors.blue; // 1-39%
    return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3); // 0%
  }

  // Метод для определения цвета текста в зависимости от цвета фона
  Color _getTextColor(Color backgroundColor) {
    // Если цвет светлый, используем темный текст, иначе светлый
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
    final progressColor = _getProgressColor(context, percentage);
    final textColor = _getTextColor(progressColor);
    final hasProgress = correctAnswers > 0;
    final isFullyCompleted = isCompleted && percentage >= 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: hasProgress
          ? progressColor.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasProgress
              ? progressColor.withOpacity(0.3)
              : Colors.transparent,
          width: hasProgress ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка темы
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasProgress
                      ? progressColor.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasProgress
                        ? progressColor.withOpacity(0.4)
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    topic.imageAsset,
                    style: TextStyle(
                      fontSize: 20,
                      color: hasProgress
                          ? progressColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: progressColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$correctAnswers/$totalQuestions',
                              style: TextStyle(
                                fontSize: 12,
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      topic.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Галочка в кружке (только при 100% прохождении) или стрелочка
              if (isFullyCompleted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: hasProgress
                      ? progressColor
                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}