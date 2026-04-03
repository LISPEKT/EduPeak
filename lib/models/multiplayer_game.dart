// lib/models/multiplayer_game.dart

enum GameType {
  duelRandom,
  duelFriend,
  team,
  tournament,
}

enum GameStatus {
  waiting,
  starting,
  inProgress,
  finished,
  cancelled,
}

enum GameSubject {
  history,
  biology,
  social,
  geography,
  mixed,
}

extension GameSubjectExtension on GameSubject {
  String get displayName {
    switch (this) {
      case GameSubject.history:
        return 'История';
      case GameSubject.biology:
        return 'Биология';
      case GameSubject.social:
        return 'Обществознание';
      case GameSubject.geography:
        return 'География';
      case GameSubject.mixed:
        return 'Микс';
    }
  }

  String get apiValue {
    switch (this) {
      case GameSubject.history:
        return 'history';
      case GameSubject.biology:
        return 'biology';
      case GameSubject.social:
        return 'social';
      case GameSubject.geography:
        return 'geography';
      case GameSubject.mixed:
        return 'mixed';
    }
  }

  static GameSubject fromApi(String value) {
    switch (value) {
      case 'history':
        return GameSubject.history;
      case 'biology':
        return GameSubject.biology;
      case 'social':
        return GameSubject.social;
      case 'geography':
        return GameSubject.geography;
      default:
        return GameSubject.mixed;
    }
  }
}

class MultiplayerGame {
  final int id;
  final String roomCode;
  final GameType gameType;
  final GameStatus status;
  final GameSubject subject;
  final int? grade;
  final int maxPlayers;
  final int currentPlayers;
  final int questionsCount;
  final int timePerQuestion;
  final DateTime createdAt;
  final MultiplayerPlayer host;
  final List<MultiplayerPlayer> players;

  MultiplayerGame({
    required this.id,
    required this.roomCode,
    required this.gameType,
    required this.status,
    required this.subject,
    this.grade,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.questionsCount,
    required this.timePerQuestion,
    required this.createdAt,
    required this.host,
    required this.players,
  });

  factory MultiplayerGame.fromJson(Map<String, dynamic> json) {
    return MultiplayerGame(
      id: json['id'],
      roomCode: json['room_code'],
      gameType: _parseGameType(json['game_type']),
      status: _parseGameStatus(json['status']),
      subject: GameSubjectExtension.fromApi(json['subject']),
      grade: json['grade'],
      maxPlayers: json['max_players'],
      currentPlayers: json['current_players'],
      questionsCount: json['questions_count'],
      timePerQuestion: json['time_per_question'],
      createdAt: DateTime.parse(json['created_at']),
      host: MultiplayerPlayer.fromJson(json['host']),
      players: (json['players'] as List)
          .map((p) => MultiplayerPlayer.fromJson(p))
          .toList(),
    );
  }

  static GameType _parseGameType(String type) {
    switch (type) {
      case 'duel_random':
        return GameType.duelRandom;
      case 'duel_friend':
        return GameType.duelFriend;
      case 'team':
        return GameType.team;
      case 'tournament':
        return GameType.tournament;
      default:
        return GameType.duelRandom;
    }
  }

  static GameStatus _parseGameStatus(String status) {
    switch (status) {
      case 'waiting':
        return GameStatus.waiting;
      case 'starting':
        return GameStatus.starting;
      case 'in_progress':
        return GameStatus.inProgress;
      case 'finished':
        return GameStatus.finished;
      case 'cancelled':
        return GameStatus.cancelled;
      default:
        return GameStatus.waiting;
    }
  }
}

class MultiplayerPlayer {
  final int id;
  final int userId;
  final String name;
  final String? avatar;
  final int score;
  final int correctAnswers;
  final int totalAnswers;
  final bool isHost;
  final bool isReady;
  final DateTime? joinedAt;

  MultiplayerPlayer({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
    required this.score,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.isHost,
    required this.isReady,
    this.joinedAt,
  });

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      avatar: json['avatar'],
      score: json['score'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      totalAnswers: json['total_answers'] ?? 0,
      isHost: json['is_host'] ?? false,
      isReady: json['is_ready'] ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : null,
    );
  }
}

class GameQuestion {
  final int id;
  final int number;
  final String text;
  final List<String> options;
  final int timeLimit;
  final int points;
  final String subject;

  GameQuestion({
    required this.id,
    required this.number,
    required this.text,
    required this.options,
    required this.timeLimit,
    required this.points,
    required this.subject,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      id: json['id'],
      number: json['number'],
      text: json['text'],
      options: List<String>.from(json['options']),
      timeLimit: json['time_limit'],
      points: json['points'],
      subject: json['subject'],
    );
  }
}

class GameAnswer {
  final int playerId;
  final String playerName;
  final bool isCorrect;
  final int timeSpent;
  final int points;

  GameAnswer({
    required this.playerId,
    required this.playerName,
    required this.isCorrect,
    required this.timeSpent,
    required this.points,
  });

  factory GameAnswer.fromJson(Map<String, dynamic> json) {
    return GameAnswer(
      playerId: json['player_id'],
      playerName: json['player_name'],
      isCorrect: json['is_correct'],
      timeSpent: json['time_spent'],
      points: json['points'],
    );
  }
}

class GameStatusResponse {
  final MultiplayerGame game;
  final GameQuestion? currentQuestion;
  final List<GameAnswer> answers;

  GameStatusResponse({
    required this.game,
    this.currentQuestion,
    required this.answers,
  });

  factory GameStatusResponse.fromJson(Map<String, dynamic> json) {
    return GameStatusResponse(
      game: MultiplayerGame.fromJson(json['game']),
      currentQuestion: json['current_question'] != null
          ? GameQuestion.fromJson(json['current_question'])
          : null,
      answers: (json['answers'] as List?)
          ?.map((a) => GameAnswer.fromJson(a))
          .toList() ??
          [],
    );
  }
}

class Friend {
  final int id;
  final String name;
  final String? avatar;
  final bool isOnline;
  final int xp;
  final String league;

  Friend({
    required this.id,
    required this.name,
    this.avatar,
    required this.isOnline,
    required this.xp,
    required this.league,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      isOnline: json['is_online'] ?? false,
      xp: json['xp'] ?? 0,
      league: json['league'] ?? 'Бронзовая',
    );
  }
}

class UserSearchResult {
  final int id;
  final String name;
  final String? avatar;
  final int xp;
  final String league;

  UserSearchResult({
    required this.id,
    required this.name,
    this.avatar,
    required this.xp,
    required this.league,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      xp: json['xp'] ?? 0,
      league: json['league'] ?? 'Бронзовая',
    );
  }
}