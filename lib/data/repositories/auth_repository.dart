import 'package:dio/dio.dart';
import '../../services/api_client.dart';
import '../../services/secure_prefs.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final dio = ApiClient.instance;
    try {
      final resp = await dio.post('/login', data: {'email': email, 'password': password});
      if (resp.statusCode == 200 || resp.statusCode == 302) {
        await SecurePrefs.saveAuthToken('dummy_token'); // потом замени на реальный
        return {'success': true};
      }
      return {'success': false, 'message': 'Invalid credentials'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data ?? 'Network error'};
    }
  }

  @override
  Future<void> logout() async {
    final dio = ApiClient.instance;
    try { await dio.post('/logout'); } finally { await SecurePrefs.clear(); }
  }
}