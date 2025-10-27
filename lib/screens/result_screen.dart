import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import '../localization.dart';
import 'xp_screen.dart';
import '../models/user_stats.dart';
import '../data/user_data_storage.dart';

class ResultScreen extends StatelessWidget {
  final dynamic topic;
  final List<int> userAnswers;
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
      } else {
        if (i < userAnswers.length &&
            userAnswers[i] == question.correctIndex) {
          correct++;
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
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final totalQuestions = topic.questions.length;
    final correctCount = correctAnswers;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.testResults),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      topic.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: correctCount / totalQuestions,
                            backgroundColor: Colors.grey[300],
                            color: _getResultColor(correctCount, totalQuestions, context),
                            strokeWidth: 12,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$correctCount/$totalQuestions',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              appLocalizations.correctAnswers,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      _getResultMessage(correctCount, totalQuestions, appLocalizations),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _getResultColor(correctCount, totalQuestions, context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${((correctCount / totalQuestions) * 100).round()}${appLocalizations.percentageCorrect}',
                        style: TextStyle(
                          color: _getResultColor(correctCount, totalQuestions, context),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Переход на экран XP вместо возврата к темам
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => XPScreen(
                              earnedXP: topic.questions.length, // кол-во вопросов = полученный XP
                              questionsCount: topic.questions.length,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        appLocalizations.returnToTopics,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(
                              topic: topic,
                              currentGrade: currentGrade,
                              currentSubject: currentSubject,
                            ),
                          ),
                              (route) => route.isFirst,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      child: Text(
                        appLocalizations.retakeTest,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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