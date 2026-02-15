import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../theme/theme_manager.dart';
import 'auth_screen.dart';
import '../services/api_service.dart';
import '../localization.dart';
import '../language_manager.dart';
import '../services/region_manager.dart';
import '../models/region.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSendingFeedback = false;
  bool _isResettingProgress = false;
  bool _showDeveloperOptions = false;
  int _aboutAppTapCount = 0;
  String? _deviceToken;
  bool _isLoadingToken = false;

  static const String _botToken = '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4';
  static const String _chatId = '1236849662';

  @override
  void initState() {
    super.initState();
    _loadDeveloperSettings();
  }

  Future<void> _loadDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showDeveloperOptions = prefs.getBool('show_developer_options') ?? false;
    });
  }

  Future<void> _loadDeviceToken() async {
    setState(() {
      _isLoadingToken = true;
    });

    try {
      // Пробуем получить из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString('device_token');

      if (savedToken != null && savedToken.isNotEmpty) {
        print('📱 Device Token из SharedPreferences: $savedToken');
        setState(() {
          _deviceToken = savedToken;
        });
        return;
      }

      // Генерируем новый токен устройства
      final newToken = 'DEVICE_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}';
      print('📱 Сгенерирован новый Device Token: $newToken');

      // Сохраняем для будущего использования
      await prefs.setString('device_token', newToken);

      setState(() {
        _deviceToken = newToken;
      });
    } catch (e) {
      print('❌ Ошибка получения токена устройства: $e');
      setState(() {
        _deviceToken = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoadingToken = false;
      });
    }
  }

  void _handleAboutAppTap() async {
    setState(() {
      _aboutAppTapCount++;
    });

    if (_aboutAppTapCount >= 20 && !_showDeveloperOptions) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_developer_options', true);

      setState(() {
        _showDeveloperOptions = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Опции разработчика разблокированы!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context);
    final regionManager = Provider.of<RegionManager>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

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
            stops: [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Раздел',
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
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Регион обучения
                    _buildSectionCard(
                      title: 'Регион обучения',
                      subtitle: 'Выберите страну для соответствующей учебной программы',
                      icon: Icons.public_rounded,
                      iconColor: Colors.blue,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Страна обучения',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: regionManager.currentRegion.id,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    items: regionManager.availableRegions.map((region) {
                                      return DropdownMenuItem<String>(
                                        value: region.id,
                                        child: Row(
                                          children: [
                                            Text(region.flag),
                                            const SizedBox(width: 12),
                                            Text(
                                              region.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.textTheme.titleMedium?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != null && newValue != regionManager.currentRegion.id) {
                                        final currentLanguage = languageManager.currentLanguageCode;
                                        final message = await regionManager.setCurrentRegion(newValue, currentLanguage: currentLanguage);
                                        final newRegion = regionManager.getRegionById(newValue);

                                        if (!newRegion.supportedLanguages.contains(currentLanguage)) {
                                          final defaultLanguage = newRegion.defaultLanguage;
                                          await languageManager.setLanguage(defaultLanguage);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(message ?? 'Язык изменен на $defaultLanguage для региона ${newRegion.name}'),
                                                backgroundColor: theme.colorScheme.primary,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${regionManager.currentRegion.totalGrades} классов, ${regionManager.currentRegion.curriculum.length} предметов',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Тема приложения
                    _buildSectionCard(
                      title: appLocalizations.appearance,
                      subtitle: appLocalizations.themeAppliedInstantly,
                      icon: Icons.palette_rounded,
                      iconColor: Colors.purple,
                      isDark: isDark,
                      child: Column(
                        children: [
                          _buildThemeOption(
                            title: appLocalizations.systemTheme,
                            subtitle: appLocalizations.followSystemSettings,
                            value: themeManager.useSystemTheme,
                            onChanged: (value) async {
                              if (value) await themeManager.setUseSystemTheme(true);
                            },
                            isLoading: themeManager.isLoading,
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOption(
                            title: appLocalizations.darkTheme,
                            subtitle: appLocalizations.alwaysUseDarkTheme,
                            value: themeManager.useDarkTheme,
                            onChanged: (value) async {
                              if (value) await themeManager.setUseDarkTheme(true);
                            },
                            isLoading: themeManager.isLoading,
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOption(
                            title: appLocalizations.lightTheme,
                            subtitle: appLocalizations.alwaysUseLightTheme,
                            value: !themeManager.useSystemTheme && !themeManager.useDarkTheme,
                            onChanged: (value) async {
                              if (value) await themeManager.setLightTheme();
                            },
                            isLoading: themeManager.isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Язык
                    _buildSectionCard(
                      title: appLocalizations.languageSettings,
                      subtitle: 'Доступные языки для региона ${regionManager.currentRegion.name}',
                      icon: Icons.language_rounded,
                      iconColor: Colors.teal,
                      isDark: isDark,
                      child: Column(
                        children: [
                          if (regionManager.currentRegion.supportedLanguages.contains('ru'))
                            _buildLanguageOption(
                              title: appLocalizations.russian,
                              value: languageManager.currentLocale.languageCode == 'ru',
                              onChanged: () => languageManager.setRussian(),
                              isLoading: languageManager.isLoading,
                            ),
                          if (regionManager.currentRegion.supportedLanguages.contains('ru'))
                            const SizedBox(height: 12),
                          if (regionManager.currentRegion.supportedLanguages.contains('en'))
                            _buildLanguageOption(
                              title: appLocalizations.english,
                              value: languageManager.currentLocale.languageCode == 'en',
                              onChanged: () => languageManager.setEnglish(),
                              isLoading: languageManager.isLoading,
                            ),
                          if (regionManager.currentRegion.supportedLanguages.contains('en'))
                            const SizedBox(height: 12),
                          if (regionManager.currentRegion.supportedLanguages.contains('de'))
                            _buildLanguageOption(
                              title: appLocalizations.german,
                              value: languageManager.currentLocale.languageCode == 'de',
                              onChanged: () => languageManager.setGerman(),
                              isLoading: languageManager.isLoading,
                            ),
                          if (regionManager.currentRegion.supportedLanguages.contains('de'))
                            const SizedBox(height: 12),
                          if (regionManager.currentRegion.supportedLanguages.contains('lt'))
                            _buildLanguageOption(
                              title: 'Литовский',
                              value: languageManager.currentLocale.languageCode == 'lt',
                              onChanged: () => languageManager.setLanguage('lt'),
                              isLoading: languageManager.isLoading,
                            ),
                          if (regionManager.currentRegion.supportedLanguages.contains('lt'))
                            const SizedBox(height: 12),
                          if (regionManager.currentRegion.supportedLanguages.contains('vi'))
                            _buildLanguageOption(
                              title: 'Вьетнамский',
                              value: languageManager.currentLocale.languageCode == 'vi',
                              onChanged: () => languageManager.setLanguage('vi'),
                              isLoading: languageManager.isLoading,
                            ),
                          if (regionManager.currentRegion.supportedLanguages.contains('vi'))
                            const SizedBox(height: 12),
                          if (regionManager.currentRegion.supportedLanguages.contains('kz'))
                            _buildLanguageOption(
                              title: 'Казахский',
                              value: languageManager.currentLocale.languageCode == 'kz',
                              onChanged: () => languageManager.setLanguage('kz'),
                              isLoading: languageManager.isLoading,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Сброс прогресса
                    _buildSectionCard(
                      title: appLocalizations.progressManagement,
                      subtitle: appLocalizations.resetProgressDescription,
                      icon: Icons.restart_alt_rounded,
                      iconColor: Colors.orange,
                      isDark: isDark,
                      child: Container(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isResettingProgress ? null : _resetProgress,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isResettingProgress
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restart_alt_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                appLocalizations.resetProgressButton,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Обратная связь
                    _buildSectionCard(
                      title: appLocalizations.feedback,
                      subtitle: appLocalizations.feedbackDescription,
                      icon: Icons.telegram_rounded,
                      iconColor: Colors.blue,
                      isDark: isDark,
                      child: Column(
                        children: [
                          TextField(
                            controller: _feedbackController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: appLocalizations.feedbackHint,
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isSendingFeedback ? null : _sendFeedback,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSendingFeedback
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    appLocalizations.sendTelegramButton,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Информация о приложении
                    GestureDetector(
                      onTap: _handleAboutAppTap,
                      child: _buildSectionCard(
                        title: appLocalizations.aboutApp,
                        subtitle: 'Версия и контактная информация',
                        icon: Icons.info_rounded,
                        iconColor: primaryColor,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _buildInfoRow(
                              title: appLocalizations.version,
                              value: 'alpha 0.42.6',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              title: appLocalizations.developer,
                              value: 'Murlit Studio',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              title: appLocalizations.support,
                              value: 'Telegram: @lispekt',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              title: appLocalizations.buildDate,
                              value: '14.02.2026',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Параметры разработчика (появляется после 20 нажатий)
                    if (_showDeveloperOptions)
                      _buildSectionCard(
                        title: 'Параметры разработчика',
                        subtitle: 'Служебные настройки для отладки',
                        icon: Icons.developer_mode_rounded,
                        iconColor: Colors.deepPurple,
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Показать токен устройства
                            _buildDeveloperOption(
                              title: 'Токен устройства',
                              subtitle: 'Уникальный идентификатор устройства',
                              icon: Icons.device_hub_rounded,
                              color: Colors.deepPurple,
                              onTap: () {
                                if (_deviceToken == null && !_isLoadingToken) {
                                  _loadDeviceToken();
                                }
                                _showDeviceTokenDialog();
                              },
                              showLoading: _isLoadingToken,
                            ),
                          ],
                        ),
                      ),

                    if (_showDeveloperOptions) const SizedBox(height: 16),

                    // Выход из аккаунта
                    _buildSectionCard(
                      title: appLocalizations.accountLogout,
                      subtitle: appLocalizations.logoutDescription,
                      icon: Icons.logout_rounded,
                      iconColor: Colors.red,
                      isDark: isDark,
                      child: Container(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _showLogoutDialog,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                appLocalizations.logout,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required bool value,
    required VoidCallback onChanged,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : onChanged,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? theme.colorScheme.primary : theme.textTheme.titleMedium?.color,
              ),
            ),
            if (isLoading && value)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else if (value)
              Icon(
                Icons.check_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                      color: value ? theme.colorScheme.primary : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading && value)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: isLoading ? null : onChanged,
                  activeColor: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showLoading = false,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.hintColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.hintColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
      ],
    );
  }

  void _showDeviceTokenDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.device_hub_rounded,
                  color: Colors.deepPurple,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Токен устройства',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 12),
              if (_isLoadingToken)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                )
              else if (_deviceToken != null && _deviceToken!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Токен:',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: _deviceToken!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Токен скопирован в буфер обмена'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: SelectableText(
                          _deviceToken!,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Text(
                      'Не удалось получить токен',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        _loadDeviceToken();
                        Navigator.pop(context);
                        _showDeviceTokenDialog();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Попробовать снова'),
                    ),
                  ],
                ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Закрыть',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, введите ваш отзыв'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() { _isSendingFeedback = true; });

    try {
      final stats = await UserDataStorage.getUserStats();
      final username = stats.username.isNotEmpty ? stats.username : 'Анонимный пользователь';
      final streak = stats.streakDays;
      final completedTopics = _calculateCompletedTopics(stats);

      final message = '''
Пользователь: $username
Дней подряд: $streak
Пройдено тем: $completedTopics
Дата: ${DateTime.now().toString().split(' ')[0]}

Сообщение:
$feedback
      ''';

      final success = await _sendToTelegram(message);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Отзыв успешно отправлен!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _feedbackController.clear();
        FocusScope.of(context).unfocus();
      } else {
        throw Exception('Не удалось отправить сообщение');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки. Проверьте интернет соединение.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() { _isSendingFeedback = false; });
    }
  }

  Future<bool> _sendToTelegram(String message) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');

      final httpClient = HttpClient();
      final request = await httpClient.postUrl(url);

      final body = {
        'chat_id': _chatId,
        'text': message,
      };

      final bodyString = body.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write(bodyString);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      httpClient.close();

      final jsonResponse = json.decode(responseBody);
      return jsonResponse['ok'] == true;
    } catch (e) {
      print('Telegram error: $e');
      return false;
    }
  }

  int _calculateCompletedTopics(UserStats stats) {
    int completed = 0;
    for (final subject in stats.topicProgress.values) {
      completed += subject.length;
    }
    return completed;
  }

  Future<void> _resetProgress() async {
    final password = await _showPasswordDialog();
    if (password == null) return;

    setState(() {
      _isResettingProgress = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');

      if (userEmail == null) {
        throw Exception('Не удалось найти данные пользователя');
      }

      final loginResult = await ApiService.login(userEmail, password);

      if (loginResult['success'] == true) {
        final confirmed = await _showFinalConfirmationDialog();
        if (confirmed != true) return;

        final currentUsername = await UserDataStorage.getUsername();
        final currentAvatar = await UserDataStorage.getAvatar();

        final cleanStats = UserStats(
          streakDays: 0,
          lastActivity: DateTime.now(),
          topicProgress: {},
          dailyCompletion: {},
          username: currentUsername,
          totalXP: 0,
          weeklyXP: 0,
          lastWeeklyReset: DateTime.now(),
        );

        await UserDataStorage.saveUserStats(cleanStats);

        final progressKeys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();
        for (final key in progressKeys) {
          await prefs.remove(key);
        }

        if (currentAvatar != '👤') {
          await UserDataStorage.saveAvatar(currentAvatar);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Прогресс успешно сброшен. Теперь можно заново проходить тесты и получать XP.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Неверный пароль');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      _passwordController.clear();
      if (mounted) {
        setState(() {
          _isResettingProgress = false;
        });
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final theme = Theme.of(context);

    return await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Подтверждение сброса',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Введите пароль от вашей учетной записи:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_passwordController.text.isNotEmpty) {
                          Navigator.pop(context, _passwordController.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Введите пароль'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Продолжить',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showFinalConfirmationDialog() async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Внимание!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'ВСЕ ваши данные прогресса будут безвозвратно удалены. Это действие нельзя отменить.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Вы уверены, что хотите продолжить?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Сбросить',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                appLocalizations.accountLogout,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Вы уверены, что хотите выйти?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Выход выполняется...'),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );

                        await UserDataStorage.clearUserData();

                        try {
                          await ApiService.logout();
                          print('✅ Logout successful from server');
                        } catch (e) {
                          print('⚠️ Server logout failed: $e');
                        }

                        widget.onLogout();

                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                                (route) => false,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Выход выполнен успешно'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        appLocalizations.logout,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}