// chat_screen.dart - ИСПРАВЛЕННЫЙ КОД С ПРАВИЛЬНЫМ СВАЙПОМ
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../localization.dart';
import 'friends_screen.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;

  const ChatScreen({Key? key, required this.friend}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _showAttachmentMenu = false;
  bool _showGamesMenu = false;

  ChatMessage? _replyingToMessage;

  final List<ChatMessage> _demoMessages = [
    ChatMessage(
      id: '1',
      text: 'Привет! Как дела?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      status: MessageStatus.sent,
      senderName: 'Мария',
    ),
    ChatMessage(
      id: '2',
      text: 'Привет! Отлично, только что закончил тему по математике 🎯',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      status: MessageStatus.sent,
      senderName: 'Вы',
    ),
    ChatMessage(
      id: '3',
      text: 'Круто! Можешь помочь с геометрией? Не понимаю теорему Пифагора',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      status: MessageStatus.sent,
      senderName: 'Мария',
    ),
    ChatMessage(
      id: '4',
      text: 'Конечно! Какая именно тема?',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      status: MessageStatus.sent,
      senderName: 'Вы',
    ),
    ChatMessage(
      id: '5',
      text: 'Теорема Пифагора в прямоугольных треугольниках',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      status: MessageStatus.sent,
      senderName: 'Мария',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _messages = _demoMessages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyingToMessage = message;
    });
    _textFieldFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      senderName: 'Вы',
      replyToMessage: _replyingToMessage,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _replyingToMessage = null;
    });

    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      final index = _messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
      }
    });
  }

  void _deleteMessage(String messageId) {
    setState(() {
      _messages.removeWhere((message) => message.id == messageId);
    });
    _showSnackBar('Сообщение удалено');
  }

  void _showMessageContextMenu(BuildContext context, ChatMessage message, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect positionRelative = RelativeRect.fromRect(
      Rect.fromPoints(
        position,
        position,
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionRelative,
      items: [
        PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              const Text('Ответить'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 20, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Удалить'),
            ],
          ),
        ),
        if (message.isFile) PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              const Text('Скачать'),
            ],
          ),
        ),
        if (message.isGameInvite) PopupMenuItem(
          value: 'accept',
          child: Row(
            children: [
              Icon(Icons.play_arrow_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Принять вызов'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'reply') {
        _replyToMessage(message);
      } else if (value == 'delete') {
        _deleteMessage(message.id);
      } else if (value == 'download') {
        _showSnackBar('Файл скачивается...');
      } else if (value == 'accept') {
        _showSnackBar('Начинаем игру!');
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleAttachmentMenu() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
      _showGamesMenu = false;
    });
  }

  void _toggleGamesMenu() {
    setState(() {
      _showGamesMenu = !_showGamesMenu;
      _showAttachmentMenu = false;
    });
  }

  Future<void> _sendFile(PlatformFile file) async {
    final fileMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '📎 ${file.name}',
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      isFile: true,
      fileName: file.name,
      fileSize: file.size,
      senderName: 'Вы',
    );

    setState(() => _messages.add(fileMessage));
    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      final index = _messages.indexWhere((m) => m.id == fileMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final file = File(image.path);
        final platformFile = PlatformFile(
          name: image.name,
          size: await file.length(),
          path: image.path,
        );
        await _sendFile(platformFile);
      }
    } catch (e) {
      _showSnackBar('Ошибка при выборе изображения');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        await _sendFile(result.files.first);
      }
    } catch (e) {
      _showSnackBar('Ошибка при выборе файла');
    }
  }

  void _startMiniGame(String topic) {
    final gameMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '🎮 Приглашение в игру: $topic',
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isGameInvite: true,
      senderName: 'Вы',
    );

    setState(() {
      _messages.add(gameMessage);
      _showGamesMenu = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, localizations),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _messages.isEmpty
                ? _buildEmptyState(localizations)
                : _buildMessagesList(),
          ),

          if (_replyingToMessage != null) _buildReplyPanel(),

          if (_showAttachmentMenu) _buildAttachmentMenu(),

          if (_showGamesMenu) _buildGamesMenu(),

          _buildInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations localizations) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.friend.name.substring(0, 1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'В сети',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded),
          onPressed: () => _showSnackBar('Видеозвонок скоро будет доступен'),
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded),
          onPressed: () => _showSnackBar('Голосовой вызов скоро будет доступен'),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Загрузка сообщений...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noMessages,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.startConversation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _SwipableMessageBubble(
          message: message,
          onReply: () => _replyToMessage(message),
          onDelete: () => _deleteMessage(message.id),
          onLongPress: (position) => _showMessageContextMenu(context, message, position),
        );
      },
    );
  }

  Widget _buildReplyPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ответ на сообщение ${_replyingToMessage!.isSentByMe ? 'вам' : _replyingToMessage!.senderName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingToMessage!.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _cancelReply,
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AttachmentButton(
            icon: Icons.photo_library_rounded,
            label: 'Галерея',
            color: Colors.blue,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          _AttachmentButton(
            icon: Icons.camera_alt_rounded,
            label: 'Камера',
            color: Colors.green,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _AttachmentButton(
            icon: Icons.insert_drive_file_rounded,
            label: 'Документ',
            color: Colors.orange,
            onTap: _pickDocument,
          ),
          _AttachmentButton(
            icon: Icons.emoji_events_rounded,
            label: 'Викторина',
            color: Colors.purple,
            onTap: _toggleGamesMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildGamesMenu() {
    final subjects = ['Математика', 'История', 'Физика', 'Химия', 'Биология', 'География'];
    final emojis = {
      'Математика': '🔢',
      'История': '🏛️',
      'Физика': '⚡',
      'Химия': '🧪',
      'Биология': '🌿',
      'География': '🌍'
    };

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Выберите тему для викторины',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return _GameSubjectCard(
                  subject: subject,
                  emoji: emojis[subject] ?? '📚',
                  onTap: () => _startMiniGame(subject),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _showAttachmentMenu
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _toggleAttachmentMenu,
              icon: Icon(
                Icons.add_rounded,
                size: 20,
                color: _showAttachmentMenu
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _textFieldFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Сообщение...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleGamesMenu,
                    icon: Icon(
                      Icons.emoji_events_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipableMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final Function(Offset) onLongPress;

  const _SwipableMessageBubble({
    required this.message,
    required this.onReply,
    required this.onDelete,
    required this.onLongPress,
  });

  @override
  State<_SwipableMessageBubble> createState() => _SwipableMessageBubbleState();
}

class _SwipableMessageBubbleState extends State<_SwipableMessageBubble> {
  double _dragOffset = 0.0;
  final double _swipeThreshold = 60.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Разрешаем свайп только вправо
        if (details.primaryDelta! > 0) return;

        setState(() {
          _dragOffset = details.primaryDelta!.abs();
        });
      },
      onHorizontalDragEnd: (details) {
        // Если свайп превысил порог - выполняем действие ответа
        if (_dragOffset > _swipeThreshold) {
          widget.onReply();
        }

        // Сбрасываем состояние свайпа
        setState(() {
          _dragOffset = 0.0;
        });
      },
      onHorizontalDragCancel: () {
        setState(() {
          _dragOffset = 0.0;
        });
      },
      onLongPress: () {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        widget.onLongPress(position);
      },
      child: Transform.translate(
        offset: Offset(-_dragOffset, 0), // Сдвигаем влево при свайпе вправо
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: widget.message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.message.isSentByMe) ...[
                _buildSenderAvatar(),
                const SizedBox(width: 8),
              ],

              Flexible(
                child: _ChatBubbleContent(message: widget.message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.message.senderName.substring(0, 1),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatBubbleContent extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubbleContent({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.replyToMessage != null) {
      return _MessageWithReply(message: message);
    }

    if (message.isGameInvite) {
      return _GameInviteCard(message: message);
    }

    if (message.isFile) {
      return _FileMessageCard(message: message);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isSentByMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: message.isSentByMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: message.isSentByMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (message.isSentByMe) ...[
                const SizedBox(width: 4),
                Icon(
                  message.status == MessageStatus.sending
                      ? Icons.access_time_rounded
                      : message.status == MessageStatus.sent
                      ? Icons.done_rounded
                      : Icons.error_rounded,
                  size: 12,
                  color: message.status == MessageStatus.error
                      ? Colors.red
                      : message.isSentByMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageWithReply extends StatelessWidget {
  final ChatMessage message;

  const _MessageWithReply({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isSentByMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: message.isSentByMe
                  ? Colors.white.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.replyToMessage!.isSentByMe ? 'Вы' : message.replyToMessage!.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: message.isSentByMe
                        ? Colors.white.withOpacity(0.9)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.replyToMessage!.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: message.isSentByMe
                        ? Colors.white.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.text,
            style: TextStyle(
              color: message.isSentByMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: message.isSentByMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (message.isSentByMe) ...[
                const SizedBox(width: 4),
                Icon(
                  message.status == MessageStatus.sending
                      ? Icons.access_time_rounded
                      : message.status == MessageStatus.sent
                      ? Icons.done_rounded
                      : Icons.error_rounded,
                  size: 12,
                  color: message.status == MessageStatus.error
                      ? Colors.red
                      : message.isSentByMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class _GameInviteCard extends StatelessWidget {
  final ChatMessage message;

  const _GameInviteCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final topic = message.text.replaceFirst('🎮 Приглашение в игру: ', '');

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Викторина',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      topic,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '5 минут',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.emoji_events_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'До 100 очков',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Принять вызов'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FileMessageCard extends StatelessWidget {
  final ChatMessage message;

  const _FileMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.insert_drive_file_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Файл',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(message.fileSize ?? 0),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.download_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}

class _AttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameSubjectCard extends StatelessWidget {
  final String subject;
  final String emoji;
  final VoidCallback onTap;

  const _GameSubjectCard({
    required this.subject,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                subject,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isGameInvite;
  final bool isFile;
  final String? fileName;
  final int? fileSize;
  final String senderName;
  final ChatMessage? replyToMessage;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.status,
    this.isGameInvite = false,
    this.isFile = false,
    this.fileName,
    this.fileSize,
    required this.senderName,
    this.replyToMessage,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isSentByMe,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isGameInvite,
    bool? isFile,
    String? fileName,
    int? fileSize,
    String? senderName,
    ChatMessage? replyToMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isGameInvite: isGameInvite ?? this.isGameInvite,
      isFile: isFile ?? this.isFile,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      senderName: senderName ?? this.senderName,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
}