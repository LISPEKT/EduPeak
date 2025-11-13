// answer_popup.dart - РЕДИЗАЙН В MD3 + ФИКС СОХРАНЕНИЯ ПРОГРЕССА
import 'package:flutter/material.dart';
import '../localization.dart';
import 'dart:convert';
import 'dart:io';

class AnswerPopup extends StatelessWidget {
  final dynamic question;
  final bool isCorrect;
  final String selectedAnswer;
  final VoidCallback onContinue;
  final bool isLastQuestion;
  final String? subjectName;
  final String? topicName;
  final int questionNumber;

  const AnswerPopup({
    required this.question,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.onContinue,
    required this.isLastQuestion,
    this.subjectName,
    this.topicName,
    required this.questionNumber,
    super.key,
  });

  // Telegram bot credentials
  static const String _botToken = '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4';
  static const String _chatId = '1236849662';

  // Вспомогательные методы для обработки correctIndex
  int _getCorrectIndex(dynamic correctIndex) {
    if (correctIndex is int) {
      return correctIndex;
    } else if (correctIndex is List<int>) {
      return correctIndex.isNotEmpty ? correctIndex[0] : -1;
    } else if (correctIndex is List) {
      return correctIndex.isNotEmpty ? (correctIndex[0] as int) : -1;
    }
    return -1;
  }

  List<int> _getCorrectAnswers(dynamic correctIndex) {
    if (correctIndex is List<int>) {
      return correctIndex;
    } else if (correctIndex is List) {
      return correctIndex.cast<int>();
    } else if (correctIndex is int) {
      return [correctIndex];
    }
    return [];
  }

  // Отправка сообщения об ошибке в Telegram
  Future<void> _reportError(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final TextEditingController messageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        title: Text(
          localizations.reportError,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.reportErrorDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: localizations.reportErrorHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.pleaseEnterErrorMessage),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.fixed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _sendErrorToTelegram(context, messageController.text.trim());
            },
            child: Text(localizations.send),
          ),
        ],
      ),
    );
  }

  Future<void> _sendErrorToTelegram(BuildContext context, String userMessage) async {
    final localizations = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.sendingErrorReport),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    try {
      final message = '''
Сообщение об ошибке в вопросе

Предмет: ${subjectName ?? 'Не указан'}
Тема: ${topicName ?? 'Не указана'}
Номер вопроса: $questionNumber
Вопрос: ${question.text ?? 'Не указан'}

Сообщение пользователя:
$userMessage

Дополнительная информация:
- Правильный ответ: ${_getCorrectAnswerText()}
- Ответ пользователя: $selectedAnswer
- Тип вопроса: ${question.answerType}
- Дата: ${DateTime.now().toString().split(' ')[0]}
      ''';

      final success = await _sendToTelegram(message);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.errorReportSent),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        throw Exception('Не удалось отправить сообщение');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorReportFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<bool> _sendToTelegram(String message) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');

      final httpClient = HttpClient();
      final request = await httpClient.postUrl(url);

      final body = {
        'chat_id': _chatId,
        'text': message,
      };

      final bodyString = body.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write(bodyString);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      httpClient.close();

      final jsonResponse = json.decode(responseBody);
      return jsonResponse['ok'] == true;
    } catch (e) {
      print('Telegram error: $e');
      return false;
    }
  }

  String _getCorrectAnswerText() {
    try {
      if (question.answerType == 'text') {
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return question.options[correctIndex];
      } else if (question.answerType == 'single_choice') {
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return question.options[correctIndex];
      } else if (question.answerType == 'multiple_choice') {
        final correctAnswers = _getCorrectAnswers(question.correctIndex);
        final correctOptions = correctAnswers.map((index) => question.options[index]).toList();
        return correctOptions.join(', ');
      }
      return 'Не найден';
    } catch (e) {
      return 'Ошибка получения';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Логика получения правильного ответа
    String getCorrectAnswerText() {
      try {
        if (question.answerType == 'text') {
          final correctIndex = _getCorrectIndex(question.correctIndex);
          return question.options[correctIndex];
        } else if (question.answerType == 'single_choice') {
          final correctIndex = _getCorrectIndex(question.correctIndex);
          return question.options[correctIndex];
        } else if (question.answerType == 'multiple_choice') {
          final correctAnswers = _getCorrectAnswers(question.correctIndex);
          final correctOptions = correctAnswers.map((index) => question.options[index]).toList();
          return correctOptions.join(', ');
        }
        return localizations.correctAnswerNotFound;
      } catch (e) {
        print('❌ Error getting correct answer: $e');
        print('❌ Correct index type: ${question.correctIndex.runtimeType}');
        print('❌ Correct index value: ${question.correctIndex}');
        return localizations.answerLoadError;
      }
    }

    Color backgroundColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isCorrect
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    IconData icon = isCorrect ? Icons.check_circle_rounded : Icons.error_rounded;
    String title = isCorrect ? localizations.correct : localizations.incorrect;

    return Container(
      color: Theme.of(context).colorScheme.scrim.withOpacity(0.5),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с иконкой
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(icon, color: accentColor, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка сообщить об ошибке
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => _reportError(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_problem_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            localizations.reportError,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Вопрос
                          Text(
                            '${localizations.question}:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              question.text ?? localizations.questionNotFound,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Ответ пользователя
                          Text(
                            '${localizations.yourAnswer}:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              selectedAnswer.isEmpty ? localizations.noAnswer : selectedAnswer,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: accentColor,
                              ),
                            ),
                          ),

                          // Правильный ответ (показываем только если ответ неправильный)
                          if (!isCorrect) ...[
                            const SizedBox(height: 20),
                            Text(
                              '${localizations.correctAnswer}:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                getCorrectAnswerText(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],

                          // Объяснение
                          const SizedBox(height: 20),
                          Text(
                            '${localizations.explanation}:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              question.explanation?.isNotEmpty == true
                                  ? question.explanation
                                  : localizations.explanationNotFound,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Кнопка продолжения
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isLastQuestion ? localizations.finishTest : localizations.continueText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}