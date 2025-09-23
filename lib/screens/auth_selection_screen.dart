import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'username_screen.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({Key? key}) : super(key: key);

  // Проверяем, есть ли уже сохраненный пользователь
  Future<bool> _checkExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUsername = prefs.containsKey('username');
    return hasUsername;
  }

  void _navigateBasedOnAuth(BuildContext context) async {
    final hasUser = await _checkExistingUser();

    if (hasUser) {
      // Если пользователь уже есть, идем сразу в главное
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Если пользователя нет, показываем экран ввода имени
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UsernameScreen()), // УБРАТЬ const
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF121212),
            ]
                : [
              AppTheme.lightTheme.primaryColorDark!,
              AppTheme.lightTheme.primaryColorLight!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.1,
                child: Container(
                  color: isDark ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EduPeak',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Подтяни школьные предметы',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Кнопка входа
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()), // УБРАТЬ const
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Войти в аккаунт',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Кнопка регистрации
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterScreen()), // УБРАТЬ const
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Создать аккаунт',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Кнопка пропуска (для существующих пользователей)
                    TextButton(
                      onPressed: () => _navigateBasedOnAuth(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text(
                        'Уже есть аккаунт? Продолжить',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}