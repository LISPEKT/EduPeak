import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../widgets/answer_popup.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/question.dart';
import '../localization.dart';

class TestScreen extends StatefulWidget {
  final dynamic topic;
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

  @override
  void initState() {
    super.initState();

    print('🎯 TestScreen initialized:');
    print('   Topic: ${widget.topic.name} (ID: ${widget.topic.id})');
    print('   Grade: ${widget.currentGrade}');
    print('   Subject: ${widget.currentSubject}');
    print('   Questions: ${widget.topic.questions.length}');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    final questions = <Question>[];

    for (final originalQuestion in widget.topic.questions) {
      if (originalQuestion.isSingleChoice) {
        final shuffledQuestion = _shuffleQuestionOptions(originalQuestion);
        questions.add(shuffledQuestion);
      } else {
        questions.add(Question(
          text: originalQuestion.text,
          options: List<String>.from(originalQuestion.options),
          correctIndex: originalQuestion.correctIndex,
          explanation: originalQuestion.explanation,
          answerType: originalQuestion.answerType,
        ));
      }
    }

    questions.shuffle();

    setState(() {
      _shuffledQuestions = questions;
    });
  }

  Question _shuffleQuestionOptions(Question originalQuestion) {
    final correctAnswer = originalQuestion.options[originalQuestion.correctIndex];
    final options = List<String>.from(originalQuestion.options);
    options.shuffle();

    final newCorrectIndex = options.indexOf(correctAnswer);

    return Question(
      text: originalQuestion.text,
      options: options,
      correctIndex: newCorrectIndex,
      explanation: originalQuestion.explanation,
      answerType: originalQuestion.answerType,
    );
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
    if (_isSubmitting) return;

    final question = _currentQuestion;
    if (question == null) return;

    // Валидация в зависимости от типа вопроса
    if (question.isTextAnswer && _textAnswer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterAnswer),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (question.isSingleChoice && _selectedAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectAnswer),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (question.isMultipleChoice && _selectedMultipleAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectAtLeastOneAnswer),
          duration: const Duration(seconds: 2),
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
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return _textAnswer.trim().toLowerCase() ==
            question.options[correctIndex].toLowerCase();
      } else if (question.isSingleChoice) {
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return _selectedAnswerIndex == correctIndex;
      } else if (question.isMultipleChoice) {
        final correctAnswers = _getCorrectAnswers(question.correctIndex);
        if (_selectedMultipleAnswers.length != correctAnswers.length) return false;

        _selectedMultipleAnswers.sort();
        final sortedCorrect = List<int>.from(correctAnswers)..sort();

        for (int i = 0; i < _selectedMultipleAnswers.length; i++) {
          if (_selectedMultipleAnswers[i] != sortedCorrect[i]) return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error in _checkAnswerCorrectness: $e');
      print('❌ Question: ${question.text}');
      print('❌ Correct index type: ${question.correctIndex.runtimeType}');
      print('❌ Correct index value: ${question.correctIndex}');
      return false;
    }
  }

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
    _animationController.reset();

    setState(() {
      _showResult = false;
      _selectedAnswerIndex = -1;
      _selectedMultipleAnswers.clear();
      _textAnswer = '';
      _textController.clear(); // Очищаем контроллер
      _currentQuestionIndex++;
    });

    _animationController.forward();

