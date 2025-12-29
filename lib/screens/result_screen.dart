// result_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import '../localization.dart';
import 'get_xp_screen.dart';
import '../models/user_stats.dart';
import '../data/user_data_storage.dart';

class ResultScreen extends StatelessWidget {
  final dynamic topic;
  final List<dynamic> userAnswers;
  final List<String> textAnswers;
  final int? correctAnswersCount;
  final int? currentGrade;
  final String? currentSubject;

  const ResultScreen({
    required this.topic,
    required this.userAnswers,
    required this.textAnswers,
    this.correctAnswersCount,
    this.currentGrade,
    this.currentSubject,
    super.key,
  });

  int get correctAnswers {
    if (correctAnswersCount != null) {
      return correctAnswersCount!;
    }

    int correct = 0;
    for (int i = 0; i < topic.questions.length; i++) {
      final question = topic.questions[i];

      if (question.answerType == 'text') {
        if (i < textAnswers.length &&
            textAnswers[i].trim().toLowerCase() ==
                question.options[question.correctIndex].toLowerCase()) {
          correct++;
        }
      } else if (question.answerType == 'single_choice') {
        if (i < userAnswers.length &&
            (userAnswers[i] as int) == question.correctIndex) {
          correct++;
        }
      } else if (question.answerType == 'multiple_choice') {
        if (i < userAnswers.length) {
          final userAnswersList = (userAnswers[i] as List<int>)..sort();
          final correctAnswers = (question.correctIndex as List<int>)..sort();

          if (userAnswersList.length == correctAnswers.length) {
            bool isCorrect = true;
            for (int j = 0; j < userAnswersList.length; j++) {
              if (userAnswersList[j] != correctAnswers[j]) {
                isCorrect = false;
                break;
              }
            }
            if (isCorrect) {
              correct++;
            }
          }
        }
      }
    }
    return correct;
  }

  String _getResultMessage(int correct, int total, AppLocalizations appLocalizations) {
    final percentage = correct / total;
    if (percentage == 1) {
      return appLocalizations.perfectExpert;
    } else if (percentage >= 0.8) {
      return appLocalizations.excellentAlmostAll;
    } else if (percentage >= 0.6) {
      return appLocalizations.goodWorkContinue;
    } else if (percentage >= 0.4) {
      return appLocalizations.notBadRoomToGrow;
    } else {
      return appLocalizations.dontWorryTryAgain;
    }
  }

  Color _getResultColor(int correct, int total, BuildContext context) {
    final percentage = correct / total;
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  void _navigateToXPScreen(BuildContext context) {
    // Используем pushAndRemoveUntil чтобы очистить всю навигационную историю
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => XPScreen(
          earnedXP: topic.questions.length,
          questionsCount: topic.questions.length,
          topicId: topic.id,
          subjectName: currentSubject,
        ),
      ),
          (route) => false, // Удаляем все предыдущие маршруты
    );
  }

  void _retakeTest(BuildContext context) {
    // Возвращаемся к уроку и очищаем навигационную историю
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          topic: topic,
          currentGrade: currentGrade,
          currentSubject: currentSubject,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final totalQuestions = topic.questions.length;
    final correctCount = correctAnswers;
    final percentage = correctCount / totalQuestions;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(appLocalizations.testResults),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Уменьшенный заголовок темы
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              topic.imageAsset,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.name,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                topic.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Основной контент с результатами
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Круговой индикатор прогресса
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: percentage,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            color: _getResultColor(correctCount, totalQuestions, context),
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$correctCount/$totalQuestions',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            Text(
                              appLocalizations.correctAnswers,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Сообщение о результате
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getResultMessage(correctCount, totalQuestions, appLocalizations),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: _getResultColor(correctCount, totalQuestions, context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(percentage * 100).round()}${appLocalizations.percentageCorrect}',
                              style: TextStyle(
                                color: _getResultColor(correctCount, totalQuestions, context),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Кнопки действий
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _navigateToXPScreen(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        appLocalizations.returnToTopics,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => _retakeTest(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        appLocalizations.retakeTest,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}