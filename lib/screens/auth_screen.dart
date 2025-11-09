// auth_screen.dart
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
  bool _isLoading = false;
  bool _showLanguageMenu = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
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
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthSelectionScreen()),
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
    final appLocalizations = AppLocalizations.of(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Основной контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Заголовок с анимацией
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.school_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            appLocalizations.appTitle,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: 'GoogleSans',
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appLocalizations.conquerKnowledge,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Статистика с анимацией
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            value: '1+',
                            label: appLocalizations.students,
                            isDark: isDark,
                          ),
                          _StatItem(
                            value: '50+',
                            label: appLocalizations.topics,
                            isDark: isDark,
                          ),
                          _StatItem(
                            value: '95%',
                            label: appLocalizations.success,
                            isDark: isDark,
                          ),
                          _StatItem(
                            value: '14+',
                            label: appLocalizations.subjects,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Описание с анимацией
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalizations.joinAndImprove,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontFamily: 'Roboto',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appLocalizations.examPreparation,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Кнопка начать обучение с анимацией
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _startLearning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  appLocalizations.startLearning,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка языка, которая раздвигается в список
          Positioned(
            bottom: 20,
            right: 20,
            child: _ExpandingLanguageButton(
              isExpanded: _showLanguageMenu,
              currentLanguage: languageManager.currentLocale.languageCode,
              onToggle: _toggleLanguageMenu,
              onChangeLanguage: _changeLanguage,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandingLanguageButton extends StatelessWidget {
  final bool isExpanded;
  final String currentLanguage;
  final VoidCallback onToggle;
  final Function(String) onChangeLanguage;
  final bool isDark;

  const _ExpandingLanguageButton({
    required this.isExpanded,
    required this.currentLanguage,
    required this.onToggle,
    required this.onChangeLanguage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 48,
      width: isExpanded ? 160 : 48, // Увеличил ширину для развернутого состояния
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isExpanded ? _buildExpandedMenu() : _buildCollapsedButton(),
    );
  }

  Widget _buildCollapsedButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onToggle,
        child: Center(
          child: Icon(
            Icons.language_outlined,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LanguageItem(
            code: 'ru',
            label: 'RU',
            isSelected: currentLanguage == 'ru',
            onTap: () => onChangeLanguage('ru'),
            isDark: isDark,
          ),
          _LanguageItem(
            code: 'en',
            label: 'EN',
            isSelected: currentLanguage == 'en',
            onTap: () => onChangeLanguage('en'),
            isDark: isDark,
          ),
          _LanguageItem(
            code: 'de',
            label: 'DE',
            isSelected: currentLanguage == 'de',
            onTap: () => onChangeLanguage('de'),
            isDark: isDark,
          ),
          // Кнопка закрытия
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _LanguageItem({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'GoogleSans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black45,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}