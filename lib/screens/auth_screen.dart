import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_selection_screen.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';
import '../localization.dart';
import '../language_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  bool _showLanguageMenu = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
      );
    }
  }

  void _toggleLanguageMenu() {
    setState(() {
      _showLanguageMenu = !_showLanguageMenu;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    await languageManager.setLanguage(languageCode);

    setState(() {
      _showLanguageMenu = false;
    });
  }

  Future<void> _startLearning() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
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
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final appLocalizations = AppLocalizations.of(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                  Theme.of(context).primaryColorDark ?? const Color(0xFF1B5E20),
                  Theme.of(context).primaryColor ?? const Color(0xFF2E7D32),
                  Theme.of(context).primaryColorLight ?? const Color(0xFF388E3C),
                ]
                    : [
                  Theme.of(context).primaryColorLight ?? const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                  const Color(0xFF81C784),
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.eco,
                      size: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.3,
                  left: size.width * 0.05,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.park,
                      size: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.3,
                  right: size.width * 0.15,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.psychology,
                      size: 35,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.2,
                  left: size.width * 0.1,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.auto_stories,
                      size: 25,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),

                // Основной контент
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Логотип и заголовок
                        ScaleTransition(
                          scale: _scaleAnimation,
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
                                child: const Icon(
                                  Icons.school,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                appLocalizations.appTitle,
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                appLocalizations.conquerKnowledge,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Статистика и описание
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatItem(
                                        value: '1+',
                                        label: appLocalizations.students,
                                      ),
                                      _StatItem(
                                        value: '50+',
                                        label: appLocalizations.topics,
                                      ),
                                      _StatItem(
                                        value: '95%',
                                        label: appLocalizations.success,
                                      ),
                                      _StatItem(
                                        value: '14+',
                                        label: appLocalizations.subjects,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  appLocalizations.joinAndImprove,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontFamily: 'Inter',
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  appLocalizations.examPreparation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
                                    fontFamily: 'Inter',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Кнопка начать обучение
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _startLearning,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF2E7D32),
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 8,
                                      shadowColor: Colors.black.withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Color(0xFF2E7D32),
                                        ),
                                      ),
                                    )
                                        : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.rocket_launch, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          appLocalizations.startLearning,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
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

          // Выпадающее меню языков (позиционируется абсолютно)
          if (_showLanguageMenu)
            Positioned(
              bottom: 80, // Располагаем над кнопкой
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LanguageMenuItem(
                      language: appLocalizations.russian,
                      isSelected: languageManager.currentLocale.languageCode == 'ru',
                      onTap: () => _changeLanguage('ru'),
                    ),
                    _buildDivider(),
                    _LanguageMenuItem(
                      language: appLocalizations.english,
                      isSelected: languageManager.currentLocale.languageCode == 'en',
                      onTap: () => _changeLanguage('en'),
                    ),
                    _buildDivider(),
                    _LanguageMenuItem(
                      language: appLocalizations.german,
                      isSelected: languageManager.currentLocale.languageCode == 'de',
                      onTap: () => _changeLanguage('de'),
                    ),
                  ],
                ),
              ),
            ),

          // Кнопка переключения языка (фиксированная позиция)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _toggleLanguageMenu,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageMenuItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  language,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}