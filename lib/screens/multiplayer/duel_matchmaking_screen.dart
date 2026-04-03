// lib/screens/multiplayer/duel_matchmaking_screen.dart

import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import '../../localization.dart';
import 'matchmaking_search_screen.dart';

class DuelMatchmakingScreen extends StatefulWidget {
  final String gameType; // 'duel_random' или 'team'

  const DuelMatchmakingScreen({
    Key? key,
    required this.gameType,
  }) : super(key: key);

  @override
  State<DuelMatchmakingScreen> createState() => _DuelMatchmakingScreenState();
}

class _DuelMatchmakingScreenState extends State<DuelMatchmakingScreen> {
  final _multiplayerService = MultiplayerService();
  bool _isLoading = true;
  bool _isLoadingSubjects = true;
  bool _isLoadingGrades = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _availableSubjects = [];
  String _selectedSubject = 'mixed';
  int? _selectedGrade;

  @override
  void initState() {
    super.initState();
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
          if (_availableSubjects.isNotEmpty) {
            _selectedSubject = _availableSubjects[0]['id'];
            _loadAvailableGrades(_selectedSubject);
          }
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Ошибка загрузки предметов';
        });
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
      });
      return;
    }

    setState(() {
      _isLoadingGrades = true;
    });

    try {
      final response = await _multiplayerService.getAvailableGrades(subject);

      if (response['success'] == true) {
        setState(() {
          _availableGrades = List<int>.from(response['grades']);
          if (_availableGrades.isNotEmpty) {
            _selectedGrade = _availableGrades.first;
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

  List<int> _availableGrades = [];

  void _startMatchmaking() {
    if (_selectedSubject != 'mixed' && _selectedGrade == null) {
      _showError('Выберите класс');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchmakingSearchScreen(
          gameType: widget.gameType,
          subject: _selectedSubject,
          grade: _selectedSubject != 'mixed' ? _selectedGrade : null,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

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
                            widget.gameType == 'duel_random' ? 'Дуэль 1x1' : 'Командная 2x2',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Выбор параметров',
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

                      const SizedBox(height: 32),

                      // Кнопка поиска
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _startMatchmaking,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Найти соперника',
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