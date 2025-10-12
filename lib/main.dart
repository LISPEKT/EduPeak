import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/theme_manager.dart';
import 'screens/avatar_crop_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'EduPeak',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeManager.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/main': (context) => const MainScreen(),
            '/auth': (context) => const AuthScreen(),
          },
          debugShowCheckedModeBanner: false,
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.linear,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: themeManager,
              builder: (context, child) {
                return Theme(
                  data: _getTheme(themeManager.themeMode, context),
                  child: child!,
                );
              },
              child: child,
            );
          },
        );
      },
    );
  }

  ThemeData _getTheme(ThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
      default:
        return AppTheme.lightTheme;
    }
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

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
      final prefs = await SharedPreferences.getInstance();
      final hasUsername = prefs.containsKey('username');

      setState(() {
        _isAuthenticated = hasUsername;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isLoading = false;
        _isAuthenticated = false;
      });
    }
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
              Text(
                'Загрузка...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? const MainScreen() : const AuthScreen();
  }
}