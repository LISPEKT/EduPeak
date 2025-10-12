import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import '../data/user_data_storage.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ВРЕМЕННАЯ ЗАГЛУШКА - всегда успешный вход
    await Future.delayed(const Duration(milliseconds: 1000));

    // Сохраняем email как username
    await UserDataStorage.saveUsername(_emailController.text.split('@').first);

    if (mounted) {
      // Переходим сразу в главное меню
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Вход в аккаунт'),
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
            const SizedBox(height: 40),
            Text(
              'Войдите в свой аккаунт',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Введите вашу почту и пароль',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Поле email
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

            // Поле пароля
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

            const Spacer(),

            // Кнопка входа
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
                  'Войти',
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