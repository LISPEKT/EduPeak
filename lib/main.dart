import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/theme_manager.dart';
import 'services/api_service.dart';
import 'localization.dart';
import 'language_manager.dart';
import 'data/subjects_manager.dart';
import 'services/region_manager.dart';
import 'data/user_data_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_stats.dart';
import 'screens/get_xp_screen.dart'; // Экран после теста (XPScreen)
import 'screens/xp_stats_screen.dart'; // График опыта (XPStatsScreen)
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Фоновая обработка сообщений - должна быть объявлена на верхнем уровне
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Инициализируем Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Настраиваем Firebase Messaging
    await _setupFirebaseMessaging();

  } catch (e) {
    print('❌ Firebase initialization error: $e');
    print('⚠️ Continuing without Firebase...');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeManager()),
      ChangeNotifierProvider(create: (_) => LanguageManager()),
      ChangeNotifierProvider(create: (_) => RegionManager()),
      ChangeNotifierProvider(create: (_) => SubjectsManager()),
      Provider<IAuthRepository>(create: (_) => AuthRepository()),
    ],
    child: const MyApp(),
  ));
}

Future<void> _setupFirebaseMessaging() async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Запрашиваем разрешения (для iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Регистрируем обработчик фоновых сообщений
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Получаем токен устройства и сохраняем его
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Сохраняем токен в SharedPreferences
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('✅ FCM token saved to SharedPreferences');
    }

    // Обработка сообщений, когда приложение в foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Обработка сообщений, когда приложение было открыто из фонового состояния
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
    });

    print('✅ Firebase Messaging configured successfully');
  } catch (e) {
    print('⚠️ Firebase Messaging setup failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return MaterialApp(
      title: 'EduPeak',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      locale: languageManager.currentLocale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      home: const SplashWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => MainScreen(onLogout: () {}),
        '/xp': (context) => XPScreen(
          earnedXP: 0,
          questionsCount: 0,
        ),
        '/xp_stats': (context) => XPStatsScreen(),
      },
    );
  }
}

/* ----------  Splash / Auth flow – без изменений  ---------- */
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _showSplash
            ? Container(key: const ValueKey('splash'), color: Colors.black)
            : const AuthWrapper(key: ValueKey('auth')),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      print('🔍 Checking authentication...');

      // 1. Проверяем через SharedPreferences напрямую
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print('📊 isLoggedIn from SharedPreferences: $isLoggedIn');

      if (isLoggedIn) {
        // 2. Проверяем валидность сессии
        final isSessionValid = await SessionManager.isSessionValid();
        print('📊 Session valid: $isSessionValid');

        if (isSessionValid) {
          // 3. Обновляем сессию
          await SessionManager.initializeSession();

          // 4. Проверяем тип аккаунта
          final authMethod = prefs.getString('auth_method');

          if (authMethod == 'local') {
            print('🔐 Local account detected - quick access');

            // 5. Для локального аккаунта создаем UserStats если нет
            try {
              final userStats = await UserDataStorage.getUserStats();
              if (userStats.username.isEmpty) {
                final username = prefs.getString('username') ?? 'Локальный Пользователь';

                final initialStats = UserStats(
                  streakDays: 0,
                  lastActivity: DateTime.now(),
                  topicProgress: {},
                  dailyCompletion: {},
                  username: username,
                  totalXP: 0,
                  weeklyXP: 0,
                );

                await UserDataStorage.saveUserStats(initialStats);
                print('✅ Created minimal user stats for local account');
              }
            } catch (e) {
              print('⚠️ Could not create user stats: $e');
            }
          }

          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });

          return;
        } else {
          // Сессия истекла
          print('❌ Session expired, clearing...');
          await prefs.remove('isLoggedIn');
          await SessionManager.clearSession();
        }
      }

      // Если нет сессии
      print('❌ No active session');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Auth check error: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    // Получаем метод аутентификации перед очисткой
    final prefs = await SharedPreferences.getInstance();
    final authMethod = prefs.getString('auth_method');

    await UserDataStorage.setLoggedIn(false);
    await SessionManager.clearSession();

    // Если локальный аккаунт - очищаем все данные
    if (authMethod == 'local') {
      await prefs.remove('auth_method');
      await prefs.remove('userEmail');
      await prefs.remove('username');
      await UserDataStorage.clearAllData();
    }

    setState(() {
      _isAuthenticated = false;
      _isLoading = true;
    });

    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Проверяем сессию...'),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated
        ? MainScreen(onLogout: _handleLogout)
        : const AuthScreen();
  }
}