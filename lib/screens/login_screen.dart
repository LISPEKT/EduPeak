// login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import '../data/user_data_storage.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import '../localization.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _serverAvailable = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _testingConnection = false;
  int _wifiTapCount = 0;
  bool _showSecretOption = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkServerAvailability();
  }

  Future<void> _checkServerAvailability() async {
    setState(() => _testingConnection = true);
    try {
      final available = await ApiService.checkServerAvailability();
      setState(() {
        _serverAvailable = available;
        _testingConnection = false;
      });
    } catch (e) {
      setState(() {
        _serverAvailable = false;
        _testingConnection = false;
      });
    }
  }

  Future<void> _testServerConnection() async {
    setState(() => _testingConnection = true);

    try {
      final available = await ApiService.checkServerAvailability();
      setState(() => _serverAvailable = available);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(available ? '✅ Сервер доступен' : '❌ Сервер недоступен'),
          backgroundColor: available ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() => _serverAvailable = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка проверки: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _testingConnection = false);
    }
  }

  void _handleWifiTap() {
    _wifiTapCount++;
    print('🔐 Secret tap count: $_wifiTapCount');

    if (_wifiTapCount >= 20 && !_showSecretOption) {
      setState(() {
        _showSecretOption = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Секретная функция разблокирована!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _createLocalAccount() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Creating local account...');

      final prefs = await SharedPreferences.getInstance();

      // Сохраняем данные пользователя
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', 'local@user.com');
      await prefs.setString('username', 'Локальный Пользователь');
      await prefs.setString('auth_method', 'local');

      // Инициализируем UserDataStorage
      await UserDataStorage.setLoggedIn(true);
      await UserDataStorage.saveUsername('Локальный Пользователь');

      // Создаем базовую статистику
      final initialStats = {
        'streakDays': 1,
        'lastActivity': DateTime.now().toIso8601String(),
        'topicProgress': {
          'История': {'introduction_history': 8},
          'Обществознание': {'social_studies_class6_topic1': 6}
        },
        'dailyCompletion': {},
        'username': 'Локальный Пользователь',
        'totalXP': 150,
        'weeklyXP': 50,
        'lastWeeklyReset': DateTime.now().toIso8601String(),
      };

      await prefs.setString('user_stats', jsonEncode(initialStats));

      print('✅ Local account created successfully!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
        );
      }
    } catch (e) {
      print('❌ Error creating local account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания аккаунта: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    final appLocalizations = AppLocalizations.of(context);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.pleaseFillAllFields),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Проверка формата email
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.enterValidEmail),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_serverAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.serverUnavailableCheckConnection),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Starting login process...');
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('📡 Login result: $response');

      if (response['success'] == true) {
        // Сохраняем имя пользователя локально (временно)
        final username = _emailController.text.split('@').first;
        await UserDataStorage.saveUsername(username);

        // Устанавливаем статус входа
        await UserDataStorage.setLoggedIn(true);

        // ПОЛНАЯ синхронизация с сервером с отладкой
        print('🔄 Starting full synchronization after login...');
        await UserDataStorage.syncFromServer();

        // Проверяем результат синхронизации
        final syncedUsername = await UserDataStorage.getUsername();
        final syncedAvatar = await UserDataStorage.getAvatar();
        print('🔄 Sync result - Username: $syncedUsername, Avatar: ${syncedAvatar != '👤' ? "Custom" : "Default"}');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? appLocalizations.loginError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Login exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.connectionError}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(appLocalizations.login),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _testingConnection
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.wifi_find_rounded),
            onPressed: () {
              _handleWifiTap();
              _testServerConnection();
            },
            tooltip: 'Проверить подключение к серверу',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Заголовок
              Text(
                appLocalizations.enterYourAccount,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'GoogleSans',
                ),
              ),

              const SizedBox(height: 8),

              // Описание
              Text(
                _serverAvailable
                    ? appLocalizations.enterCredentials
                    : appLocalizations.serverUnavailableCheckConnection,
                style: TextStyle(
                  fontSize: 14,
                  color: _serverAvailable
                      ? (isDark ? Colors.white70 : Colors.black54)
                      : Colors.orange,
                  fontFamily: 'Roboto',
                ),
              ),

              const SizedBox(height: 32),

              // Секретная кнопка (появляется после 20 нажатий)
              if (_showSecretOption) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFF4CAF50)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.rocket_launch_rounded, color: const Color(0xFF4CAF50)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Секретный режим разблокирован!',
                              style: TextStyle(
                                color: const Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createLocalAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Создать локальный аккаунт',
                                style: TextStyle(
                                  fontSize: 14,
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
              ],

              // Поле email
              TextField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: appLocalizations.email,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontFamily: 'Roboto',
                  ),
                  hintText: appLocalizations.enterEmail,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontFamily: 'Roboto',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Поле пароля
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: appLocalizations.password,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontFamily: 'Roboto',
                  ),
                  hintText: appLocalizations.enterPassword,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontFamily: 'Roboto',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // Ссылка на регистрацию
              GestureDetector(
                onTap: _navigateToRegister,
                child: RichText(
                  text: TextSpan(
                    text: '${appLocalizations.noAccount} ',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontFamily: 'Roboto',
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: appLocalizations.register,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Кнопка проверки сервера (если недоступен)
              if (!_serverAvailable) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _testingConnection ? null : _testServerConnection,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _testingConnection
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.refresh_rounded),
                        const SizedBox(width: 8),
                        Text(_testingConnection ? 'Проверка...' : 'Проверить подключение'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Кнопка входа
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_serverAvailable ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
                      : Text(
                    appLocalizations.login,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}