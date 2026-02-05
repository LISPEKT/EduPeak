import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Основные импорты приложения
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
import 'screens/get_xp_screen.dart';
import 'screens/xp_stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка ориентации (опционально)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('🚀 Запуск EduPeak без Firebase');

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

/* ----------  Splash / Auth flow  ---------- */
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
            ? Container(
          key: const ValueKey('splash'),
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Здесь можно добавить логотип
                Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'EduPeak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
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
      print('🔍 Проверка аутентификации...');

      // Проверяем через SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print('📊 isLoggedIn из SharedPreferences: $isLoggedIn');

      if (isLoggedIn) {
        // Проверяем валидность сессии
        final isSessionValid = await SessionManager.isSessionValid();
        print('📊 Сессия действительна: $isSessionValid');

        if (isSessionValid) {
          // Обновляем сессию
          await SessionManager.initializeSession();

          // Проверяем тип аккаунта
          final authMethod = prefs.getString('auth_method');

          if (authMethod == 'local') {
            print('🔐 Обнаружен локальный аккаунт');

            // Для локального аккаунта создаем UserStats если нет
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
                print('✅ Создана базовая статистика для локального аккаунта');
              }
            } catch (e) {
              print('⚠️ Не удалось создать статистику пользователя: $e');
            }
          }

          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });

          return;
        } else {
          // Сессия истекла
          print('❌ Сессия истекла, очистка...');
          await prefs.remove('isLoggedIn');
          await SessionManager.clearSession();
        }
      }

      // Если нет сессии
      print('❌ Нет активной сессии');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Ошибка проверки аутентификации: $e');
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