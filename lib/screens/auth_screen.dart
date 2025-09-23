import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_selection_screen.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasUsername = prefs.containsKey('username');

      if (hasUsername && mounted) {
        // Если пользователь уже авторизован, переходим сразу в главное
        Navigator.pushReplacementNamed(context, '/main');
        return;
      }
    } catch (e) {
      print('Error checking auth: $e');
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Имитация процесса входа через Google
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _navigateToAuthSelection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToAuthSelection() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthSelectionScreen(),
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
  }

  void _skipAuth() async {
    // Создаем временного пользователя
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'Ученик');
    await prefs.setString('user_avatar', '👤');

    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : AppTheme.lightTheme.primaryColorDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 20),
              Text(
                'Загрузка...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
              const Color(0xFF1E3A2E),
              const Color(0xFF121212),
              const Color(0xFF0A0A0A),
            ]
                : [
              const Color(0xFF2E7D32),
              const Color(0xFF4CAF50),
              const Color(0xFF81C784),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Фоновые элементы
            Positioned(
              top: size.height * 0.1,
              right: size.width * 0.1,
              child: _AnimatedIcon(
                icon: Icons.school,
                delay: 0,
                size: 40,
              ),
            ),
            Positioned(
              top: size.height * 0.2,
              left: size.width * 0.05,
              child: _AnimatedIcon(
                icon: Icons.auto_stories,
                delay: 200,
                size: 30,
              ),
            ),
            Positioned(
              bottom: size.height * 0.25,
              right: size.width * 0.15,
              child: _AnimatedIcon(
                icon: Icons.psychology,
                delay: 400,
                size: 35,
              ),
            ),
            Positioned(
              bottom: size.height * 0.15,
              left: size.width * 0.1,
              child: _AnimatedIcon(
                icon: Icons.quiz,
                delay: 600,
                size: 25,
              ),
            ),

            // Основной контент
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Хедер с кнопкой пропуска
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _skipAuth,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text(
                          'Пропустить',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Заголовок и описание
                    _AnimatedContent(
                      delay: 800,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.school,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'EduPeak',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Достигай новых вершин в обучении',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Inter',
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Подготовка к школе • Углубленное изучение • Персональный прогресс',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Кнопка входа
                    _AnimatedContent(
                      delay: 1200,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    const Color(0xFF2E7D32),
                                  ),
                                ),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.account_circle, size: 20),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Начать обучение',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Присоединяйтесь к тысячам учеников',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
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

// Анимированная иконка для фона
class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final int delay;
  final double size;

  const _AnimatedIcon({
    required this.icon,
    required this.delay,
    required this.size,
  });

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.icon,
          size: widget.size,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}

// Анимированный контент
class _AnimatedContent extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedContent({
    required this.child,
    required this.delay,
  });

  @override
  State<_AnimatedContent> createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<_AnimatedContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}