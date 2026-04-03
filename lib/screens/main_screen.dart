// lib/screens/main_screen.dart

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
import 'package:edu_peak/services/api_service.dart';
import 'multiplayer/multiplayer_home_screen.dart';

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

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
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

  Map<String, double> _subjectProgressCache = {};

  // Анимации
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

  late AnimationController _subjectListAppearController;
  late Animation<double> _subjectListOpacity;
  late Animation<Offset> _subjectListSlide;

  // Для вращающейся плашки
  Timer? _cardRotationTimer;
  Duration _cardRotationDuration = const Duration(seconds: 10);
  int _currentCardState = 0;
  List<NewsItem> _newsItems = [];
  late AnimationController _progressAnimationController;
  late PageController _pageController;
  bool _isManualScrolling = false;
  bool _isAutoRotating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    _progressAnimationController = AnimationController(
      duration: _cardRotationDuration,
      vsync: this,
    );

    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onPageChanged);

    _editIconScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _editButtonController, curve: Curves.easeInOut),
    );
    _editIconRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _editButtonController, curve: Curves.easeInOut),
    );
    _manageButtonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _manageButtonController, curve: Curves.easeInOut),
    );
    _manageButtonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _manageButtonController, curve: Curves.easeOutBack),
    );
    _xpCardScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _xpCardController, curve: Curves.easeInOut),
    );
    _avatarScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _avatarScaleController, curve: Curves.easeInOut),
    );
    _subjectListOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subjectListAppearController, curve: Curves.easeIn),
    );
    _subjectListSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _subjectListAppearController, curve: Curves.easeOutCubic),
    );

    _checkAuthStatus();
    _loadInitialData();
    _startBackgroundSync();
    _loadLatestNews();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceSyncProfile();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _subjectListAppearController.forward();
    });

    _startAutoRotation();
    _startProgressAnimation();
  }

  String _getLatestNews() {
    if (_newsItems.isNotEmpty) return _newsItems[0].title;
    return 'Следите за обновлениями';
  }

  Future<void> _loadInitialData() async {
    try {
      final cachedData = await UserDataStorage.getCachedUserData();

      setState(() {
        _username = cachedData['username'];
        _avatar = cachedData['avatar'];
      });

      print('✅ Данные загружены из кэша: $_username');

      _loadUserStats();
      _loadSelectedSubjects();
      _loadAllSubjects();

    } catch (e) {
      print('❌ Ошибка загрузки кэша: $e');
    }
  }

  Future<void> _startBackgroundSync() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final needsSync = await UserDataStorage.needsSync();

    if (needsSync) {
      print('🔄 Фоновая синхронизация данных...');

      final result = await UserDataStorage.syncXpAndProgress();

      if (result['success'] == true && result['hasUpdates'] == true && mounted) {
        final stats = await UserDataStorage.getUserStats();
        setState(() {
          _userStats = stats;
        });
        print('✅ Данные обновлены в фоне');
      }
    }

    await UserDataStorage.syncProfileInBackground();

    final cachedData = await UserDataStorage.getCachedUserData();
    if (mounted) {
      setState(() {
        if (_username != cachedData['username']) {
          _username = cachedData['username'];
        }
        if (_avatar != cachedData['avatar']) {
          _avatar = cachedData['avatar'];
        }
      });
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await UserDataStorage.getUserStats();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _lastDataUpdate = DateTime.now();
        });
      }
    } catch (e) {
      print('❌ Error loading user stats: $e');
    }
  }

  Future<void> _syncAvatarFromServer() async {
    try {
      final profile = await ApiService().getProfile();
      if (profile != null && profile['avatar_url'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_avatar_url', profile['avatar_url']);
        print('✅ Аватар синхронизирован с сервера: ${profile['avatar_url']}');
      }
    } catch (e) {
      print('❌ Ошибка синхронизации аватара: $e');
    }
  }

  Future<void> _forceSyncProfile() async {
    if (await UserDataStorage.isLoggedIn()) {
      await UserDataStorage.syncProfileFromServer();
      _loadUserData();
    }
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
        _newsItems = [
          NewsItem(
            id: 1,
            title: 'Полностью добавлен предмет обществознание 0.42.4',
            description: '',
            date: '14 февраля 2026',
            imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Update+0.42.4',
            category: 'Обновления',
            isRead: prefs.getBool('news_1_read') ?? false,
          ),
        ];
        await _saveNewsToStorage();
      }
    } catch (e) {
      print('❌ Error loading news: $e');
      _newsItems = [
        NewsItem(
          id: 1,
          title: 'Полностью добавлен предмет обществознание 0.42.4',
          description: '',
          date: '14 февраля 2026',
          imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Update+0.42.4',
          category: 'Обновления',
          isRead: false,
        ),
      ];
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveNewsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newsJson = _newsItems.map((news) => jsonEncode(news.toMap())).toList();
      await prefs.setStringList('news_items', newsJson);
      for (final news in _newsItems) {
        await prefs.setBool('news_${news.id}_read', news.isRead);
      }
    } catch (e) {
      print('❌ Error saving news: $e');
    }
  }

  void _startAutoRotation() {
    _cardRotationTimer?.cancel();
    _cardRotationTimer = Timer.periodic(_cardRotationDuration, (timer) {
      if (!mounted || !_isAutoRotating || _isManualScrolling) return;

      if (_pageController.hasClients) {
        final nextPage = (_currentCardState + 1) % 3;
        _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut
        );
      }
    });
  }

  void _restartAutoRotation() {
    _cardRotationTimer?.cancel();
    _cardRotationTimer = Timer.periodic(_cardRotationDuration, (timer) {
      if (!mounted || !_isAutoRotating || _isManualScrolling) return;

      if (_pageController.hasClients) {
        final nextPage = (_currentCardState + 1) % 3;
        _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut
        );
      }
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
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? 0;
    final newCardState = (page.round() % 3).abs();
    if (newCardState != _currentCardState) {
      setState(() => _currentCardState = newCardState);
      _restartAutoRotation();
      _restartProgressAnimation();
    }
  }

  void _handleCardTap(int cardIndex) async {
    await _triggerVibration();
    switch (cardIndex) {
      case 0: _openXPScreen(); break;
      case 1: _openNewsScreen(); break;
      case 2: _openLeagueScreen(); break;
    }
  }

  void _openNewsScreen() async {
    await _triggerVibration();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => NewsScreen()));
    if (mounted) await _loadLatestNews();
  }

  void _openLeagueScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EduLeagueScreen()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cardRotationTimer?.cancel();
    _editButtonController.dispose();
    _manageButtonController.dispose();
    _xpCardController.dispose();
    _avatarScaleController.dispose();
    _subjectListAppearController.dispose();
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

  Future<void> _triggerVibration() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {}
  }

  Future<void> _loadUserData() async {
    try {
      await UserDataStorage.syncProfileFromServer();

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
      if (mounted) setState(() => _selectedSubjects = savedSubjects ?? []);
    } catch (e) {
      print('❌ Error loading selected subjects: $e');
    }
  }

  Future<void> _loadAllSubjects() async {
    final allSubjects = <String>{};
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) allSubjects.add(subject.name);
    }
    if (mounted) setState(() => _allSubjects = allSubjects.toList());
  }

  Future<void> _saveSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedSubjects', _selectedSubjects);
    } catch (e) {
      print('❌ Error saving subjects: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final authMethod = prefs.getString('auth_method');
      final token = prefs.getString('token');

      print('🔍 Проверка аутентификации при запуске:');
      print('   - isLoggedIn: $isLoggedIn');
      print('   - auth_method: $authMethod');
      print('   - token: ${token != null ? "есть" : "нет"}');

      if (!isLoggedIn || token == null) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
          );
        }
      } else {
        // Восстанавливаем сессию
        await SessionManager.initializeSession(token);

        // Загружаем данные пользователя
        await _loadUserData();
        await _loadSelectedSubjects();
        await _loadAllSubjects();

        print('✅ Сессия восстановлена, пользователь: $_username');
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    }
  }

  void _onBottomNavTap(int index) async {
    await _triggerVibration();
    if (_isEditing) _toggleEditMode();
    setState(() => _currentBottomNavIndex = index);
    if (index == 0 && mounted) {
      final now = DateTime.now();
      if (_lastDataUpdate == null || now.difference(_lastDataUpdate!).inSeconds > 5) {
        _loadUserData();
        _loadLatestNews();
      }
    }
  }

  void _toggleEditMode() async {
    await _triggerVibration();

    if (_isEditing) {
      _manageButtonController.reverse();
      _editButtonController.reverse().then((_) {
        setState(() => _isEditing = false);
        _saveSelectedSubjects();
      });
    } else {
      setState(() => _isEditing = true);
      _editButtonController.forward();
      _manageButtonController.forward();
    }
  }

  void _addSubject(String subject) async {
    await _triggerVibration();
    if (!_selectedSubjects.contains(subject)) {
      setState(() => _selectedSubjects.add(subject));
      _saveSelectedSubjects();
      _showSnackBar('${AppLocalizations.of(context).subjectAdded}: "$subject"');
    }
  }

  void _removeSubject(String subject) async {
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
          await _triggerVibration();
          _addSubject(subject);
        },
        onRemoveSubject: (subject) async {
          await _triggerVibration();
          _removeSubject(subject);
        },
        appLocalizations: appLocalizations,
      ),
    ).then((_) => _loadSelectedSubjects());
  }

  void _showSnackBar(String message) async {
    await _triggerVibration();
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 105, left: 20, right: 20),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    const icons = {
      'Математика': Icons.calculate_rounded,
      'Алгебра': Icons.functions_rounded,
      'Геометрия': Icons.shape_line_rounded,
      'Русский язык': Icons.menu_book_rounded,
      'Литература': Icons.book_rounded,
      'История': Icons.history_rounded,
      'Обществознание': Icons.people_rounded,
      'География': Icons.public_rounded,
      'Биология': Icons.eco_rounded,
      'Физика': Icons.science_rounded,
      'Химия': Icons.science_rounded,
      'Английский язык': Icons.language_rounded,
      'Информатика': Icons.computer_rounded,
      'Статистика и вероятность': Icons.trending_up_rounded,
    };
    return icons[subject] ?? Icons.school_rounded;
  }

  Widget _getCurrentScreen() {
    switch (_currentBottomNavIndex) {
      case 0:
        return _buildHomeScreenContent();
      case 1:
        return ReviewScreen(onBottomNavTap: _onBottomNavTap, currentIndex: _currentBottomNavIndex);
      case 2:
        return DictionaryScreen(onBottomNavTap: _onBottomNavTap, currentIndex: _currentBottomNavIndex);
      case 3:
        return MultiplayerHomeScreen();
      case 4:
        return const SubscriptionScreen();
      case 5:
        return ProfileScreen(
            onBottomNavTap: _onBottomNavTap,
            currentIndex: _currentBottomNavIndex,
            onLogout: widget.onLogout
        );
      default:
        return _buildHomeScreenContent();
    }
  }

  Color _getSubjectColor(String subject) {
    const colors = {
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
      'Статистика и вероятность': Color(0xFF00BCD4),
      'Информатика': Color(0xFF607D8B),
    };
    if (!colors.containsKey(subject)) {
      final hash = subject.hashCode;
      return HSLColor.fromAHSL(1.0, (hash % 360).toDouble(), 0.7, 0.6).toColor();
    }
    return colors[subject]!;
  }

  double _calculateSubjectProgress(String subjectName) {
    if (_subjectProgressCache.containsKey(subjectName)) return _subjectProgressCache[subjectName]!;
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
    await _triggerVibration();
    _xpCardController.reverse().then((_) => _xpCardController.forward());
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => XPStatsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _openSubjectInfo(String subject) async {
    await _triggerVibration();
    Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectInfoScreen(subjectName: subject)));
  }

  void _openProfileEditor() async {
    await _triggerVibration();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditorScreen(
          currentAvatar: _avatar,
          onAvatarUpdate: (newAvatar) => setState(() => _avatar = newAvatar),
          onUsernameUpdate: (newUsername) => setState(() => _username = newUsername),
          onBottomNavTap: _onBottomNavTap,
          currentIndex: _currentBottomNavIndex,
        ),
      ),
    ).then((_) => _loadUserData());
  }

  bool _isPhotoAvatar() => _avatar.startsWith('/') || _avatar.contains('.');

  Widget _buildHomeScreenContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final appLocalizations = AppLocalizations.of(context);

    final cardHeight = isSmallScreen ? 100.0 : 130.0;
    final cardPadding = isSmallScreen ? 14.0 : 18.0;
    final iconSize = isSmallScreen ? 22.0 : 28.0;
    final titleFontSize = isSmallScreen ? 13.0 : 15.0;
    final valueFontSize = isSmallScreen ? 17.0 : 20.0;

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
              stops: const [0.0, 0.3, 0.7]
          )
              : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.08),
                Colors.white.withOpacity(0.7),
                Colors.white,
              ],
              stops: const [0.0, 0.3, 0.7]
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmallScreen ? 12 : 16),
                child: Row(
                  children: [
                    Semantics(
                      label: 'Профиль пользователя, $_username',
                      button: true,
                      child: GestureDetector(
                        onTapDown: (_) => _avatarScaleController.forward(),
                        onTapUp: (_) => _avatarScaleController.reverse(),
                        onTapCancel: () => _avatarScaleController.reverse(),
                        onTap: () async {
                          await _triggerVibration();
                          _openProfileEditor();
                        },
                        child: ScaleTransition(
                          scale: _avatarScale,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: _isPhotoAvatar()
                                ? ClipOval(
                              child: Image.file(
                                  File(_avatar),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person_rounded, color: primaryColor, size: 26)
                              ),
                            )
                                : Icon(Icons.person_rounded, color: primaryColor, size: 26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              appLocalizations.helloWhatToStudy,
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis
                          ),
                          const SizedBox(height: 3),
                          Text(
                              _username.isNotEmpty ? _username : appLocalizations.guest,
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 17 : 19,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleMedium?.color,
                                  height: 1.2
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis
                          ),
                        ],
                      ),
                    ),
                    // Стрик
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (_userStats.streakDays > 0 ? Colors.orange : Colors.grey).withOpacity(0.3),
                            width: 1
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              Icons.local_fire_department_rounded,
                              color: _userStats.streakDays > 0 ? Colors.orange : Colors.grey,
                              size: 20
                          ),
                          const SizedBox(width: 6),
                          Text(
                              '${_userStats.streakDays}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _userStats.streakDays > 0 ? Colors.orange : Colors.grey
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Карточки
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      height: cardHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 3,
                        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                        onPageChanged: (index) {
                          setState(() => _isManualScrolling = true);
                          _stopProgressAnimation();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() => _isManualScrolling = false);
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
                                if (details.delta.dx.abs() > 5) {
                                  setState(() => _isManualScrolling = true);
                                  _stopProgressAnimation();
                                }
                              },
                              onPanEnd: (_) {
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  if (mounted) {
                                    setState(() => _isManualScrolling = false);
                                    _restartProgressAnimation();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? theme.cardColor : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4)
                                  )],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: _buildCardContent(
                                      index,
                                      theme,
                                      isDark,
                                      primaryColor,
                                      iconSize: iconSize,
                                      titleFontSize: titleFontSize,
                                      valueFontSize: valueFontSize,
                                      isSmallScreen: isSmallScreen
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _currentCardState == i ? 20 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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

              // Заголовок предметов
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          appLocalizations.mySubjects,
                          style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color
                          ),
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isEditing)
                          FadeTransition(
                            opacity: _manageButtonOpacity,
                            child: ScaleTransition(
                              scale: _manageButtonScale,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                                child: InkWell(
                                  onTap: _showSubjectsDialog,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? theme.cardColor : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2)
                                      )],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.playlist_add_rounded, color: primaryColor, size: 20),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                              appLocalizations.management,
                                              style: TextStyle(
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor
                                              ),
                                              overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_isEditing) const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2)
                            )],
                          ),
                          child: IconButton(
                            icon: ScaleTransition(
                              scale: _editIconScale,
                              child: RotationTransition(
                                turns: _editIconRotation,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _isEditing
                                      ? const Icon(Icons.done_rounded, key: ValueKey('done'), color: Color(0xFF4CAF50))
                                      : Icon(Icons.edit_rounded, key: const ValueKey('edit'), color: primaryColor),
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

              // Список предметов
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
                        if (oldIndex < newIndex) newIndex -= 1;
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

  Widget _buildCardContent(int state, ThemeData theme, bool isDark, Color primaryColor,
      {required double iconSize, required double titleFontSize, required double valueFontSize, required bool isSmallScreen}) {
    switch (state) {
      case 0:
        return _buildXPCardContent(
            theme, isDark, primaryColor,
            iconSize: iconSize,
            titleFontSize: titleFontSize,
            valueFontSize: valueFontSize,
            isSmallScreen: isSmallScreen
        );
      case 1:
        return _buildNewsCardContent(
            theme, isDark, primaryColor,
            iconSize: iconSize,
            titleFontSize: titleFontSize,
            valueFontSize: valueFontSize,
            isSmallScreen: isSmallScreen
        );
      case 2:
        return _buildLeagueCardContent(
            theme, isDark, primaryColor,
            iconSize: iconSize,
            titleFontSize: titleFontSize,
            valueFontSize: valueFontSize,
            isSmallScreen: isSmallScreen
        );
      default:
        return _buildXPCardContent(
            theme, isDark, primaryColor,
            iconSize: iconSize,
            titleFontSize: titleFontSize,
            valueFontSize: valueFontSize,
            isSmallScreen: isSmallScreen
        );
    }
  }

  Widget _buildXPCardContent(ThemeData theme, bool isDark, Color primaryColor,
      {required double iconSize, required double titleFontSize, required double valueFontSize, required bool isSmallScreen}) {
    final appLocalizations = AppLocalizations.of(context);
    return Row(
      key: const ValueKey('xp'),
      children: [
        Container(
          width: iconSize * 2.5,
          height: iconSize * 2.5,
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.leaderboard_rounded, color: primaryColor, size: iconSize),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalizations.yourXp, style: TextStyle(fontSize: titleFontSize, color: theme.hintColor)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 1 : 2),
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('XP', style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: primaryColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text('${_userStats.totalXP} XP',
                  style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCardContent(ThemeData theme, bool isDark, Color primaryColor,
      {required double iconSize, required double titleFontSize, required double valueFontSize, required bool isSmallScreen}) {
    final appLocalizations = AppLocalizations.of(context);
    return Row(
      key: const ValueKey('news'),
      children: [
        Container(
          width: iconSize * 2.5,
          height: iconSize * 2.5,
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.new_releases_rounded, color: Colors.blue, size: iconSize),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalizations.latestNews, style: TextStyle(fontSize: titleFontSize, color: theme.hintColor)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 1 : 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Новости",
                      style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                  _getLatestNews(),
                  style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueCardContent(ThemeData theme, bool isDark, Color primaryColor,
      {required double iconSize, required double titleFontSize, required double valueFontSize, required bool isSmallScreen}) {
    final appLocalizations = AppLocalizations.of(context);
    String userLeague = _determineLeagueByXP(_userStats.totalXP);
    Color leagueColor = _getLeagueColor(userLeague);

    return Row(
      key: const ValueKey('league'),
      children: [
        Container(
          width: iconSize * 2.5,
          height: iconSize * 2.5,
          decoration: BoxDecoration(color: leagueColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(_getLeagueIcon(userLeague), color: leagueColor, size: iconSize),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalizations.yourLeague, style: TextStyle(fontSize: titleFontSize, color: theme.hintColor)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 1 : 2),
                    decoration: BoxDecoration(color: leagueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                        appLocalizations.league,
                        style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: leagueColor,
                            fontWeight: FontWeight.w500
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                  userLeague,
                  style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: leagueColor
                  )
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
      case 'Нереальная': return const Color(0xFFE6E6FA);
      case 'Легендарная': return const Color(0xFFFF4500);
      case 'Элитная': return const Color(0xFF7F7F7F);
      case 'Бриллиантовая': return const Color(0xFFB9F2FF);
      case 'Платиновая': return const Color(0xFFE5E4E2);
      case 'Золотая': return const Color(0xFFFFD700);
      case 'Серебряная': return const Color(0xFFC0C0C0);
      case 'Бронзовая': return const Color(0xFFCD7F32);
      default: return const Color(0xFFCD7F32);
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
    if (_userStats.totalXP >= 5000) return '${appLocalizations.excellentWork} ${appLocalizations.youEarnedXP} ${_userStats.totalXP} XP';
    if (_userStats.totalXP >= 1000) return '${appLocalizations.youEarnedXP} ${_userStats.totalXP} XP. ${appLocalizations.excellentProgress}';
    if (_userStats.totalXP >= 500) return '${_userStats.totalXP} XP - ${appLocalizations.goodResult}';
    if (_userStats.totalXP >= 100) return '${appLocalizations.youAlreadyHave} ${_userStats.totalXP} XP. ${appLocalizations.moveForward}';
    return appLocalizations.passFirstTestAndGetXP;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.1), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(index: 0, icon: Icons.home_filled, isDark: isDark, isSmallScreen: isSmallScreen),
            _buildBottomNavItem(index: 1, icon: Icons.refresh_rounded, isDark: isDark, isSmallScreen: isSmallScreen),
            _buildBottomNavItem(index: 2, icon: Icons.book_rounded, isDark: isDark, isSmallScreen: isSmallScreen),
            _buildBottomNavItem(index: 3, icon: Icons.sports_esports_rounded, isDark: isDark, isSmallScreen: isSmallScreen),
            _buildBottomNavItem(index: 4, icon: Icons.star_rounded, isDark: isDark, isSmallScreen: isSmallScreen),
            _buildBottomNavItem(index: 5, isDark: isDark, isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    IconData? icon,
    required bool isDark,
    required bool isSmallScreen
  }) {
    final isSelected = index == _currentBottomNavIndex;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;

    if (index == 5) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onBottomNavTap(index),
            borderRadius: BorderRadius.circular(28),
            splashColor: const Color(0xFF4CAF50).withOpacity(0.15),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 55,
              margin: EdgeInsets.all(isSelected ? 4 : 6),
              decoration: isSelected
                  ? BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
              )
                  : null,
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: isSmallScreen ? 28 : 32,
                    height: isSmallScreen ? 28 : 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : inactiveColor, width: isSelected ? 2 : 1.5),
                    ),
                    child: _isPhotoAvatar()
                        ? ClipOval(
                      child: Image.file(
                        File(_avatar),
                        fit: BoxFit.cover,
                        width: isSmallScreen ? 24 : 28,
                        height: isSmallScreen ? 24 : 28,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            color: isSelected ? Colors.white : inactiveColor,
                            size: isSmallScreen ? 16 : 18
                        ),
                      ),
                    )
                        : Center(
                      child: Icon(
                          Icons.person_rounded,
                          color: isSelected ? Colors.white : inactiveColor,
                          size: isSmallScreen ? 16 : 18
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBottomNavTap(index),
          borderRadius: BorderRadius.circular(28),
          splashColor: const Color(0xFF4CAF50).withOpacity(0.15),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 55,
            margin: EdgeInsets.all(isSelected ? 4 : 6),
            decoration: isSelected
                ? BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
            )
                : null,
            child: Center(
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                    icon,
                    color: isSelected ? Colors.white : inactiveColor,
                    size: isSmallScreen ? 22 : 26
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// _SubjectsDialog
// ============================================
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
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    ));
    _removeListAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
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
            : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAddingMode ? const Color(0xFF4CAF50) : Colors.transparent,
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
                      onTap: () => _switchMode(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAddingMode ? const Color(0xFFEA4335) : Colors.transparent,
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
          Expanded(
            child: Stack(
              children: [
                SlideTransition(
                  position: _addListAnimation,
                  child: _buildAddSubjectsList(),
                ),
                SlideTransition(
                  position: _removeListAnimation,
                  child: _buildRemoveSubjectsList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddSubjectsList() {
    final availableSubjects = widget.allSubjects
        .where((subject) => !widget.selectedSubjects.contains(subject))
        .toList();
    if (availableSubjects.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: availableSubjects.length,
      itemBuilder: (context, index) {
        final subject = availableSubjects[index];
        final color = widget.getSubjectColor(subject);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? widget.theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  widget.onAddSubject(subject);
                  setState(() {});
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
            onTap: () {
              widget.onAddSubject(subject);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildRemoveSubjectsList() {
    final subjectsToRemove = List.from(widget.selectedSubjects);
    if (subjectsToRemove.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA4335).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_circle_rounded,
                  size: 48,
                  color: Color(0xFFEA4335),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: subjectsToRemove.length,
      itemBuilder: (context, index) {
        final subject = subjectsToRemove[index];
        final color = widget.getSubjectColor(subject);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? widget.theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                color: const Color(0xFFEA4335),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA4335).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  widget.onRemoveSubject(subject);
                  setState(() {});
                },
                icon: const Icon(Icons.remove_rounded, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
            onTap: () {
              widget.onRemoveSubject(subject);
              setState(() {});
            },
          ),
        );
      },
    );
  }
}

// ============================================
// _SubjectsList
// ============================================
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
    if (widget.isEditing) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.only(bottom: 110, top: 8),
        itemCount: widget.selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = widget.selectedSubjects[index];
          final progress = widget.calculateSubjectProgress(subject);
          final color = widget.getSubjectColor(subject);
          return Container(
            key: ValueKey('$subject-$index'),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubjectCard(
                    subject: subject,
                    progress: progress,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
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
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.drag_indicator_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onReorderStart: (index) async {
          try { await HapticFeedback.lightImpact(); } catch (e) {}
        },
        onReorder: widget.onReorder,
        onReorderEnd: (_) async {
          try { await HapticFeedback.lightImpact(); } catch (e) {}
        },
        buildDefaultDragHandles: false,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 110, top: 8),
        itemCount: widget.selectedSubjects.length,
        itemBuilder: (context, index) {
          final subject = widget.selectedSubjects[index];
          final progress = widget.calculateSubjectProgress(subject);
          final color = widget.getSubjectColor(subject);
          return Container(
            key: ValueKey('$subject-$index'),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => widget.onSubjectTap(subject),
                      icon: Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.appLocalizations.progress, style: TextStyle(fontSize: 14, color: theme.hintColor)),
                      Text('$completedPercent%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(40),
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
              child: Icon(Icons.school_rounded, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              widget.appLocalizations.noSelectedSubjects,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
            ),
            const SizedBox(height: 12),
            Text(
              widget.appLocalizations.addSubjectsToLearn,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: theme.hintColor),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                widget.appLocalizations.addSubjectsButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}