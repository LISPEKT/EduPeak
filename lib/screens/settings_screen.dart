// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../localization.dart';
import '../theme/theme_manager.dart';
import '../language_manager.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import 'auth_screen.dart';

// Импорты подэкранов
import 'settings/account_settings_screen.dart';
import 'settings/security_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/theme_settings_screen.dart';
import 'settings/devices_settings_screen.dart';
import 'settings/language_settings_screen.dart';
import 'subscription_screen.dart';
import 'settings/support_screen.dart';
import 'settings/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({
    required this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  int _aboutAppTapCount = 0;
  bool _showDeveloperOptions = false;

  // Данные для отображения
  String _username = '';
  String _email = '';
  String _avatar = '👤';
  int _activeSessions = 1;
  int _unreadSupportMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDeveloperSettings();
    _loadSupportUnreadCount();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      _username = await UserDataStorage.getUsername();
      _avatar = await UserDataStorage.getAvatar();

      final prefs = await SharedPreferences.getInstance();
      _email = prefs.getString('userEmail') ?? 'не указан';

      final sessions = prefs.getStringList('active_sessions');
      _activeSessions = sessions?.length ?? 1;

    } catch (e) {
      print('❌ Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showDeveloperOptions = prefs.getBool('show_developer_options') ?? false;
    });
  }

  Future<void> _loadSupportUnreadCount() async {
    // TODO: Загрузить количество непрочитанных сообщений
    setState(() {
      _unreadSupportMessages = 0;
    });
  }

  void _handleAboutAppTap() async {
    setState(() => _aboutAppTapCount++);

    if (_aboutAppTapCount >= 20 && !_showDeveloperOptions) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_developer_options', true);

      setState(() => _showDeveloperOptions = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Опции разработчика разблокированы!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalizations.section,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          appLocalizations.settings,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Список основных пунктов меню
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Аккаунт
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      iconColor: Colors.blue,
                      title: 'Аккаунт',
                      subtitle: _username,
                      onTap: () => _navigateToAccountSettings(context),
                    ),

                    // Безопасность
                    _buildMenuItem(
                      icon: Icons.security_rounded,
                      iconColor: Colors.green,
                      title: 'Безопасность',
                      subtitle: '$_activeSessions активных сессий',
                      onTap: () => _navigateToSecuritySettings(context),
                    ),

                    // Уведомления
                    _buildMenuItem(
                      icon: Icons.notifications_rounded,
                      iconColor: Colors.orange,
                      title: 'Уведомления',
                      subtitle: 'Настройка уведомлений',
                      onTap: () => _navigateToNotificationsSettings(context),
                    ),

                    // Оформление
                    _buildMenuItem(
                      icon: Icons.palette_rounded,
                      iconColor: Colors.purple,
                      title: 'Оформление',
                      subtitle: isDark ? 'Темная тема' : 'Светлая тема',
                      onTap: () => _navigateToThemeSettings(context),
                    ),

                    // Устройства
                    _buildMenuItem(
                      icon: Icons.devices_other_rounded,
                      iconColor: Colors.teal,
                      title: 'Устройства',
                      subtitle: '$_activeSessions устройств',
                      onTap: () => _navigateToDevicesSettings(context),
                    ),

                    // Язык
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      iconColor: Colors.indigo,
                      title: 'Язык',
                      subtitle: _getCurrentLanguageName(),
                      onTap: () => _navigateToLanguageSettings(context),
                    ),

                    // EduPeak+
                    _buildMenuItem(
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                      title: 'EduPeak+',
                      subtitle: 'Премиум подписка',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Неактивна',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () => _navigateToSubscription(context),
                    ),

                    // Поддержка
                    _buildMenuItem(
                      icon: Icons.support_agent_rounded,
                      iconColor: Colors.blueGrey,
                      title: 'Поддержка',
                      subtitle: _unreadSupportMessages > 0
                          ? '$_unreadSupportMessages новых'
                          : 'Связаться с нами',
                      trailing: _unreadSupportMessages > 0
                          ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_unreadSupportMessages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : null,
                      onTap: () => _navigateToSupport(context),
                    ),

                    // О приложении (с секретным тапом)
                    GestureDetector(
                      onTap: _handleAboutAppTap,
                      behavior: HitTestBehavior.opaque,
                      child: _buildMenuItem(
                        icon: Icons.info_rounded,
                        iconColor: primaryColor,
                        title: 'О приложении',
                        subtitle: 'Версия beta 0.43.0',
                        onTap: () => _navigateToPrivacyPolicy(context),
                      ),
                    ),

                    // Опции разработчика (секретные)
                    if (_showDeveloperOptions) ...[
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        icon: Icons.developer_mode_rounded,
                        iconColor: Colors.deepPurple,
                        title: '⚡ Опции разработчика',
                        subtitle: 'Служебные настройки',
                        onTap: _showDeveloperOptionsDialog,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Кнопка выхода
                    _buildLogoutButton(theme),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Универсальный элемент меню
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing (если есть)
                if (trailing != null) trailing,

                // Стрелка
                if (trailing == null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.hintColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Кнопка выхода
  Widget _buildLogoutButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Выйти из аккаунта',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentLanguageName() {
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    return languageManager.getCurrentLanguageName();
  }

  // Навигационные методы
  void _navigateToAccountSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountSettingsScreen(
          currentUsername: _username,
          currentEmail: _email,
          currentAvatar: _avatar,
          onUpdate: _loadUserData,
        ),
      ),
    );
  }

  void _navigateToSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SecuritySettingsScreen(),
      ),
    );
  }

  void _navigateToNotificationsSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsSettingsScreen(),
      ),
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ThemeSettingsScreen(),
      ),
    );
  }

  void _navigateToDevicesSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DevicesSettingsScreen(),
      ),
    );
  }

  void _navigateToLanguageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LanguageSettingsScreen(),
      ),
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }

  void _navigateToSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportScreen(
          onNewMessage: _loadSupportUnreadCount,
        ),
      ),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _showDeveloperOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Опции разработчика'),
        content: const Text('Здесь будут служебные настройки'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await ApiService.logout();
      await UserDataStorage.clearUserData();

      if (context.mounted) Navigator.pop(context);

      widget.onLogout();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выходе: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}