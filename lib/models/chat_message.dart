// lib/models/chat_message.dart

enum MessageType {
  text,
  gameInvite,
  gameAccepted,
  gameDeclined,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Текст';
      case MessageType.gameInvite:
        return 'Приглашение в игру';
      case MessageType.gameAccepted:
        return 'Приглашение принято';
      case MessageType.gameDeclined:
        return 'Приглашение отклонено';
    }
  }
}

class MessageReaction {
  final String reaction;
  final int count;
  final bool userReacted;
  final List<Map<String, dynamic>> users;

  MessageReaction({
    required this.reaction,
    required this.count,
    required this.userReacted,
    required this.users,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      reaction: json['reaction'],
      count: json['count'],
      userReacted: json['user_reacted'] ?? false,
      users: List<Map<String, dynamic>>.from(json['users'] ?? []),
    );
  }
}

class ReplyInfo {
  final int id;
  final int senderId;
  final String senderName;
  final String content;

  ReplyInfo({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
  });

  factory ReplyInfo.fromJson(Map<String, dynamic> json) {
    return ReplyInfo(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      content: json['content'],
    );
  }
}

class ForwardInfo {
  final int id;
  final String senderName;
  final String content;
  final DateTime createdAt;

  ForwardInfo({
    required this.id,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  factory ForwardInfo.fromJson(Map<String, dynamic> json) {
    return ForwardInfo(
      id: json['id'],
      senderName: json['sender_name'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final int receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  // Новые поля
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final ReplyInfo? replyTo;
  final ForwardInfo? forwardedFrom;
  final List<MessageReaction> reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.metadata,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.replyTo,
    this.forwardedFrom,
    this.reactions = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Парсим тип сообщения
    MessageType messageType = MessageType.text;
    if (json['type'] == 'game_invite') messageType = MessageType.gameInvite;
    if (json['type'] == 'game_accepted') messageType = MessageType.gameAccepted;
    if (json['type'] == 'game_declined') messageType = MessageType.gameDeclined;

    // Парсим reply_to
    ReplyInfo? replyTo;
    if (json['reply_to'] != null) {
      replyTo = ReplyInfo.fromJson(json['reply_to']);
    }

    // Парсим forwarded_from из metadata (если есть)
    ForwardInfo? forwardedFrom;
    if (json['metadata'] != null && json['metadata']['forwarded_from'] != null) {
      forwardedFrom = ForwardInfo.fromJson(json['metadata']['forwarded_from']);
    }

    // Парсим реакции
    List<MessageReaction> reactions = [];
    if (json['reactions'] != null) {
      reactions = (json['reactions'] as List)
          .map((r) => MessageReaction.fromJson(r))
          .toList();
    }

    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      receiverId: json['receiver_id'],
      content: json['is_deleted'] == true
          ? '[Сообщение удалено]'
          : json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: messageType,
      metadata: json['metadata'],
      isEdited: json['is_edited'] ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      replyTo: replyTo,
      forwardedFrom: forwardedFrom,
      reactions: reactions,
    );
  }

  // Для локального создания сообщения (optimistic update)
  factory ChatMessage.local({
    required int id,
    required int senderId,
    required String senderName,
    String? senderAvatar,
    required int receiverId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
      isRead: false,
      type: type,
      metadata: metadata,
    );
  }
}