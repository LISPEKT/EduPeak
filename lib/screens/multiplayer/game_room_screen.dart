// lib/screens/multiplayer/game_room_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import '../../localization.dart';
import 'game_result_screen.dart';

class GameRoomScreen extends StatefulWidget {
  final int gameId;
  final Map<String, dynamic> gameData;

  const GameRoomScreen({
    Key? key,
    required this.gameId,
    required this.gameData,
  }) : super(key: key);

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final _multiplayerService = MultiplayerService();
  Timer? _statusTimer;
  Timer? _questionTimer;

  Map<String, dynamic>? _gameStatus;
  Map<String, dynamic>? _currentQuestion;
  List<Map<String, dynamic>> _answers = [];
  List<Map<String, dynamic>> _players = [];

  // Для множественного выбора
  Set<int> _selectedAnswers = {};
  bool _hasAnswered = false;
  bool _isLoading = false;
  int _timeLeft = 0;
  bool _showResults = false;
  int _currentQuestionId = 0;
  bool _isMultipleChoice = false;

  @override
  void initState() {
    super.initState();
    _players = List<Map<String, dynamic>>.from(widget.gameData['players']);
    _startPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _refreshGameStatus();
    });
  }

  Future<void> _refreshGameStatus() async {
    if (!mounted) return;

    final response = await _multiplayerService.getGameStatus(widget.gameId);
    if (response['success'] == true) {
      final newStatus = response;

      setState(() {
        _gameStatus = newStatus;
        _players = List<Map<String, dynamic>>.from(newStatus['game']['players']);

        // Обновляем текущий вопрос
        if (newStatus['current_question'] != null) {
          final newQuestion = newStatus['current_question'];

          // Логируем для отладки
          print('📊 Получен вопрос: ${newQuestion['text']}');
          print('📊 correct_option тип: ${newQuestion['correct_option'].runtimeType}');
          print('📊 correct_option значение: ${newQuestion['correct_option']}');
          print('📊 options: ${newQuestion['options']}');

          // Проверяем, изменился ли вопрос
          if (_currentQuestion == null ||
              _currentQuestion!['id'] != newQuestion['id']) {

            _currentQuestion = newQuestion;
            _currentQuestionId = newQuestion['id'];
            _timeLeft = newQuestion['time_limit'];
            _showResults = false;
            _hasAnswered = false;
            _selectedAnswers.clear();

            // Определяем тип вопроса
            final correctOption = newQuestion['correct_option'];
            _isMultipleChoice = correctOption is List ||
                (correctOption is String && correctOption.contains(','));

            print('📊 _isMultipleChoice: $_isMultipleChoice');

            // Запускаем таймер вопроса
            _startQuestionTimer();
          }
        }

        // Обновляем ответы
        if (newStatus['answers'] != null) {
          _answers = List<Map<String, dynamic>>.from(newStatus['answers']);
        }
      });

      // Проверяем завершение игры
      if (newStatus['game']['status'] == 'finished') {
        _statusTimer?.cancel();
        _questionTimer?.cancel();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameResultsScreen(
                gameId: widget.gameId,
                gameData: widget.gameData,
              ),
            ),
          );
        }
      }
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          // Время вышло, автоматически отправляем ответ
          if (!_hasAnswered) {
            _submitAnswer();
          }
          _showResults = true;
        }
      });
    });
  }

  // Проверка правильности ответа
  // Проверка правильности ответа
  bool _isAnswerCorrect() {
    final correctOption = _currentQuestion!['correct_option'];

    // Определяем правильные ответы
    Set<int> correctAnswers = {};

    if (correctOption is List) {
      correctAnswers = correctOption
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
          .where((e) => e >= 0)
          .toSet();
    } else if (correctOption is int) {
      correctAnswers = {correctOption};
    } else if (correctOption is String && correctOption.contains(',')) {
      correctAnswers = correctOption
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? -1)
          .where((e) => e >= 0)
          .toSet();
    } else {
      final singleCorrect = int.tryParse(correctOption.toString()) ?? 0;
      if (singleCorrect >= 0) {
        correctAnswers = {singleCorrect};
      }
    }

    return _selectedAnswers.length == correctAnswers.length &&
        _selectedAnswers.every((a) => correctAnswers.contains(a));
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswers.isEmpty || _hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _isLoading = true;
    });

    try {
      final timeSpent = _currentQuestion!['time_limit'] - _timeLeft;

      // Для множественного выбора отправляем индексы через запятую
      String selectedOption;
      if (_isMultipleChoice) {
        selectedOption = _selectedAnswers.join(',');
        print('🎯 Множественный выбор: отправляем "$selectedOption"');
      } else {
        selectedOption = _selectedAnswers.first.toString();
        print('🎯 Одиночный выбор: отправляем "$selectedOption"');
      }

      print('📤 Отправка ответа на вопрос ${_currentQuestion!['id']}');
      print('📤 Выбрано: $selectedOption');
      print('📤 Времени затрачено: $timeSpent');

      final response = await _multiplayerService.submitAnswer(
        gameId: widget.gameId,
        questionId: _currentQuestion!['id'],
        selectedOption: selectedOption,
        timeSpent: timeSpent,
      );

      print('📥 Ответ от сервера: $response');

      if (response['success'] == true) {
        print('✅ Ответ отправлен: правильно=${response['is_correct']}, очки=${response['points_earned']}');
      } else {
        print('❌ Ошибка отправки ответа: ${response['message']}');
        setState(() {
          _hasAnswered = false;
        });
      }
    } catch (e) {
      print('❌ Error submitting answer: $e');
      setState(() {
        _hasAnswered = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _showResults = true;
    }
  }

  void _toggleAnswer(int index) {
    if (_hasAnswered || _showResults) return;

    setState(() {
      if (_isMultipleChoice) {
        // Множественный выбор - переключаем
        if (_selectedAnswers.contains(index)) {
          _selectedAnswers.remove(index);
        } else {
          _selectedAnswers.add(index);
        }
      } else {
        // Одиночный выбор - заменяем
        _selectedAnswers.clear();
        _selectedAnswers.add(index);
      }
    });
  }

  Color _getProgressColor() {
    if (_players.isEmpty) return Colors.grey;

    final answeredCount = _answers.length;
    final totalPlayers = _players.length;
    final percentage = answeredCount / totalPlayers;

    if (percentage == 1.0) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_currentQuestion == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Загрузка вопроса...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final sortedPlayers = List<Map<String, dynamic>>.from(_players)
      ..sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
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
                            'Вопрос ${_currentQuestion!['number']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            _currentQuestion!['subject'] ?? 'Предмет',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Таймер
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeLeft < 10 ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _timeLeft < 10 ? Colors.red : primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 16,
                            color: _timeLeft < 10 ? Colors.red : primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_timeLeft с',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _timeLeft < 10 ? Colors.red : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Прогресс ответов
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
                                  'Ответили:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.hintColor,
                                  ),
                                ),
                                Text(
                                  '${_answers.length}/${_players.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getProgressColor(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _answers.length / _players.length,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                              color: _getProgressColor(),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Вопрос
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
                            // Индикатор типа вопроса
                            if (_isMultipleChoice)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_box_rounded, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Выберите несколько вариантов',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            Text(
                              _currentQuestion!['text'],
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 20,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Варианты ответов
                            if (!_showResults)
                              ...List.generate(
                                _currentQuestion!['options'].length,
                                    (index) => _buildAnswerOption(index),
                              )
                            else
                              ...List.generate(
                                _currentQuestion!['options'].length,
                                    (index) => _buildResultOption(index),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Таблица лидеров
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
                            Row(
                              children: [
                                Icon(Icons.leaderboard_rounded, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Таблица лидеров',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...sortedPlayers.take(3).map((player) => _buildLeaderboardRow(player)),
                            if (sortedPlayers.length > 3) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  // TODO: показать полную таблицу
                                },
                                child: Text('Показать всех'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Кнопка ответа
              if (!_hasAnswered && !_showResults)
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
                      onPressed: _selectedAnswers.isNotEmpty && !_isLoading
                          ? _submitAnswer
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _selectedAnswers.isNotEmpty ? primaryColor : theme.disabledColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        _selectedAnswers.isNotEmpty
                            ? (_isMultipleChoice
                            ? 'Ответить (${_selectedAnswers.length} вариантов)'
                            : 'Ответить')
                            : 'Выберите ответ',
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

  Widget _buildAnswerOption(int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedAnswers.contains(index);

    return GestureDetector(
      onTap: _hasAnswered || _showResults ? null : () => _toggleAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Иконка выбора (радио или чекбокс)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                shape: _isMultipleChoice ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: _isMultipleChoice ? BorderRadius.circular(6) : null,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.hintColor,
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
                _currentQuestion!['options'][index],
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

  Widget _buildResultOption(int index) {
    final theme = Theme.of(context);
    final correctOption = _currentQuestion!['correct_option'];

    // Определяем правильные ответы с правильной типизацией
    Set<int> correctAnswers = {};

    if (correctOption is List) {
      // Преобразуем List<dynamic> в Set<int>
      correctAnswers = correctOption
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
          .where((e) => e >= 0)
          .toSet();
    } else if (correctOption is int) {
      correctAnswers = {correctOption};
    } else if (correctOption is String && correctOption.contains(',')) {
      correctAnswers = correctOption
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? -1)
          .where((e) => e >= 0)
          .toSet();
    } else {
      final singleCorrect = int.tryParse(correctOption.toString()) ?? 0;
      if (singleCorrect >= 0) {
        correctAnswers = {singleCorrect};
      }
    }

    final isCorrect = correctAnswers.contains(index);
    final wasSelected = _selectedAnswers.contains(index);

    // Находим ответы на этот вариант
    final answersForOption = _answers.where((a) {
      final selected = a['selected_option'].toString();
      return selected.contains(index.toString()) || selected == index.toString();
    }).toList();
    final answeredBy = answersForOption.map((a) => a['player_name']).join(', ');

    Color borderColor;
    Color bgColor;

    if (isCorrect && wasSelected) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.2);
    } else if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
    } else if (wasSelected) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
    } else {
      borderColor = theme.colorScheme.outline.withOpacity(0.2);
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: wasSelected || isCorrect ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : (wasSelected ? Colors.red : theme.colorScheme.surfaceVariant),
                  shape: _isMultipleChoice ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _isMultipleChoice ? BorderRadius.circular(6) : null,
                ),
                child: Center(
                  child: Icon(
                    isCorrect
                        ? Icons.check_rounded
                        : (wasSelected ? Icons.close_rounded : null),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentQuestion!['options'][index],
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              if (isCorrect)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '✓ Правильно',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          if (answersForOption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                'Ответили: $answeredBy',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> player) {
    final theme = Theme.of(context);
    final isCurrentUser = player['is_current_user'] ?? false;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '${player['score'] ?? 0}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player['name'] ?? 'Игрок',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          if ((player['streak'] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, size: 12, color: Colors.orange),
                  const SizedBox(width: 2),
                  Text(
                    '${player['streak']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}