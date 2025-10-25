import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../widgets/answer_popup.dart';
import '../data/user_data_storage.dart';
import '../data/subjects_data.dart';
import '../models/question.dart';

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
  String _textAnswer = '';
  bool _showResult = false;
  bool _isAnswerCorrect = false;
  bool _isSubmitting = false;
  final List<int> _userAnswers = [];
  final List<String> _textAnswers = [];
  int _correctAnswersCount = 0;
  List<Question> _shuffledQuestions = []; // Изменен тип на List<Question>
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _shuffleQuestions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _shuffleQuestions() {
    // Создаем глубокую копию вопросов с перемешанными вариантами
    final questions = <Question>[];

    for (final originalQuestion in widget.topic.questions) {
      if (originalQuestion.answerType == 'choice') {
        // Для вопросов с выбором - перемешиваем варианты
        final shuffledQuestion = _shuffleQuestionOptions(originalQuestion);
        questions.add(shuffledQuestion);
      } else {
        // Для текстовых вопросов - просто копируем
        questions.add(Question(
          text: originalQuestion.text,
          options: List<String>.from(originalQuestion.options), // Явное указание типа
          correctIndex: originalQuestion.correctIndex,
          explanation: originalQuestion.explanation,
          answerType: originalQuestion.answerType,
        ));
      }
    }

    // Перемешиваем порядок вопросов
    questions.shuffle();

    setState(() {
      _shuffledQuestions = questions;
    });
  }

  Question _shuffleQuestionOptions(Question originalQuestion) {
    final correctAnswer = originalQuestion.options[originalQuestion.correctIndex];
    final options = List<String>.from(originalQuestion.options); // Явное указание типа
    options.shuffle();

    // Находим новый индекс правильного ответа после перемешивания
    final newCorrectIndex = options.indexOf(correctAnswer);

    // Создаем новый вопрос с перемешанными вариантами
    return Question(
      text: originalQuestion.text,
      options: options, // Теперь options имеет правильный тип List<String>
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

    // Валидация
    if (question.answerType == 'text' && _textAnswer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите ответ'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (question.answerType == 'choice' && _selectedAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите ответ'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Проверка ответа
    bool isCorrect;
    if (question.answerType == 'text') {
      isCorrect = _textAnswer.trim().toLowerCase() ==
          question.options[question.correctIndex].toLowerCase();
    } else {
      isCorrect = _selectedAnswerIndex == question.correctIndex;
    }

    // Анимация проверки
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnswerCorrect = isCorrect;
          _showResult = true;
          _isSubmitting = false;

          if (isCorrect) {
            _correctAnswersCount++;
          }

          // Сохраняем ответ
          if (question.answerType == 'text') {
            _textAnswers.add(_textAnswer);
            _userAnswers.add(-1);
          } else {
            _userAnswers.add(_selectedAnswerIndex);
            _textAnswers.add('');
          }
        });
      }
    });

    print('🎯 Question ${_currentQuestionIndex + 1}: ${isCorrect ? 'CORRECT' : 'WRONG'}');
    print('📊 Correct answers: $_correctAnswersCount/$totalQuestions');
  }

  void _nextQuestion() {
    _animationController.reset();

    setState(() {
      _showResult = false;
      _selectedAnswerIndex = -1;
      _textAnswer = '';
      _currentQuestionIndex++;
    });

    _animationController.forward();

    if (!_hasMoreQuestions) {
      _completeTest();
    }
  }

  void _completeTest() async {
    try {
      await UserDataStorage.updateDailyCompletion();

      final subjectName = _findSubjectForTopic();
      await UserDataStorage.updateTopicProgress(
          subjectName,
          widget.topic.name,
          _correctAnswersCount
      );

      print('✅ PROGRESS SAVED SUCCESSFULLY');
      print('📚 Subject: $subjectName');
      print('📖 Topic: ${widget.topic.name}');
      print('🎯 Correct answers: $_correctAnswersCount/$totalQuestions');

      // Проверяем сохраненный прогресс
      final stats = await UserDataStorage.getUserStats();
      final savedProgress = stats.topicProgress[subjectName]?[widget.topic.name] ?? 0;
      print('💾 Verified saved progress: $savedProgress');

    } catch (e) {
      print('❌ ERROR saving progress: $e');
    }

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
    for (final grade in subjectsByGrade.keys) {
      final subjects = subjectsByGrade[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        for (final topic in topics) {
          if (topic.name == widget.topic.name) {
            return subject.name;
          }
        }
      }
    }
    return _getSubjectNameByTopicName();
  }

  String _getSubjectNameByTopicName() {
    final topicName = widget.topic.name.toLowerCase();
    if (topicName.contains('грамматика') || topicName.contains('орфография') ||
        topicName.contains('синтаксис') || topicName.contains('сложносочин') ||
        topicName.contains('сложноподчин')) {
      return 'Русский язык';
    } else if (topicName.contains('уравнен') || topicName.contains('алгебр') ||
        topicName.contains('математик')) {
      return 'Математика';
    }
    return 'Русский язык';
  }

  Color _getProgressColor() {
    final percentage = _correctAnswersCount / totalQuestions;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Theme.of(context).primaryColor;
  }

  Widget _buildQuestionIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalQuestions, (index) {
        final isActive = index == _currentQuestionIndex;
        final isCompleted = index < _currentQuestionIndex;
        final isCorrect = index < _userAnswers.length ?
        (index < _shuffledQuestions.length &&
            _userAnswers[index] == _shuffledQuestions[index].correctIndex) : false;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_hasMoreQuestions) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
              border: Border.all(
                color: _getProgressColor().withOpacity(0.3),
              ),
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
                    'Вопрос ${_currentQuestionIndex + 1}/$totalQuestions',
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
                        if (question.answerType == 'text') ...[
                          TextField(
                            onChanged: (value) => setState(() => _textAnswer = value),
                            decoration: InputDecoration(
                              hintText: 'Введите ваш ответ...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                            ),
                          ),
                        ] else ...[
                          ...List.generate(question.options.length, (index) {
                            final isSelected = _selectedAnswerIndex == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ElevatedButton(
                                onPressed: _showResult ? null : () {
                                  setState(() {
                                    _selectedAnswerIndex = index;
                                  });
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
                                  shadowColor: Colors.black.withOpacity(0.1),
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
                        ],
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : const Text(
                        'Проверить ответ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
              selectedAnswer: question.answerType == 'text'
                  ? _textAnswer
                  : question.options[_selectedAnswerIndex],
              onContinue: _nextQuestion,
              isLastQuestion: _currentQuestionIndex == _shuffledQuestions.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}