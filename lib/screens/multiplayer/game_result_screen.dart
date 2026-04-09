// lib/screens/multiplayer/game_results_screen.dart

import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import '../../localization.dart';

class GameResultsScreen extends StatefulWidget {
  final int gameId;
  final Map<String, dynamic> gameData;

  const GameResultsScreen({
    Key? key,
    required this.gameId,
    required this.gameData,
  }) : super(key: key);

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  final _multiplayerService = MultiplayerService();
  Map<String, dynamic>? _results;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _multiplayerService.getGameResults(widget.gameId);

      if (response['success'] == true) {
        setState(() {
          _results = response['results'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Ошибка загрузки результатов';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playAgain() {
    // Возвращаемся на главный экран мультиплеера
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Загрузка результатов...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _goToHome,
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      );
    }

    final winner = _results?['winner'];
    final players = List<Map<String, dynamic>>.from(_results?['players'] ?? []);
    final gameInfo = _results?['game'];

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
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.red,
                        onPressed: _goToHome,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Игра завершена',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Результаты',
                            style: TextStyle(
                              fontSize: 28,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Информация об игре
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
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: theme.hintColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Информация об игре',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Предмет', gameInfo?['subject'] ?? 'Неизвестно'),
                            _buildInfoRow('Класс', '${gameInfo?['grade'] ?? '?'}'),
                            _buildInfoRow('Вопросов', '${gameInfo?['questions_count'] ?? 0}'),
                            _buildInfoRow('Начало', _formatDate(gameInfo?['started_at'])),
                            _buildInfoRow('Завершение', _formatDate(gameInfo?['finished_at'])),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Таблица результатов
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
                          children: [
                            Row(
                              children: [
                                Icon(Icons.leaderboard_rounded, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Таблица результатов',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...players.asMap().entries.map((entry) {
                              final index = entry.key;
                              final player = entry.value;
                              final isWinner = index == 0;
                              return _buildResultRow(
                                index + 1,
                                player,
                                isWinner,
                                theme,
                                primaryColor,
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Кнопки действий
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _goToHome,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(color: theme.dividerColor),
                              ),
                              child: Text(
                                'На главную',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _playAgain,
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Играть снова',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.hintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
      int rank,
      Map<String, dynamic> player,
      bool isWinner,
      ThemeData theme,
      Color primaryColor,
      ) {
    Color rankColor;
    IconData rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events_rounded;
        break;
      case 2:
        rankColor = Colors.grey;
        rankIcon = Icons.military_tech_rounded;
        break;
      case 3:
        rankColor = Colors.brown;
        rankIcon = Icons.military_tech_rounded;
        break;
      default:
        rankColor = theme.hintColor;
        rankIcon = Icons.circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? primaryColor.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: isWinner
            ? Border.all(color: primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Ранг
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(rankIcon, color: rankColor, size: 16)
                  : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Аватар
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${player['score']} очков',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${player['correct_answers']}/${player['total_answers']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Стреак
          if (player['max_streak'] > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 12,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${player['max_streak']}',
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Неизвестно';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Неизвестно';
    }
  }
}