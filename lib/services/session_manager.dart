import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _lastActiveKey = 'last_active_timestamp';
  static const String _authTokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expiry'; // Добавляем ключ для времени истечения токена

  static Future<void> initializeSession(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Сохраняем текущее время как время последней активности
      await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);

      // Сохраняем токен
      await prefs.setString(_authTokenKey, token);

      // Устанавливаем время истечения токена (например, 30 дней)
      final expiryTime = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      await prefs.setInt(_tokenExpiryKey, expiryTime);

      print('✅ Session initialized with token');
    } catch (e) {
      print('❌ Error initializing session: $e');
    }
  }

  static Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Проверяем наличие токена
      final token = prefs.getString(_authTokenKey);
      if (token == null || token.isEmpty) {
        print('❌ No auth token found');
        return false;
      }

      // 2. Проверяем время истечения токена
      final expiryTime = prefs.getInt(_tokenExpiryKey);
      if (expiryTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expiryTime) {
          print('❌ Token expired');
          return false;
        }
      }

      // 3. Проверяем время последней активности (дополнительная проверка)
      final lastActive = prefs.getInt(_lastActiveKey);
      if (lastActive != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        const maxSessionDuration = 30 * 24 * 60 * 60 * 1000; // 30 дней

        if ((now - lastActive) > maxSessionDuration) {
          print('❌ Session too old');
          return false;
        }
      }

      print('✅ Session is valid');
      return true;

    } catch (e) {
      print('❌ Error checking session validity: $e');
      return false;
    }
  }

  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
      print('✅ Last activity updated');
    } catch (e) {
      print('❌ Error updating last activity: $e');
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActiveKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_tokenExpiryKey);
      print('✅ Session completely cleared');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  // Получить текущий токен
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }
}