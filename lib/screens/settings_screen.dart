import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final String currentAvatar;
  final Function(String) onAvatarUpdate;

  const SettingsScreen({
    required this.onLogout,
    required this.currentAvatar,
    required this.onAvatarUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSendingFeedback = false;
  bool _useSystemTheme = true;
  bool _useDarkTheme = false;

  static const String _botToken = '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4';
  static const String _chatId = '1236849662';

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useSystemTheme = prefs.getBool('use_system_theme') ?? true;
      _useDarkTheme = prefs.getBool('use_dark_theme') ?? false;
    });
  }

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
      // Получаем данные пользователя
      final stats = await UserDataStorage.getUserStats();
      final username = stats.username.isNotEmpty ? stats.username : 'Анонимный пользователь';
      final streak = stats.streakDays;
      final completedTopics = _calculateCompletedTopics(stats);

      // Формируем сообщение
      final message = '''
НОВЫЙ ОТЗЫВ ИЗ EDUPEAK

Пользователь: $username
Дней подряд: $streak
Пройдено тем: $completedTopics
Дата: ${DateTime.now().toString().split(' ')[0]}

Сообщение:
$feedback

---
Приложение: EduPeak
      ''';

      // Отправляем в Telegram
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

  Future<void> _saveThemeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_system_theme', value);
    if (value) {
      await prefs.setBool('use_dark_theme', false);
    }
    setState(() {
      _useSystemTheme = value;
      if (value) _useDarkTheme = false;
    });
  }

  Future<void> _saveDarkThemeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_dark_theme', value);
    if (value) {
      await prefs.setBool('use_system_theme', false);
    }
    setState(() {
      _useDarkTheme = value;
      if (value) _useSystemTheme = false;
    });
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Сбросить прогресс',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'Вы уверены? Это действие нельзя отменить. Весь ваш прогресс будет удален.',
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
              'Сбросить',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final stats = await UserDataStorage.getUserStats();
      stats.resetProgress();
      await UserDataStorage.saveUserStats(stats);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Прогресс успешно сброшен'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showAvatarSelectionDialog() {
    final avatars = ['🐳','😎','😭','👻','👾','🐁'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Выберите аватар',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.onAvatarUpdate(avatars[index]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.currentAvatar == avatars[index]
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatars[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
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
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Выйти из аккаунта',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите выйти? Все ваши данные будут удалены.',
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

              // Полностью очищаем все данные пользователя
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Вызываем колбэк выхода
              widget.onLogout();

              // Закрываем экран настроек
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль пользователя
          Card(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarSelectionDialog,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.currentAvatar,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Нажмите для смены аватара',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Выйти из аккаунта',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Настройки темы
          Card(
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
                        'Внешний вид',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Для применения темы перезапустите приложение',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildThemeOption(
                    title: 'Системная тема',
                    subtitle: 'Следовать настройкам системы',
                    value: _useSystemTheme,
                    onChanged: _saveThemeSetting,
                  ),
                  const Divider(height: 24),
                  _buildThemeOption(
                    title: 'Тёмная тема',
                    subtitle: 'Всегда использовать тёмную тему',
                    value: _useDarkTheme,
                    onChanged: _saveDarkThemeSetting,
                  ),
                  const Divider(height: 24),
                  _buildThemeOption(
                    title: 'Светлая тема',
                    subtitle: 'Всегда использовать светлую тему',
                    value: !_useSystemTheme && !_useDarkTheme,
                    onChanged: (value) {
                      if (value) {
                        _saveThemeSetting(false);
                        _saveDarkThemeSetting(false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Сброс прогресса
          Card(
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
                        'Управление прогрессом',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сбросить весь прогресс обучения',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetProgress,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restart_alt, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Сбросить прогресс обучения',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Обратная связь через Telegram
          Card(
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
                        'Обратная связь',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Отправьте ваш отзыв или предложение. Мы получим его мгновенно!',
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
                      hintText: 'Напишите ваш отзыв, идею или сообщите об ошибке...',
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
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Отправить через Telegram',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Информация о приложении
          Card(
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
                        'О приложении',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Версия', 'alpha 0.19'),
                  _buildInfoRow('Разработчик', 'Murlit Studio'),
                  _buildInfoRow('Поддержка', 'Telegram: @lispekt'),
                  _buildInfoRow('Дата сборки', '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
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
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
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