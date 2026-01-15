import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../data/subjects_data.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../localization.dart';
import 'subject_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'review_screen.dart';
import 'dictionary_screen.dart';
import 'subscription_screen.dart';
import 'xp_stats_screen.dart';
import 'subject_info_screen.dart';
import '../theme/app_theme.dart';
import 'profile_editor_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  int _currentBottomNavIndex = 0;
  String _username = '';
  String _avatar = '👤';
  UserStats _userStats = UserStats(
    streakDays: 0,
    lastActivity: DateTime.now(),
    topicProgress: {},
    dailyCompletion: {},
    username: '',
    totalXP: 0,
    weeklyXP: 0,
    lastWeeklyReset: DateTime.now(),
  );

  List<String> _selectedSubjects = [];
  List<String> _allSubjects = [];
  DateTime? _lastDataUpdate;
  bool _isEditing = false;

  // Для оптимизации расчета прогресса
  Map<String, double> _subjectProgressCache = {};

  // Анимации (только для редактирования и предметов)
  late AnimationController _editButtonController;
  late AnimationController _manageButtonController;
  late AnimationController _xpCardController;
  late AnimationController _avatarScaleController;
  late Animation<double> _editIconScale;
  late Animation<double> _editIconRotation;
  late Animation<double> _manageButtonOpacity;
  late Animation<double> _manageButtonScale;
  late Animation<double> _xpCardScale;
  late Animation<double> _avatarScale;

  // Анимация для блока с предметами
  late AnimationController _subjectListAppearController;
  late Animation<double> _subjectListOpacity;
  late Animation<Offset> _subjectListSlide;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Инициализация контроллеров анимации (только для UI элементов)
    _editButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _manageButtonController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _xpCardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _avatarScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _subjectListAppearController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Настройка анимаций
    _editIconScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _editButtonController,
        curve: Curves.easeInOut,
      ),
    );

    _editIconRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _editButtonController,
        curve: Curves.easeInOut,
      ),
    );

    _manageButtonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _manageButtonController,
        curve: Curves.easeInOut,
      ),
    );

    _manageButtonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _manageButtonController,
        curve: Curves.easeOutBack,
      ),
    );

    _xpCardScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _xpCardController,
        curve: Curves.easeInOut,
      ),
    );

    _avatarScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _avatarScaleController,
        curve: Curves.easeInOut,
      ),
    );

    _subjectListOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _subjectListAppearController,
        curve: Curves.easeIn,
      ),
    );

    _subjectListSlide = Tween<Offset>(
      begin: Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _subjectListAppearController,
        curve: Curves.easeOutCubic,
      ),
    );

    _checkAuthStatus();
    _loadUserData();
    _loadSelectedSubjects();
    _loadAllSubjects();

    // Запуск анимаций при загрузке
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _subjectListAppearController.forward();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _editButtonController.dispose();
    _manageButtonController.dispose();
    _xpCardController.dispose();
    _avatarScaleController.dispose();
    _subjectListAppearController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentBottomNavIndex == 0) {
      _loadUserData();
    }
  }

  // Метод для виброотдачи
  Future<void> _triggerVibration() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Игнорируем ошибки вибрации
    }
  }

  Future<void> _loadUserData() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final username = await UserDataStorage.getUsername();
      final avatar = await UserDataStorage.getAvatar();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _username = username;
          _avatar = avatar;
          _lastDataUpdate = DateTime.now();
          // Сбрасываем кэш прогресса при загрузке новых данных
          _subjectProgressCache.clear();
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _loadSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSubjects = prefs.getStringList('selectedSubjects');

      if (mounted) {
        setState(() {
          _selectedSubjects = savedSubjects ?? [];
        });
      }
    } catch (e) {
      print('❌ Error loading selected subjects: $e');
    }
  }

  Future<void> _loadAllSubjects() async {
    final allSubjects = <String>{};
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) {
        allSubjects.add(subject.name);
      }
    }

    if (mounted) {
      setState(() {
        _allSubjects = allSubjects.toList();
      });
    }
  }

  Future<void> _saveSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedSubjects', _selectedSubjects);
      print('✅ Subjects saved: $_selectedSubjects');
    } catch (e) {
      print('❌ Error saving subjects: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  void _onBottomNavTap(int index) async {
    // Виброотдача при переключении табов
    await _triggerVibration();

    if (_isEditing) {
      _toggleEditMode();
    }

    setState(() {
      _currentBottomNavIndex = index;
    });

    if (index == 0 && mounted) {
      final now = DateTime.now();
      if (_lastDataUpdate == null ||
          now.difference(_lastDataUpdate!).inSeconds > 5) {
        _loadUserData();
      }
    }
  }

  void _toggleEditMode() async {
    // Виброотдача при переключении режима редактирования
    await _triggerVibration();

    // Анимация аватарки
    _avatarScaleController.forward().then((_) {
      _avatarScaleController.reverse();
    });

    // Запускаем анимации в нужном направлении
    if (_isEditing) {
      // Выключаем режим редактирования
      _manageButtonController.reverse();
      _editButtonController.reverse().then((_) {
        setState(() {
          _isEditing = false;
        });
        // Сохраняем изменения при выходе из режима редактирования
        _saveSelectedSubjects();
      });
    } else {
      // Включаем режим редактирования
      setState(() {
        _isEditing = true;
      });
      _editButtonController.forward();
      _manageButtonController.forward();
    }
  }

  void _addSubject(String subject) async {
    // Виброотдача при добавлении предмета
    await _triggerVibration();

    if (!_selectedSubjects.contains(subject)) {
      setState(() {
        _selectedSubjects.add(subject);
      });
      _saveSelectedSubjects();
      _showSnackBar('Предмет "$subject" добавлен');
    }
  }

  void _removeSubject(String subject) async {
    // Виброотдача при удалении предмета
    await _triggerVibration();

    final index = _selectedSubjects.indexOf(subject);
    if (index != -1) {
      setState(() {
        _selectedSubjects.removeAt(index);
      });
      _saveSelectedSubjects();
      _showSnackBar('Предмет "$subject" удален');
    }
  }

  void _showSubjectsDialog() async {
    // Виброотдача при открытии диалога
    await _triggerVibration();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _SubjectsDialog(
        theme: theme,
        isDark: isDark,
        selectedSubjects: _selectedSubjects,
        allSubjects: _allSubjects,
        getSubjectColor: _getSubjectColor,
        getSubjectIcon: _getSubjectIcon,
        onAddSubject: (subject) async {
          // Виброотдача при добавлении
          await _triggerVibration();
          _addSubject(subject);
        },
        onRemoveSubject: (subject) async {
          // Виброотдача при удалении
          await _triggerVibration();
          _removeSubject(subject);
        },
      ),
    ).then((_) {
      // После закрытия диалога обновляем список предметов
      _loadSelectedSubjects();
    });
  }

  void _showSnackBar(String message) async {
    // Виброотдача при показе snackbar
    await _triggerVibration();

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    final icons = {
      'Математика': Icons.calculate_rounded,
      'Алгебра': Icons.functions_rounded,
      'Геометрия': Icons.square_foot_rounded,
      'Русский язык': Icons.text_fields_rounded,
      'Литература': Icons.menu_book_rounded,
      'История': Icons.history_rounded,
      'Обществознание': Icons.people_rounded,
      'География': Icons.public_rounded,
      'Биология': Icons.psychology_rounded,
      'Физика': Icons.science_rounded,
      'Химия': Icons.biotech_rounded,
      'Английский язык': Icons.language_rounded,
    };
    return icons[subject] ?? Icons.school_rounded;
  }

  Widget _getCurrentScreen() {
    switch (_currentBottomNavIndex) {
      case 0:
        return _buildHomeScreenContent();
      case 1:
        return ReviewScreen(
          onBottomNavTap: _onBottomNavTap,
          currentIndex: _currentBottomNavIndex,
        );
      case 2:
        return DictionaryScreen(
          onBottomNavTap: _onBottomNavTap,
          currentIndex: _currentBottomNavIndex,
        );
      case 3:
        return const SubscriptionScreen();
      case 4:
        return ProfileScreen(
          onBottomNavTap: _onBottomNavTap,
          currentIndex: _currentBottomNavIndex,
          onLogout: widget.onLogout,
        );
      default:
        return _buildHomeScreenContent();
    }
  }

  Color _getSubjectColor(String subject) {
    final colors = {
      'Математика': Color(0xFF4285F4),
      'Алгебра': Color(0xFF2196F3),
      'Геометрия': Color(0xFF3F51B5),
      'Русский язык': Color(0xFFEA4335),
      'Литература': Color(0xFFFBBC05),
      'История': Color(0xFF34A853),
      'Обществознание': Color(0xFF8E44AD),
      'География': Color(0xFF00BCD4),
      'Биология': Color(0xFF4CAF50),
      'Физика': Color(0xFF9C27B0),
      'Химия': Color(0xFFFF9800),
      'Английский язык': Color(0xFFE91E63),
    };
    return colors[subject] ?? Colors.grey;
  }

  double _calculateSubjectProgress(String subjectName) {
    if (!_userStats.topicProgress.containsKey(subjectName)) {
      return 0.0;
    }

    final completedTopics = _userStats.topicProgress[subjectName]?.length ?? 0;

    int totalTopics = 0;
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) {
        if (subject.name == subjectName) {
          totalTopics += subject.topicsByGrade[grade]?.length ?? 0;
        }
      }
    }

    return totalTopics > 0 ? completedTopics / totalTopics : 0.0;
  }

  void _openXPScreen() async {
    // Виброотдача при открытии экрана опыта
    await _triggerVibration();

    // Анимация нажатия на XP карточку
    _xpCardController.reverse().then((_) {
      _xpCardController.forward();
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => XPStatsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _openSubjectInfo(String subject) async {
    // Виброотдача при открытии информации о предмете
    await _triggerVibration();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectInfoScreen(subjectName: subject),
      ),
    );
  }

  void _openProfileEditor() async {
    // Виброотдача при открытии редактора профиля
    await _triggerVibration();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditorScreen(
          currentAvatar: _avatar,
          onAvatarUpdate: (newAvatar) {
            setState(() {
              _avatar = newAvatar;
            });
          },
          onUsernameUpdate: (newUsername) {
            setState(() {
              _username = newUsername;
            });
          },
          onBottomNavTap: (index) {
            // Переключение на другой таб
            _onBottomNavTap(index);
          },
          currentIndex: _currentBottomNavIndex,
        ),
      ),
    ).then((_) {
      // Обновляем данные профиля после возвращения
      _loadUserData();
    });
  }

  Widget _buildHomeScreenContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
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
              // Верхняя панель с аватаркой
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Аватарка и приветствие
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTapDown: (_) {
                              _avatarScaleController.forward();
                            },
                            onTapUp: (_) {
                              _avatarScaleController.reverse();
                            },
                            onTapCancel: () {
                              _avatarScaleController.reverse();
                            },
                            onTap: () async {
                              await _triggerVibration();
                              _openProfileEditor();
                            },
                            child: ScaleTransition(
                              scale: _avatarScale,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark ? theme.cardColor : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isPhotoAvatar()
                                    ? ClipOval(
                                  child: Image.file(
                                    File(_avatar),
                                    fit: BoxFit.cover,
                                    width: 56,
                                    height: 56,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_rounded,
                                        color: primaryColor,
                                        size: 28,
                                      );
                                    },
                                  ),
                                )
                                    : Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: primaryColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Привет, что будем изучать сегодня?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.hintColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _username.isNotEmpty ? _username : 'Гость',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ПЛАШКА С ОПЫТОМ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTapDown: (_) {
                    _xpCardController.reverse();
                  },
                  onTapUp: (_) {
                    _xpCardController.forward();
                  },
                  onTapCancel: () {
                    _xpCardController.forward();
                  },
                  onTap: () async {
                    await _triggerVibration();
                    _openXPScreen();
                  },
                  child: ScaleTransition(
                    scale: _xpCardScale,
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          // Иконка XP
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.leaderboard_rounded,
                              color: primaryColor,
                              size: 36,
                            ),
                          ),
                          SizedBox(width: 20),

                          // Информация об опыте
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Твой опыт',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    Text(
                                      '${_userStats.totalXP} XP',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _userStats.totalXP > 10000
                                      ? 1.0
                                      : _userStats.totalXP / 10000,
                                  backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 10,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _getMotivationMessage(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Заголовок предметов с кнопками
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Название "Мои предметы" - теперь может скрываться
                    if (!_isEditing ||
                        MediaQuery.of(context).size.width > 400) // Показываем если достаточно места
                      Expanded(
                        flex: _isEditing ? 0 : 1, // В режиме редактирования меньше приоритета
                        child: Text(
                          'Мои предметы',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Кнопки редактирования и добавления/удаления
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Кнопка управления предметами (только в режиме редактирования)
                        if (_isEditing)
                          FadeTransition(
                            opacity: _manageButtonOpacity,
                            child: ScaleTransition(
                              scale: _manageButtonScale,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.4,
                                ),
                                child: InkWell(
                                  onTap: _showSubjectsDialog,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? theme.cardColor : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.playlist_add_rounded,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Управление',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_isEditing) SizedBox(width: 8),
                        // Кнопка редактирования/готово
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
                            icon: ScaleTransition(
                              scale: _editIconScale,
                              child: RotationTransition(
                                turns: _editIconRotation,
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: _isEditing
                                      ? Icon(
                                    Icons.done_rounded,
                                    key: ValueKey('done'),
                                    color: Color(0xFF4CAF50),
                                  )
                                      : Icon(
                                    Icons.edit_rounded,
                                    key: ValueKey('edit'),
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: _toggleEditMode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Список предметов с перетаскиванием
              Expanded(
                child: SlideTransition(
                  position: _subjectListSlide,
                  child: FadeTransition(
                    opacity: _subjectListOpacity,
                    child: _selectedSubjects.isEmpty
                        ? _buildEmptyState()
                        : _buildSubjectList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    // Если режим редактирования - используем ReorderableListView
    if (_isEditing) {
      return ReorderableListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        itemCount: _selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = _selectedSubjects[index];
          final progress = _calculateSubjectProgress(subject);
          final color = _getSubjectColor(subject);

          return Container(
            key: ValueKey('$subject-$index'),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              children: [
                // Карточка предмета - БЕЗ АНИМАЦИЙ
                Expanded(
                  child: _buildSubjectCard(
                    subject: subject,
                    progress: progress,
                    color: color,
                  ),
                ),
                // Иконка перетаскивания справа
                ReorderableDragStartListener(
                  index: index,
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTapDown: (_) async {
                        await _triggerVibration();
                      },
                      child: Container(
                        width: 36,
                        height: 124,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: color,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onReorderStart: (index) async {
          // Виброотдача при начале перетаскивания
          await _triggerVibration();
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          // Без setState - изменяем список напрямую для избежания "скачка"
          final item = _selectedSubjects.removeAt(oldIndex);
          _selectedSubjects.insert(newIndex, item);

          // Только сохраняем, но не перерисовываем
          _saveSelectedSubjects();
        },
        onReorderEnd: (_) async {
          // Виброотдача при окончании перетаскивания
          await _triggerVibration();
          // Сохраняем и показываем уведомление
          _showSnackBar('Порядок предметов обновлен');
        },
        buildDefaultDragHandles: false,
      );
    } else {
      // Если не режим редактирования - обычный ListView
      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        itemCount: _selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = _selectedSubjects[index];
          final progress = _calculateSubjectProgress(subject);
          final color = _getSubjectColor(subject);

          return Container(
            key: ValueKey('$subject-$index'),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: _buildSubjectCard(
              subject: subject,
              progress: progress,
              color: color,
            ),
          );
        },
      );
    }
  }

  Widget _buildSubjectCard({
    required String subject,
    required double progress,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completedPercent = (progress * 100).round();

    return GestureDetector(
      onTap: () async {
        // Виброотдача при нажатии на карточку предмета
        await _triggerVibration();
        _openSubjectInfo(subject);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Верхняя часть с названием и кнопками
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Название предмета
                  Expanded(
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Правая часть с кнопками
                  Row(
                    children: [
                      // Кнопка перехода к предмету - как было раньше
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            // Виброотдача при нажатии на кнопку перехода
                            await _triggerVibration();
                            _openSubjectInfo(subject);
                          },
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            color: color,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Прогресс бар
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Прогресс',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                      Text(
                        '$completedPercent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 60,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Нет выбранных предметов',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Добавьте предметы для обучения',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.hintColor,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await _triggerVibration();
                _showSubjectsDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Добавить предметы',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPhotoAvatar() {
    return _avatar.startsWith('/') || _avatar.contains('.');
  }

  String _getMotivationMessage() {
    if (_userStats.totalXP >= 5000) {
      return 'Отличная работа! Ты набрал уже ${_userStats.totalXP} XP';
    } else if (_userStats.totalXP >= 1000) {
      return 'У тебя ${_userStats.totalXP} XP. Отличный прогресс!';
    } else if (_userStats.totalXP >= 500) {
      return '${_userStats.totalXP} XP - хороший результат!';
    } else if (_userStats.totalXP >= 100) {
      return 'У тебя уже ${_userStats.totalXP} XP. Двигайся дальше!';
    } else {
      return 'Пройди первый тест и получи свои первые XP!';
    }
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildBottomNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: appLocalizations.home,
              isDark: isDark,
            ),
            _buildBottomNavItem(
              index: 1,
              icon: Icons.refresh_rounded,
              label: appLocalizations.review,
              isDark: isDark,
            ),
            _buildBottomNavItem(
              index: 2,
              icon: Icons.book_rounded,
              label: appLocalizations.dictionary,
              isDark: isDark,
            ),
            _buildBottomNavItem(
              index: 3,
              icon: Icons.star_rounded,
              label: 'Premium',
              isDark: isDark,
            ),
            _buildBottomNavItem(
              index: 4,
              icon: Icons.person_rounded,
              label: appLocalizations.profile,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _getCurrentScreen(),
        ),
        _buildBottomNavigationBar(),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = index == _currentBottomNavIndex;
    final color = isSelected ? Color(0xFF4CAF50) : (isDark ? Colors.grey[500]! : Colors.grey[400]!);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBottomNavTap(index),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectsDialog extends StatefulWidget {
  final ThemeData theme;
  final bool isDark;
  final List<String> selectedSubjects;
  final List<String> allSubjects;
  final Color Function(String) getSubjectColor;
  final IconData Function(String) getSubjectIcon;
  final Function(String) onAddSubject;
  final Function(String) onRemoveSubject;

  const _SubjectsDialog({
    required this.theme,
    required this.isDark,
    required this.selectedSubjects,
    required this.allSubjects,
    required this.getSubjectColor,
    required this.getSubjectIcon,
    required this.onAddSubject,
    required this.onRemoveSubject,
  });

  @override
  State<_SubjectsDialog> createState() => _SubjectsDialogState();
}

class _SubjectsDialogState extends State<_SubjectsDialog> with SingleTickerProviderStateMixin {
  bool _isAddingMode = true;
  late AnimationController _switchController;
  late Animation<Offset> _addListAnimation;
  late Animation<Offset> _removeListAnimation;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _addListAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));

    _removeListAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _switchMode(bool toAdding) async {
    // Виброотдача при переключении режимов
    await HapticFeedback.lightImpact();

    if (toAdding != _isAddingMode) {
      if (toAdding) {
        _switchController.reverse();
      } else {
        _switchController.forward();
      }
      setState(() {
        _isAddingMode = toAdding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: widget.isDark
            ? widget.theme.scaffoldBackgroundColor
            : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isAddingMode ? 'Добавить предметы' : 'Удалить предметы',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.textTheme.titleMedium?.color,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: widget.theme.hintColor),
                  iconSize: 24,
                ),
              ],
            ),
          ),

          // Переключатель режимов
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _switchMode(true);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAddingMode ? Color(0xFF4CAF50) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Добавить',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isAddingMode ? Colors.white : widget.theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _switchMode(false);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAddingMode ? Color(0xFFEA4335) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Удалить',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !_isAddingMode ? Colors.white : widget.theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Список предметов
          Expanded(
            child: Stack(
              children: [
                // Список для добавления
                SlideTransition(
                  position: _addListAnimation,
                  child: _buildAddSubjectsList(),
                ),

                // Список для удаления
                SlideTransition(
                  position: _removeListAnimation,
                  child: _buildRemoveSubjectsList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddSubjectsList() {
    // Обновляем список доступных для добавления предметов каждый раз
    final availableSubjects = widget.allSubjects
        .where((subject) => !widget.selectedSubjects.contains(subject))
        .toList();

    if (availableSubjects.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Все предметы добавлены',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Вы добавили все доступные предметы',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: availableSubjects.length,
      itemBuilder: (context, index) {
        final subject = availableSubjects[index];
        final color = widget.getSubjectColor(subject);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? widget.theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.getSubjectIcon(subject),
                color: color,
                size: 24,
              ),
            ),
            title: Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.theme.textTheme.titleMedium?.color,
              ),
            ),
            trailing: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  widget.onAddSubject(subject);
                  // Обновляем UI после добавления
                  setState(() {});
                },
                icon: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            onTap: () {
              widget.onAddSubject(subject);
              // Обновляем UI после добавления
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildRemoveSubjectsList() {
    // Обновляем список предметов для удаления каждый раз
    final subjectsToRemove = List.from(widget.selectedSubjects);

    if (subjectsToRemove.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFEA4335).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove_circle_rounded,
                  size: 48,
                  color: Color(0xFFEA4335),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Нет предметов для удаления',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Добавьте предметы в список изучения',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: subjectsToRemove.length,
      itemBuilder: (context, index) {
        final subject = subjectsToRemove[index];
        final color = widget.getSubjectColor(subject);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? widget.theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.getSubjectIcon(subject),
                color: color,
                size: 24,
              ),
            ),
            title: Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.theme.textTheme.titleMedium?.color,
              ),
            ),
            trailing: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFEA4335),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEA4335).withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  widget.onRemoveSubject(subject);
                  // Обновляем UI после удаления
                  setState(() {});
                },
                icon: Icon(
                  Icons.remove_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            onTap: () {
              widget.onRemoveSubject(subject);
              // Обновляем UI после удаления
              setState(() {});
            },
          ),
        );
      },
    );
  }
}