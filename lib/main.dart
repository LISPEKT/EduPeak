import 'dart:async';
import 'dart:convert';
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

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();

    // Устанавливаем полностью прозрачные системные панели
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Немедленный переход к проверке аутентификации
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Пустой контейнер, который сразу заменится
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
  String? _authError;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      print('🔍 Проверка аутентификации...');

      // Получаем SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Проверяем, есть ли сохраненные данные для автологина
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      final authMethod = prefs.getString('auth_method');

      print('📊 Состояние из SharedPreferences:');
      print('   - isLoggedIn: $isLoggedIn');
      print('   - email: $savedEmail');
      print('   - auth_method: $authMethod');

      if (isLoggedIn) {
        if (authMethod == 'server' && savedEmail != null && savedPassword != null) {
          // Пытаемся автоматически войти на сервер
          print('🔄 Попытка автоматического входа на сервер...');
          await _performAutoLogin(savedEmail, savedPassword);
        } else if (authMethod == 'local') {
          // Локальный аккаунт
          print('🔐 Обнаружен локальный аккаунт');
          await _initializeLocalAccount(prefs);
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        } else {
          // Некорректные данные для авторизации
          print('❌ Некорректные данные для авторизации');
          await _clearInvalidSession(prefs);
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
      } else {
        // Нет сохраненной сессии
        print('❌ Нет активной сессии');
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('❌ Ошибка проверки аутентификации: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
        _authError = 'Ошибка проверки сессии';
      });
    }
  }

  Future<void> _performAutoLogin(String email, String password) async {
    try {
      print('🔄 Выполняем автоматический вход для: $email');

      // Используем ApiService для логина с полной логикой
      final response = await ApiService.login(email, password);

      if (response['success'] == true) {
        print('✅ Автоматический вход успешен!');

        // Сохраняем данные для будущих автоматических входов
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_method', 'server');
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);

        // Сохраняем токен в сессию
        final token = response['token'];
        await SessionManager.initializeSession(token);

        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        print('❌ Автоматический вход не удался: ${response['message']}');
        await _clearInvalidSession(await SharedPreferences.getInstance());
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
          _authError = response['message'] ?? 'Ошибка автоматического входа';
        });
      }
    } catch (e) {
      print('❌ Ошибка автоматического входа: $e');
      await _clearInvalidSession(await SharedPreferences.getInstance());
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
        _authError = 'Ошибка соединения с сервером';
      });
    }
  }

  Future<void> _initializeLocalAccount(SharedPreferences prefs) async {
    try {
      // Для локального аккаунта создаем UserStats если нет
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

      // Инициализируем сессию для локального аккаунта
      await SessionManager.initializeSession('local_account_token');
      await SessionManager.updateLastActivity();

    } catch (e) {
      print('⚠️ Ошибка инициализации локального аккаунта: $e');
    }
  }

  Future<void> _clearInvalidSession(SharedPreferences prefs) async {
    print('🧹 Очистка невалидной сессии...');
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('auth_method');
    await prefs.remove('user_password');
    await SessionManager.clearSession();
    print('✅ Сессия очищена');
  }

  void _handleSuccessfulLogin(Map<String, dynamic> responseData, String email, String password) async {
    print('✅ Ручной вход успешен!');

    // Сохраняем данные для будущих автоматических входов
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('auth_method', 'server');
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    // Сохраняем токен в сессии
    final token = responseData['token'];
    await SessionManager.initializeSession(token);

    setState(() {
      _isAuthenticated = true;
      _isLoading = false;
    });
  }

  void _handleLocalAccountLogin(String username) async {
    print('✅ Локальный вход успешен!');

    // Сохраняем данные локального аккаунта
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('auth_method', 'local');
    await prefs.setString('username', username);

    // Инициализируем сессию для локального аккаунта
    await SessionManager.initializeSession('local_account_token');

    setState(() {
      _isAuthenticated = true;
      _isLoading = false;
    });
  }

  void _handleLogout() async {
    // Получаем метод аутентификации перед очисткой
    final prefs = await SharedPreferences.getInstance();
    final authMethod = prefs.getString('auth_method');

    // Очищаем сессию
    await SessionManager.clearSession();
    await prefs.setBool('isLoggedIn', false);

    // Если локальный аккаунт - очищаем все данные
    if (authMethod == 'local') {
      await prefs.remove('auth_method');
      await prefs.remove('username');
      await UserDataStorage.clearAllData();
    } else if (authMethod == 'server') {
      // Для серверного аккаунта сохраняем email для повторного входа
      // Пароль остается сохраненным для автоматического входа
      await prefs.remove('auth_method');
    }

    setState(() {
      _isAuthenticated = false;
      _isLoading = true;
      _authError = null;
    });

    // Повторно проверяем аутентификацию (вернет false)
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _authError != null
                    ? _authError!
                    : 'Проверяем сессию...',
                style: const TextStyle(fontSize: 16),
              ),
              if (_authError != null) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _authError = null;
                    });
                    _checkAuth();
                  },
                  child: const Text('Повторить'),
                ),
              ]
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