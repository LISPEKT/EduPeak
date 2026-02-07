import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
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
import 'eduleague_screen.dart';
import 'news_screen.dart';

// Модель новости (добавьте в отдельный файл models/news_item.dart или здесь)
class NewsItem {
  final int id;
  final String title;
  final String description;
  final String date;
  final String imageUrl;
  final String category;
  final bool isRead;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.category,
    required this.isRead,
  });

  NewsItem copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? imageUrl,
    String? category,
    bool? isRead,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'imageUrl': imageUrl,
      'category': category,
      'isRead': isRead,
    };
  }

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      isRead: map['isRead'],
    );
  }
}

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

  // Для вращающейся плашки
  late Timer _cardRotationTimer;
  Duration _cardRotationDuration = Duration(seconds: 10);
  int _currentCardState = 0; // 0 = XP, 1 = новость, 2 = лига
  double _progressValue = 0.0;
  bool _isAnimating = false;
  List<NewsItem> _newsItems = [];
  late AnimationController _progressAnimationController;
  late PageController _pageController;
  bool _isManualScrolling = false;
  bool _isAutoRotating = true;

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

    // Для прогресс бара
    _progressAnimationController = AnimationController(
      duration: _cardRotationDuration,
      vsync: this,
    );

    // PageController для горизонтальной прокрутки карточек
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onPageChanged);

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
    _loadLatestNews();

    // Запуск анимаций при загрузке
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _subjectListAppearController.forward();
      }
    });

    // Запускаем автоматическую ротацию
    _startAutoRotation();
    _startProgressAnimation();
  }

  String _getLatestNews() {
    if (_newsItems.isNotEmpty) {
      return _newsItems[0].title;
    }
    return 'Следите за обновлениями';
  }

  Future<void> _loadLatestNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNewsJson = prefs.getStringList('news_items');

      if (savedNewsJson != null && savedNewsJson.isNotEmpty) {
        _newsItems = savedNewsJson.map((json) {
          final map = Map<String, dynamic>.from(jsonDecode(json));
          return NewsItem.fromMap(map);
        }).toList();
      } else {
        // Если нет сохраненных новостей, создаем дефолтную
        _newsItems = [
          NewsItem(
            id: 1,
            title: 'Добавлен экран новостей в обновлении 0.42.0',
            description: 'Мы рады сообщить о выходе обновления 0.42.0! Теперь в приложении появился новый раздел "Новости", где вы можете следить за всеми обновлениями и важными анонсами.',
            date: '18 января 2025',
            imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Update+0.42.0',
            category: 'Обновления',
            isRead: prefs.getBool('news_1_read') ?? false,
          ),
        ];
        await _saveNewsToStorage();
      }
    } catch (e) {
      print('❌ Error loading news: $e');
      // Если ошибка, создаем дефолтную новость
      _newsItems = [
        NewsItem(
          id: 1,
          title: 'Добавлен экран новостей в обновлении 0.42.0',
          description: 'Мы рады сообщить о выходе обновления 0.42.0! Теперь в приложении появился новый раздел "Новости", где вы можете следить за всеми обновлениями и важными анонсами.',
          date: '18 января 2025',
          imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Update+0.42.0',
          category: 'Обновления',
          isRead: false,
        ),
      ];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveNewsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newsJson = _newsItems.map((news) => jsonEncode(news.toMap())).toList();
      await prefs.setStringList('news_items', newsJson);

      // Сохраняем статус прочтения для каждой новости
      for (final news in _newsItems) {
        await prefs.setBool('news_${news.id}_read', news.isRead);
      }
    } catch (e) {
      print('❌ Error saving news: $e');
    }
  }

  void _startAutoRotation() {
    _cardRotationTimer = Timer.periodic(_cardRotationDuration, (timer) {
      if (!mounted || !_isAutoRotating || _isManualScrolling) return;

      final nextPage = (_currentCardState + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _restartAutoRotation() {
    if (_cardRotationTimer.isActive) {
      _cardRotationTimer.cancel();
    }

    _cardRotationTimer = Timer.periodic(_cardRotationDuration, (timer) {
      if (!mounted || !_isAutoRotating || _isManualScrolling) return;

      final nextPage = (_currentCardState + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startProgressAnimation() {
    _progressAnimationController.duration = _cardRotationDuration;
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  void _restartProgressAnimation() {
    _progressAnimationController.stop();
    _progressAnimationController.value = 0.0;
    _progressAnimationController.forward();
  }

  void _stopProgressAnimation() {
    _progressAnimationController.stop();
  }

  void _onPageChanged() {
    final page = _pageController.page ?? 0;
    final newCardState = (page.round() % 3).abs();

    if (newCardState != _currentCardState) {
      setState(() {
        _currentCardState = newCardState;
      });

      // СБРАСЫВАЕМ ТАЙМЕР ПРИ РУЧНОМ ПЕРЕКЛЮЧЕНИИ
      _restartAutoRotation();
      _restartProgressAnimation();
    }
  }

  void _handleCardTap(int cardIndex) async {
    await _triggerVibration();

    // Открываем разные экраны в зависимости от карточки
    switch (cardIndex) {
      case 0: // XP
        _openXPScreen();
        break;
      case 1: // Новость
        _openNewsScreen();
        break;
      case 2: // Лига
        _openLeagueScreen();
        break;
    }
  }

  void _openNewsScreen() async {
    await _triggerVibration();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsScreen(),
      ),
    );

    // При возвращении из экрана новостей обновляем данные
    if (mounted) {
      await _loadLatestNews();
    }
  }

  void _openLeagueScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EduLeagueScreen(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _editButtonController.dispose();
    _manageButtonController.dispose();
    _xpCardController.dispose();
    _avatarScaleController.dispose();
    _subjectListAppearController.dispose();
    _cardRotationTimer.cancel();
    _progressAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentBottomNavIndex == 0) {
      _loadUserData();
      _loadLatestNews();
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
        _loadLatestNews();
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
      _showSnackBar('${AppLocalizations.of(context).subjectAdded}: "$subject"');
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
      _showSnackBar('${AppLocalizations.of(context).subjectRemoved}: "$subject"');
    }
  }

  void _showSubjectsDialog() async {
    // Виброотдача при открытии диалога
    await _triggerVibration();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

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
        appLocalizations: appLocalizations,
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
    // Используем кэш для оптимизации
    if (_subjectProgressCache.containsKey(subjectName)) {
      return _subjectProgressCache[subjectName]!;
    }

    if (!_userStats.topicProgress.containsKey(subjectName)) {
      _subjectProgressCache[subjectName] = 0.0;
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

    final progress = totalTopics > 0 ? completedTopics / totalTopics : 0.0;
    _subjectProgressCache[subjectName] = progress;

    return progress;
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

  bool _isPhotoAvatar() {
    return _avatar.startsWith('/') || _avatar.contains('.');
  }

  Widget _buildHomeScreenContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final appLocalizations = AppLocalizations.of(context);

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
                                  appLocalizations.helloWhatToStudy,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: theme.hintColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _username.isNotEmpty ? _username : appLocalizations.guest,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 20,
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

              // ВРАЩАЮЩАЯСЯ ПЛАШКА С ГОРИЗОНТАЛЬНОЙ ПРОКРУТКОЙ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Column(
                  children: [
                    // Карточка с жестами свайпа
                    SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 3,
                        physics: const PageScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        onPageChanged: (index) {
                          setState(() {
                            _isManualScrolling = true;
                          });
                          _stopProgressAnimation();

                          Future.delayed(Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isManualScrolling = false;
                              });
                              _restartProgressAnimation();
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () => _handleCardTap(index),
                              onPanUpdate: (details) {
                                // Для свайпа мышкой на ПК
                                if (details.delta.dx.abs() > 5) {
                                  setState(() {
                                    _isManualScrolling = true;
                                  });
                                  _stopProgressAnimation();
                                }
                              },
                              onPanEnd: (_) {
                                Future.delayed(Duration(milliseconds: 300), () {
                                  if (mounted) {
                                    setState(() {
                                      _isManualScrolling = false;
                                    });
                                    _restartProgressAnimation();
                                  }
                                });
                              },
                              child: Container(
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
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                  child: _buildCardContent(index, theme, isDark, primaryColor),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16),

                    // Плавный прогресс бар
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedBuilder(
                        animation: _progressAnimationController,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: MediaQuery.of(context).size.width * _progressAnimationController.value,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 8),

                    // Индикаторы состояний
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                i,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: _currentCardState == i ? 24 : 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(4),
                                color: _currentCardState == i
                                    ? primaryColor
                                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Заголовок предметов с кнопками
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Название "Мои предметы"
                    Expanded(
                      child: Text(
                        appLocalizations.mySubjects,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
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
                                            appLocalizations.management,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 12 : 14,
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

              // Список предметов с перетаскиванием (ИЗОЛИРОВАН В StatefulWidget)
              Expanded(
                child: SlideTransition(
                  position: _subjectListSlide,
                  child: FadeTransition(
                    opacity: _subjectListOpacity,
                    child: _SubjectsList(
                      selectedSubjects: _selectedSubjects,
                      isEditing: _isEditing,
                      calculateSubjectProgress: _calculateSubjectProgress,
                      getSubjectColor: _getSubjectColor,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _selectedSubjects.removeAt(oldIndex);
                        _selectedSubjects.insert(newIndex, item);
                        _saveSelectedSubjects();
                      },
                      onSubjectTap: _openSubjectInfo,
                      appLocalizations: appLocalizations,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(int state, ThemeData theme, bool isDark, Color primaryColor) {
    final appLocalizations = AppLocalizations.of(context);

    switch (state) {
      case 0: // XP
        return _buildXPCardContent(theme, isDark, primaryColor);
      case 1: // Новость
        return _buildNewsCardContent(theme, isDark, primaryColor);
      case 2: // Лига
        return _buildLeagueCardContent(theme, isDark, primaryColor);
      default:
        return _buildXPCardContent(theme, isDark, primaryColor);
    }
  }

  Widget _buildXPCardContent(ThemeData theme, bool isDark, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;
    final appLocalizations = AppLocalizations.of(context);

    return Row(
      key: ValueKey('xp'),
      children: [
        // Иконка XP
        Container(
          width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.leaderboard_rounded,
            color: primaryColor,
            size: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),

        // Информация об опыте
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocalizations.yourXp,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.hintColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 1 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'XP',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                '${_userStats.totalXP} XP',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : (isMediumScreen ? 22 : 24),
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                _getMotivationMessage(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: theme.hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCardContent(ThemeData theme, bool isDark, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;
    final appLocalizations = AppLocalizations.of(context);

    // Проверяем есть ли непрочитанные новости
    bool hasUnreadNews = _newsItems.any((news) => !news.isRead);

    return Row(
      key: ValueKey('news'),
      children: [
        // Иконка новости
        Container(
          width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.new_releases_rounded,
            color: Colors.blue,
            size: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),

        // Информация о новости
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocalizations.latestNews,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.hintColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 1 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasUnreadNews ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasUnreadNews ? appLocalizations.newUnread : appLocalizations.read,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: hasUnreadNews ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                _getLatestNews(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                _newsItems.isNotEmpty ? _newsItems[0].date : appLocalizations.updatedToday,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueCardContent(ThemeData theme, bool isDark, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;
    final appLocalizations = AppLocalizations.of(context);

    String userLeague = _determineLeagueByXP(_userStats.totalXP);
    Color leagueColor = _getLeagueColor(userLeague);

    return Row(
      key: ValueKey('league'),
      children: [
        // Иконка лиги
        Container(
          width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
          decoration: BoxDecoration(
            color: leagueColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getLeagueIcon(userLeague),
            color: leagueColor,
            size: isSmallScreen ? 24 : (isMediumScreen ? 28 : 32),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),

        // Информация о лиге
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocalizations.yourLeague,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.hintColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 1 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: leagueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appLocalizations.league,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: leagueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                userLeague,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                  fontWeight: FontWeight.bold,
                  color: leagueColor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                '${_userStats.totalXP} XP',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                _getLeagueMessage(userLeague),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: theme.hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _determineLeagueByXP(int xp) {
    if (xp >= 5000) return 'Нереальная';
    if (xp >= 4000) return 'Легендарная';
    if (xp >= 3000) return 'Элитная';
    if (xp >= 2000) return 'Бриллиантовая';
    if (xp >= 1500) return 'Платиновая';
    if (xp >= 1000) return 'Золотая';
    if (xp >= 500) return 'Серебряная';
    return 'Бронзовая';
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Нереальная': return Color(0xFFE6E6FA);
      case 'Легендарная': return Color(0xFFFF4500);
      case 'Элитная': return Color(0xFF7F7F7F);
      case 'Бриллиантовая': return Color(0xFFB9F2FF);
      case 'Платиновая': return Color(0xFFE5E4E2);
      case 'Золотая': return Color(0xFFFFD700);
      case 'Серебряная': return Color(0xFFC0C0C0);
      case 'Бронзовая': return Color(0xFFCD7F32);
      default: return Color(0xFFCD7F32);
    }
  }

  IconData _getLeagueIcon(String league) {
    switch (league) {
      case 'Нереальная': return Icons.auto_awesome_rounded;
      case 'Легендарная': return Icons.whatshot_rounded;
      case 'Элитная': return Icons.star_rounded;
      case 'Бриллиантовая': return Icons.diamond_rounded;
      case 'Платиновая': return Icons.lens_rounded;
      case 'Золотая': return Icons.lens_rounded;
      case 'Серебряная': return Icons.lens_rounded;
      case 'Бронзовая': return Icons.lens_rounded;
      default: return Icons.lens_rounded;
    }
  }

  String _getLeagueMessage(String league) {
    final appLocalizations = AppLocalizations.of(context);

    switch (league) {
      case 'Нереальная': return appLocalizations.youreLegend;
      case 'Легендарная': return appLocalizations.almostAtTop;
      case 'Элитная': return appLocalizations.excellentResult;
      case 'Бриллиантовая': return appLocalizations.greatWorkTop;
      case 'Платиновая': return appLocalizations.goodProgress;
      case 'Золотая': return appLocalizations.notBadAimHigher;
      case 'Серебряная': return appLocalizations.goodStart;
      case 'Бронзовая': return appLocalizations.beginnerAhead;
      default: return appLocalizations.beginnerAhead;
    }
  }

  String _getMotivationMessage() {
    final appLocalizations = AppLocalizations.of(context);

    if (_userStats.totalXP >= 5000) {
      return '${appLocalizations.excellentWork} ${appLocalizations.youEarnedXP} ${_userStats.totalXP} XP';
    } else if (_userStats.totalXP >= 1000) {
      return '${appLocalizations.youEarnedXP} ${_userStats.totalXP} XP. ${appLocalizations.excellentProgress}';
    } else if (_userStats.totalXP >= 500) {
      return '${_userStats.totalXP} XP - ${appLocalizations.goodResult}';
    } else if (_userStats.totalXP >= 100) {
      return '${appLocalizations.youAlreadyHave} ${_userStats.totalXP} XP. ${appLocalizations.moveForward}';
    } else {
      return appLocalizations.passFirstTestAndGetXP;
    }
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

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 60,
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
              label: appLocalizations.premium,
              isDark: isDark,
            ),
            _buildBottomNavItem(
              index: 4,
              label: appLocalizations.profile,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    IconData? icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = index == _currentBottomNavIndex;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final textColor = isSelected ? Colors.white : inactiveColor;

    // Для элемента профиля (index = 4) показываем аватар вместо иконки
    if (index == 4) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onBottomNavTap(index),
            borderRadius: BorderRadius.circular(35),
            child: Container(
              height: 70,
              margin: EdgeInsets.all(isSelected ? 4 : 0),
              decoration: isSelected
                  ? BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Аватар пользователя вместо иконки
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : inactiveColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: _isPhotoAvatar()
                        ? ClipOval(
                      child: Image.file(
                        File(_avatar),
                        fit: BoxFit.cover,
                        width: 22,
                        height: 22,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person_rounded,
                            color: isSelected ? Colors.white : inactiveColor,
                            size: 16,
                          );
                        },
                      ),
                    )
                        : Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: isSelected ? Colors.white : inactiveColor,
                        size: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Для остальных элементов - стандартная иконка
    final iconColor = isSelected ? Colors.white : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBottomNavTap(index),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            height: 70,
            margin: EdgeInsets.all(isSelected ? 4 : 0),
            decoration: isSelected
                ? BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon!,
                  size: 20,
                  color: iconColor,
                ),
                SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textColor,
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
  final AppLocalizations appLocalizations;

  const _SubjectsDialog({
    required this.theme,
    required this.isDark,
    required this.selectedSubjects,
    required this.allSubjects,
    required this.getSubjectColor,
    required this.getSubjectIcon,
    required this.onAddSubject,
    required this.onRemoveSubject,
    required this.appLocalizations,
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
                  _isAddingMode ? widget.appLocalizations.addSubjects : widget.appLocalizations.removeSubjects,
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
                            widget.appLocalizations.addSubjects,
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
                            widget.appLocalizations.removeSubjects,
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
                  widget.appLocalizations.allSubjectsAdded,
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
                  widget.appLocalizations.allSubjectsMessage,
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
                  widget.appLocalizations.noSubjectsToRemove,
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
                  widget.appLocalizations.addSubjectsMessage,
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

// Изолированный StatefulWidget для списка предметов
class _SubjectsList extends StatefulWidget {
  final List<String> selectedSubjects;
  final bool isEditing;
  final double Function(String) calculateSubjectProgress;
  final Color Function(String) getSubjectColor;
  final void Function(int, int) onReorder;
  final void Function(String) onSubjectTap;
  final AppLocalizations appLocalizations;

  const _SubjectsList({
    required this.selectedSubjects,
    required this.isEditing,
    required this.calculateSubjectProgress,
    required this.getSubjectColor,
    required this.onReorder,
    required this.onSubjectTap,
    required this.appLocalizations,
  });

  @override
  State<_SubjectsList> createState() => _SubjectsListState();
}

class _SubjectsListState extends State<_SubjectsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedSubjects.isEmpty) {
      return _buildEmptyState();
    }

    // Если режим редактирования - используем ReorderableListView
    if (widget.isEditing) {
      return ReorderableListView.builder(
        padding: EdgeInsets.only(bottom: 110, top: 8),
        itemCount: widget.selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = widget.selectedSubjects[index];
          final progress = widget.calculateSubjectProgress(subject);
          final color = widget.getSubjectColor(subject);

          return Container(
            key: ValueKey('$subject-$index'),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              children: [
                // Карточка предмета
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
              ],
            ),
          );
        },
        onReorderStart: (index) async {
          try {
            await HapticFeedback.lightImpact();
          } catch (e) {}
        },
        onReorder: widget.onReorder,
        onReorderEnd: (_) async {
          try {
            await HapticFeedback.lightImpact();
          } catch (e) {}
        },
        buildDefaultDragHandles: false,
      );
    } else {
      // Если не режим редактирования - обычный ListView
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 110, top: 8),
        itemCount: widget.selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = widget.selectedSubjects[index];
          final progress = widget.calculateSubjectProgress(subject);
          final color = widget.getSubjectColor(subject);

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
      onTap: () => widget.onSubjectTap(subject),
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

                  // Кнопка перехода к предмету
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => widget.onSubjectTap(subject),
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
                        widget.appLocalizations.progress,
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
              widget.appLocalizations.noSelectedSubjects,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              widget.appLocalizations.addSubjectsToLearn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.hintColor,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Открытие диалога предметов будет из родительского виджета
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
                widget.appLocalizations.addSubjectsButton,
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
}