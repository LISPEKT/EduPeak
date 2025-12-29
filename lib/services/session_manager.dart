import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _lastActiveKey = 'last_active_timestamp';

  static Future<void> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
      print('✅ Session initialized');
    } catch (e) {
      print('❌ Error initializing session: $e');
    }
  }

  static Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActive = prefs.getInt(_lastActiveKey);

      if (lastActive == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      const maxSessionDuration = 30 * 24 * 60 * 60 * 1000; // 30 дней

      return (now - lastActive) < maxSessionDuration;
    } catch (e) {
      print('❌ Error checking session validity: $e');
      return false;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActiveKey);
      print('✅ Session cleared');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }
}