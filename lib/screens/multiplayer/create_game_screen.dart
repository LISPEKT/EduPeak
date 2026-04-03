// lib/screens/multiplayer/create_game_screen.dart

import 'package:flutter/material.dart';
import '../../localization.dart';
import '../../services/multiplayer_service.dart';
import 'game_lobby_screen.dart';
import 'topic_selection_screen.dart';

class CreateGameScreen extends StatefulWidget {
  final String gameType;
  final String title;
  final int? defaultMaxPlayers;

  const CreateGameScreen({
    Key? key,
    required this.gameType,
    required this.title,
    this.defaultMaxPlayers,
  }) : super(key: key);

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _multiplayerService = MultiplayerService();
  bool _isLoading = false;
  bool _isLoadingSubjects = true;
  bool _isLoadingGrades = false;
  bool _isLoadingTopics = false;
  String? _errorMessage;

  // Данные с сервера
  List<Map<String, dynamic>> _availableSubjects = [];
  List<int> _availableGrades = [];
  List<Map<String, dynamic>> _availableTopics = [];

  // Настройки игры
  String _selectedSubject = 'mixed';
  int? _selectedGrade;
  String? _selectedTopicId;
  String? _selectedTopicName;
  int _maxPlayers = 2;
  int _questionsCount = 10;
  int _timePerQuestion = 30;

  // Доступное количество вопросов
  int _availableQuestions = 20;
  int _availableTopicQuestions = 0;

  @override
  void initState() {
    super.initState();
    if (widget.defaultMaxPlayers != null) {
      _maxPlayers = widget.defaultMaxPlayers!;
    }
    _loadAvailableSubjects();
  }

