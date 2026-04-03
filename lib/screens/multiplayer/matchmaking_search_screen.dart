// lib/screens/multiplayer/matchmaking_search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import 'game_room_screen.dart';
import 'game_lobby_screen.dart';
import 'dart:math';

class MatchmakingSearchScreen extends StatefulWidget {
  final String gameType; // 'duel_random' или 'team'
  final String subject;
  final int? grade;

  const MatchmakingSearchScreen({
    Key? key,
    required this.gameType,
    required this.subject,
    this.grade,
  }) : super(key: key);

  @override
  State<MatchmakingSearchScreen> createState() => _MatchmakingSearchScreenState();
}

class _MatchmakingSearchScreenState extends State<MatchmakingSearchScreen> {
  final _multiplayerService = MultiplayerService();
  Timer? _searchTimer;
  Timer? _statusTimer;
  bool _isSearching = true;
  String? _matchFoundId;
  String? _errorMessage;
  int _searchTime = 0;
  int _playersFound = 0;

  @override
  void initState() {
    super.initState();
    _startSearch();
    _startTimer();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _statusTimer?.cancel();
    if (_matchFoundId == null) {
      _cancelSearch();
    }
    super.dispose();
  }

  void _startTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isSearching) {
        setState(() {
          _searchTime++;
        });
      }
    });
  }

  Future<void> _startSearch() async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final response = await _multiplayerService.startMatchmaking(
        gameType: widget.gameType,
        subject: widget.subject,
        grade: widget.grade,
      );

      if (response['success'] == true) {
        final matchId = response['match_id'];
        setState(() {
          // ИСПРАВЛЕНИЕ: преобразуем int в String
          _matchFoundId = matchId.toString();
        });
        _startPollingGame(_matchFoundId!); // Теперь это String
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Ошибка поиска';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сети: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _cancelSearch() async {
    if (_matchFoundId != null) return;

    try {
      await _multiplayerService.cancelMatchmaking();
    } catch (e) {
      print('Error canceling matchmaking: $e');
    }
  }

  void _startPollingGame(String matchId) {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final response = await _multiplayerService.getMatchmakingStatus(matchId);

      if (response['success'] == true) {
        final status = response['status'];
        final playersCount = response['players_count'] ?? 0;

        setState(() {
          _playersFound = playersCount;
        });

        if (status == 'matched') {
          timer.cancel();
          _searchTimer?.cancel();

          final gameData = response['game'];
          final roomCode = response['room_code'];

          if (mounted) {
            if (widget.gameType == 'team') {
              // Для командной игры - сначала лобби
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameLobbyScreen(
                    gameData: gameData,
                    roomCode: roomCode,
                  ),
                ),
              );
            } else {
              // Для дуэли - сразу в игровую комнату (или лобби на 2 игроков)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameRoomScreen(
                    gameId: gameData['id'],
                    gameData: gameData,
                  ),
                ),
              );
            }
          }
        } else if (status == 'cancelled' || status == 'failed') {
          timer.cancel();
          setState(() {
            _errorMessage = response['message'] ?? 'Поиск отменен';
            _isSearching = false;
          });
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.red,
                        onPressed: () {
                          _cancelSearch();
                          Navigator.pop(context);
                        },
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
                            'Поиск соперника',
                            style: TextStyle(
                              fontSize: 20,
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
                child: Center(
                  child: _errorMessage != null
                      ? Column(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Назад'),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Анимация поиска
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return CustomPaint(
                                  painter: _RadarPainter(
                                    progress: value / (2 * 3.14159),
                                    color: primaryColor,
                                  ),
                                  size: const Size(100, 100),
                                );
                              },
                              onEnd: () {
                                // Анимация зацикливается
                              },
                            ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Поиск соперника...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_searchTime),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _playersFound > 0
                                  ? 'Найдено игроков: $_playersFound'
                                  : 'Ожидание игроков...',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (widget.gameType == 'team')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Можно пригласить друга по коду комнаты, '
                                'когда игра будет найдена',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          _cancelSearch();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Отменить поиск'),
                      ),
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
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Рисуем круги
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paint);
    }

    // Рисуем линии
    for (int i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2;
      final end = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }

    // Рисуем сканирующий луч
    final sweepAngle = 2 * 3.14159 * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      center: Alignment.center,
      colors: [color.withOpacity(0.8), Colors.transparent],
      stops: const [0.0, 0.3],
      transform: GradientRotation(sweepAngle),
    );

    canvas.drawArc(
      rect,
      sweepAngle - 0.2,
      0.4,
      true,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}