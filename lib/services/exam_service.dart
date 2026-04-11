import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ExamService {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;
  ExamService._internal();

  final String _baseUrl = 'https://edupeak.ru';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> _request(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Не авторизован'};

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final uri = Uri.parse('$_baseUrl$path');

      HttpClientRequest request;
      switch (method) {
        case 'POST':
          request = await client.postUrl(uri);
          break;
        default:
          request = await client.getUrl(uri);
      }

      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      if (body != null) {
        request.headers.set('Content-Type', 'application/json; charset=utf-8');
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети: $e'};
    }
  }

  Future<Map<String, dynamic>> getSubjectExams(String subjectKey) =>
      _request('GET', '/api/exams/subject/$subjectKey');

  Future<Map<String, dynamic>> getVariants(int examSubjectId, {int? year}) {
    final path = year != null
        ? '/api/exams/variants/$examSubjectId?year=$year'
        : '/api/exams/variants/$examSubjectId';
    return _request('GET', path);
  }

  Future<Map<String, dynamic>> generateVariant(int examSubjectId, int year) =>
      _request('POST', '/api/exams/variants/$examSubjectId/generate', body: {'year': year});

  Future<Map<String, dynamic>> startAttempt(int variantId) =>
      _request('POST', '/api/exams/attempt/$variantId/start');

  Future<Map<String, dynamic>> saveAnswer(
      int attemptId,
      int questionId, {
        String? userAnswer,
        bool isSkipped = false,
      }) =>
      _request('POST', '/api/exams/attempt/$attemptId/save-answer', body: {
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_skipped': isSkipped,
      });

  Future<Map<String, dynamic>> finishAttempt(
      int attemptId,
      int timeSpent,
      List<Map<String, dynamic>> answers,
      ) =>
      _request('POST', '/api/exams/attempt/$attemptId/finish', body: {
        'time_spent': timeSpent,
        'answers': answers,
      });

  Future<Map<String, dynamic>> getAttemptResult(int attemptId) =>
      _request('GET', '/api/exams/attempt/$attemptId/result');

  Future<Map<String, dynamic>> getUserAttempts(int examSubjectId) =>
      _request('GET', '/api/exams/attempts/$examSubjectId/history');
}