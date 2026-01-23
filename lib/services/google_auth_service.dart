// lib/services/google_auth_service.dart
// TODO: ????????? Firebase ? Google Sign-In

import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import 'api_service.dart';
import 'session_manager.dart';

class GoogleAuthService {
  // ????????? ???????? - ?????? ??????? ????????? ???????
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('? Google Sign-In (stub mode)...');

      final prefs = await SharedPreferences.getInstance();
      final username = 'Google User';
      final email = 'google@user.com';

      // 1. ????????? ?????? ?????
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('username', username);
      await prefs.setString('auth_method', 'google');
      await prefs.setString('lastLogin', DateTime.now().toIso8601String());

      // 2. ?????????????? ??????
      await SessionManager.initializeSession();

      // 3. ??????? ????????? ?????? ????????????
      final userStats = UserStats(
        streakDays: 0,
        lastActivity: DateTime.now(),
        topicProgress: {},
        dailyCompletion: {},
        username: username,
        totalXP: 0,
        weeklyXP: 0,
      );

      await UserDataStorage.saveUserStats(userStats);
      await UserDataStorage.saveUsername(username);

      print('? Local Google account created (stub mode)');

      return {
        'success': true,
        'message': '????????? ??????? Google ?????? (????? ????????)',
        'username': username,
        'email': email,
        'local_mode': true
      };
    } catch (e) {
      print('? Error in Google Sign-In stub: $e');
      return {'success': false, 'message': '?????? ????? ????? Google'};
    }
  }

  Future<bool> isGoogleUserSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authMethod = prefs.getString('auth_method');
      return authMethod == 'google';
    } catch (e) {
      print('? Error checking Google sign-in status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getGoogleUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'email': prefs.getString('userEmail'),
        'name': prefs.getString('username'),
      };
    } catch (e) {
      print('? Error getting Google user info: $e');
      return {};
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      print('? Signing out from Google (stub)...');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_method');

      print('? Google sign-out complete (stub)');
    } catch (e) {
      print('? Error signing out from Google: $e');
    }
  }
}