// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/theme_manager.dart';
import 'services/api_service.dart';
import 'data/user_data_storage.dart';
import 'localization.dart';
import 'language_manager.dart';
import 'data/subjects_manager.dart';
import 'services/region_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeManager()),
      ChangeNotifierProvider(create: (_) => LanguageManager()),
      ChangeNotifierProvider(create: (_) => RegionManager()),
      ChangeNotifierProvider(create: (_) => SubjectsManager()),
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
      home: const AuthWrapper(),
      routes: {
        '/main': (context) => MainScreen(onLogout: () {}),
        '/auth': (context) => const AuthScreen(),
      },
      debugShowCheckedModeBanner: false,
      checkerboardOffscreenLayers: false,
      checkerboardRasterCacheImages: false,
      showPerformanceOverlay: false,
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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();

      if (isLoggedIn) {
        print('🔄 App start - syncing with server...');
        final syncResult = await ApiService.syncAllUserData();

        if (syncResult['success'] == true) {
          print('✅ Sync completed: ${syncResult['message']}');
        } else {
          print('⚠️ Sync completed with issues: ${syncResult['message']}');
        }
      }

      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Consumer<LanguageManager>(
                builder: (context, languageManager, child) {
                  return Text(
                    languageManager.currentLanguageCode == 'ru'
                        ? 'Загрузка...'
                        : languageManager.currentLanguageCode == 'en'
                        ? 'Loading...'
                        : 'Laden...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
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