import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../widgets/answer_popup.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/question.dart';
import '../models/topic.dart';
import '../localization.dart';
import 'get_xp_screen.dart';

class TestScreen extends StatefulWidget {
  final Topic topic;
  final int? currentGrade;
  final String? currentSubject;

  const TestScreen({
    required this.topic,
    this.currentGrade,
    this.currentSubject,
    super.key,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  List<int> _selectedMultipleAnswers = [];
  String _textAnswer = '';
  bool _showResult = false;
  bool _isAnswerCorrect = false;
  bool _isSubmitting = false;
  final List<dynamic> _userAnswers = [];
  final List<String> _textAnswers = [];
  int _correctAnswersCount = 0;
  List<Question> _shuffledQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late TextEditingController _textController;
  bool _testCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _textController = TextEditingController();
    _shuffleQuestions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _shuffleQuestions() {
    if (widget.topic.questions.isEmpty) {
      print('⚠️ No questions in topic: ${widget.topic.name}');
      return;
    }

    final questions = List<Question>.from(widget.topic.questions);
    questions.shuffle();

    setState(() {
      _shuffledQuestions = questions;
    });
  }

  Question? get _currentQuestion {
    if (_currentQuestionIndex < _shuffledQuestions.length) {
      return _shuffledQuestions[_currentQuestionIndex];
    }
    return null;
  }

  bool get _hasMoreQuestions => _currentQuestionIndex < _shuffledQuestions.length;
  int get totalQuestions => _shuffledQuestions.length;
  double get _progressValue => _hasMoreQuestions ? (_currentQuestionIndex / totalQuestions) : 1.0;

  void _checkAnswer() {
    if (_isSubmitting || _testCompleted) return;

    final question = _currentQuestion;
    if (question == null) return;

    // Валидация
    if (question.isTextAnswer && _textAnswer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterAnswer),
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (question.isSingleChoice && _selectedAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectAnswer),
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (question.isMultipleChoice && _selectedMultipleAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectAtLeastOneAnswer),
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    bool isCorrect = _checkAnswerCorrectness(question);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnswerCorrect = isCorrect;
          _showResult = true;
          _isSubmitting = false;

          if (isCorrect) {
            _correctAnswersCount++;
          }

          // Сохраняем ответ пользователя
          if (question.isTextAnswer) {
            _userAnswers.add(_textAnswer);
            _textAnswers.add(_textAnswer);
          } else if (question.isSingleChoice) {
            _userAnswers.add(_selectedAnswerIndex);
            _textAnswers.add('');
          } else if (question.isMultipleChoice) {
            _userAnswers.add(List<int>.from(_selectedMultipleAnswers));
            _textAnswers.add('');
          }
        });
      }
    });
  }

  bool _checkAnswerCorrectness(Question question) {
    try {
      if (question.isTextAnswer) {
        return _textAnswer.trim().toLowerCase() == question.options[0].toLowerCase();
      } else if (question.isSingleChoice) {
        final correctIndex = question.correctIndex is List<int>
            ? (question.correctIndex as List<int>)[0]
            : question.correctIndex as int;
        return _selectedAnswerIndex == correctIndex;
      } else if (question.isMultipleChoice) {
        final correctAnswers = question.correctIndex as List<int>;
        if (_selectedMultipleAnswers.length != correctAnswers.length) return false;

        final userAnswersSorted = List<int>.from(_selectedMultipleAnswers)..sort();
        final correctAnswersSorted = List<int>.from(correctAnswers)..sort();

        for (int i = 0; i < userAnswersSorted.length; i++) {
          if (userAnswersSorted[i] != correctAnswersSorted[i]) return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error in _checkAnswerCorrectness: $e');
      return false;
    }
  }

  void _toggleMultipleAnswer(int index) {
    setState(() {
      if (_selectedMultipleAnswers.contains(index)) {
        _selectedMultipleAnswers.remove(index);
      } else {
        _selectedMultipleAnswers.add(index);
      }
    });
  }

  void _nextQuestion() {
    if (_testCompleted) return;

    _animationController.reset();

    setState(() {
      _showResult = false;
      _selectedAnswerIndex = -1;
      _selectedMultipleAnswers.clear();
      _textAnswer = '';
      _textController.clear();
      _currentQuestionIndex++;
    });

    _animationController.forward();

    if (!_hasMoreQuestions) {
      _completeTest();
    }
  }

  // В test_screen.dart добавьте этот метод
  Future<void> _completeTest() async {
    if (_testCompleted) return;

    print('🎯 START _completeTest');
    print('📊 Test results - Correct: $_correctAnswersCount/${widget.topic.questions.length}');

    setState(() {
      _testCompleted = true;
    });

    String subjectName = widget.currentSubject ?? 'Общий';
    final topicId = widget.topic.id;
    int earnedXP = 0;

    try {
      // Обновляем ежедневную активность
      await UserDataStorage.updateDailyCompletion();

      // Получаем предыдущий прогресс
      final oldProgress = await UserDataStorage.getTopicProgressById(topicId);
      print('📊 Previous progress: $oldProgress');

      // Рассчитываем заработанный XP
      if (_correctAnswersCount > oldProgress) {
        final difference = _correctAnswersCount - oldProgress;
        earnedXP = difference * 10; // 10 XP за каждый новый правильный ответ

        // Бонус за 100% прохождение (только если впервые достигли 100%)
        if (_correctAnswersCount == widget.topic.questions.length && oldProgress < widget.topic.questions.length) {
          earnedXP += 100;
        }
      }

      // Сохраняем прогресс - МАКСИМУМ из старого и нового
      final newProgress = _correctAnswersCount > oldProgress ? _correctAnswersCount : oldProgress;
      await UserDataStorage.saveTopicProgress(
        subjectName,
        topicId,
        newProgress,
      );
      print('✅ Progress saved: $newProgress correct answers (was $oldProgress)');
      print('💰 XP to award: $earnedXP XP');

    } catch (e) {
      print('❌ ERROR in _completeTest: $e');
    }

    print('🎯 END _completeTest');

    // Переходим на экран XP с информацией о результатах
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => XPScreen(
            earnedXP: earnedXP,
            questionsCount: _correctAnswersCount,
            topicId: widget.topic.id,
            subjectName: widget.currentSubject,
          ),
        ),
      );
    }
  }