  Future<void> _loadAvailableSubjects() async {
    setState(() {
      _isLoadingSubjects = true;
      _errorMessage = null;
    });

    try {
      final response = await _multiplayerService.getAvailableSubjects();

      if (response['success'] == true) {
        setState(() {
          _availableSubjects = List<Map<String, dynamic>>.from(response['subjects']);
          // По умолчанию выбираем первый доступный предмет (обычно mixed)
          if (_availableSubjects.isNotEmpty) {
            _selectedSubject = _availableSubjects[0]['id'];
            _loadAvailableGrades(_selectedSubject);
          }
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Ошибка загрузки предметов';
        });
        // Заглушка на случай ошибки
        _loadFallbackSubjects();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сети: $e';
      });
      _loadFallbackSubjects();
    } finally {
      setState(() {
        _isLoadingSubjects = false;
      });
    }
  }

  void _loadFallbackSubjects() {
    // Заглушка на случай ошибки
    setState(() {
      _availableSubjects = [
        {'id': 'mixed', 'name': 'Микс', 'available': true},
        {'id': 'biology', 'name': 'Биология', 'available': true},
        {'id': 'history', 'name': 'История', 'available': true},
      ];
      _selectedSubject = 'mixed';
      _loadAvailableGrades('mixed');
    });
  }

  Future<void> _loadAvailableGrades(String subject) async {
    if (subject == 'mixed') {
      setState(() {
        _availableGrades = [5, 6, 7, 8, 9, 10, 11];
        _selectedGrade = null;
        _selectedTopicId = null;
        _selectedTopicName = null;
        _availableTopics = [];
      });
      return;
    }

    setState(() {
      _isLoadingGrades = true;
      _selectedTopicId = null;
      _selectedTopicName = null;
      _availableTopics = [];
    });

    try {
      final response = await _multiplayerService.getAvailableGrades(subject);

      if (response['success'] == true) {
        setState(() {
          _availableGrades = List<int>.from(response['grades']);
          if (_availableGrades.isNotEmpty) {
            _selectedGrade = _availableGrades.first;
            _loadAvailableQuestions();
            _loadAvailableTopics();
          }
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки классов: $e');
    } finally {
      setState(() {
        _isLoadingGrades = false;
      });
    }
  }

  Future<void> _loadAvailableTopics() async {
    if (_selectedSubject == 'mixed' || _selectedGrade == null) {
      setState(() {
        _availableTopics = [];
        _selectedTopicId = null;
        _selectedTopicName = null;
      });
      return;
    }

    setState(() {
      _isLoadingTopics = true;
    });

    try {
      final response = await _multiplayerService.getAvailableTopics(
        _selectedSubject,
        _selectedGrade!,
      );

      if (response['success'] == true) {
        setState(() {
          _availableTopics = List<Map<String, dynamic>>.from(response['topics']);
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки тем: $e');
    } finally {
      setState(() {
        _isLoadingTopics = false;
      });
    }
  }

  Future<void> _loadAvailableQuestions() async {
    if (_selectedSubject == 'mixed' || _selectedGrade == null) {
      setState(() {
        _availableQuestions = 20;
        _availableTopicQuestions = 0;
      });
      return;
    }

    try {
      if (_selectedTopicId != null) {
        // Если выбрана конкретная тема
        final count = await _multiplayerService.getTopicQuestionsCount(
          _selectedSubject,
          _selectedGrade!,
          _selectedTopicId!,
        );
        setState(() {
          _availableTopicQuestions = count;
          _availableQuestions = count;
        });
      } else {
        // Если тема не выбрана - все вопросы предмета
        final count = await _multiplayerService.getAvailableQuestionsCount(
          _selectedSubject,
          _selectedGrade!,
        );
        setState(() {
          _availableQuestions = count > 0 ? count : 3;
          _availableTopicQuestions = 0;
        });
      }

      if (_questionsCount > _availableQuestions) {
        _questionsCount = _availableQuestions;
      }
    } catch (e) {
      print('❌ Ошибка загрузки количества вопросов: $e');
    }
  }

  Future<void> _createGame() async {
    if (_selectedSubject != 'mixed' && _selectedGrade == null) {
      _showError('Выберите класс');
      return;
    }

    if (_selectedSubject != 'mixed' && _selectedGrade != null) {
      if (_questionsCount > _availableQuestions) {
        _showError('Доступно только $_availableQuestions вопросов');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final response = await _multiplayerService.createGame(
        gameType: widget.gameType,
        subject: _selectedSubject,
        grade: _selectedSubject != 'mixed' ? _selectedGrade : null,
        topicId: _selectedTopicId,
        maxPlayers: _maxPlayers,
        questionsCount: _questionsCount,
        timePerQuestion: _timePerQuestion,
      );

      if (response['success'] == true) {
        final gameData = response['game'];
        final roomCode = response['room_code'];

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameLobbyScreen(
                gameData: gameData,
                roomCode: roomCode,
              ),
            ),
          );
        }
      } else {
        _showError(response['message'] ?? 'Ошибка создания игры');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildQuestionsSlider(ThemeData theme, Color primaryColor) {
    if (_selectedSubject != 'mixed' && _selectedGrade != null) {
      final maxQuestions = _availableQuestions;
      final divisions = maxQuestions - 3;

      if (maxQuestions <= 3 || divisions <= 0) {
        return Slider(
          value: _questionsCount.toDouble(),
          min: 3,
          max: 3,
          divisions: null,
          activeColor: primaryColor,
          onChanged: _isLoading
              ? null
              : (value) {
            setState(() {
              _questionsCount = 3;
            });
          },
        );
      }

      return Slider(
        value: _questionsCount.toDouble(),
        min: 3,
        max: maxQuestions.toDouble(),
        divisions: divisions,
        activeColor: primaryColor,
        onChanged: _isLoading
            ? null
            : (value) {
          setState(() {
            _questionsCount = value.round();
          });
        },
      );
    } else {
      return Slider(
        value: _questionsCount.toDouble(),
        min: 3,
        max: 20,
        divisions: 17,
        activeColor: primaryColor,
        onChanged: _isLoading
            ? null
            : (value) {
          setState(() {
            _questionsCount = value.round();
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Отладка - печатаем состояние
    print('🎯 _selectedSubject: $_selectedSubject');
    print('🎯 _selectedGrade: $_selectedGrade');
    print('🎯 _availableTopics.length: ${_availableTopics.length}');
    print('🎯 _isLoadingTopics: $_isLoadingTopics');

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
              // Заголовок
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
                            'Создание игры',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
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
                child: _isLoadingSubjects
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadAvailableSubjects,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Предмет
                      _buildSectionCard(
                        title: 'Предмет',
                        child: Column(
                          children: [
                            ..._availableSubjects.map((subject) => _buildRadioOption(
                              value: subject['id'],
                              groupValue: _selectedSubject,
                              title: subject['name'],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubject = value;
                                  _loadAvailableGrades(value);
                                });
                              },
                            )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Класс
                      if (_selectedSubject != 'mixed' && _availableGrades.isNotEmpty)
                        _buildSectionCard(
                          title: 'Класс',
                          child: _isLoadingGrades
                              ? Center(child: CircularProgressIndicator())
                              : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableGrades.map((grade) {
                              final isSelected = _selectedGrade == grade;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGrade = grade;
                                    _selectedTopicId = null;
                                    _selectedTopicName = null;
                                    _loadAvailableQuestions();
                                    _loadAvailableTopics();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withOpacity(0.1)
                                        : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : theme.colorScheme.outline.withOpacity(0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$grade класс',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected
                                          ? primaryColor
                                          : theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Тема - показываем всегда, если есть темы
                      if (_selectedSubject != 'mixed' && _selectedGrade != null)
                        _buildSectionCard(
                          title: 'Тема (необязательно)',
                          subtitle: _selectedTopicId == null
                              ? (_isLoadingTopics
                              ? 'Загрузка тем...'
                              : (_availableTopics.isEmpty
                              ? 'Нет доступных тем'
                              : 'Выберите тему для теста'))
                              : 'Выбрана тема: $_selectedTopicName',
                          child: _isLoadingTopics
                              ? const Center(child: CircularProgressIndicator())
                              : _availableTopics.isEmpty
                              ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: theme.hintColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Для этого предмета и класса нет доступных тем',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Column(
                            children: [
                              // Кнопка выбора темы
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TopicSelectionScreen(
                                        subject: _selectedSubject,
                                        grade: _selectedGrade!,
                                        onTopicSelected: (topic) {
                                          setState(() {
                                            _selectedTopicId = topic['id'];
                                            _selectedTopicName = topic['name'];
                                          });
                                          _loadAvailableQuestions();
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _selectedTopicId != null
                                        ? primaryColor.withOpacity(0.1)
                                        : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _selectedTopicId != null
                                          ? primaryColor
                                          : theme.colorScheme.outline.withOpacity(0.2),
                                      width: _selectedTopicId != null ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selectedTopicId != null
                                            ? Icons.check_circle_rounded
                                            : Icons.topic_rounded,
                                        color: _selectedTopicId != null
                                            ? primaryColor
                                            : theme.hintColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedTopicId != null
                                                  ? 'Тема: $_selectedTopicName'
                                                  : 'Выберите тему',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: _selectedTopicId != null ? FontWeight.w600 : FontWeight.normal,
                                                color: _selectedTopicId != null
                                                    ? primaryColor
                                                    : theme.textTheme.titleMedium?.color,
                                              ),
                                            ),
                                            if (_selectedTopicId != null)
                                              Text(
                                                'Нажмите чтобы изменить',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.hintColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: theme.hintColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Кнопка сброса (если тема выбрана)
                              if (_selectedTopicId != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedTopicId = null;
                                        _selectedTopicName = null;
                                      });
                                      _loadAvailableQuestions();
                                    },
                                    child: Text(
                                      'Сбросить выбор темы',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      if (_selectedSubject != 'mixed' && _selectedGrade != null)
                        const SizedBox(height: 16),

                      // Количество игроков
                      _buildSectionCard(
                        title: 'Количество игроков',
                        subtitle: widget.gameType == 'duel_random' || widget.gameType == 'duel_friend'
                            ? 'В дуэли всегда 2 игрока'
                            : null,
                        child: widget.gameType == 'duel_random' || widget.gameType == 'duel_friend'
                            ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_rounded, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                '2 игрока',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_maxPlayers игроков',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _maxPlayers.toDouble(),
                              min: 2,
                              max: widget.gameType == 'team' ? 6 : 8,
                              divisions: widget.gameType == 'team' ? 4 : 6,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _maxPlayers = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Количество вопросов
                      _buildSectionCard(
                        title: 'Количество вопросов',
                        subtitle: _selectedSubject != 'mixed' && _selectedGrade != null
                            ? (_selectedTopicId != null
                            ? 'Доступно вопросов по теме: $_availableQuestions'
                            : 'Доступно: $_availableQuestions вопросов')
                            : null,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_questionsCount вопросов',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildQuestionsSlider(theme, primaryColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Время на вопрос
                      _buildSectionCard(
                        title: 'Время на вопрос',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_timePerQuestion секунд',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _timePerQuestion.toDouble(),
                              min: 10,
                              max: 60,
                              divisions: 10,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _timePerQuestion = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Кнопка создания
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _createGame,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
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
                              : const Text(
                            'Создать игру',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: theme.hintColor,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String title,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? theme.colorScheme.primary : theme.hintColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}