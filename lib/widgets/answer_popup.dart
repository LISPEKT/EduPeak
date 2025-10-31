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
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          localizations.reportError,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.reportErrorDescription,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: localizations.reportErrorHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.pleaseEnterErrorMessage),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _sendErrorToTelegram(context, messageController.text.trim());
            },
            child: Text(
              localizations.send,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
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
        backgroundColor: Colors.blue,
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
          ),
        );
      } else {
        throw Exception('Не удалось отправить сообщение');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorReportFailed),
          backgroundColor: Colors.red,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    Color backgroundColor;
    Color accentColor;
    IconData icon;
    String title;

    if (isCorrect) {
      backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
      accentColor = isDark ? const Color(0xFF4CAF50) : Colors.green;
      icon = Icons.check_circle;
      title = localizations.correct;
    } else {
      backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
      accentColor = isDark ? const Color(0xFFF44336) : Colors.red;
      icon = Icons.error;
      title = localizations.incorrect;
    }

    return Container(
      color: Colors.black54,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(icon, color: accentColor, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка сообщить об ошибке - ПЕРЕМЕЩЕНА ВВЕРХ
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _reportError(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_problem, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            localizations.reportError,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Вопрос
                          Text(
                            '${localizations.question}:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.text ?? localizations.questionNotFound,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ответ пользователя
                          Text(
                            '${localizations.yourAnswer}:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              selectedAnswer.isEmpty ? localizations.noAnswer : selectedAnswer,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Правильный ответ (показываем только если ответ неправильный)
                          if (!isCorrect) ...[
                            const SizedBox(height: 16),
                            Text(
                              '${localizations.correctAnswer}:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Text(
                                getCorrectAnswerText(),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],

                          // Объяснение
                          const SizedBox(height: 16),
                          Text(
                            '${localizations.explanation}:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation?.isNotEmpty == true
                                ? question.explanation
                                : localizations.explanationNotFound,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4,
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
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        isLastQuestion ? localizations.finishTest : localizations.continueText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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