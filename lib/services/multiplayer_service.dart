// lib/services/multiplayer_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/multiplayer_game.dart';


class MultiplayerService {
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  final String _baseUrl = 'https://edupeak.ru';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // === ИГРЫ ===

  // Создать игру
  // lib/services/multiplayer_service.dart

  Future<Map<String, dynamic>> createGame({
    required String gameType,
    required String subject,
    int? grade,
    String? topicId,  // Добавьте этот параметр
    required int maxPlayers,
    required int questionsCount,
    required int timePerQuestion,
  }) async {
    print('🎮 Создание игры...');
    print('📤 Параметры: gameType=$gameType, subject=$subject, grade=$grade, topicId=$topicId, maxPlayers=$maxPlayers, questions=$questionsCount, time=$timePerQuestion');

    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ Токен не найден');
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/multiplayer/create';
      print('📡 URL: $url');

      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'game_type': gameType,
        'subject': subject,
        'grade': grade,
        'topic_id': topicId,
        'max_players': maxPlayers,
        'questions_count': questionsCount,
        'time_per_question': timePerQuestion,
      });
      print('📦 Body: $body');

      // Правильная отправка UTF-8
      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      print('📥 Статус ответа: ${response.statusCode}');

      final responseBody = await response.transform(utf8.decoder).join();
      print('📥 Ответ: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          print('✅ Игра создана, код: ${jsonResponse['room_code']}');
          return jsonResponse;
        } else {
          print('❌ Ошибка от сервера: ${jsonResponse['message']}');
          return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка создания игры'};
        }
      } else {
        print('❌ HTTP ошибка: ${response.statusCode}');
        return {'success': false, 'message': 'Ошибка сервера: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Исключение: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getGameResults(int gameId) async {
    print('📊 Получение результатов игры: $gameId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/results'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Результаты получены');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка получения результатов'};
    } catch (e) {
      print('❌ Ошибка получения результатов: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getAvailableSubjects() async {
    print('📚 Загрузка доступных предметов...');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/available-subjects'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Загружено предметов: ${jsonResponse['subjects'].length}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки предметов'};
    } catch (e) {
      print('❌ Ошибка загрузки предметов: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> startMatchmaking({
    required String gameType,
    required String subject,
    int? grade,
  }) async {
    print('🎮 Начало матчмейкинга: $gameType, subject=$subject, grade=$grade');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/matchmaking/start'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'game_type': gameType,
        'subject': subject,
        'grade': grade,
      });

      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Матчмейкинг начат, match_id: ${jsonResponse['match_id']}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка начала поиска'};
    } catch (e) {
      print('❌ Ошибка матчмейкинга: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getMatchmakingStatus(String matchId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/matchmaking/status/$matchId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка получения статуса'};
    } catch (e) {
      print('❌ Ошибка получения статуса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelMatchmaking() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/matchmaking/cancel'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка отмены поиска: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final uri = Uri.parse('$_baseUrl$path');
      HttpClientRequest request;

      switch (method.toUpperCase()) {
        case 'GET':
          request = await client.getUrl(uri);
          break;
        case 'POST':
          request = await client.postUrl(uri);
          break;
        case 'PUT':
          request = await client.putUrl(uri);
          break;
        case 'DELETE':
          request = await client.deleteUrl(uri);
          break;
        default:
          request = await client.getUrl(uri);
      }

      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      if (body != null) {
        request.headers.set('Content-Type', 'application/json; charset=utf-8');
        final jsonString = jsonEncode(body);
        final utf8Bytes = utf8.encode(jsonString);
        request.add(utf8Bytes);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка запроса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getAvailableGrades(String subject) async {
    print('📚 Загрузка доступных классов для $subject...');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/multiplayer/available-grades?subject=$subject';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Загружено классов: ${jsonResponse['grades'].length}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки классов'};
    } catch (e) {
      print('❌ Ошибка загрузки классов: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getAvailableTopics(String subject, int grade) async {
    print('📚 Загрузка доступных тем для $subject $grade класса...');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/multiplayer/available-topics?subject=$subject&grade=$grade';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Загружено тем: ${jsonResponse['topics'].length}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки тем'};
    } catch (e) {
      print('❌ Ошибка загрузки тем: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<int> getTopicQuestionsCount(String subject, int grade, String topicId) async {
    print('📊 Получение количества вопросов для темы $topicId');

    try {
      final token = await _getToken();
      if (token == null) {
        return 0;
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/multiplayer/topic-questions-count?subject=$subject&grade=$grade&topic_id=$topicId';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        print('✅ Доступно вопросов по теме: ${jsonResponse['count']}');
        return jsonResponse['count'];
      }

      return 0;
    } catch (e) {
      print('❌ Ошибка получения количества вопросов по теме: $e');
      return 0;
    }
  }

  Future<int> getAvailableQuestionsCount(String subject, int grade) async {
    print('📊 Получение количества вопросов для $subject $grade класса');

    try {
      final token = await _getToken();
      if (token == null) {
        return 0;
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/multiplayer/questions-count?subject=$subject&grade=$grade';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        print('✅ Доступно вопросов: ${jsonResponse['count']}');
        return jsonResponse['count'];
      }

      return 0;
    } catch (e) {
      print('❌ Ошибка получения количества вопросов: $e');
      return 0;
    }
  }

  // Присоединиться к игре по коду
  Future<Map<String, dynamic>> joinGame(String roomCode) async {
    print('🎮 Присоединение к игре: $roomCode');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/join/$roomCode'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Присоединились к игре');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка присоединения'};
    } catch (e) {
      print('❌ Ошибка присоединения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Получить информацию об игре
  Future<Map<String, dynamic>> getGame(int gameId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка получения игры: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Получить статус игры (live обновления)
  Future<Map<String, dynamic>> getGameStatus(int gameId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/status'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка получения статуса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Начать игру (только хост)
  Future<Map<String, dynamic>> startGame(int gameId) async {
    print('🎮 Начало игры: $gameId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/start'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Игра началась');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка начала игры'};
    } catch (e) {
      print('❌ Ошибка начала игры: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Покинуть игру
  Future<Map<String, dynamic>> leaveGame(int gameId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/leave'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка выхода из игры: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Установить готовность
  Future<Map<String, dynamic>> setReady(int gameId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/ready'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка установки готовности: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Отправить ответ
  Future<Map<String, dynamic>> submitAnswer({
    required int gameId,
    required int questionId,
    required String selectedOption, // Изменено на String
    required int timeSpent,
  }) async {
    print('🎮 === ОТПРАВКА ОТВЕТА ===');
    print('🎮 gameId: $gameId');
    print('🎮 questionId: $questionId');
    print('🎮 selectedOption: $selectedOption');
    print('🎮 timeSpent: $timeSpent');

    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ Токен не найден');
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/game/$gameId/answer'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'question_id': questionId,
        'selected_option': selectedOption, // Уже строка
        'time_spent': timeSpent,
      });

      print('📦 Тело запроса: $body');
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Ответ отправлен');
        return jsonResponse;
      }

      print('❌ Ошибка: ${jsonResponse['message']}');
      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка отправки ответа'};
    } catch (e) {
      print('❌ Исключение: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // === ДРУЗЬЯ ===

  // lib/services/multiplayer_service.dart

  Future<Map<String, dynamic>> getFriends() async {
    print('👥 Загрузка друзей...');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/multiplayer/friends'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Загружено друзей: ${jsonResponse['friends']?.length ?? 0}');
        print('✅ Загружено запросов: ${jsonResponse['pending_requests']?.length ?? 0}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки друзей'};
    } catch (e) {
      print('❌ Ошибка загрузки друзей: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest(int userId) async {
    print('📤 Отправка запроса в друзья пользователю $userId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/friends/request'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'user_id': userId});
      print('📦 Body: $body');
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Запрос отправлен');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка отправки запроса'};
    } catch (e) {
      print('❌ Ошибка отправки запроса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Принять запрос в друзья
  Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/friends/accept/$requestId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка принятия запроса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Отклонить запрос в друзья
  Future<Map<String, dynamic>> declineFriendRequest(int requestId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/multiplayer/friends/decline/$requestId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка отклонения запроса: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    print('🔍 Поиск пользователей: $query');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      // Кодируем запрос для URL
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$_baseUrl/api/multiplayer/search?query=$encodedQuery';
      print('📡 URL: $url');

      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Статус: ${response.statusCode}');
      print('📥 Ответ: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Найдено пользователей: ${jsonResponse['users']?.length ?? 0}');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка поиска'};
    } catch (e) {
      print('❌ Ошибка поиска: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // === ЧАТ ===

  Future<Map<String, dynamic>> getConversations() async {
    print('💬 Загрузка списка чатов...');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/chat/conversations'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки чатов'};
    } catch (e) {
      print('❌ Ошибка загрузки чатов: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getMessages(int friendId, {int page = 1}) async {
    print('💬 Загрузка сообщений с другом $friendId, страница $page');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final url = '$_baseUrl/api/chat/messages/$friendId?page=$page';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка загрузки сообщений'};
    } catch (e) {
      print('❌ Ошибка загрузки сообщений: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // lib/services/multiplayer_service.dart

  Future<Map<String, dynamic>> sendMessage(int friendId, String content) async {
    print('💬 Отправка сообщения другу $friendId: "$content"');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/send'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'friend_id': friendId,
        'content': content,
        'type': 'text',
      });

      print('📦 Body JSON: $body');

      // Правильная отправка UTF-8
      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ сервера: $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('✅ Сообщение успешно отправлено');
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка отправки сообщения'};
    } catch (e) {
      print('❌ Ошибка отправки сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> sendGameInvite(int friendId, int gameId, String roomCode) async {
    print('🎮 Отправка приглашения в игру другу $friendId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/send-invite'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'friend_id': friendId,
        'game_id': gameId,
        'room_code': roomCode,
      });

      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ сервера: $responseBody');
      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка отправки приглашения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> respondToGameInvite(int messageId, bool accept) async {
    print('🎮 Ответ на приглашение в игру: ${accept ? 'Принято' : 'Отклонено'}');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/respond-invite'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'message_id': messageId,
        'accept': accept,
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка ответа на приглашение'};
    } catch (e) {
      print('❌ Ошибка ответа на приглашение: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> markMessagesAsRead(int friendId) async {
    print('👁️ Отметка сообщений как прочитанных от друга $friendId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/mark-read'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'friend_id': friendId});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      }

      return {'success': false, 'message': jsonResponse['message'] ?? 'Ошибка отметки сообщений'};
    } catch (e) {
      print('❌ Ошибка отметки сообщений: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> editMessage(int messageId, String content) async {
    print('✏️ Редактирование сообщения $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.putUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId/edit'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'content': content});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка редактирования сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Удалить сообщение
  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    print('🗑️ Полное удаление сообщения $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.deleteUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка удаления сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleReaction(int messageId, String reaction) async {
    print('😊 Реакция $reaction на сообщение $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/messages/reaction'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'message_id': messageId,
        'reaction': reaction,
      });

      // Конвертируем в UTF-8 байты
      final utf8Bytes = utf8.encode(body);
      request.add(utf8Bytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      print('📥 Ответ реакции: $responseBody');
      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка установки реакции: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Получить реакции на сообщение
  Future<Map<String, dynamic>> getMessageReactions(int messageId) async {
    print('😊 Получение реакций на сообщение $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId/reactions'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка получения реакций: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Закрепить сообщение
  Future<Map<String, dynamic>> pinMessage(int messageId, int friendId) async {
    print('📌 Закрепление сообщения $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId/pin'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'friend_id': friendId});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка закрепления сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Открепить сообщение
  Future<Map<String, dynamic>> unpinMessage(int messageId, int friendId) async {
    print('📌 Открепление сообщения $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId/unpin'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({'friend_id': friendId});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка открепления сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Получить закрепленные сообщения
  Future<Map<String, dynamic>> getPinnedMessages(int friendId) async {
    print('📌 Получение закрепленных сообщений с другом $friendId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/chat/pinned/$friendId'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка получения закрепленных сообщений: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Ответить на сообщение
  Future<Map<String, dynamic>> replyToMessage(int friendId, int replyToId, String content) async {
    print('💬 Ответ на сообщение $replyToId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/reply'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'friend_id': friendId,
        'reply_to_id': replyToId,
        'content': content,
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка отправки ответа: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Переслать сообщение
  Future<Map<String, dynamic>> forwardMessage(int messageId, int toFriendId) async {
    print('↪️ Пересылка сообщения $messageId пользователю $toFriendId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(Uri.parse('$_baseUrl/api/chat/forward'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final body = jsonEncode({
        'message_id': messageId,
        'to_friend_id': toFriendId,
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка пересылки сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  // Скопировать сообщение (получить текст)
  Future<Map<String, dynamic>> copyMessage(int messageId) async {
    print('📋 Копирование сообщения $messageId');

    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Не авторизован'};
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl/api/chat/messages/$messageId/copy'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody);
    } catch (e) {
      print('❌ Ошибка копирования сообщения: $e');
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }
}