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

  static const String _botToken = '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4';
  static const String _chatId = '1236849662';

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context);
    final regionManager = Provider.of<RegionManager>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          appLocalizations.settings,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRegionSection(regionManager, appLocalizations),
          const SizedBox(height: 16),
          _buildThemeSection(themeManager, appLocalizations),
          const SizedBox(height: 16),
          _buildLanguageSection(languageManager, appLocalizations, regionManager),
          const SizedBox(height: 16),
          _buildResetProgressSection(appLocalizations),
          const SizedBox(height: 16),
          _buildFeedbackSection(appLocalizations),
          const SizedBox(height: 16),
          _buildAppInfoSection(appLocalizations),
          const SizedBox(height: 16),
          _buildLogoutSection(appLocalizations),
        ],
      ),
    );
  }

  Widget _buildRegionSection(RegionManager regionManager, AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.public_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Регион обучения',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Выберите страну для соответствующей учебной программы',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Страна обучения',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: regionManager.currentRegion.id,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null && newValue != regionManager.currentRegion.id) {
                          final languageManager = Provider.of<LanguageManager>(context, listen: false);
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
                                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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

  Widget _buildThemeSection(ThemeManager themeManager, AppLocalizations appLocalizations) {
    final isLightTheme = !themeManager.useSystemTheme && !themeManager.useDarkTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.appearance,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        appLocalizations.themeAppliedInstantly,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              title: appLocalizations.systemTheme,
              subtitle: appLocalizations.followSystemSettings,
              value: themeManager.useSystemTheme,
              onChanged: (value) async {
                if (value) await themeManager.setUseSystemTheme(true);
              },
              isLoading: themeManager.isLoading,
            ),
            const Divider(height: 24),
            _buildThemeOption(
              title: appLocalizations.darkTheme,
              subtitle: appLocalizations.alwaysUseDarkTheme,
              value: themeManager.useDarkTheme,
              onChanged: (value) async {
                if (value) await themeManager.setUseDarkTheme(true);
              },
              isLoading: themeManager.isLoading,
            ),
            const Divider(height: 24),
            _buildThemeOption(
              title: appLocalizations.lightTheme,
              subtitle: appLocalizations.alwaysUseLightTheme,
              value: isLightTheme,
              onChanged: (value) async {
                if (value) await themeManager.setLightTheme();
              },
              isLoading: themeManager.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(LanguageManager languageManager, AppLocalizations appLocalizations, RegionManager regionManager) {
    final supportedLanguages = regionManager.currentRegion.supportedLanguages;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.languageSettings,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Доступные языки для региона ${regionManager.currentRegion.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (supportedLanguages.contains('ru'))
              _buildLanguageOption(
                title: appLocalizations.russian,
                value: languageManager.currentLocale.languageCode == 'ru',
                onChanged: () => languageManager.setRussian(),
                isLoading: languageManager.isLoading,
              ),
            if (supportedLanguages.contains('ru')) const Divider(height: 16),
            if (supportedLanguages.contains('en'))
              _buildLanguageOption(
                title: appLocalizations.english,
                value: languageManager.currentLocale.languageCode == 'en',
                onChanged: () => languageManager.setEnglish(),
                isLoading: languageManager.isLoading,
              ),
            if (supportedLanguages.contains('en')) const Divider(height: 16),
            if (supportedLanguages.contains('de'))
              _buildLanguageOption(
                title: appLocalizations.german,
                value: languageManager.currentLocale.languageCode == 'de',
                onChanged: () => languageManager.setGerman(),
                isLoading: languageManager.isLoading,
              ),
            if (supportedLanguages.contains('lt')) const Divider(height: 16),
            if (supportedLanguages.contains('lt'))
              _buildLanguageOption(
                title: 'Литовский',
                value: languageManager.currentLocale.languageCode == 'lt',
                onChanged: () => languageManager.setLanguage('lt'),
                isLoading: languageManager.isLoading,
              ),
            if (supportedLanguages.contains('vi')) const Divider(height: 16),
            if (supportedLanguages.contains('vi'))
              _buildLanguageOption(
                title: 'Вьетнамский',
                value: languageManager.currentLocale.languageCode == 'vi',
                onChanged: () => languageManager.setLanguage('vi'),
                isLoading: languageManager.isLoading,
              ),
            if (supportedLanguages.contains('kz')) const Divider(height: 16),
            if (supportedLanguages.contains('kz'))
              _buildLanguageOption(
                title: 'Казахский',
                value: languageManager.currentLocale.languageCode == 'kz',
                onChanged: () => languageManager.setLanguage('kz'),
                isLoading: languageManager.isLoading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required bool value,
    required VoidCallback onChanged,
    required bool isLoading,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isLoading && value
          ? SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : Icon(
        Icons.check_rounded,
        color: value ? Theme.of(context).colorScheme.primary : Colors.transparent,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          color: value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: isLoading ? null : onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isLoading,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isLoading && value
          ? SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : Icon(
        Icons.check_rounded,
        color: value ? Theme.of(context).colorScheme.primary : Colors.transparent,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: value ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: isLoading ? null : onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: isLoading ? null : () => onChanged(!value),
    );
  }

  Widget _buildResetProgressSection(AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.progressManagement,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        appLocalizations.resetProgressDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isResettingProgress ? null : _resetProgress,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.telegram_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.feedback,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        appLocalizations.feedbackDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: appLocalizations.feedbackHint,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSendingFeedback ? null : _sendFeedback,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLocalizations.aboutApp,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(title: appLocalizations.version, value: 'alpha 0.35.2'),
            const Divider(height: 16),
            _buildInfoRow(title: appLocalizations.developer, value: 'Murlit Studio'),
            const Divider(height: 16),
            _buildInfoRow(title: appLocalizations.support, value: 'Telegram: @lispekt'),
            const Divider(height: 16),
            _buildInfoRow(title: appLocalizations.buildDate, value: '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.accountLogout,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        appLocalizations.logoutDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _showLogoutDialog,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    appLocalizations.logout,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Остальные методы (_sendFeedback, _resetProgress, _showPasswordDialog, _showFinalConfirmationDialog, _showLogoutDialog)
  // остаются без изменений, только нужно обновить SnackBar и AlertDialog в стиле MD3

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

        // Сохраняем текущие данные пользователя перед сбросом
        final currentUsername = await UserDataStorage.getUsername();
        final currentAvatar = await UserDataStorage.getAvatar();

        // Создаем новую чистую статистику
        final cleanStats = UserStats(
          streakDays: 0,
          lastActivity: DateTime.now(),
          topicProgress: {}, // ПУСТОЙ прогресс по темам
          dailyCompletion: {},
          username: currentUsername, // Сохраняем имя
          totalXP: 0,
          weeklyXP: 0,
          lastWeeklyReset: DateTime.now(),
        );

        // Сохраняем чистую статистику
        await UserDataStorage.saveUserStats(cleanStats);

        // Очищаем локальный прогресс в SharedPreferences
        final progressKeys = prefs.getKeys().where((key) => key.startsWith('progress_')).toList();
        for (final key in progressKeys) {
          await prefs.remove(key);
        }

        // Восстанавливаем аватар если был
        if (currentAvatar != '👤') {
          await UserDataStorage.saveAvatar(currentAvatar);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Прогресс успешно сброшен. Теперь можно заново проходить тесты и получать XP.'),
              backgroundColor: Colors.green,
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
    final appLocalizations = AppLocalizations.of(context);

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Подтверждение сброса прогресса',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Для сброса прогресса введите пароль от вашей учетной записи:',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_passwordController.text.isNotEmpty) {
                Navigator.pop(context, _passwordController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Введите пароль'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text(
              'Продолжить',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showFinalConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Окончательное подтверждение',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'ВСЕ ваши данные прогресса будут безвозвратно удалены. Это действие нельзя отменить.\n\nВы уверены, что хотите продолжить?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Сбросить прогресс',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          appLocalizations.accountLogout,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Выход выполняется...'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }

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
                  const SnackBar(
                    content: Text('Выход выполнен успешно'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              appLocalizations.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}