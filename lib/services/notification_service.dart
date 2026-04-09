import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Пропускаем локальные уведомления на Android в release режиме
    // Они работают только в debug
    if (Platform.isAndroid) {
      print('📱 Android: локальные уведомления отключены');
      // Только запрашиваем разрешения и получаем FCM токен
      await _requestPermissions();

      // Проверяем, не симулятор ли это
      if (await _isSimulator()) {
        print('📱 Симулятор обнаружен, пропускаем FCM инициализацию');
        return;
      }

      try {
        await _getFCMToken();
      } catch (e) {
        print('⚠️ FCM инициализация пропущена: $e');
      }

      _setupNotificationHandlers();
      return;
    }

    // Для iOS оставляем полную инициализацию
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);
    await _requestPermissions();

    if (await _isSimulator()) {
      print('📱 Симулятор обнаружен, пропускаем FCM инициализацию');
      return;
    }

    try {
      await _getFCMToken();
    } catch (e) {
      print('⚠️ FCM инициализация пропущена: $e');
    }

    _setupNotificationHandlers();
  }

  Future<bool> _isSimulator() async {
    if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('📱 Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);

        bool isLoggedIn = await ApiService.isLoggedIn();
        if (isLoggedIn) {
          await _sendTokenToServer(token);
        }
      }
    } catch (e) {
      print('⚠️ Не удалось получить FCM токен: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final apiToken = await ApiService.getToken();
      if (apiToken == null) return;

      final apiService = ApiService();
      await apiService.registerFCMToken(token);

      print('✅ FCM token sent to server');
    } catch (e) {
      print('❌ Error sending token to server: $e');
    }
  }

  Future<void> resendTokenAfterLogin() async {
    if (await _isSimulator()) {
      print('📱 Симулятор, пропускаем отправку токена');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');
    if (token != null && token.isNotEmpty) {
      await _sendTokenToServer(token);
    } else {
      try {
        token = await _firebaseMessaging.getToken();
        if (token != null && token.isNotEmpty) {
          await prefs.setString('fcm_token', token);
          await _sendTokenToServer(token);
        }
      } catch (e) {
        print('⚠️ Не удалось получить токен при повторной отправке: $e');
      }
    }
  }

  void _setupNotificationHandlers() {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Received message: ${message.notification?.title}');
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Opened from notification');
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'new_message':
        print('💬 Новое сообщение от ${data['sender_name']}');
        break;
      case 'friend_request':
        print('👥 Новая заявка в друзья от ${data['sender_name']}');
        break;
      case 'friend_request_accepted':
        print('✅ Заявка в друзья принята');
        break;
      case 'league_changed':
        print('🏆 Изменение лиги: ${data['old_league']} → ${data['new_league']}');
        break;
      case 'game_invite':
        print('🎮 Приглашение в игру от ${data['sender_name']}');
        break;
      case 'game_started':
        print('🎮 Игра началась!');
        break;
      case 'game_result':
        print('📊 Результаты игры');
        break;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('📱 Background message: ${message.notification?.title}');
}