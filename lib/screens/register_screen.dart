import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import '../data/user_data_storage.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../localization.dart';
import '../services/region_manager.dart'; // Добавляем импорт

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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

  final _scrollController = ScrollController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkServer();

    // Добавляем слушатели для автоматической прокрутки
    _usernameFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // Прокручиваем к активному полю ввода
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_usernameFocus.hasFocus || _emailFocus.hasFocus ||
          _passwordFocus.hasFocus || _confirmPasswordFocus.hasFocus) {
        _scrollToActiveField();
      }
    });
  }

  void _scrollToActiveField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _checkServer() async {
    final available = await ApiService.checkServerAvailability();
    setState(() {
      _serverAvailable = available;
    });
  }

  Future<void> _register() async {
    final appLocalizations = AppLocalizations.of(context);

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.pleaseFillAllFields),
          backgroundColor: Colors.orange,
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
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.passwordsDoNotMatch),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.passwordMinLength),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        await UserDataStorage.saveUsername(_usernameController.text.trim());
        await UserDataStorage.setLoggedIn(true);
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
            content: Text(response['message'] ?? appLocalizations.registrationError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.error}: $e'),
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
  void dispose() {
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Виджет выбора региона
  Widget _buildRegionSelection() {
    final regionManager = Provider.of<RegionManager>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Регион обучения',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите страну для соответствующей учебной программы',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: regionManager.currentRegion.id,
              decoration: InputDecoration(
                labelText: 'Страна',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: regionManager.availableRegions.map((region) {
                return DropdownMenuItem<String>(
                  value: region.id,
                  child: Row(
                    children: [
                      Text(region.flag),
                      const SizedBox(width: 8),
                      Text(region.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  await regionManager.setCurrentRegion(newValue);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${regionManager.currentRegion.totalGrades} классов, ${regionManager.currentRegion.curriculum.length} предметов',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.green[200] : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(appLocalizations.createAccount),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
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
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appLocalizations.serverUnavailableCheckConnection,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Text(
                appLocalizations.createAccount,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'GoogleSans',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appLocalizations.enterEmailAndPassword,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 32),

              // Секция выбора региона
              _buildRegionSelection(),

              const SizedBox(height: 24),

              // Поле имени пользователя
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_emailFocus);
                },
                decoration: InputDecoration(
                  labelText: appLocalizations.username,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
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
                    Icons.person_outlined,
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
              ),
              const SizedBox(height: 16),

              // Поле email
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
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
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                },
                decoration: InputDecoration(
                  labelText: appLocalizations.password,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
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
              const SizedBox(height: 16),

              // Поле подтверждения пароля
              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  _register();
                },
                decoration: InputDecoration(
                  labelText: appLocalizations.confirmPassword,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
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
                    Icons.lock_outline_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
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

              const SizedBox(height: 8),
              Text(
                appLocalizations.passwordMinLength,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),

              const SizedBox(height: 32),

              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                    appLocalizations.createAccount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Добавляем отступ внизу для удобства прокрутки
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}