// Метод для расчета XP
  int _calculateEarnedXP(int newProgress, int oldProgress) {
    if (newProgress <= oldProgress) return 0;

    final difference = newProgress - oldProgress;
    int earned = difference * 10; // 10 XP за каждый новый правильный ответ

    // Бонус за 100% прохождение (только если впервые достигли 100%)
    final topic = widget.topic;
    if (newProgress == topic.questions.length && oldProgress < topic.questions.length) {
      earned += 100;
    }

    return earned;
  }

  int _calculateXPEarned(int newProgress, int oldProgress, bool isPerfectScore) {
    if (newProgress <= oldProgress) return 0;

    final difference = newProgress - oldProgress;
    final baseXP = difference * 10;
    final bonusXP = isPerfectScore ? 100 : 0;

    return baseXP + bonusXP;
  }

  Color _getProgressColor() {
    if (widget.topic.questions.isEmpty) return Theme.of(context).colorScheme.primary;

    final percentage = _correctAnswersCount / widget.topic.questions.length;
    if (percentage == 1.0) return Colors.green;
    if (percentage >= 0.8) return Colors.lightGreen;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuestionIndicator() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(totalQuestions, (index) {
        final isActive = index == _currentQuestionIndex;
        final isCompleted = index < _currentQuestionIndex;

        return Container(
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : (isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    if (question.isTextAnswer) {
      return TextField(
        controller: _textController,
        onChanged: (value) => setState(() => _textAnswer = value),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).enterAnswer,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: 3,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    } else if (question.isSingleChoice) {
      return Column(
        children: List.generate(question.options.length, (index) {
          final isSelected = _selectedAnswerIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FilledButton.tonal(
              onPressed: _showResult ? null : () {
                setState(() => _selectedAnswerIndex = index);
              },
              style: FilledButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                question.options[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      );
    } else if (question.isMultipleChoice) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: Theme.of(context).colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).selectMultipleAnswers,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (index) {
            final isSelected = _selectedMultipleAnswers.contains(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.tonal(
                onPressed: _showResult ? null : () => _toggleMultipleAnswer(index),
                style: FilledButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    if (!_hasMoreQuestions && _testCompleted) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                appLocalizations.completingTest,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasMoreQuestions) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Завершение теста...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final question = _currentQuestion!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getProgressColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getProgressColor().withOpacity(0.3)),
            ),
            child: Text(
              '$_correctAnswersCount/$totalQuestions',
              style: TextStyle(
                color: _getProgressColor(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Прогресс бар и индикатор
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value * _progressValue,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          color: _getProgressColor(),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionIndicator(),
                  ],
                ),
                const SizedBox(height: 24),

                // Счетчик вопросов
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${appLocalizations.question} ${_currentQuestionIndex + 1}/$totalQuestions',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Текст вопроса
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.text,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildAnswerOptions(question),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Кнопка ответа
                if (!_showResult) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _checkAnswer,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        appLocalizations.checkAnswer,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Попап с результатом ответа
          if (_showResult) ...[
            AnswerPopup(
              question: question,
              isCorrect: _isAnswerCorrect,
              selectedAnswer: _getSelectedAnswerText(question),
              onContinue: _nextQuestion,
              isLastQuestion: _currentQuestionIndex == _shuffledQuestions.length - 1,
              subjectName: widget.currentSubject,
              topicName: widget.topic.name,
              questionNumber: _currentQuestionIndex + 1,
            ),
          ],
        ],
      ),
    );
  }

  String _getSelectedAnswerText(Question question) {
    if (question.isTextAnswer) {
      return _textAnswer.isNotEmpty ? _textAnswer : AppLocalizations.of(context).noAnswerProvided;
    } else if (question.isSingleChoice) {
      return _selectedAnswerIndex >= 0 ? question.options[_selectedAnswerIndex] : AppLocalizations.of(context).noAnswerSelected;
    } else if (question.isMultipleChoice) {
      if (_selectedMultipleAnswers.isEmpty) return AppLocalizations.of(context).noAnswerSelected;
      final selectedOptions = _selectedMultipleAnswers.map((index) => question.options[index]).toList();
      return selectedOptions.join(', ');
    }
    return AppLocalizations.of(context).unknownAnswerType;
  }
}