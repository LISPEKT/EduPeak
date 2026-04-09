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

  final Map<int, List<String>> _shuffledOptions = {};
  final Map<int, List<int>> _correctIndexMap = {};

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

    for (int i = 0; i < questions.length; i++) {
      final originalQuestion = questions[i];

      if (!originalQuestion.isTextAnswer) {
        List<MapEntry<int, String>> optionsWithIndices = [];
        for (int j = 0; j < originalQuestion.options.length; j++) {
          optionsWithIndices.add(MapEntry(j, originalQuestion.options[j]));
        }

        optionsWithIndices.shuffle();
        _shuffledOptions[i] = optionsWithIndices.map((e) => e.value).toList();

        if (originalQuestion.isSingleChoice) {
          final oldCorrectIndex = originalQuestion.correctIndex is List<int>
              ? (originalQuestion.correctIndex as List<int>)[0]
              : originalQuestion.correctIndex as int;

          int newCorrectIndex = -1;
          for (int k = 0; k < optionsWithIndices.length; k++) {
            if (optionsWithIndices[k].key == oldCorrectIndex) {
              newCorrectIndex = k;
              break;
            }
          }
          _correctIndexMap[i] = [newCorrectIndex];
        } else if (originalQuestion.isMultipleChoice) {
          final oldCorrectIndices = originalQuestion.correctIndex as List<int>;
          final List<int> newCorrectIndices = [];

          for (int oldIndex in oldCorrectIndices) {
            for (int k = 0; k < optionsWithIndices.length; k++) {
              if (optionsWithIndices[k].key == oldIndex) {
                newCorrectIndices.add(k);
                break;
              }
            }
          }
          newCorrectIndices.sort();
          _correctIndexMap[i] = newCorrectIndices;
        }
      }
    }

    setState(() {
      _shuffledQuestions = questions;
    });
  }

  List<String> _getShuffledOptionsForQuestion(Question question, int index) {
    if (question.isTextAnswer) return question.options;
    return _shuffledOptions[index] ?? question.options;
  }

  dynamic _getCorrectIndicesForQuestion(int index) {
    if (index < _shuffledQuestions.length) {
      final question = _shuffledQuestions[index];
      if (question.isTextAnswer) return 0;
      return _correctIndexMap[index] ?? question.correctIndex;
    }
    return null;
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

  bool get _isMultipleChoice => _currentQuestion?.isMultipleChoice ?? false;

  bool get _hasSelection {
    final question = _currentQuestion;
    if (question == null) return false;
    if (question.isTextAnswer) return _textAnswer.trim().isNotEmpty;
    if (question.isSingleChoice) return _selectedAnswerIndex != -1;
    if (question.isMultipleChoice) return _selectedMultipleAnswers.isNotEmpty;
    return false;
  }

  void _checkAnswer() {
    if (_isSubmitting || _testCompleted) return;

    final question = _currentQuestion;
    if (question == null) return;

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

          if (isCorrect) _correctAnswersCount++;

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
        final correctIndices = _getCorrectIndicesForQuestion(_currentQuestionIndex);
        final correctIndex = correctIndices is List<int> ? correctIndices[0] : correctIndices as int;
        return _selectedAnswerIndex == correctIndex;
      } else if (question.isMultipleChoice) {
        final correctIndices = _getCorrectIndicesForQuestion(_currentQuestionIndex) as List<int>;
        if (_selectedMultipleAnswers.length != correctIndices.length) return false;

        final userAnswersSorted = List<int>.from(_selectedMultipleAnswers)..sort();
        final correctAnswersSorted = List<int>.from(correctIndices)..sort();

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
      await UserDataStorage.updateDailyCompletion();

      final oldProgress = await UserDataStorage.getTopicProgressById(topicId);
      print('📊 Previous progress: $oldProgress');

      if (_correctAnswersCount > oldProgress) {
        final difference = _correctAnswersCount - oldProgress;
        earnedXP = difference * 10;

        if (_correctAnswersCount == widget.topic.questions.length && oldProgress < widget.topic.questions.length) {
          earnedXP += 100;
        }
      }

      final newProgress = _correctAnswersCount > oldProgress ? _correctAnswersCount : oldProgress;
      await UserDataStorage.saveTopicProgress(subjectName, topicId, newProgress);
      print('✅ Progress saved: $newProgress correct answers (was $oldProgress)');
      print('💰 XP to award: $earnedXP XP');
    } catch (e) {
      print('❌ ERROR in _completeTest: $e');
    }

    print('🎯 END _completeTest');

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

  Color _getProgressColor() {
    if (widget.topic.questions.isEmpty) return Theme.of(context).colorScheme.primary;

    final percentage = _correctAnswersCount / widget.topic.questions.length;
    if (percentage == 1.0) return Colors.green;
    if (percentage >= 0.8) return Colors.lightGreen;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuestionIndicator() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
                ? primaryColor
                : (isActive ? primaryColor : theme.colorScheme.outline.withOpacity(0.3)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildAnswerOption(int index, Question question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final options = _getShuffledOptionsForQuestion(question, _currentQuestionIndex);

    final bool isSelected = question.isSingleChoice
        ? _selectedAnswerIndex == index
        : _selectedMultipleAnswers.contains(index);

    return GestureDetector(
      onTap: _showResult ? null : () {
        if (question.isSingleChoice) {
          setState(() => _selectedAnswerIndex = index);
        } else {
          _toggleMultipleAnswer(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : (isDark
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Иконка радио/чекбокс — как в GameRoomScreen
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : theme.colorScheme.surfaceVariant,
                shape: _isMultipleChoice ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: _isMultipleChoice ? BorderRadius.circular(6) : null,
                border: Border.all(
                  color: isSelected ? primaryColor : theme.hintColor,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                _isMultipleChoice ? Icons.check_rounded : Icons.circle_rounded,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                options[index],
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final options = _getShuffledOptionsForQuestion(question, _currentQuestionIndex);

    if (question.isTextAnswer) {
      return TextField(
        controller: _textController,
        onChanged: (value) => setState(() => _textAnswer = value),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).enterAnswer,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: 3,
        style: theme.textTheme.bodyLarge,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.isMultipleChoice) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_box_rounded, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context).selectMultipleAnswers,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
        ...List.generate(
          options.length,
              (index) => _buildAnswerOption(index, question),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (!_hasMoreQuestions && _testCompleted) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 20),
              Text(appLocalizations.completingTest, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    if (!_hasMoreQuestions) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 20),
              Text('Завершение теста...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    final question = _currentQuestion!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Градиентный фон как в GameRoomScreen
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.15),
                  theme.scaffoldBackgroundColor.withOpacity(0.7),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.3, 0.7],
              )
                  : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.08),
                  Colors.white.withOpacity(0.7),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Кастомная верхняя панель как в GameRoomScreen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: primaryColor,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${appLocalizations.question} ${_currentQuestionIndex + 1}/$totalQuestions',
                              style: TextStyle(fontSize: 14, color: theme.hintColor),
                            ),
                            Text(
                              widget.topic.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Счётчик правильных ответов — аналог таймера в GameRoomScreen
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getProgressColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getProgressColor(), width: 1),
                        ),
                        child: Text(
                          '$_correctAnswersCount/$totalQuestions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getProgressColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Основной контент
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Карточка прогресса — как в GameRoomScreen
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Прогресс теста',
                                    style: TextStyle(fontSize: 14, color: theme.hintColor),
                                  ),
                                  _buildQuestionIndicator(),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: _progressAnimation.value * _progressValue,
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                    color: primaryColor,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Карточка вопроса — как в GameRoomScreen
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.text,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 20,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildAnswerOptions(question),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Закреплённая кнопка снизу — как в GameRoomScreen
                if (!_showResult)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _hasSelection && !_isSubmitting ? _checkAnswer : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: _hasSelection ? primaryColor : theme.disabledColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          _hasSelection
                              ? (_isMultipleChoice
                              ? '${appLocalizations.checkAnswer} (${_selectedMultipleAnswers.length})'
                              : appLocalizations.checkAnswer)
                              : appLocalizations.pleaseSelectAnswer,
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

          // Попап результата (без изменений)
          if (_showResult)
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
      ),
    );
  }

  String _getSelectedAnswerText(Question question) {
    final options = _getShuffledOptionsForQuestion(question, _currentQuestionIndex);

    if (question.isTextAnswer) {
      return _textAnswer.isNotEmpty ? _textAnswer : AppLocalizations.of(context).noAnswerProvided;
    } else if (question.isSingleChoice) {
      return _selectedAnswerIndex >= 0 ? options[_selectedAnswerIndex] : AppLocalizations.of(context).noAnswerSelected;
    } else if (question.isMultipleChoice) {
      if (_selectedMultipleAnswers.isEmpty) return AppLocalizations.of(context).noAnswerSelected;
      final selectedOptions = _selectedMultipleAnswers.map((index) => options[index]).toList();
      return selectedOptions.join(', ');
    }
    return AppLocalizations.of(context).unknownAnswerType;
  }
}