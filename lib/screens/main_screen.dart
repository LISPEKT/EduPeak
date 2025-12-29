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

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
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
  DateTime? _lastDataUpdate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
    _loadUserData();
    _loadSelectedSubjects();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentBottomNavIndex == 0) {
      _loadUserData();
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

      final allSubjects = _getAllSubjects();

      if (mounted) {
        setState(() {
          _selectedSubjects = savedSubjects ?? allSubjects;
        });
      }
    } catch (e) {
      print('❌ Error loading selected subjects: $e');
    }
  }

  List<String> _getAllSubjects() {
    final allSubjects = <String>{};
    for (final grade in getSubjectsByGrade(context).keys) {
      final subjects = getSubjectsByGrade(context)[grade] ?? [];
      for (final subject in subjects) {
        allSubjects.add(subject.name);
      }
    }
    return allSubjects.toList();
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

  void _onBottomNavTap(int index) {
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
      'Математика': Color(0xFF4285F4), // Синий Google
      'Алгебра': Color(0xFF2196F3), // Голубой
      'Геометрия': Color(0xFF3F51B5), // Индиго
      'Русский язык': Color(0xFFEA4335), // Красный Google
      'Литература': Color(0xFFFBBC05), // Желтый Google
      'История': Color(0xFF34A853), // Зеленый Google
      'Обществознание': Color(0xFF8E44AD), // Фиолетовый
      'География': Color(0xFF00BCD4), // Бирюзовый
      'Биология': Color(0xFF4CAF50), // Зеленый
      'Физика': Color(0xFF9C27B0), // Пурпурный
      'Химия': Color(0xFFFF9800), // Оранжевый
      'Английский язык': Color(0xFFE91E63), // Розовый
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

  void _openXPScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => XPStatsScreen(),
      ),
    );
  }

  void _openSubjectInfo(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectInfoScreen(subjectName: subject),
      ),
    );
  }

  // В основных экранах добавьте отображение текущего XP:
  Widget _buildXPIndicator() {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserDataStorage.getUserStatsOverview(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final xp = snapshot.data!['totalXP'] ?? 0;
          final league = snapshot.data!['currentLeague'] ?? 'Бронза';

          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text('$xp XP • $league'),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
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
              // Верхняя панель с аватаркой и поиском
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Аватарка и приветствие
                    Row(
                      children: [
                        Container(
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
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, что будем изучать сегодня?',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              _username.isNotEmpty ? _username : 'Гость',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Кнопка поиска
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
                        icon: Icon(Icons.search_rounded),
                        color: primaryColor,
                        onPressed: () {
                          // TODO: Реализовать поиск
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // НОВАЯ ПЛАШКА С ОПЫТОМ (как на других экранах)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                              value: _userStats.totalXP > 10000 ? 1.0 : _userStats.totalXP / 10000,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
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

              // Заголовок предметов
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои предметы',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              // Список предметов с затемнением (цвет фона, а не карточек)
              Expanded(
                child: Stack(
                  children: [
                    // Контент с отступами
                    _selectedSubjects.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                      padding: EdgeInsets.all(20),
                      children: _selectedSubjects.map((subject) {
                        final progress = _calculateSubjectProgress(subject);
                        final color = _getSubjectColor(subject);

                        return _buildSubjectCard(
                          subject: subject,
                          progress: progress,
                          color: color,
                          isDark: isDark,
                          theme: theme,
                        );
                      }).toList(),
                    ),

                    // Затемнение сверху (цвет фона)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(1.0),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.8),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.6),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.4),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.2),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.1),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                          ),
                        ),
                      ),
                    ),

                    // Затемнение снизу (цвет фона)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(1.0),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.8),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.6),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.4),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.2),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.1),
                              (isDark ? theme.scaffoldBackgroundColor : Colors.white).withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildSubjectCard({
    required String subject,
    required double progress,
    required Color color,
    required bool isDark,
    required ThemeData theme,
  }) {
    final completedPercent = (progress * 100).round();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          // Верхняя часть с названием и кнопкой
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
                GestureDetector(
                  onTap: () => _openSubjectInfo(subject),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Прогресс бар
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
              onPressed: () {
                // TODO: Реализовать добавление предметов
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
    return _avatar.startsWith('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
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