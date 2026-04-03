// lib/screens/multiplayer/chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/multiplayer_service.dart';
import '../../localization.dart';
import 'game_lobby_screen.dart';
import '../../models/chat_message.dart';
import '../../widgets/message_context_menu.dart';
import 'create_game_screen.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> friend;

  const ChatScreen({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _multiplayerService = MultiplayerService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Timer? _refreshTimer;
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markAsRead();
    _startPolling();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Если пользователь прокручивает вверх, отключаем автоскролл
    if (_scrollController.hasClients && _scrollController.offset > 100) {
      _shouldAutoScroll = false;
    }

    // Если пользователь прокрутил в самый низ, включаем автоскролл
    if (_scrollController.hasClients && _scrollController.offset < 10) {
      _shouldAutoScroll = true;
    }
  }

  void _startPolling() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadNewMessages();
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    // Так как список перевернут (reverse: true), offset 0 это самый низ
    return _scrollController.offset < 300;
  }

  Future<void> _loadNewMessages() async {
    if (!mounted) return;

    try {
      final response = await _multiplayerService.getMessages(widget.friend['id'], page: 1);
      if (response['success'] == true) {
        final newMessages = (response['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();

        if (newMessages.isEmpty) return;

        // Проверяем, было ли последнее сообщение от собеседника
        final wasLastFromFriend = _messages.isNotEmpty &&
            _messages.first.senderId == widget.friend['id'];

        // Проверяем, есть ли новые сообщения
        final hasNewMessages = _messages.isEmpty ||
            newMessages.first.id > _messages.first.id;

        // Проверяем, пришло ли новое сообщение от собеседника
        final hasNewFromFriend = hasNewMessages &&
            newMessages.first.senderId == widget.friend['id'];

        final wasNearBottom = _isNearBottom();

        setState(() {
          _messages = newMessages;
        });

        // Скроллим вниз если:
        // 1. Пользователь был внизу и есть новые сообщения
        // 2. Пришло новое сообщение от собеседника (чтобы сразу увидеть)
        // 3. Это первая загрузка
        if ((wasNearBottom && hasNewMessages) ||
            (hasNewFromFriend && wasNearBottom) ||
            (_currentPage == 1 && _messages.isNotEmpty && wasNearBottom)) {
          _scrollToBottom();
          _markAsRead();
        }

        // Если пришло сообщение от собеседника, но пользователь не внизу,
        // не скроллим, но показываем индикатор (можно добавить позже)
      }
    } catch (e) {
      print('Error loading new messages: $e');
    }
  }

  Future<void> _loadMessages({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _messages = [];
        _currentPage = 1;
      });
    }

    final response = await _multiplayerService.getMessages(
      widget.friend['id'],
      page: _currentPage,
    );

    if (response['success'] == true && mounted) {
      final messages = (response['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList();

      setState(() {
        if (_currentPage == 1) {
          _messages = messages;
        } else {
          _messages.addAll(messages);
        }
        _hasMore = response['has_more'] ?? false;
        _isLoading = false;
      });

      if (_currentPage == 1 && _messages.isNotEmpty) {
        _scrollToBottom();
        _markAsRead();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _isLoading) return;

    _currentPage++;
    await _loadMessages();
  }

  Future<void> _markAsRead() async {
    try {
      await _multiplayerService.markMessagesAsRead(widget.friend['id']);

      setState(() {
        for (var i = 0; i < _messages.length; i++) {
          if (_messages[i].receiverId == widget.friend['id'] && !_messages[i].isRead) {
            _messages[i] = ChatMessage(
              id: _messages[i].id,
              senderId: _messages[i].senderId,
              senderName: _messages[i].senderName,
              senderAvatar: _messages[i].senderAvatar,
              receiverId: _messages[i].receiverId,
              content: _messages[i].content,
              createdAt: _messages[i].createdAt,
              isRead: true,
              type: _messages[i].type,
              metadata: _messages[i].metadata,
            );
          }
        }
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final response = await _multiplayerService.sendMessage(
        widget.friend['id'],
        content,
      );

      if (response['success'] == true && mounted) {
        final newMessage = ChatMessage.fromJson(response['message_data']);
        setState(() {
          _messages.insert(0, newMessage);
          _messageController.clear();
        });

        // После отправки своего сообщения всегда скроллим вниз
        _scrollToBottom();
        _markAsRead();
        _shouldAutoScroll = true;
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendGameInvite() async {
    // Navigate to create game screen instead of creating directly
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGameScreen(
          gameType: 'duel_friend',
          title: 'Пригласить ${widget.friend['name']}',
        ),
      ),
    );

    // If game was created and we have room code, send invite
    if (result != null && result is Map<String, dynamic> && result['success'] == true) {
      final gameData = result['game'];
      final roomCode = result['room_code'];

      final inviteResponse = await _multiplayerService.sendGameInvite(
        widget.friend['id'],
        gameData['id'],
        roomCode,
      );

      if (inviteResponse['success'] == true && mounted) {
        final inviteMessage = ChatMessage.fromJson(inviteResponse['message_data']);
        setState(() {
          _messages.insert(0, inviteMessage);
        });
        _scrollToBottom();
        _showInviteSentDialog(roomCode);
      }
    }
  }

  void _showInviteSentDialog(String roomCode) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.sports_esports_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Приглашение отправлено'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Код комнаты для друга:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                roomCode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ожидайте, пока друг присоединится',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _handleInviteResponse(ChatMessage message, bool accept) async {
    final response = await _multiplayerService.respondToGameInvite(message.id, accept);

    if (response['success'] == true && mounted) {
      if (accept) {
        final gameData = response['game'];
        final roomCode = response['room_code'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameLobbyScreen(
              gameData: gameData,
              roomCode: roomCode,
            ),
          ),
        );
      } else {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = ChatMessage(
              id: message.id,
              senderId: message.senderId,
              senderName: message.senderName,
              senderAvatar: message.senderAvatar,
              receiverId: message.receiverId,
              content: 'Приглашение отклонено',
              createdAt: message.createdAt,
              isRead: true,
              type: MessageType.gameDeclined,
              metadata: message.metadata,
            );
          }
        });
      }
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final response = await _multiplayerService.deleteMessage(message.id);
    if (response['success'] == true && mounted) {
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сообщение удалено'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showContextMenu(BuildContext context, ChatMessage message, bool isMe) {
    if (!isMe) return; // Показываем меню только для своих сообщений

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageContextMenu(
        message: message,
        isMe: isMe,
        onDelete: () => _deleteMessage(message),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Бронзовая': return const Color(0xFFCD7F32);
      case 'Серебряная': return const Color(0xFFC0C0C0);
      case 'Золотая': return const Color(0xFFFFD700);
      case 'Платиновая': return const Color(0xFFE5E4E2);
      case 'Бриллиантовая': return const Color(0xFFB9F2FF);
      case 'Элитная': return const Color(0xFF7F7F7F);
      case 'Легендарная': return const Color(0xFFFF4500);
      case 'Нереальная': return const Color(0xFFE6E6FA);
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else {
      return '${time.day}.${time.month}.${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final leagueColor = _getLeagueColor(widget.friend['league'] ?? 'Бронзовая');

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Кнопка назад
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
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

                    const SizedBox(width: 16),

                    // Центральная часть с информацией о друге
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            // Аватар
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: leagueColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: leagueColor,
                                  width: 2,
                                ),
                              ),
                              child: widget.friend['avatar'] != null
                                  ? ClipOval(
                                child: Image.network(
                                  widget.friend['avatar'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_rounded,
                                    color: leagueColor,
                                    size: 22,
                                  ),
                                ),
                              )
                                  : Icon(
                                Icons.person_rounded,
                                color: leagueColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Имя и статус
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.friend['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: widget.friend['is_online'] == true
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.friend['is_online'] == true
                                            ? 'В сети'
                                            : 'Не в сети',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.hintColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: leagueColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget.friend['league'] ?? 'Бронзовая',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: leagueColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Кнопка игры
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _sendGameInvite,
                      ),
                    ),
                  ],
                ),
              ),

              // Список сообщений
              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Загрузка сообщений...',
                        style: TextStyle(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                )
                    : _messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 40,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет сообщений',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Напишите что-нибудь, чтобы начать общение',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                )
                    : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200 &&
                        _hasMore &&
                        !_isLoading) {
                      _loadMoreMessages();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId != widget.friend['id'];
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
                ),
              ),

              // Нижняя панель ввода
              Container(
                padding: const EdgeInsets.all(16),
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
                child: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Поле ввода
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 48,
                            maxHeight: 120,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.scaffoldBackgroundColor
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: 'Написать сообщение...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: theme.hintColor,
                                      fontSize: 15,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Кнопка отправки
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _messageController.text.isNotEmpty
                              ? primaryColor
                              : theme.disabledColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (_messageController.text.isNotEmpty)
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _isSending ? null : _sendMessage,
                          padding: EdgeInsets.zero,
                        ),
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

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        _showContextMenu(context, message, isMe);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              // Аватар собеседника
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _getLeagueColor(widget.friend['league'] ?? 'Бронзовая').withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: widget.friend['avatar'] != null
                    ? ClipOval(
                  child: Image.network(
                    widget.friend['avatar'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: _getLeagueColor(widget.friend['league'] ?? 'Бронзовая'),
                    ),
                  ),
                )
                    : Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: _getLeagueColor(widget.friend['league'] ?? 'Бронзовая'),
                ),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : (isDark ? theme.cardColor : Colors.white),
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe
                            ? theme.colorScheme.primary
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? theme.colorScheme.primary.withOpacity(0.7)
                                : theme.hintColor,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 12,
                            color: message.isRead
                                ? Colors.blue
                                : theme.colorScheme.primary.withOpacity(0.5),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}