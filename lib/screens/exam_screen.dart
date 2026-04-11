import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/exam_service.dart';
import 'exam_result_screen.dart';

class ExamScreen extends StatefulWidget {
  final Map<String, dynamic> variant;
  final Map<String, dynamic> examSubject;

  const ExamScreen({Key? key, required this.variant, required this.examSubject}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _examService = ExamService();

  int? _attemptId;
  List<Map<String, dynamic>> _questions = [];
  Map<int, String?> _userAnswers = {};  // questionId -> answer
  Map<int, bool> _skippedMap = {};
  Map<int, List<bool>> _multiAnswers = {}; // для multiple_choice

  int _currentIndex = 0;
  int _timeLeft = 0;
  int _totalTime = 0;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFinishing = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadAttempt() async {
    final response = await _examService.startAttempt(widget.variant['id']);
    if (response['success'] == true && mounted) {
      final data = response['data'] as Map<String, dynamic>;
      final questions = List<Map<String, dynamic>>.from(data['questions']);
      final savedAnswers = data['saved_answers'] as Map<String, dynamic>? ?? {};
      final timeMinutes = data['time_minutes'] as int;

      // Восстанавливаем сохранённые ответы
      final answerMap = <int, String?>{};
      final skipMap = <int, bool>{};
      savedAnswers.forEach((qId, ans) {
        final id = int.tryParse(qId) ?? 0;
        answerMap[id] = ans['user_answer'];
        skipMap[id] = ans['is_skipped'] == true;
      });

      setState(() {
        _attemptId = data['attempt_id'];
        _questions = questions;
        _userAnswers = answerMap;
        _skippedMap = skipMap;
        _totalTime = timeMinutes * 60;
        _timeLeft = timeMinutes * 60;
        _isLoading = false;
      });

      _startTimer();
      _syncTextController();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          t.cancel();
          _finishExam();
        }
      });
    });
  }

  void _syncTextController() {
    if (_questions.isEmpty) return;
    final q = _questions[_currentIndex];
    final qId = q['id'] as int;
    final at = q['answer_type'] as String;
    if (at == 'short_answer' || at == 'essay') {
      _textController.text = _userAnswers[qId] ?? '';
    }
  }

  void _goTo(int index) {
    _saveCurrentAnswer();
    setState(() => _currentIndex = index);
    _syncTextController();
  }

  void _saveCurrentAnswer() {
    if (_questions.isEmpty) return;
    final q = _questions[_currentIndex];
    final qId = q['id'] as int;
    final at = q['answer_type'] as String;

    if (at == 'short_answer' || at == 'essay') {
      final text = _textController.text.trim();
      _userAnswers[qId] = text.isEmpty ? null : text;
    }
    // single_choice и multiple_choice обновляются сразу при нажатии
  }

  void _autoSave(int questionId, String? answer, bool isSkipped) {
    if (_attemptId == null) return;
    _examService.saveAnswer(_attemptId!, questionId, userAnswer: answer, isSkipped: isSkipped);
  }

  Future<void> _finishExam() async {
    if (_isFinishing || _attemptId == null) return;
    _saveCurrentAnswer();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Завершить экзамен?'),
        content: Text('Отвечено: ${_answeredCount}/${_questions.length}\nПропущено: ${_skippedCount}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Продолжить')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Завершить')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isFinishing = true);
    _timer?.cancel();

    final timeSpent = _totalTime - _timeLeft;
    final answers = _questions.map((q) {
      final qId = q['id'] as int;
      return {
        'question_id': qId,
        'user_answer': _userAnswers[qId],
        'is_skipped': _skippedMap[qId] ?? false,
      };
    }).toList();

    final response = await _examService.finishAttempt(_attemptId!, timeSpent, answers);

    if (response['success'] == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            resultData: response['data'] as Map<String, dynamic>,
            examSubject: widget.examSubject,
            variantNumber: widget.variant['variant_number'],
          ),
        ),
      );
    } else {
      setState(() => _isFinishing = false);
    }
  }

  int get _answeredCount => _questions.where((q) {
    final qId = q['id'] as int;
    return (_userAnswers[qId] != null && _userAnswers[qId]!.isNotEmpty) && _skippedMap[qId] != true;
  }).length;

  int get _skippedCount => _skippedMap.values.where((v) => v).length;

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    final ratio = _timeLeft / (_totalTime > 0 ? _totalTime : 1);
    if (ratio < 0.1) return Colors.red;
    if (ratio < 0.25) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final examType = widget.examSubject['exam_type'] as String;
    final accentColor = examType == 'ege' ? const Color(0xFF8B2FC9) : const Color(0xFF1565C0);

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: accentColor)));
    }

    final q = _questions[_currentIndex];
    final qId = q['id'] as int;
    final answerType = q['answer_type'] as String;
    final part = q['part'] as int;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? theme.cardColor : Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.red,
                      onPressed: () async {
                        final exit = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Выйти из экзамена?'),
                            content: const Text('Прогресс будет сохранён. Вы сможете вернуться позже.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Остаться')),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Выйти'),
                              ),
                            ],
                          ),
                        );
                        if (exit == true && mounted) Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Задание ${_currentIndex + 1} / ${_questions.length}  •  Часть $part',
                        style: TextStyle(fontSize: 14, color: theme.hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getTimerColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getTimerColor()),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_rounded, size: 14, color: _getTimerColor()),
                          const SizedBox(width: 4),
                          Text(_formatTime(_timeLeft), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getTimerColor())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                color: accentColor,
                backgroundColor: accentColor.withOpacity(0.1),
                minHeight: 3,
              ),

              // Question navigator
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _questions.length,
                  itemBuilder: (ctx, i) {
                    final qi = _questions[i]['id'] as int;
                    final isAnswered = _userAnswers[qi] != null && _userAnswers[qi]!.isNotEmpty && _skippedMap[qi] != true;
                    final isSkipped = _skippedMap[qi] == true;
                    final isCurrent = i == _currentIndex;

                    Color bg;
                    if (isCurrent) bg = accentColor;
                    else if (isSkipped) bg = Colors.orange.withOpacity(0.2);
                    else if (isAnswered) bg = Colors.green.withOpacity(0.2);
                    else bg = theme.colorScheme.surfaceVariant.withOpacity(0.5);

                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: Container(
                        width: 34, height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrent ? Border.all(color: accentColor, width: 2) : null,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Question body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Part badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: part == 1 ? accentColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          part == 1 ? 'Часть 1' : 'Часть 2',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: part == 1 ? accentColor : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Question text
                      Text(q['question_text'] as String, style: TextStyle(fontSize: 16, height: 1.5, color: theme.textTheme.titleMedium?.color)),
                      const SizedBox(height: 20),

                      // Answer input
                      _buildAnswerInput(q, qId, answerType, accentColor, theme, isDark),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    // Пропустить
                    OutlinedButton(
                      onPressed: () {
                        _saveCurrentAnswer();
                        setState(() {
                          _skippedMap[qId] = true;
                          _userAnswers[qId] = null;
                        });
                        _autoSave(qId, null, true);
                        if (_currentIndex < _questions.length - 1) _goTo(_currentIndex + 1);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Пропустить'),
                    ),
                    const SizedBox(width: 12),
                    // Назад / Вперёд
                    if (_currentIndex > 0)
                      IconButton(
                        onPressed: () => _goTo(_currentIndex - 1),
                        icon: Icon(Icons.arrow_back_rounded, color: accentColor),
                      ),
                    const Spacer(),
                    if (_currentIndex < _questions.length - 1)
                      FilledButton(
                        onPressed: () => _goTo(_currentIndex + 1),
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Далее'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _isFinishing ? null : _finishExam,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Завершить'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput(Map<String, dynamic> q, int qId, String answerType, Color accentColor, ThemeData theme, bool isDark) {
    switch (answerType) {
      case 'single_choice':
        final options = List<String>.from(q['options'] ?? []);
        final selected = _userAnswers[qId];
        return Column(
          children: options.asMap().entries.map((e) {
            final isSelected = selected == e.key.toString();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _userAnswers[qId] = e.key.toString();
                  _skippedMap[qId] = false;
                });
                _autoSave(qId, e.key.toString(), false);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.1) : (isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? accentColor : theme.colorScheme.outline.withOpacity(0.2), width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : theme.colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? accentColor : theme.hintColor, width: 1.5),
                      ),
                      child: isSelected ? const Icon(Icons.circle_rounded, size: 14, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.value, style: TextStyle(fontSize: 15, color: theme.textTheme.titleMedium?.color))),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case 'multiple_choice':
        final options = List<String>.from(q['options'] ?? []);
        final selectedStr = _userAnswers[qId] ?? '';
        final selectedIndices = selectedStr.isEmpty ? <int>{} : selectedStr.split(',').map((s) => int.tryParse(s.trim()) ?? -1).toSet();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('Выберите несколько вариантов', style: TextStyle(fontSize: 12, color: Colors.blue)),
            ),
            ...options.asMap().entries.map((e) {
              final isSelected = selectedIndices.contains(e.key);
              return GestureDetector(
                onTap: () {
                  final newSet = Set<int>.from(selectedIndices);
                  if (isSelected) newSet.remove(e.key); else newSet.add(e.key);
                  final ans = newSet.isEmpty ? null : newSet.join(',');
                  setState(() {
                    _userAnswers[qId] = ans;
                    _skippedMap[qId] = false;
                  });
                  _autoSave(qId, ans, false);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor.withOpacity(0.1) : (isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? accentColor : theme.colorScheme.outline.withOpacity(0.2), width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? accentColor : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? accentColor : theme.hintColor, width: 1.5),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value, style: TextStyle(fontSize: 15, color: theme.textTheme.titleMedium?.color))),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      case 'short_answer':
        return TextField(
          controller: _textController,
          onChanged: (val) {
            _userAnswers[qId] = val.trim().isEmpty ? null : val.trim();
            _skippedMap[qId] = false;
          },
          decoration: InputDecoration(
            hintText: 'Введите ответ...',
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 2)),
            contentPadding: const EdgeInsets.all(16),
          ),
        );

      case 'essay':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('Развёрнутый ответ — проверяется вручную', style: TextStyle(fontSize: 12, color: Colors.orange)),
            ),
            TextField(
              controller: _textController,
              maxLines: 8,
              onChanged: (val) {
                _userAnswers[qId] = val.trim().isEmpty ? null : val.trim();
                _skippedMap[qId] = false;
              },
              decoration: InputDecoration(
                hintText: 'Напишите развёрнутый ответ...',
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 2)),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}