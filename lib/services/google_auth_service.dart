import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '196195829359-udl3ov49uk4lff41q6j6jjbuh7lgkkfm.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🟢 Начинаем вход через Google...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Вход отменен'};
      }

      print('🟢 Google пользователь: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      print('🟢 ID Token получен: ${googleAuth.idToken != null ? 'YES' : 'NO'}');
      print('🟢 Access Token получен: ${googleAuth.accessToken != null ? 'YES' : 'NO'}');
      print('🟢 Server Auth Code получен: ${googleAuth.serverAuthCode != null ? 'YES' : 'NO'}');

      // Используем serverAuthCode если idToken нет
      String? tokenToSend = googleAuth.idToken;

      if (tokenToSend == null && googleAuth.serverAuthCode != null) {
        print('🟢 Используем serverAuthCode вместо idToken');
        tokenToSend = googleAuth.serverAuthCode;
      }

      if (tokenToSend == null) {
        return {'success': false, 'message': 'Не удалось получить токен'};
      }

      print('🟢 Отправляем токен на сервер...');

      final response = await http.post(
        Uri.parse('https://edupeak.ru/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_token': tokenToSend,
        }),
      );

      print('🟢 Ответ от сервера: ${response.statusCode}');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('userId', data['user']['id']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_method', 'google');

        final savedToken = await prefs.getString('token');
        print('✅ Токен сохранен: ${savedToken != null ? "YES, длина ${savedToken.length}" : "NO"}');

        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'isNewUser': data['is_new_user'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ошибка авторизации',
        };
      }
    } catch (e) {
      print('🔴 Исключение: $e');
      return {
        'success': false,
        'message': 'Ошибка: $e',
      };
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('isLoggedIn');
    await prefs.remove('auth_method');
  }
}