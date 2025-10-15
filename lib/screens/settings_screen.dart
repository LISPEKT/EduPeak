// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../theme/theme_manager.dart';
import 'auth_screen.dart';
import 'avatar_crop_screen.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final String currentAvatar;
  final Function(String) onAvatarUpdate;
  final Function(String) onUsernameUpdate;

  const SettingsScreen({
    required this.onLogout,
    required this.currentAvatar,
    required this.onAvatarUpdate,
    required this.onUsernameUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSendingFeedback = false;
  bool _isLoading = false;
  String _currentUsername = '';

  static const String _botToken = '8326804174:AAE0KfB3X1MIuW4YE9mT2zbl7eAnw4OHDJ4';
  static const String _chatId = '1236849662';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await UserDataStorage.getUsername();
    setState(() {
      _currentUsername = username;
      _usernameController.text = username;
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Открываем редактор фото перед сохранением
        final editedImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AvatarCropScreen(imagePath: image.path),
          ),
        );

        if (editedImagePath != null && editedImagePath is String) {
          setState(() => _isLoading = true);

          try {
            final response = await ApiService.updateAvatar(editedImagePath);

            if (response['success'] == true) {
              // Сохраняем локально
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_avatar_path', editedImagePath);
              widget.onAvatarUpdate(editedImagePath);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Фото профиля успешно обновлено'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка загрузки: $e'),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при выборе изображения'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя пользователя')),
      );
      return;
    }

    await UserDataStorage.saveUsername(newUsername);
    widget.onUsernameUpdate(newUsername);

    setState(() {
      _currentUsername = newUsername;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Имя пользователя обновлено!'),
          backgroundColor: Colors.green,
        ),
      );
      FocusScope.of(context).unfocus();
    }
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

              // Выходим из аккаунта на сервере
              await ApiService.logout();

              // Очищаем локальные данные
              await UserDataStorage.clearUserData();

              // Закрываем экран настроек
              if (mounted) {
                Navigator.pop(context);
              }

              // Вызываем колбэк выхода
              widget.onLogout();
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

  bool _isPhotoAvatar() {
    return widget.currentAvatar.startsWith('/');
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

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
          _buildProfileSection(),

          const SizedBox(height: 20),

          // Настройки темы
          _buildThemeSection(themeManager),

          const SizedBox(height: 20),

          // Сброс прогресса
          _buildResetProgressSection(),

          const SizedBox(height: 20),

          // Обратная связь через Telegram
          _buildFeedbackSection(),

          const SizedBox(height: 20),

          // Информация о приложении
          _buildAppInfoSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
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
              onTap: _isLoading ? null : _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                      image: _isPhotoAvatar()
                          ? DecorationImage(
                        image: FileImage(File(widget.currentAvatar)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _isPhotoAvatar()
                        ? null
                        : Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
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

            // Изменение имени пользователя
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Имя пользователя',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _updateUsername,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Обновить имя'),
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
    );
  }

  Widget _buildThemeSection(ThemeManager themeManager) {
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
                  'Внешний вид',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Тема применится мгновенно',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              context: context,
              title: 'Системная тема',
              subtitle: 'Следовать настройкам системы',
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
              title: 'Тёмная тема',
              subtitle: 'Всегда использовать тёмную тему',
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
              title: 'Светлая тема',
              subtitle: 'Всегда использовать светлую тему',
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

  Widget _buildResetProgressSection() {
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
    );
  }

  Widget _buildFeedbackSection() {
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
    );
  }

  Widget _buildAppInfoSection() {
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
                  'О приложении',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              title: 'Версия',
              value: 'alpha 0.24',
            ),
            _buildInfoRow(
              title: 'Разработчик',
              value: 'Murlit Studio',
            ),
            _buildInfoRow(
              title: 'Поддержка',
              value: 'Telegram: @lispekt',
            ),
            _buildInfoRow(
              title: 'Дата сборки',
              value: '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
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