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
import 'services/central_data_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Инициализация уведомлений
  await NotificationService().initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('🚀 Запуск EduPeak');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeManager()),
      ChangeNotifierProvider(create: (_) => LanguageManager()),
      ChangeNotifierProvider(create: (_) => RegionManager()),
      ChangeNotifierProvider(create: (_) => SubjectsManager()),
      ChangeNotifierProvider(create: (_) => CentralDataManager()),
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
        '/xp': (context) => XPScreen(earnedXP: 0, questionsCount: 0),
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
    _loadInitialData();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

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

  Future<void> _loadInitialData() async {
    print('📦 Загрузка начальных данных...');
    try {} catch (e) {
      print('❌ Ошибка загрузки начальных данных: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      final authMethod = prefs.getString('auth_method');
      final token = prefs.getString('token');

      print('📊 Состояние из SharedPreferences:');
      print('   - isLoggedIn: $isLoggedIn');
      print('   - email: $savedEmail');
      print('   - auth_method: $authMethod');
      print('   - token: ${token != null ? "есть" : "нет"}');

      if (isLoggedIn) {
        if (authMethod == 'google') {
          if (token != null) {
            print('✅ Google аккаунт, токен найден');
            await SessionManager.initializeSession(token);
            await _performFullSync(); // ← ДОБАВЛЕНО: синхронизация при входе
            setState(() {
              _isAuthenticated = true;
              _isLoading = false;
            });
            return;
          } else {
            print('❌ Google аккаунт, но токен отсутствует');
            await _clearInvalidSession(prefs);
            setState(() {
              _isAuthenticated = false;
              _isLoading = false;
            });
            return;
          }
        }

        if (authMethod == 'server' && savedEmail != null && savedPassword != null) {
          print('🔄 Попытка автоматического входа на сервер...');
          await _performAutoLogin(savedEmail, savedPassword);
          return;
        }

        if (authMethod == 'local') {
          print('🔐 Обнаружен локальный аккаунт');
          await _initializeLocalAccount(prefs);
          await _performFullSync(); // ← ДОБАВЛЕНО: синхронизация при входе
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        }

        print('❌ Некорректные данные для авторизации');
        await _clearInvalidSession(prefs);
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      } else {
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

  // ==================== НОВЫЙ МЕТОД ПОЛНОЙ СИНХРОНИЗАЦИИ ====================
  Future<void> _performFullSync() async {
    print('🔄 ПОЛНАЯ СИНХРОНИЗАЦИЯ ДАННЫХ ПРИ ВХОДЕ...');

    try {
      // 1. Синхронизируем профиль
      await UserDataStorage.syncProfileFromServer();

      // 2. Синхронизируем XP и прогресс
      final syncResult = await UserDataStorage.syncXpAndProgress();
      print('✅ Результат синхронизации: ${syncResult['message']}');

      // 3. Синхронизируем достижения
      try {
        final achievementsResponse = await ApiService.getAchievementProgress();
        if (achievementsResponse['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          final progress = achievementsResponse['progress'] ?? {};
          progress.forEach((key, value) {
            if (value == true) {
              prefs.setBool('achievement_$key', true);
            }
          });
          print('✅ Достижения синхронизированы');
        }
      } catch (e) {
        print('⚠️ Ошибка синхронизации достижений: $e');
      }

      // 4. Обновляем кэшированные значения
      final stats = await UserDataStorage.getUserStats();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_total_xp', stats.totalXP);
      await prefs.setInt('cached_weekly_xp', stats.weeklyXP);
      await prefs.setInt('cached_streak_days', stats.streakDays);

      // 5. 📱 ОТПРАВКА FCM ТОКЕНА НА СЕРВЕР
      await _sendFCMTokenToServer();

      print('✅ Полная синхронизация завершена! XP=${stats.totalXP}');

    } catch (e) {
      print('❌ Ошибка полной синхронизации: $e');
    }
  }

// Добавьте этот метод в класс _AuthWrapperState
  Future<void> _sendFCMTokenToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('fcm_token');

      if (token != null && token.isNotEmpty) {
        print('📱 Отправка FCM токена на сервер: $token');
        final apiService = ApiService();
        final result = await apiService.registerFCMToken(token);
        if (result['success'] == true) {
          print('✅ FCM токен зарегистрирован на сервере');
        } else {
          print('❌ Ошибка регистрации FCM токена: ${result['message']}');
        }
      } else {
        print('⚠️ FCM токен не найден в SharedPreferences');
      }
    } catch (e) {
      print('❌ Ошибка отправки FCM токена: $e');
    }
  }

  Future<void> _performAutoLogin(String email, String password) async {
    try {
      print('🔄 Выполняем автоматический вход для: $email');

      final response = await ApiService.login(email, password);

      if (response['success'] == true) {
        print('✅ Автоматический вход успешен!');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_method', 'server');
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);

        final token = response['token'];
        await SessionManager.initializeSession(token);

        // ← ДОБАВЛЕНО: синхронизация после авто-логина
        await _performFullSync();

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

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final authMethod = prefs.getString('auth_method');

    await SessionManager.clearSession();
    await prefs.setBool('isLoggedIn', false);

    if (authMethod == 'local') {
      await prefs.remove('auth_method');
      await prefs.remove('username');
      await UserDataStorage.clearAllData();
    } else if (authMethod == 'server') {
      await prefs.remove('auth_method');
    }

    setState(() {
      _isAuthenticated = false;
      _isLoading = true;
      _authError = null;
    });

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
                _authError != null ? _authError! : 'Проверяем сессию...',
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