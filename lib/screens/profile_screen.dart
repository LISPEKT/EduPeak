import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../localization.dart';
import '../data/subjects_data.dart';
import 'profile_editor_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'eduleague_screen.dart';
import 'streak_screen.dart';
import 'xp_stats_screen.dart';
import 'settings_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int) onBottomNavTap;
  final int currentIndex;
  final VoidCallback onLogout;

  const ProfileScreen({
    Key? key,
    required this.onBottomNavTap,
    required this.currentIndex,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _avatar = '👤';
  DateTime? _registrationDate;
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
  int _totalXP = 0;
  int _weeklyXP = 0;
  String _currentLeague = 'Бронзовая';
  String _mostPopularSubject = 'Математика';
  int _completedTopics = 0;
  int _correctAnswers = 0;
  int _achievementsCompleted = 0;
  int _totalAchievements = 0;
  int _friendsCount = 0;
  Map<DateTime, int> _dailyActivity = {};
  Map<DateTime, int> _dailyXP = {};
  Map<String, double> _subjectProgress = {};
  List<Map<String, dynamic>> _friendsList = [];

  // Ключи для кэширования
  static const String _cachedTotalXPKey = 'cached_total_xp';
  static const String _cachedWeeklyXPKey = 'cached_weekly_xp';
  static const String _cachedCompletedTopicsKey = 'cached_completed_topics';
  static const String _cachedCorrectAnswersKey = 'cached_correct_answers';
  static const String _cachedStreakDaysKey = 'cached_streak_days';
  static const String _cachedAchievementsCompletedKey = 'cached_achievements_completed';
  static const String _cachedTotalAchievementsKey = 'cached_total_achievements';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadUserData();
    _loadUserStats();
    _loadSelectedSubjects();
    _loadAchievementsData();
    _calculateSubjectProgress();
  }

  // Загрузка кэшированных данных
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _totalXP = prefs.getInt(_cachedTotalXPKey) ?? 0;
        _weeklyXP = prefs.getInt(_cachedWeeklyXPKey) ?? 0;
        _completedTopics = prefs.getInt(_cachedCompletedTopicsKey) ?? 0;
        _correctAnswers = prefs.getInt(_cachedCorrectAnswersKey) ?? 0;
        _userStats = _userStats.copyWith(
          streakDays: prefs.getInt(_cachedStreakDaysKey) ?? 0,
        );
        _achievementsCompleted = prefs.getInt(_cachedAchievementsCompletedKey) ?? 0;
        _totalAchievements = prefs.getInt(_cachedTotalAchievementsKey) ?? 0;
      });
    } catch (e) {
      print('❌ Error loading cached data: $e');
    }
  }

  // Сохранение данных в кэш
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cachedTotalXPKey, _totalXP);
      await prefs.setInt(_cachedWeeklyXPKey, _weeklyXP);
      await prefs.setInt(_cachedCompletedTopicsKey, _completedTopics);
      await prefs.setInt(_cachedCorrectAnswersKey, _correctAnswers);
      await prefs.setInt(_cachedStreakDaysKey, _userStats.streakDays);
      await prefs.setInt(_cachedAchievementsCompletedKey, _achievementsCompleted);
      await prefs.setInt(_cachedTotalAchievementsKey, _totalAchievements);
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final username = await UserDataStorage.getUsername();
      final avatar = await UserDataStorage.getAvatar();
      final prefs = await SharedPreferences.getInstance();
      final registrationTimestamp = prefs.getInt('registrationDate') ?? DateTime.now().millisecondsSinceEpoch;

      if (mounted) {
        setState(() {
          _username = username;
          _avatar = avatar;
          _registrationDate = DateTime.fromMillisecondsSinceEpoch(registrationTimestamp);
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final statsOverview = await UserDataStorage.getUserStatsOverview();

      final totalXP = statsOverview['totalXP'] as int? ?? 0;
      final weeklyXP = statsOverview['weeklyXP'] as int? ?? 0;
      final completedTopics = statsOverview['completedTopics'] as int? ?? 0;
      final correctAnswers = statsOverview['totalCorrectAnswers'] as int? ?? 0;
      final currentLeague = statsOverview['currentLeague'] as String? ?? 'Бронзовая';
      final username = statsOverview['username'] as String? ?? '';

      final actualLeague = _determineLeagueByXP(totalXP);

      String popularSubject = AppLocalizations.of(context).noData;
      int maxTopics = 0;
      if (stats.topicProgress.isNotEmpty) {
        for (final subject in stats.topicProgress.keys) {
          final topicCount = stats.topicProgress[subject]?.length ?? 0;
          if (topicCount > maxTopics) {
            maxTopics = topicCount;
            popularSubject = subject;
          }
        }
      }

      if (mounted) {
        setState(() {
          _userStats = stats;
          _totalXP = totalXP;
          _weeklyXP = weeklyXP;
          _completedTopics = completedTopics;
          _correctAnswers = correctAnswers;
          _currentLeague = actualLeague;
          _mostPopularSubject = popularSubject;
          _username = username.isNotEmpty ? username : _username;
        });

        // Сохраняем обновленные данные в кэш
        _saveToCache();
      }

      _calculateSubjectProgress();
    } catch (e) {
      print('❌ Error loading user stats: $e');
    }
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

  Future<void> _loadAchievementsData() async {
    try {
      // Сначала загружаем данные из кэша
      await _loadCachedData();

      // Если в кэше 0/0, устанавливаем дефолтные значения
      if (_totalAchievements == 0) {
        setState(() {
          _totalAchievements = 36; // Общее количество достижений
        });
      }
    } catch (e) {
      print('❌ Error loading achievements data: $e');
    }
  }

  Future<Map<String, int>> _getAchievementsFromScreen() async {
    // В реальном приложении здесь нужно получить данные из AchievementsScreen
    // Сейчас эмулируем получение данных
    await Future.delayed(Duration(milliseconds: 50));

    // Возвращаем значения из кэша или дефолтные
    return {
      'completed': _achievementsCompleted,
      'total': _totalAchievements,
    };
  }

  Future<void> _loadSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSubjects = prefs.getStringList('selectedSubjects');
      if (savedSubjects != null && savedSubjects.isNotEmpty) {
        setState(() {
          _selectedSubjects = savedSubjects;
        });
      } else {
        final allSubjects = _getAllSubjects();
        setState(() {
          _selectedSubjects = allSubjects;
        });
      }
    } catch (e) {
      print('❌ Error loading selected subjects: $e');
    }
  }

  void _calculateSubjectProgress() {
    final progress = <String, double>{};
    final subjectsByGrade = getSubjectsByGrade(context);
    final allSubjects = <String>{};

    for (final grade in subjectsByGrade.keys) {
      final subjects = subjectsByGrade[grade] ?? [];
      for (final subject in subjects) {
        allSubjects.add(subject.name);
      }
    }

    for (final subjectName in allSubjects) {
      if (_userStats.topicProgress.containsKey(subjectName)) {
        final topics = _userStats.topicProgress[subjectName] ?? {};
        final totalTopics = _getTotalTopicsForSubject(subjectName);
        if (totalTopics > 0) {
          final completedTopics = topics.length;
          progress[subjectName] = completedTopics / totalTopics;
        } else {
          progress[subjectName] = 0.0;
        }
      } else {
        progress[subjectName] = 0.0;
      }
    }

    if (mounted) {
      setState(() {
        _subjectProgress = progress;
      });
    }
  }

  int _getTotalTopicsForSubject(String subjectName) {
    final subjectsByGrade = getSubjectsByGrade(context);
    int totalTopics = 0;
    for (final grade in subjectsByGrade.keys) {
      final subjects = subjectsByGrade[grade] ?? [];
      for (final subject in subjects) {
        if (subject.name == subjectName) {
          final topics = subject.topicsByGrade[grade] ?? [];
          totalTopics += topics.length;
        }
      }
    }
    return totalTopics;
  }

  List<String> _getAllSubjects() {
    final allSubjects = <String>{};
    final subjectsByGrade = getSubjectsByGrade(context);
    for (final grade in subjectsByGrade.keys) {
      final subjects = subjectsByGrade[grade] ?? [];
      for (final subject in subjects) {
        allSubjects.add(subject.name);
      }
    }
    return allSubjects.toList();
  }

  bool _isPhotoAvatar() {
    return _avatar.startsWith('/') || _avatar.contains('.');
  }

  String _formatRegistrationDate() {
    if (_registrationDate == null) return AppLocalizations.of(context).unknown;
    final appLocalizations = AppLocalizations.of(context);
    final formatter = DateFormat('dd.MM.yyyy');
    return '${appLocalizations.since} ${formatter.format(_registrationDate!)}';
  }

  IconData _getLeagueIcon() {
    switch (_currentLeague) {
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

  Color _getLeagueColor() {
    switch (_currentLeague) {
      case 'Нереальная': return Color(0xFFE6E6FA);
      case 'Легендарная': return Color(0xFFFF4500);
      case 'Элитная': return Color(0xFF7F7F7F);
      case 'Бриллиантовая': return Color(0xFFB9F2FF);
      case 'Платиновая': return Color(0xFFE5E4E2);
      case 'Золотая': return Color(0xFFFFD700);
      case 'Серебряная': return Color(0xFFC0C0C0);
      case 'Бронзовая': return Color(0xFFCD7F32);
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  void _openStatisticsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(userStats: _userStats),
      ),
    );
  }

  void _openAchievementsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(
          onAchievementsLoaded: (AchievementCount count) {
            // Обновляем данные при загрузке достижений
            setState(() {
              _achievementsCompleted = count.completed;
              _totalAchievements = count.total;
            });

            // Сохраняем в кэш
            _saveToCache();
          },
        ),
      ),
    ).then((_) {
      // Обновляем данные при возвращении с экрана
      _loadAchievementsData();
    });
  }

  void _openFriendsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendsScreen(),
      ),
    ).then((_) {
    });
  }

  void _openLeagueScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EduLeagueScreen(),
      ),
    );
  }

  void _openStreakScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StreakScreen(
          dailyActivity: _dailyActivity,
          streakDays: _userStats.streakDays,
        ),
      ),
    );
  }

  void _openXPScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => XPStatsScreen()
      ),
    );
  }

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(onLogout: widget.onLogout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalizations.section,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          appLocalizations.profile,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
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
                        icon: Icon(Icons.settings_rounded),
                        color: primaryColor,
                        onPressed: _openSettingsScreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Остальной контент в скролле
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная карточка профиля
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Container(
                          padding: EdgeInsets.all(20),
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
                              // Аватар
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileEditorScreen(
                                        currentAvatar: _avatar,
                                        onAvatarUpdate: (newAvatar) {
                                          setState(() {
                                            _avatar = newAvatar;
                                          });
                                          UserDataStorage.saveAvatar(newAvatar);
                                        },
                                        onUsernameUpdate: (newUsername) {
                                          setState(() {
                                            _username = newUsername;
                                          });
                                          UserDataStorage.saveUsername(newUsername);
                                        },
                                        onBottomNavTap: widget.onBottomNavTap,
                                        currentIndex: widget.currentIndex,
                                      ),
                                    ),
                                  ).then((_) => _loadUserData());
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isPhotoAvatar()
                                      ? ClipOval(
                                    child: Image.file(
                                      File(_avatar),
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person_rounded,
                                          color: primaryColor,
                                          size: 36,
                                        );
                                      },
                                    ),
                                  )
                                      : Icon(
                                    Icons.person_rounded,
                                    color: primaryColor,
                                    size: 36,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),

                              // Информация профиля
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _username.isNotEmpty ? _username : appLocalizations.noName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.titleMedium?.color,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _formatRegistrationDate(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    // Друзья
                                    GestureDetector(
                                      onTap: _openFriendsScreen,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.people_rounded,
                                              size: 16,
                                              color: primaryColor,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              '$_friendsCount ${appLocalizations.friendsCount}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: primaryColor,
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
                          ),
                        ),
                      ),

                      // Статистика в ряд
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          appLocalizations.statisticsPlural,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: appLocalizations.daysInRow,
                                value: '${_userStats.streakDays}',
                                color: Colors.orange,
                                icon: Icons.local_fire_department_rounded,
                                isDark: isDark,
                                onTap: _openStreakScreen,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: appLocalizations.xpEarned,
                                value: '$_totalXP',
                                color: Colors.green,
                                icon: Icons.leaderboard_rounded,
                                isDark: isDark,
                                onTap: _openXPScreen,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: appLocalizations.topicsCompleted,
                                value: '$_completedTopics',
                                color: Colors.blue,
                                icon: Icons.check_circle_rounded,
                                isDark: isDark,
                                onTap: _openStatisticsScreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Изучаемые предметы
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appLocalizations.studiedSubjects,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedSubjects.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedSubjects.length,
                            itemBuilder: (context, index) {
                              final subject = _selectedSubjects[index];
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  subject,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Дополнительная статистика
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          children: [
                            // Достижения
                            _buildFeatureCard(
                              title: appLocalizations.achievements,
                              subtitle: '$_achievementsCompleted/$_totalAchievements ${appLocalizations.achievementsCompleted}',
                              icon: Icons.emoji_events_rounded,
                              color: Colors.amber,
                              isDark: isDark,
                              onTap: _openAchievementsScreen,
                            ),
                            SizedBox(height: 12),

                            // Лига
                            _buildFeatureCard(
                              title: appLocalizations.league,
                              subtitle: _currentLeague,
                              icon: _getLeagueIcon(),
                              color: _getLeagueColor(),
                              isDark: isDark,
                              onTap: _openLeagueScreen,
                            ),
                          ],
                        ),
                      ),

                      // Отступ для BottomNavigationBar
                      SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}