import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'username_screen.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF1B5E20), // Темно-зеленый
              const Color(0xFF2E7D32), // Средне-зеленый
              const Color(0xFF388E3C), // Светло-зеленый
            ]
                : [
              const Color(0xFF4CAF50), // Светло-зеленый
              const Color(0xFF66BB6A), // Очень светлый зеленый
              const Color(0xFF81C784), // Бледно-зеленый
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Анимированные фоновые элементы
            Positioned(
              top: size.height * 0.15,
              right: size.width * 0.1,
              child: Icon(
                Icons.eco,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            Positioned(
              top: size.height * 0.3,
              left: size.width * 0.05,
              child: Icon(
                Icons.park,
                size: 30,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Positioned(
              bottom: size.height * 0.3,
              right: size.width * 0.15,
              child: Icon(
                Icons.psychology,
                size: 35,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: size.width * 0.1,
              child: Icon(
                Icons.auto_stories,
                size: 25,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // Основной контент
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EduPeak',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выберите способ входа',
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
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Войти в аккаунт',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Создать аккаунт',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

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