    if (!_hasMoreQuestions) {
      _completeTest();
    }
  }

  void _completeTest() async {
    print('🎯 START _completeTest');
    print('📊 Test results - Correct: $_correctAnswersCount/$totalQuestions');

    try {
      print('1. Starting daily completion update...');
      await UserDataStorage.updateDailyCompletion();
      print('✅ Daily completion updated');

      String subjectName = widget.currentSubject ?? 'История';
      if (subjectName.isEmpty) {
        subjectName = _findSubjectForTopic();
      }

      final topicId = widget.topic.id;

      print('2. Topic info - Subject: $subjectName, Topic ID: $topicId, Topic Name: ${widget.topic.name}');

      print('3. Calling updateTopicProgress...');
      await UserDataStorage.updateTopicProgress(
          subjectName,
          topicId,
          _correctAnswersCount
      );
      print('✅ updateTopicProgress completed');

    } catch (e) {
      print('❌ ERROR in _completeTest: $e');
      print('❌ Stack trace: ${e.toString()}');
    }

    print('🎯 END _completeTest');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
            topic: widget.topic,
            userAnswers: _userAnswers,
            textAnswers: _textAnswers,
            correctAnswersCount: _correctAnswersCount,
            currentGrade: widget.currentGrade,
            currentSubject: widget.currentSubject,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  String _findSubjectForTopic() {
    final subjectsData = getSubjectsByGrade(context);

    for (final grade in subjectsData.keys) {
      final subjects = subjectsData[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        for (final topic in topics) {
          if (topic.id == widget.topic.id) {
            return subject.name;
          }
        }
      }
    }
    return 'История';
  }

  Color _getProgressColor() {
    final percentage = _correctAnswersCount / totalQuestions;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Theme.of(context).primaryColor;
  }

  bool _isAnswerCorrectAtIndex(int questionIndex) {
    final question = _shuffledQuestions[questionIndex];
    final userAnswer = _userAnswers[questionIndex];

    if (userAnswer == null) return false;

    try {
      if (question.isTextAnswer) {
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return (userAnswer as String).trim().toLowerCase() ==
            question.options[correctIndex].toLowerCase();
      } else if (question.isSingleChoice) {
        final correctIndex = _getCorrectIndex(question.correctIndex);
        return (userAnswer as int) == correctIndex;
      } else if (question.isMultipleChoice) {
        final correctAnswers = _getCorrectAnswers(question.correctIndex);
        final userAnswers = (userAnswer as List<int>);

        if (userAnswers.length != correctAnswers.length) return false;

        userAnswers.sort();
        final sortedCorrect = List<int>.from(correctAnswers)..sort();

        for (int i = 0; i < userAnswers.length; i++) {
          if (userAnswers[i] != sortedCorrect[i]) return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error in _isAnswerCorrectAtIndex: $e');
      print('❌ Question: ${question.text}');
      print('❌ Correct index type: ${question.correctIndex.runtimeType}');
      print('❌ Correct index value: ${question.correctIndex}');
      print('❌ User answer type: ${userAnswer.runtimeType}');
      print('❌ User answer value: $userAnswer');
      return false;
    }
  }

  Widget _buildQuestionIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalQuestions, (index) {
        final isActive = index == _currentQuestionIndex;
        final isCompleted = index < _currentQuestionIndex;
        final isCorrect = index < _userAnswers.length ? _isAnswerCorrectAtIndex(index) : false;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? (isCorrect ? Colors.green : Colors.red)
                : (isActive ? Theme.of(context).primaryColor : Colors.grey[300]),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: 3,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
      );
    } else if (question.isSingleChoice) {
      return Column(
        children: List.generate(question.options.length, (index) {
          final isSelected = _selectedAnswerIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _showResult ? null : () {
                setState(() => _selectedAnswerIndex = index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Theme.of(context).cardColor,
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                elevation: isSelected ? 2 : 0,
              ),
              child: Text(
                question.options[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      );
    } else if (question.isMultipleChoice) {
      return Column(
        children: [
          // Подсказка для множественного выбора
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).selectMultipleAnswers,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (index) {
            final isSelected = _selectedMultipleAnswers.contains(index);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: _showResult ? null : () => _toggleMultipleAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.15)
                      : Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  elevation: isSelected ? 2 : 0,
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
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 2,
                        ),
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 15,
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

    if (!_hasMoreQuestions) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
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

    final question = _currentQuestion!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 1,
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
                          backgroundColor: Colors.grey[300],
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${appLocalizations.question} ${_currentQuestionIndex + 1}/$totalQuestions',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
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

                        // Варианты ответов
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
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
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