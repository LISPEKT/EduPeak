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

  Future<void> _sendFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ваш отзыв')),
      );
      return;
    }

    setState(() {
      _isSendingFeedback = true;
    });

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
          const SnackBar(
            content: Text('Отзыв успешно отправлен!'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
        FocusScope.of(context).unfocus();
      } else {
        throw Exception('Не удалось отправить сообщение');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка отправки. Проверьте интернет соединение.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSendingFeedback = false;
      });
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

        final stats = await UserDataStorage.getUserStats();
        stats.resetProgress();
        await UserDataStorage.saveUserStats(stats);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Прогресс успешно сброшен'),
              backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.settings),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(themeManager, appLocalizations),

          const SizedBox(height: 20),

          _buildLanguageSection(languageManager, appLocalizations),

          const SizedBox(height: 20),

          _buildResetProgressSection(appLocalizations),

          const SizedBox(height: 20),

          _buildFeedbackSection(appLocalizations),

          const SizedBox(height: 20),

          _buildAppInfoSection(appLocalizations),

          const SizedBox(height: 20),

          _buildLogoutSection(appLocalizations),
        ],
      ),
    );
  }

  Widget _buildThemeSection(ThemeManager themeManager, AppLocalizations appLocalizations) {
    final isLightTheme = !themeManager.useSystemTheme && !themeManager.useDarkTheme;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.appearance,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.themeAppliedInstantly,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              context: context,
              title: appLocalizations.systemTheme,
              subtitle: appLocalizations.followSystemSettings,
              value: themeManager.useSystemTheme,
              onChanged: (value) async {
                if (value) {
                  await themeManager.setUseSystemTheme(true);
                }
              },
              isLoading: themeManager.isLoading,
            ),
            const Divider(height: 24),
            _buildThemeOption(
              context: context,
              title: appLocalizations.darkTheme,
              subtitle: appLocalizations.alwaysUseDarkTheme,
              value: themeManager.useDarkTheme,
              onChanged: (value) async {
                if (value) {
                  await themeManager.setUseDarkTheme(true);
                } else if (!themeManager.useSystemTheme && !themeManager.useDarkTheme) {
                  await themeManager.setLightTheme();
                }
              },
              isLoading: themeManager.isLoading,
            ),
            const Divider(height: 24),
            _buildThemeOption(
              context: context,
              title: appLocalizations.lightTheme,
              subtitle: appLocalizations.alwaysUseLightTheme,
              value: isLightTheme,
              onChanged: (value) async {
                if (value) {
                  await themeManager.setLightTheme();
                } else {
                  await themeManager.setUseDarkTheme(true);
                }
              },
              isLoading: themeManager.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(LanguageManager languageManager, AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.languageSettings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.selectAppLanguage,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(
              title: appLocalizations.russian,
              value: languageManager.currentLocale.languageCode == 'ru',
              onChanged: () => languageManager.setRussian(),
              isLoading: languageManager.isLoading,
            ),
            const Divider(height: 24),
            _buildLanguageOption(
              title: appLocalizations.english,
              value: languageManager.currentLocale.languageCode == 'en',
              onChanged: () => languageManager.setEnglish(),
              isLoading: languageManager.isLoading,
            ),
            const Divider(height: 24),
            _buildLanguageOption(
              title: appLocalizations.german,
              value: languageManager.currentLocale.languageCode == 'de',
              onChanged: () => languageManager.setGerman(),
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
    return IgnorePointer(
      ignoring: isLoading,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isLoading && value) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: value,
              onChanged: isLoading ? null : (bool? newValue) {
                if (newValue == true) {
                  onChanged();
                }
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isLoading,
  }) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  if (isLoading && value) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: isLoading ? null : onChanged,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetProgressSection(AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.progressManagement,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.resetProgressDescription,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isResettingProgress ? null : _resetProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isResettingProgress
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restart_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      appLocalizations.resetProgressButton,
                      style: TextStyle(fontSize: 16),
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

  Widget _buildFeedbackSection(AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.telegram,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.feedback,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.feedbackDescription,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: appLocalizations.feedbackHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSendingFeedback ? null : _sendFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSendingFeedback
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Text(
                      appLocalizations.sendTelegramButton,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildAppInfoSection(AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.aboutApp,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              title: appLocalizations.version,
              value: 'alpha 0.32',
            ),
            _buildInfoRow(
              title: appLocalizations.developer,
              value: 'Murlit Studio',
            ),
            _buildInfoRow(
              title: appLocalizations.support,
              value: 'Telegram: @lispekt',
            ),
            _buildInfoRow(
              title: appLocalizations.buildDate,
              value: '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.accountLogout,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.logoutDescription,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      appLocalizations.logout,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildInfoRow({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}