// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../data/user_data_storage.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _serverAvailable = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final available = await ApiService.checkServerAvailability();

    setState(() {
      _serverAvailable = available;
      _debugInfo = 'Сервер: ${available ? "доступен" : "недоступен"}\n';
    });
  }

  Future<void> _testEndpoints() async {
    setState(() => _isLoading = true);

    try {
      final results = await ApiService.discoverEndpoints();
      print('🎯 Endpoints discovery results:');
      results.forEach((endpoint, data) {
        print('$endpoint: $data');
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Результаты теста endpoints'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: results.entries.map((entry) {
                final endpoint = entry.key;
                final data = entry.value as Map;
                return ListTile(
                  title: Text(endpoint),
                  subtitle: Text('Status: ${data['status']} - Exists: ${data['exists']}'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error testing endpoints: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    // Проверка формата email
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный email')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен быть не менее 6 символов')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Исправленный вызов с правильными аргументами
      final response = await ApiService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        await UserDataStorage.saveUsername(_usernameController.text.trim());

        // Устанавливаем статус входа
        await UserDataStorage.setLoggedIn(true);

        // Синхронизируем данные с сервером
        await UserDataStorage.syncFromServer();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(onLogout: () {})),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Ошибка регистрации'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Создание аккаунта'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_serverAvailable) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Сервер недоступен. Проверьте подключение.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_debugInfo.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  print(_debugInfo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_debugInfo)),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Нажмите для информации о сервере',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            Text(
              'Создайте аккаунт',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите вашу почту и придумайте пароль',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Имя пользователя',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: isDark ? Colors.white70 : null,
                ),
                filled: isDark,
                fillColor: isDark ? const Color(0xFF1E1E1E) : null,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: isDark ? Colors.white70 : null,
                ),
                filled: isDark,
                fillColor: isDark ? const Color(0xFF1E1E1E) : null,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Пароль',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: isDark ? Colors.white70 : null,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: isDark,
                fillColor: isDark ? const Color(0xFF1E1E1E) : null,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDark ? Colors.white70 : null,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                filled: isDark,
                fillColor: isDark ? const Color(0xFF1E1E1E) : null,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Пароль должен содержать не менее 6 символов',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text(
                  'Создать аккаунт',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}