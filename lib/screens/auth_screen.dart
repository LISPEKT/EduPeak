import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_selection_screen.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';
import '../localization.dart';
import '../language_manager.dart';
import '../data/user_data_storage.dart'; // ДОБАВЬТЕ ЭТОТ ИМПОРТ

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
    try {
      print('🔍 Checking existing auth in AuthScreen...');
      final isValid = await UserDataStorage.isLoggedIn();
      print('📊 Auth validation result: $isValid');

      if (isValid && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
        );
      }
    } catch (e) {
      print('❌ Error checking existing auth: $e');
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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final appLocalizations = AppLocalizations.of(context)!;
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            appLocalizations.appTitle,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appLocalizations.conquerKnowledge,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
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
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appLocalizations.examPreparation,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
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
                        FilledButton(
                          onPressed: _isLoading ? null : _startLearning,
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 56),
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
                              Icon(Icons.arrow_forward_rounded, size: 20),
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка языка
          Positioned(
            bottom: 20,
            right: 20,
            child: _ExpandingLanguageButton(
              isExpanded: _showLanguageMenu,
              currentLanguage: languageManager.currentLocale.languageCode,
              onToggle: _toggleLanguageMenu,
              onChangeLanguage: _changeLanguage,
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

  const _ExpandingLanguageButton({
    required this.isExpanded,
    required this.currentLanguage,
    required this.onToggle,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 48,
      width: isExpanded ? 160 : 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isExpanded ? _buildExpandedMenu(context) : _buildCollapsedButton(context),
    );
  }

  Widget _buildCollapsedButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onToggle,
        child: Center(
          child: Icon(
            Icons.language_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedMenu(BuildContext context) {
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
          ),
          _LanguageItem(
            code: 'en',
            label: 'EN',
            isSelected: currentLanguage == 'en',
            onTap: () => onChangeLanguage('en'),
          ),
          _LanguageItem(
            code: 'de',
            label: 'DE',
            isSelected: currentLanguage == 'de',
            onTap: () => onChangeLanguage('de'),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  const _LanguageItem({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}