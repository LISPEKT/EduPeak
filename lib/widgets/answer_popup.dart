import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../localization.dart';

class AnswerPopup extends StatefulWidget {
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

  @override
  State<AnswerPopup> createState() => _AnswerPopupState();
}

class _AnswerPopupState extends State<AnswerPopup> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.reportError,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: theme.hintColor),
                    iconSize: 24,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.report_problem_rounded,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations.reportErrorDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 24),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              localizations.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              localizations.send,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
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
Предмет: ${widget.subjectName ?? 'Не указан'}
Тема: ${widget.topicName ?? 'Не указана'}
Номер вопроса: ${widget.questionNumber}
Вопрос: ${widget.question.text ?? 'Не указан'}

Сообщение пользователя:
$userMessage

Дополнительная информация:
- Правильный ответ: ${_getCorrectAnswerText()}
- Ответ пользователя: ${widget.selectedAnswer}
- Тип вопроса: ${widget.question.answerType}
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
      if (widget.question.answerType == 'text') {
        final correctIndex = _getCorrectIndex(widget.question.correctIndex);
        return widget.question.options[correctIndex];
      } else if (widget.question.answerType == 'single_choice') {
        final correctIndex = _getCorrectIndex(widget.question.correctIndex);
        return widget.question.options[correctIndex];
      } else if (widget.question.answerType == 'multiple_choice') {
        final correctAnswers = _getCorrectAnswers(widget.question.correctIndex);
        final correctOptions = correctAnswers.map((i) => widget.question.options[i]).toList();
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
    final accentColor = widget.isCorrect ? const Color(0xFF34A853) : const Color(0xFFEA4335);
    final isSmallScreen = MediaQuery.of(context).size.height < 600;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Плавное затемнение фона
            GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
              ),
            ),
            // Попап с анимацией появления
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок — только текст результата
                    Text(
                      widget.isCorrect ? localizations.correct : localizations.incorrect,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Вопрос
                    Text(
                      '${localizations.question}:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.question.text ?? localizations.questionNotFound,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ваш ответ
                    Text(
                      '${localizations.yourAnswer}:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.selectedAnswer.isEmpty ? localizations.noAnswer : widget.selectedAnswer,
                        style: TextStyle(
                          fontSize: 14,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),

                    if (!widget.isCorrect) ...[
                      const SizedBox(height: 20),
                      Text(
                        '${localizations.correctAnswer}:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34A853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF34A853).withOpacity(0.3)),
                        ),
                        child: Text(
                          _getCorrectAnswerText(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF34A853),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Объяснение
                    Text(
                      '${localizations.explanation}:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.question.explanation?.isNotEmpty == true
                            ? widget.question.explanation
                            : localizations.explanationNotFound,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Кнопка сообщить об ошибке
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _reportError(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.report_problem_rounded, size: 18),
                        label: const Text(
                          'Сообщить об ошибке',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Кнопка продолжить
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isLastQuestion ? localizations.finishTest : localizations.continueText,
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
    );
  }
}