// lib/screens/multiplayer/game_lobby_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import '../../data/user_data_storage.dart';
import '../../localization.dart';
import 'game_room_screen.dart';

class GameLobbyScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;
  final String roomCode;

  const GameLobbyScreen({
    Key? key,
    required this.gameData,
    required this.roomCode,
  }) : super(key: key);

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final _multiplayerService = MultiplayerService();
  Timer? _statusTimer;
  Map<String, dynamic>? _gameData;
  bool _isLoading = false;
  bool _isReady = false;
  int _gameId = 0;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _gameData = widget.gameData;
    _gameId = widget.gameData['id'];
    _loadCurrentUser();
    _startPolling();
  }

  Future<void> _loadCurrentUser() async {
    // Получаем ID текущего пользователя
    // В вашем случае нужно реализовать метод getUserId в UserDataStorage
    // Пока используем заглушку - сравниваем по имени или email
    final currentUsername = await UserDataStorage.getUsername();
    final players = List<Map<String, dynamic>>.from(_gameData!['players']);

    // Ищем игрока с таким же именем
    for (var player in players) {
      if (player['name'] == currentUsername) {
        setState(() {
          _currentUserId = player['user_id'];
          _isReady = player['is_ready'] ?? false;
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _refreshGameStatus();
    });
  }

  Future<void> _refreshGameStatus() async {
    if (!mounted) return;

    final response = await _multiplayerService.getGame(_gameId);
    if (response['success'] == true) {
      setState(() {
        _gameData = response['game'];

        // Обновляем статус готовности текущего игрока
        final players = List<Map<String, dynamic>>.from(_gameData!['players']);
        for (var player in players) {
          if (player['user_id'] == _currentUserId) {
            _isReady = player['is_ready'] ?? false;
            break;
          }
        }
      });

      // Если игра началась, переходим в игровую комнату
      if (_gameData != null && _gameData!['status'] == 'in_progress') {
        _statusTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameRoomScreen(
                gameId: _gameId,
                gameData: _gameData!,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleReady() async {
    setState(() => _isLoading = true);

    try {
      final response = await _multiplayerService.setReady(_gameId);
      if (response['success'] == true) {
        setState(() {
          _isReady = response['is_ready'];
        });
      }
    } catch (e) {
      print('Error toggling ready: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startGame() async {
    print('🎮 Попытка начать игру для gameId: $_gameId');
    setState(() => _isLoading = true);

    try {
      final response = await _multiplayerService.startGame(_gameId);
      print('📥 Ответ от сервера: $response');

      if (response['success'] == true) {
        print('✅ Игра началась успешно');
      } else {
        print('❌ Ошибка: ${response['message']}');
        _showError(response['message'] ?? 'Ошибка начала игры');
      }
    } catch (e) {
      print('❌ Исключение: $e');
      _showError('Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveGame() async {
    await _multiplayerService.leaveGame(_gameId);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _copyRoomCode() {
    // TODO: реализовать копирование в буфер обмена
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Код скопирован: ${widget.roomCode}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  bool _isHost() {
    if (_gameData == null) return false;
    final players = List<Map<String, dynamic>>.from(_gameData!['players']);
    for (var player in players) {
      if (player['user_id'] == _currentUserId) {
        return player['is_host'] ?? false;
      }
    }
    return false;
  }

  bool _canStart() {
    if (_gameData == null) return false;
    final players = List<Map<String, dynamic>>.from(_gameData!['players']);

    // Проверяем, что минимум 2 игрока
    if (players.length < 2) return false;

    // Проверяем, что все игроки готовы
    for (var player in players) {
      if (!(player['is_ready'] ?? false)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_gameData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final players = List<Map<String, dynamic>>.from(_gameData!['players']);
    final isHost = _isHost();
    final canStart = _canStart();

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
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.red,
                        onPressed: _leaveGame,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Комната',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Ожидание игроков',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Код комнаты
                    GestureDetector(
                      onTap: _copyRoomCode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              widget.roomCode,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Список игроков
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Игроки (${players.length}/${_gameData!['max_players']})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...players.map((player) => _buildPlayerCard(player)),

                      // Слоты для ожидающих игроков
                      if (players.length < _gameData!['max_players'])
                        ...List.generate(
                          _gameData!['max_players'] - players.length,
                              (index) => _buildEmptySlot(),
                        ),
                    ],
                  ),
                ),
              ),

              // Нижняя панель
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
                child: Column(
                  children: [
                    // Кнопка готовности для не-хостов
                    if (!isHost)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _toggleReady,
                          style: FilledButton.styleFrom(
                            backgroundColor: _isReady ? Colors.green : primaryColor,
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
                            _isReady ? 'Готов' : 'Готовность',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Кнопка старта для хоста
                    if (isHost) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: canStart && !_isLoading ? _startGame : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: canStart ? Colors.green : theme.disabledColor,
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
                            canStart ? 'Начать игру' : 'Ожидание игроков...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Для начала игры нужно минимум 2 игрока',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final theme = Theme.of(context);
    final isCurrentUser = player['user_id'] == _currentUserId;
    final isPlayerReady = player['is_ready'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primary.withOpacity(0.1)
            : (theme.brightness == Brightness.dark ? theme.cardColor : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: player['is_host'] == true
              ? Colors.amber
              : (isPlayerReady
              ? Colors.green.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2)),
          width: player['is_host'] == true ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Аватар
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: player['avatar'] != null
                ? ClipOval(
              child: Image.network(
                player['avatar'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            )
                : Icon(
              Icons.person_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    if (player['is_host'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Хост',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Вы',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  player['score'] != null ? 'Очки: ${player['score']}' : '',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          // Статус готовности
          if (!player['is_host'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPlayerReady
                    ? Colors.green.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    isPlayerReady ? Icons.check_rounded : Icons.hourglass_empty_rounded,
                    size: 16,
                    color: isPlayerReady ? Colors.green : theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPlayerReady ? 'Готов' : 'Ожидание',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isPlayerReady ? Colors.green : theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Ожидание игрока...',
            style: TextStyle(
              fontSize: 14,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}