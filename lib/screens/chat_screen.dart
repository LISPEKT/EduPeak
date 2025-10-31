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

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  final _scrollController = ScrollController();
  bool _showMiniGames = false;
  bool _showAttachmentMenu = false;
  bool _isTextFieldFocused = false;
  final FocusNode _textFieldFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFieldWidthAnimation;

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onTextFieldFocusChange);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _textFieldWidthAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadMessages();
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_onTextFieldFocusChange);
    _textFieldFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextFieldFocusChange() {
    setState(() {
      _isTextFieldFocused = _textFieldFocusNode.hasFocus;
      if (_isTextFieldFocused) {
        _showMiniGames = false;
        _showAttachmentMenu = false;
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _unfocusTextField() {
    _textFieldFocusNode.unfocus();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getChatMessages(widget.friend.id);

      if (response['success'] == true) {
        final messagesData = response['messages'] as List;
        setState(() {
          _messages = messagesData.map((data) => ChatMessage.fromJson(data)).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await ApiService.sendMessage(
        widget.friend.id,
        message,
      );

      setState(() {
        final index = _messages.indexWhere((m) => m.id == newMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: response['success'] == true
                ? MessageStatus.sent
                : MessageStatus.error,
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        final index = _messages.indexWhere((m) => m.id == newMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.error,
          );
        }
      });
    }
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
    );

    setState(() {
      _messages.add(fileMessage);
    });

    _scrollToBottom();

    try {
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        final index = _messages.indexWhere((m) => m.id == fileMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.sent,
          );
        }
      });
    } catch (e) {
      print('Error sending file: $e');
      setState(() {
        final index = _messages.indexWhere((m) => m.id == fileMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.error,
          );
        }
      });
    }
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
      print('Error picking image: $e');
      _showErrorSnackBar('Ошибка при выборе изображения');
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
      print('Error picking document: $e');
      _showErrorSnackBar('Ошибка при выборе файла');
    }
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        await _sendFile(result.files.first);
      }
    } catch (e) {
      print('Error picking audio: $e');
      _showErrorSnackBar('Ошибка при выборе аудио');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startMiniGame(String topic) {
    final gameMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '🎮 Приглашение в игру: $topic',
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isGameInvite: true,
    );

    setState(() {
      _messages.add(gameMessage);
      _showMiniGames = false;
      _unfocusTextField();
    });

    _scrollToBottom();

    ApiService.sendMessage(widget.friend.id, 'game_invite:$topic');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  void _showFilePicker() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
      _showMiniGames = false;
      _unfocusTextField();
    });
    if (_showAttachmentMenu) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleMiniGames() {
    setState(() {
      _showMiniGames = !_showMiniGames;
      _showAttachmentMenu = false;
      _unfocusTextField();
    });
  }

  Map<String, String> _getLocalizedSubjectNames() {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'en') {
      return {
        'Русский язык': 'Russian Language',
        'Математика': 'Mathematics',
        'Алгебра': 'Algebra',
        'Геометрия': 'Geometry',
        'История': 'History',
        'Физика': 'Physics',
        'Химия': 'Chemistry',
        'Биология': 'Biology',
        'География': 'Geography',
        'Английский язык': 'English Language',
        'Литература': 'Literature',
        'Обществознание': 'Social Studies',
        'Информатика': 'Computer Science',
      };
    } else if (locale == 'de') {
      return {
        'Русский язык': 'Russische Sprache',
        'Математика': 'Mathematik',
        'Алгебра': 'Algebra',
        'Геометрия': 'Geometrie',
        'История': 'Geschichte',
        'Физика': 'Physik',
        'Химия': 'Chemie',
        'Биология': 'Biologie',
        'География': 'Geographie',
        'Английский язык': 'Englische Sprache',
        'Литература': 'Literatur',
        'Обществознание': 'Sozialkunde',
        'Информатика': 'Informatik',
      };
    }

    return {
      'Русский язык': 'Русский язык',
      'Математика': 'Математика',
      'Алгебра': 'Алгебра',
      'Геометрия': 'Геометрия',
      'История': 'История',
      'Физика': 'Физика',
      'Химия': 'Химия',
      'Биология': 'Биология',
      'География': 'География',
      'Английский язык': 'Английский язык',
      'Литература': 'Литература',
      'Обществознание': 'Обществознание',
      'Информатика': 'Информатика',
    };
  }

  final Map<String, String> _subjectEmojis = {
    'Русский язык': '📚',
    'Математика': '🔢',
    'Алгебра': '𝑥²',
    'Геометрия': '△',
    'Английский язык': '🔤',
    'Литература': '📖',
    'Биология': '🌿',
    'Физика': '⚡',
    'Химия': '🧪',
    'География': '🌍',
    'История': '🏛️',
    'Обществознание': '👥',
    'Информатика': '💻',
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _unfocusTextField,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              _buildUserAvatar(widget.friend.avatar, widget.friend.username, 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.friend.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${widget.friend.username}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.videocam),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () {},
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(localizations.viewProfile),
                ),
                PopupMenuItem(
                  child: Text(localizations.clearChat),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _unfocusTextField,
                behavior: HitTestBehavior.translucent,
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
                    : _messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        localizations.noMessages,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        localizations.startConversation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _ChatBubble(
                      message: message,
                      onFileTap: () {
                        if (message.isFile) {
                          _showFilePreview(message);
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: _showAttachmentMenu && !_isTextFieldFocused
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _AttachmentMenu(
                onClose: _showFilePicker,
                onImageFromGallery: () => _pickImage(ImageSource.gallery),
                onImageFromCamera: () => _pickImage(ImageSource.camera),
                onDocument: _pickDocument,
                onAudio: _pickAudio,
                scaleAnimation: _scaleAnimation,
                fadeAnimation: _fadeAnimation,
              ),
              secondChild: SizedBox.shrink(),
            ),

            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: _showMiniGames && !_isTextFieldFocused
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _MiniGamesGrid(
                  onGameSelected: _startMiniGame,
                  subjectEmojis: _subjectEmojis,
                  localizedSubjects: _getLocalizedSubjectNames(),
                ),
              ),
              secondChild: SizedBox.shrink(),
            ),

            _ChatInput(
              controller: _messageController,
              focusNode: _textFieldFocusNode,
              onSend: _sendMessage,
              onAttachFile: _showFilePicker,
              onToggleMiniGames: _toggleMiniGames,
              showMiniGames: _showMiniGames,
              showAttachmentMenu: _showAttachmentMenu,
              isTextFieldFocused: _isTextFieldFocused,
              textFieldWidthAnimation: _textFieldWidthAnimation,
              onBackgroundTap: _unfocusTextField,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePreview(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Файл: ${message.fileName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Размер: ${_formatFileSize(message.fileSize ?? 0)}'),
            SizedBox(height: 16),
            Text('Этот файл был отправлен в чат.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Скачать'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String avatar, String username, double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getAvatarColor(username),
      child: Text(
        avatar.length > 2 ? avatar.substring(0, 2) : avatar,
        style: TextStyle(fontSize: size * 0.5),
      ),
    );
  }

  Color _getAvatarColor(String username) {
    final colors = [
      Color(0xFFF44336), Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF673AB7),
      Color(0xFF3F51B5), Color(0xFF2196F3), Color(0xFF03A9F4), Color(0xFF00BCD4),
      Color(0xFF009688), Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFCDDC39),
      Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFFF5722),
    ];

    final index = username.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onFileTap;

  const _ChatBubble({required this.message, this.onFileTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.isSentByMe
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isGameInvite)
                      _GoogleStyleGameInvite(
                        topic: message.text.replaceFirst('🎮 Приглашение в игру: ', ''),
                        isSentByMe: message.isSentByMe,
                        onAccept: () {
                          print('Игра принята: ${message.text}');
                        },
                        onDecline: () {
                          print('Игра отклонена: ${message.text}');
                        },
                      )
                    else if (message.isFile)
                      GestureDetector(
                        onTap: onFileTap,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: message.isSentByMe
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: message.isSentByMe ? Colors.white70 : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.fileName ?? 'Файл',
                                      style: TextStyle(
                                        color: message.isSentByMe ? Colors.white : null,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatFileSize(message.fileSize ?? 0),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: message.isSentByMe ? Colors.white70 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isSentByMe ? Colors.white : null,
                        ),
                      ),
                    if (!message.isFile && !message.isGameInvite) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: message.isSentByMe
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                          if (message.isSentByMe) ...[
                            const SizedBox(width: 4),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                message.status == MessageStatus.sending
                                    ? Icons.access_time
                                    : message.status == MessageStatus.sent
                                    ? Icons.done
                                    : Icons.error,
                                key: ValueKey(message.status),
                                size: 12,
                                color: message.status == MessageStatus.error
                                    ? Colors.red
                                    : message.isSentByMe
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}

class _GoogleStyleGameInvite extends StatelessWidget {
  final String topic;
  final bool isSentByMe;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _GoogleStyleGameInvite({
    required this.topic,
    required this.isSentByMe,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок приглашения
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.videogame_asset,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Приглашение в игру',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isSentByMe ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Битва знаний: $topic',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSentByMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Описание
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: isSentByMe ? Colors.white70 : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '5 минут',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSentByMe ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: isSentByMe ? Colors.white70 : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'До 100 очков',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSentByMe ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Соревнуйтесь в знаниях по теме "$topic". Чем быстрее отвечаете, тем больше очков получаете!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isSentByMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Принять вызов',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onDecline,
                  icon: Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: isSentByMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttachFile;
  final VoidCallback onToggleMiniGames;
  final bool showMiniGames;
  final bool showAttachmentMenu;
  final bool isTextFieldFocused;
  final Animation<double> textFieldWidthAnimation;
  final VoidCallback onBackgroundTap;

  const _ChatInput({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttachFile,
    required this.onToggleMiniGames,
    required this.showMiniGames,
    required this.showAttachmentMenu,
    required this.isTextFieldFocused,
    required this.textFieldWidthAnimation,
    required this.onBackgroundTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBackgroundTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: isTextFieldFocused ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isTextFieldFocused ? 0 : 96,
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.add,
                          onPressed: onAttachFile,
                          tooltip: 'Прикрепить файл',
                          isActive: showAttachmentMenu,
                        ),
                        SizedBox(width: 8),
                        _CircleIconButton(
                          icon: Icons.videogame_asset,
                          onPressed: onToggleMiniGames,
                          tooltip: 'Мини-игры',
                          isActive: showMiniGames,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8),

                Expanded(
                  child: AnimatedBuilder(
                    animation: textFieldWidthAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: textFieldWidthAnimation.value,
                        child: child,
                      );
                    },
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                AnimatedScale(
                  duration: Duration(milliseconds: 200),
                  scale: isTextFieldFocused ? 1.1 : 1.0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      onPressed: onSend,
                      icon: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 20,
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade600,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _MiniGamesGrid extends StatelessWidget {
  final Function(String) onGameSelected;
  final Map<String, String> subjectEmojis;
  final Map<String, String> localizedSubjects;

  const _MiniGamesGrid({
    required this.onGameSelected,
    required this.subjectEmojis,
    required this.localizedSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = [
      'Русский язык', 'Математика', 'Алгебра', 'Геометрия',
      'История', 'Физика', 'Химия', 'Биология',
      'География', 'Английский язык', 'Литература',
      'Обществознание', 'Информатика'
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final localizedName = localizedSubjects[subject] ?? subject;
          final emoji = subjectEmojis[subject] ?? '📚';

          return GestureDetector(
            onTap: () => onGameSelected(subject),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 28)),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      localizedName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
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
        },
      ),
    );
  }
}

class _AttachmentMenu extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onImageFromGallery;
  final VoidCallback onImageFromCamera;
  final VoidCallback onDocument;
  final VoidCallback onAudio;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const _AttachmentMenu({
    required this.onClose,
    required this.onImageFromGallery,
    required this.onImageFromCamera,
    required this.onDocument,
    required this.onAudio,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _AttachmentOption(
                icon: Icons.photo,
                title: 'Фото из галереи',
                color: Colors.green,
                onTap: onImageFromGallery,
              ),
              _AttachmentOption(
                icon: Icons.camera_alt,
                title: 'Сделать фото',
                color: Colors.blue,
                onTap: onImageFromCamera,
              ),
              _AttachmentOption(
                icon: Icons.insert_drive_file,
                title: 'Документ',
                color: Colors.orange,
                onTap: onDocument,
              ),
              _AttachmentOption(
                icon: Icons.audiotrack,
                title: 'Аудио',
                color: Colors.purple,
                onTap: onAudio,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
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

  ChatMessage({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.status,
    this.isGameInvite = false,
    this.isFile = false,
    this.fileName,
    this.fileSize,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isSentByMe: json['is_sent_by_me'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values[json['status'] ?? 0],
      isGameInvite: json['is_game_invite'] ?? false,
      isFile: json['is_file'] ?? false,
      fileName: json['file_name'],
      fileSize: json['file_size'],
    );
  }

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
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
}