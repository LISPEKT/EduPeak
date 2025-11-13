import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/review_item.dart';
import '../localization.dart';
import 'topic_popup.dart';
import 'test_review_screen.dart';

class ReviewScreen extends StatefulWidget {
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

      // Собираем все темы, которые пользователь начинал проходить
      for (final grade in subjectsData.keys) {
        final subjects = subjectsData[grade] ?? [];
        for (final subject in subjects) {
          final topics = subject.topicsByGrade[grade] ?? [];
          for (final topic in topics) {
            final topicProgress = stats.topicProgress[subject.name]?[topic.id] ?? 0;

            // Показываем только те темы, которые пользователь начинал проходить
            if (topicProgress > 0) {
              // Добавляем вопросы из начатой темы (ограничиваем количеством)
              final questionsToAdd = topicProgress > 5 ? 5 : topicProgress;
              for (int i = 0; i < questionsToAdd; i++) {
                if (i < topic.questions.length) {
                  startedTopicsItems.add(ReviewItem(
                    question: topic.questions[i],
                    topic: topic,
                    subject: subject.name,
                    grade: grade,
                    questionIndex: i,
                  ));
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

  void _startReviewTest() {
    if (_startedTopicsItems.isEmpty) return;

    // Берем до 10 случайных вопросов из начатых тем
    final testQuestions = _startedTopicsItems.length > 10
        ? _startedTopicsItems.sublist(0, 10)
        : List<ReviewItem>.from(_startedTopicsItems);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestReviewScreen(
          reviewItems: testQuestions,
          testTitle: 'Повторение тем',
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Загружаем темы для повторения...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.review,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Статистика и кнопка запуска теста
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Статистика
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(
                        title: 'Всего вопросов',
                        value: _reviewItems.length,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _StatCard(
                        title: 'Начатые темы',
                        value: _startedTopicsItems.length,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Кнопка повторения
                if (_startedTopicsItems.isNotEmpty)
                  FilledButton(
                    onPressed: _startReviewTest,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Повторить темы (${_startedTopicsItems.length > 10 ? 10 : _startedTopicsItems.length} вопросов)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Начните изучать темы для повторения!',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Список начатых тем
          Expanded(
            child: _startedTopicsItems.isEmpty
                ? _buildEmptyState()
                : _buildQuestionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 24),
          Text(
            'Пока нет начатых тем',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Начните изучать темы, и они появятся здесь для повторения',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // Навигация на главный экран для выбора тем
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Начать изучение'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Начатые темы для повторения:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _startedTopicsItems.length,
            itemBuilder: (context, index) {
              final item = _startedTopicsItems[index];
              return _QuestionCard(
                item: item,
                onTap: () => _openTopic(item),
                questionText: _getQuestionText(item.question),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final ReviewItem item;
  final VoidCallback onTap;
  final String questionText;

  const _QuestionCard({
    required this.item,
    required this.onTap,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${item.subject} • ${item.topic.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}