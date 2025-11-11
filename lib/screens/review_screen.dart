import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/review_item.dart'; // Импортируем общий класс
import '../localization.dart';
import 'topic_popup.dart';
import 'test_review_screen.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewItem> _reviewItems = [];
  List<ReviewItem> _incorrectQuestions = [];
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

      List<ReviewItem> allItems = [];
      List<ReviewItem> incorrectItems = [];

      // Анализируем прогресс пользователя для поиска тем с ошибками
      for (final grade in subjectsData.keys) {
        final subjects = subjectsData[grade] ?? [];
        for (final subject in subjects) {
          final topics = subject.topicsByGrade[grade] ?? [];
          for (final topic in topics) {
            final topicProgress = stats.topicProgress[subject.name]?[topic.id] ?? 0;
            final totalQuestions = topic.questions.length;

            // Собираем все вопросы для повторения
            if (topicProgress < totalQuestions && topic.questions.isNotEmpty) {
              for (int i = 0; i < topic.questions.length; i++) {
                final question = topic.questions[i];
                final item = ReviewItem(
                  question: question,
                  topic: topic,
                  subject: subject.name,
                  grade: grade,
                  questionIndex: i,
                );
                allItems.add(item);

                // Вопросы с ошибками - где прогресс меньше индекса вопроса
                if (i >= topicProgress) {
                  incorrectItems.add(item);
                }
              }
            }
          }
        }
      }

      // Перемешиваем вопросы
      allItems.shuffle();
      incorrectItems.shuffle();

      setState(() {
        _reviewItems = allItems;
        _incorrectQuestions = incorrectItems;
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
    if (_incorrectQuestions.isEmpty) return;

    // Берем до 10 случайных неправильных вопросов
    final testQuestions = _incorrectQuestions.length > 10
        ? _incorrectQuestions.sublist(0, 10)
        : List<ReviewItem>.from(_incorrectQuestions);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestReviewScreen(
          reviewItems: testQuestions,
          testTitle: 'Повторение ошибок',
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
        // Для объекта Question используем toString или другие доступные методы
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загружаем вопросы для повторения...'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Повторение'),
      ),
      body: Column(
        children: [
          // Статистика и кнопка запуска теста
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      title: 'Всего вопросов',
                      value: _reviewItems.length,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'С ошибками',
                      value: _incorrectQuestions.length,
                      color: Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_incorrectQuestions.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _startReviewTest,
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Повторить ошибки (${_incorrectQuestions.length > 10 ? 10 : _incorrectQuestions.length} вопросов)',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Все вопросы пройдены правильно!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Список вопросов с ошибками
          Expanded(
            child: _incorrectQuestions.isEmpty
                ? _buildEmptyState()
                : _buildQuestionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Пока нет вопросов с ошибками',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Продолжайте изучать темы, и здесь появятся вопросы, в которых вы ошиблись',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
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
          padding: EdgeInsets.all(16),
          child: Text(
            'Вопросы с ошибками:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _incorrectQuestions.length,
            itemBuilder: (context, index) {
              final item = _incorrectQuestions[index];
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
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange),
          ),
          child: Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          questionText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${item.subject} • ${item.topic.name}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}