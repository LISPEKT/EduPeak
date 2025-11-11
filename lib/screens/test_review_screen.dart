import 'package:flutter/material.dart';
import 'test_screen.dart';
import '../models/topic.dart';
import '../models/question.dart';
import '../models/review_item.dart';

class TestReviewScreen extends StatelessWidget {
  final List<ReviewItem> reviewItems;
  final String testTitle;

  const TestReviewScreen({
    Key? key,
    required this.reviewItems,
    required this.testTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Создаем виртуальную тему из вопросов для повторения
    final virtualTopic = _createVirtualTopic();

    return TestScreen(
      topic: virtualTopic,
      currentGrade: reviewItems.isNotEmpty ? reviewItems.first.grade : null,
      currentSubject: reviewItems.isNotEmpty ? reviewItems.first.subject : 'Повторение',
    );
  }

  Topic _createVirtualTopic() {
    // Создаем виртуальную тему с вопросами для повторения
    final virtualQuestions = <Question>[];

    for (final reviewItem in reviewItems) {
      final originalQuestion = reviewItem.question;

      // Создаем Question из данных вопроса
      final question = Question(
        text: _getQuestionText(originalQuestion),
        options: _getQuestionOptions(originalQuestion),
        correctIndex: _getCorrectAnswerIndex(originalQuestion),
        explanation: _getQuestionExplanation(originalQuestion),
        answerType: _getAnswerType(originalQuestion),
      );

      virtualQuestions.add(question);
    }

    return Topic(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      name: testTitle,
      description: 'Повторение вопросов с ошибками',
      imageAsset: '📚',
      explanation: 'Этот тест содержит вопросы, в которых вы ранее ошиблись. Постарайтесь ответить правильно на все вопросы!',
      questions: virtualQuestions,
    );
  }

  String _getQuestionText(dynamic question) {
    if (question is Map<String, dynamic>) {
      return question['text'] ?? 'Вопрос для повторения';
    } else if (question is Question) {
      return question.text;
    }
    return 'Вопрос для повторения';
  }

  List<String> _getQuestionOptions(dynamic question) {
    if (question is Map<String, dynamic>) {
      return List<String>.from(question['options'] ?? ['Вариант A', 'Вариант B', 'Вариант C', 'Вариант D']);
    } else if (question is Question) {
      return question.options;
    }
    return ['Вариант A', 'Вариант B', 'Вариант C', 'Вариант D'];
  }

  dynamic _getCorrectAnswerIndex(dynamic question) {
    if (question is Map<String, dynamic>) {
      return question['correctAnswerIndex'] ?? 0;
    } else if (question is Question) {
      return question.correctIndex;
    }
    return 0;
  }

  String _getQuestionExplanation(dynamic question) {
    if (question is Map<String, dynamic>) {
      return question['explanation'] ?? 'Объяснение ответа';
    } else if (question is Question) {
      return question.explanation;
    }
    return 'Объяснение ответа';
  }

  String _getAnswerType(dynamic question) {
    if (question is Map<String, dynamic>) {
      return question['answerType'] ?? 'single';
    } else if (question is Question) {
      return question.answerType;
    }
    return 'single';
  }
}