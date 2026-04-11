import 'package:flutter/material.dart';

class ExamResultScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final Map<String, dynamic> examSubject;
  final int variantNumber;

  const ExamResultScreen({
    Key? key,
    required this.resultData,
    required this.examSubject,
    required this.variantNumber,
  }) : super(key: key);

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  bool _showReview = false;

  String _formatTime(int? seconds) {
    if (seconds == null) return '--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}м ${s}с';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final examType = widget.examSubject['exam_type'] as String;
    final accentColor = examType == 'ege' ? const Color(0xFF8B2FC9) : const Color(0xFF1565C0);

    final primaryScore = widget.resultData['primary_score'] as int? ?? 0;
    final testScore = widget.resultData['test_score'] as int?;
    final grade = widget.resultData['grade'] as int?;
    final maxScore = widget.resultData['max_score'] as int? ?? 1;
    final timeSpent = widget.resultData['time_spent'] as int?;
    final questions = List<Map<String, dynamic>>.from(widget.resultData['questions'] ?? []);

    final correctCount = questions.where((q) => q['is_correct'] == true).length;
    final part1 = questions.where((q) => q['part'] == 1).toList();
    final part2 = questions.where((q) => q['part'] == 2).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: accentColor,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(examType.toUpperCase(), style: TextStyle(fontSize: 13, color: accentColor, fontWeight: FontWeight.w600)),
                        Text('Результат • Вариант ${widget.variantNumber}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Score card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          // Круговой прогресс
                          SizedBox(
                            width: 160, height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: primaryScore / maxScore,
                                  strokeWidth: 10,
                                  color: accentColor,
                                  backgroundColor: accentColor.withOpacity(0.1),
                                  strokeCap: StrokeCap.round,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$primaryScore', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: accentColor)),
                                    Text('из $maxScore', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                                    Text('перв. баллов', style: TextStyle(fontSize: 11, color: theme.hintColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Дополнительные баллы
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (testScore != null) ...[
                                _scorePill('$testScore тест. балл', Colors.purple),
                                const SizedBox(width: 10),
                              ],
                              if (grade != null)
                                _scorePill('Оценка: $grade', grade >= 4 ? Colors.green : grade == 3 ? Colors.orange : Colors.red),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Статистика
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statCol(Icons.check_rounded, '$correctCount', 'Верно', Colors.green),
                              _statCol(Icons.close_rounded, '${questions.length - correctCount}', 'Неверно', Colors.red),
                              _statCol(Icons.timer_rounded, _formatTime(timeSpent), 'Время', Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Кнопка разбора
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showReview = !_showReview),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: BorderSide(color: accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(_showReview ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                        label: Text(_showReview ? 'Скрыть разбор' : 'Показать разбор'),
                      ),
                    ),

                    // Разбор ответов
                    if (_showReview) ...[
                      const SizedBox(height: 16),
                      if (part1.isNotEmpty) _buildReviewSection('Часть 1', part1, theme, isDark, accentColor),
                      if (part2.isNotEmpty) _buildReviewSection('Часть 2', part2, theme, isDark, Colors.orange),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('К списку вариантов', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scorePill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _statCol(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Map<String, dynamic>> questions, ThemeData theme, bool isDark, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
        ...questions.map((q) => _buildReviewCard(q, theme, isDark, color)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> q, ThemeData theme, bool isDark, Color accentColor) {
    final isCorrect = q['is_correct'] == true;
    final isEssay = q['answer_type'] == 'essay';
    final isSkipped = q['is_skipped'] == true;

    Color statusColor;
    String statusText;
    if (isSkipped) { statusColor = Colors.grey; statusText = 'Пропущено'; }
    else if (isEssay) { statusColor = Colors.orange; statusText = 'Развёрнутый'; }
    else if (isCorrect) { statusColor = Colors.green; statusText = 'Верно'; }
    else { statusColor = Colors.red; statusText = 'Неверно'; }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('№${q['question_number']}  $statusText', style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text('+${q['score_earned']}/${q['max_score']}', style: TextStyle(fontSize: 12, color: theme.hintColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(q['question_text'] as String, style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color), maxLines: 3, overflow: TextOverflow.ellipsis),
          if (!isSkipped && q['user_answer'] != null) ...[
            const SizedBox(height: 6),
            Text('Ваш ответ: ${q['user_answer']}', style: TextStyle(fontSize: 13, color: isCorrect ? Colors.green : Colors.red)),
          ],
          if (!isCorrect && !isEssay && q['correct_answer'] != null) ...[
            const SizedBox(height: 4),
            Text('Правильно: ${q['correct_answer']}', style: const TextStyle(fontSize: 13, color: Colors.green)),
          ],
          if (q['explanation'] != null && (q['explanation'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(q['explanation'] as String, style: TextStyle(fontSize: 12, color: theme.hintColor, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}