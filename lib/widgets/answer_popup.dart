import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import '../localization.dart';

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

  String get _botToken => const String.fromEnvironment('TELEGRAM_BOT_TOKEN',
      defaultValue: '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4');

  String get _chatId => const String.fromEnvironment('TELEGRAM_CHAT_ID',
      defaultValue: '1236849662');

  int _getCorrectIndex(dynamic correctIndex) {
    if (correctIndex is int) return correctIndex;
    if (correctIndex is List<int>) return correctIndex.isNotEmpty ? correctIndex[0] : -1;
    if (correctIndex is List) {
      return correctIndex.isNotEmpty ? (correctIndex[0] as int) : -1;
    }
    return -1;
  }

  List<int> _getCorrectAnswers(dynamic correctIndex) {
    if (correctIndex is List<int>) return correctIndex;
    if (correctIndex is List) return correctIndex.cast<int>();
    if (correctIndex is int) return [correctIndex];
    return [];
  }

  Future<void> _reportError(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  Icons.report_problem_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                localizations.reportError,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                localizations.reportErrorDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: localizations.reportErrorHint,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        foregroundColor: theme.textTheme.titleMedium?.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.pleaseEnterErrorMessage),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        await _sendErrorToTelegram(context, text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        localizations.send,
                        style: TextStyle(
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

  Future<void> _sendErrorToTelegram(BuildContext context, String userMessage) async {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.sendingErrorReport),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    try {
      final msg = '''
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
      final ok = await _sendToTelegram(msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? localizations.errorReportSent : localizations.errorReportFailed),
          backgroundColor: ok ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorReportFailed),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<bool> _sendToTelegram(String message) async {
    if (_botToken.isEmpty || _chatId.isEmpty) return false;
    try {
      final dio = Dio();
      final resp = await dio.post(
        'https://api.telegram.org/bot$_botToken/sendMessage',
        data: {'chat_id': _chatId, 'text': message},
      );
      return resp.statusCode == 200;
    } catch (_) {
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
        final correctOptions = correctAnswers.map((i) => question.options[i]).toList();
        return correctOptions.join(', ');
      }
      return 'Не найден';
    } catch (_) {
      return 'Ошибка получения';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final accentColor = isCorrect ? Color(0xFF34A853) : Color(0xFFEA4335);
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.error_rounded;
    final title = isCorrect ? localizations.correct : localizations.incorrect;

    return Container(
      color: theme.colorScheme.scrim.withOpacity(0.7),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5, // Половина экрана
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(icon, color: accentColor, size: 30),
                    ),
                    SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Вопрос
                      Text(
                        '${localizations.question}:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.text ?? localizations.questionNotFound,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Ваш ответ
                      Text(
                        '${localizations.yourAnswer}:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          selectedAnswer.isEmpty ? localizations.noAnswer : selectedAnswer,
                          style: TextStyle(
                            fontSize: 14,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),

                      if (!isCorrect) ...[
                        SizedBox(height: 16),
                        Text(
                          '${localizations.correctAnswer}:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF34A853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF34A853).withOpacity(0.3)),
                          ),
                          child: Text(
                            _getCorrectAnswerText(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF34A853),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 16),
                      Text(
                        '${localizations.explanation}:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.explanation?.isNotEmpty == true
                              ? question.explanation
                              : localizations.explanationNotFound,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Кнопка сообщить об ошибке
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _reportError(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? theme.cardColor : Colors.white,
                            foregroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          icon: Icon(Icons.report_problem_rounded, size: 18),
                          label: Text(
                            'Сообщить об ошибке',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Кнопка продолжить
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shadowColor: Colors.transparent,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}