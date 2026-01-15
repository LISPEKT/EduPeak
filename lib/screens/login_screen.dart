import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import '../data/user_data_storage.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import '../localization.dart';
import 'dart:convert';
import '../services/secure_prefs.dart';
import '../models/user_stats.dart';
import '../services/session_manager.dart';

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
          backgroundColor: available ? Colors.green : Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      setState(() => _serverAvailable = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка проверки: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        SnackBar(
          content: Text('🎉 Секретная функция разблокирована!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _createLocalAccount() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Creating local account...');

      final username = 'LocalUser';
      final email = 'local@user.com';
      final password = '12345678';

      // 1. СОХРАНЯЕМ В SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('username', username);
      await prefs.setString('auth_method', 'local');
      await prefs.setString('local_password', password);
      await prefs.setString('lastLogin', DateTime.now().toIso8601String());

      // 2. ИНИЦИАЛИЗИРУЕМ СЕССИЮ
      await SessionManager.initializeSession();

      print('✅ Local account created successfully!');
      print('📧 Email: $email');
      print('🔑 Password: $password');
      print('👤 Username: $username');

      // 3. Показываем информацию о созданном аккаунте
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('✅ Локальный аккаунт создан'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Вы можете войти с этими данными:'),
                SizedBox(height: 12),
                _buildAccountInfo('📧 Email', email),
                _buildAccountInfo('👤 Логин', username),
                _buildAccountInfo('🔑 Пароль', password),
                SizedBox(height: 16),
                Text(
                  'Этот пароль нужен для будущих входов в локальный аккаунт.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToMainScreen();
                },
                child: Text('Продолжить'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error creating local account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания аккаунта: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAccountInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              value,
              style: TextStyle(fontFamily: 'Monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
    );
  }

  Future<void> _login() async {
    final appLocalizations = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.pleaseFillAllFields),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!_serverAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.serverUnavailableCheckConnection),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        // Успешный вход
        final username = _emailController.text.split('@').first;

        // 1. СОХРАНЯЕМ СТАТУС ВХОДА
        await UserDataStorage.setLoggedIn(true);

        // 2. СОХРАНЯЕМ ИМЯ ПОЛЬЗОВАТЕЛЯ
        await UserDataStorage.saveUsername(username);

        // 3. ИНИЦИАЛИЗИРУЕМ СЕССИЮ
        await SessionManager.initializeSession();

        // 4. СОЗДАЕМ И СОХРАНЯЕМ БАЗОВЫЕ ДАННЫЕ
        final userStats = UserStats(
          streakDays: 0,
          lastActivity: DateTime.now(),
          topicProgress: {},
          dailyCompletion: {},
          username: username,
          totalXP: 0,
          weeklyXP: 0,
        );

        await UserDataStorage.saveUserStats(userStats);

        // 5. СОХРАНЯЕМ В SharedPreferences ДЛЯ БЫСТРОГО ВОССТАНОВЛЕНИЯ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _emailController.text.trim());
        await prefs.setString('username', username);
        await prefs.setString('lastLogin', DateTime.now().toIso8601String());

        print('✅ Login successful! User data saved locally.');
        print('👤 Username: $username');
        print('📧 Email: ${_emailController.text.trim()}');

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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('❌ Login exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.connectionError}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillLocalAccountCredentials() {
    setState(() {
      _emailController.text = 'local@user.com';
      _passwordController.text = '12345678';
      _showSecretOption = true; // Чтобы показать кнопку
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Данные локального аккаунта заполнены'),
        duration: Duration(seconds: 2),
      ),
    );
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
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(appLocalizations.login),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _testingConnection
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(Icons.wifi_find_rounded),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 8),

              // Описание
              Text(
                _serverAvailable
                    ? appLocalizations.enterCredentials
                    : appLocalizations.serverUnavailableCheckConnection,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _serverAvailable
                      ? Theme.of(context).colorScheme.onBackground.withOpacity(0.7)
                      : Colors.orange,
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Локальный режим разблокирован',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _isLoading ? null : _createLocalAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onPrimary),
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 18),
                            const SizedBox(width: 8),
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
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
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
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Ссылка на регистрацию
              GestureDetector(
                onTap: _navigateToRegister,
                child: RichText(
                  text: TextSpan(
                    text: '${appLocalizations.noAccount} ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                    children: [
                      TextSpan(
                        text: appLocalizations.register,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Кнопка проверки сервера (если недоступен)
              if (!_serverAvailable) ...[
                OutlinedButton(
                  onPressed: _testingConnection ? null : _testServerConnection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _testingConnection
                          ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Icon(Icons.refresh_rounded),
                      const SizedBox(width: 8),
                      Text(_testingConnection ? 'Проверка...' : 'Проверить подключение'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Кнопка входа
              FilledButton(
                onPressed: _isLoading || !_serverAvailable ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onPrimary),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}