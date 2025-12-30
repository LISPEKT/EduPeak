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
  int _totalAchievements = 41;
  int _friendsCount = 0;
  Map<DateTime, int> _dailyActivity = {};
  Map<DateTime, int> _dailyXP = {};
  Map<String, double> _subjectProgress = {};
  List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> _achievementsList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserStats();
    _loadSelectedSubjects();
    _loadFriendsData();
    _loadAchievementsData();
    _calculateSubjectProgress();
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

      String popularSubject = 'Нет данных';
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

  Future<void> _loadFriendsData() async {
    try {
      final friendsData = await _simulateFriendsApiCall();
      if (mounted) {
        setState(() {
          _friendsList = friendsData;
          _friendsCount = friendsData.length;
        });
      }
    } catch (e) {
      print('❌ Error loading friends data: $e');
      _createMockFriendsData();
    }
  }

  Future<List<Map<String, dynamic>>> _simulateFriendsApiCall() async {
    await Future.delayed(Duration(milliseconds: 100));
    return [
      {
        'id': '1',
        'name': 'Александр Иванов',
        'username': 'alex_ivanov',
        'streakDays': 7,
        'completedTopics': 15,
        'correctAnswers': 120,
        'avatar': '👨‍🎓',
        'currentLeague': 'Серебряная',
        'weeklyXP': 450,
        'isOnline': true,
      },
      {
        'id': '2',
        'name': 'Мария Петрова',
        'username': 'maria_petrova',
        'streakDays': 14,
        'completedTopics': 22,
        'correctAnswers': 180,
        'avatar': '👩‍🎓',
        'currentLeague': 'Золотая',
        'weeklyXP': 620,
        'isOnline': false,
      },
      {
        'id': '3',
        'name': 'Иван Сидоров',
        'username': 'ivan_sidorov',
        'streakDays': 3,
        'completedTopics': 8,
        'correctAnswers': 65,
        'avatar': '👨‍💼',
        'currentLeague': 'Бронзовая',
        'weeklyXP': 210,
        'isOnline': true,
      },
    ];
  }

  void _createMockFriendsData() {
    setState(() {
      _friendsList = [
        {
          'id': '1',
          'name': 'Тестовый друг 1',
          'username': 'test_friend1',
          'streakDays': 5,
          'completedTopics': 10,
          'correctAnswers': 80,
          'avatar': '👤',
          'currentLeague': 'Бронзовая',
          'weeklyXP': 300,
          'isOnline': true,
        },
      ];
      _friendsCount = _friendsList.length;
    });
  }

  Future<void> _loadAchievementsData() async {
    try {
      final achievementsData = await _simulateAchievementsApiCall();
      if (mounted) {
        setState(() {
          _achievementsList = achievementsData;
          _achievementsCompleted = achievementsData.where((a) => a['isUnlocked'] == true).length;
        });
      }
    } catch (e) {
      print('❌ Error loading achievements data: $e');
      _createMockAchievementsData();
    }
  }

  Future<List<Map<String, dynamic>>> _simulateAchievementsApiCall() async {
    await Future.delayed(Duration(milliseconds: 100));

    bool isBronzeAchieved = _isLeagueAchieved('Бронзовая');
    bool isSilverAchieved = _isLeagueAchieved('Серебряная');
    bool isGoldAchieved = _isLeagueAchieved('Золотая');
    bool isPlatinumAchieved = _isLeagueAchieved('Платиновая');
    bool isDiamondAchieved = _isLeagueAchieved('Бриллиантовая');
    bool isEliteAchieved = _isLeagueAchieved('Элитная');
    bool isLegendaryAchieved = _isLeagueAchieved('Легендарная');
    bool isUnrealAchieved = _isLeagueAchieved('Нереальная');

    return [
      {
        'id': 'first_test',
        'name': 'Первый шаг',
        'description': 'Пройдите первый тест',
        'imageAsset': '🎯',
        'requiredValue': 1,
        'currentValue': _completedTopics >= 1 ? 1 : 0,
        'type': 'testsCompleted',
        'isUnlocked': _completedTopics >= 1,
      },
      {
        'id': 'streak_3',
        'name': 'Начало пути',
        'description': 'Занимайтесь 3 дня подряд',
        'imageAsset': '🔥',
        'requiredValue': 3,
        'currentValue': _userStats.streakDays,
        'type': 'streakDays',
        'isUnlocked': _userStats.streakDays >= 3,
      },
      {
        'id': 'correct_100',
        'name': 'Точный ответ',
        'description': 'Дайте 100 правильных ответов',
        'imageAsset': '✅',
        'requiredValue': 100,
        'currentValue': _correctAnswers,
        'type': 'correctAnswers',
        'isUnlocked': _correctAnswers >= 100,
      },
      {
        'id': 'bronze_league',
        'name': 'Бронзовый боец',
        'description': 'Достигните Бронзовой лиги',
        'imageAsset': '🥉',
        'requiredValue': 1,
        'currentValue': isBronzeAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isBronzeAchieved,
      },
      {
        'id': 'silver_league',
        'name': 'Серебряный стратег',
        'description': 'Достигните Серебряной лиги',
        'imageAsset': '🥈',
        'requiredValue': 1,
        'currentValue': isSilverAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isSilverAchieved,
      },
      {
        'id': 'gold_league',
        'name': 'Золотой чемпион',
        'description': 'Достигните Золотой лиги',
        'imageAsset': '🥇',
        'requiredValue': 1,
        'currentValue': isGoldAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isGoldAchieved,
      },
      {
        'id': 'platinum_league',
        'name': 'Платиновый гений',
        'description': 'Достигните Платиновой лиги',
        'imageAsset': '💎',
        'requiredValue': 1,
        'currentValue': isPlatinumAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isPlatinumAchieved,
      },
      {
        'id': 'diamond_league',
        'name': 'Бриллиантовый мастер',
        'description': 'Достигните Бриллиантовой лиги',
        'imageAsset': '💠',
        'requiredValue': 1,
        'currentValue': isDiamondAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isDiamondAchieved,
      },
      {
        'id': 'elite_league',
        'name': 'Элитный воин',
        'description': 'Достигните Элитной лиги',
        'imageAsset': '⭐',
        'requiredValue': 1,
        'currentValue': isEliteAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isEliteAchieved,
      },
      {
        'id': 'legendary_league',
        'name': 'Легендарный герой',
        'description': 'Достигните Легендарной лиги',
        'imageAsset': '🔥',
        'requiredValue': 1,
        'currentValue': isLegendaryAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isLegendaryAchieved,
      },
      {
        'id': 'unreal_league',
        'name': 'Нереальный гений',
        'description': 'Достигните Нереальной лиги',
        'imageAsset': '🌌',
        'requiredValue': 1,
        'currentValue': isUnrealAchieved ? 1 : 0,
        'type': 'league',
        'isUnlocked': isUnrealAchieved,
      },
    ];
  }

  bool _isLeagueAchieved(String league) {
    final leagueOrder = ['Бронзовая', 'Серебряная', 'Золотая', 'Платиновая', 'Бриллиантовая', 'Элитная', 'Легендарная', 'Нереальная'];
    final currentIndex = leagueOrder.indexOf(_currentLeague);
    final targetIndex = leagueOrder.indexOf(league);
    return currentIndex >= targetIndex;
  }

  void _createMockAchievementsData() {
    setState(() {
      _achievementsList = [
        {
          'id': 'first_test',
          'name': 'Первый шаг',
          'description': 'Пройдите первый тест',
          'imageAsset': '🎯',
          'requiredValue': 1,
          'currentValue': 1,
          'type': 'testsCompleted',
          'isUnlocked': true,
        },
        {
          'id': 'bronze_league',
          'name': 'Бронзовый боец',
          'description': 'Достигните Бронзовой лиги',
          'imageAsset': '🥉',
          'requiredValue': 1,
          'currentValue': 1,
          'type': 'league',
          'isUnlocked': true,
        },
      ];
      _achievementsCompleted = _achievementsList.where((a) => a['isUnlocked'] == true).length;
    });
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
    if (_registrationDate == null) return 'Неизвестно';
    final formatter = DateFormat('dd.MM.yyyy');
    return 'На EduPeak с ${formatter.format(_registrationDate!)}';
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
        builder: (_) => AchievementsScreen(),
      ),
    ).then((_) {
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
      _loadFriendsData();
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
        builder: (_) => XPStatsScreen(
          dailyXP: _dailyXP,
        ),
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
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                          'Раздел',
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

              // Остальной контент в скролле (как на других экранах)
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
                                      _username.isNotEmpty ? _username : 'Без имени',
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

                                    // Лига и XP
                                    Row(
                                      children: [
                                        // Лига
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getLeagueColor().withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getLeagueColor(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getLeagueIcon(),
                                                size: 14,
                                                color: _getLeagueColor(),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                _currentLeague,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getLeagueColor(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),

                                        // XP
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.bolt_rounded,
                                                size: 14,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                '$_totalXP XP',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                              '$_friendsCount друзей',
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
                          'Статистика',
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
                                title: 'Дней',
                                value: '${_userStats.streakDays}',
                                subtitle: 'подряд',
                                color: Colors.orange,
                                icon: Icons.local_fire_department_rounded,
                                isDark: isDark,
                                onTap: _openStreakScreen,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Опыт',
                                value: '$_totalXP',
                                subtitle: 'XP',
                                color: Colors.green,
                                icon: Icons.leaderboard_rounded,
                                isDark: isDark,
                                onTap: _openXPScreen,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Темы',
                                value: '$_completedTopics',
                                subtitle: 'завершено',
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
                              'Изучаемые предметы',
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
                              title: 'Достижения',
                              subtitle: '$_achievementsCompleted/$_totalAchievements завершено',
                              icon: Icons.emoji_events_rounded,
                              color: Colors.amber,
                              isDark: isDark,
                              onTap: _openAchievementsScreen,
                            ),
                            SizedBox(height: 12),

                            // Лига
                            _buildFeatureCard(
                              title: 'Лига',
                              subtitle: _currentLeague,
                              icon: _getLeagueIcon(),
                              color: _getLeagueColor(),
                              isDark: isDark,
                              onTap: _openLeagueScreen,
                            ),
                            SizedBox(height: 12),

                            // Лучший предмет
                            _buildFeatureCard(
                              title: 'Лучший предмет',
                              subtitle: _mostPopularSubject,
                              icon: Icons.school_rounded,
                              color: Colors.purple,
                              isDark: isDark,
                              onTap: _openStatisticsScreen,
                            ),
                            SizedBox(height: 12),

                            // Правильные ответы
                            _buildFeatureCard(
                              title: 'Правильные ответы',
                              subtitle: '$_correctAnswers',
                              icon: Icons.check_rounded,
                              color: Colors.teal,
                              isDark: isDark,
                              onTap: _openStatisticsScreen,
                            ),
                            SizedBox(height: 12),

                            // Еженедельный опыт
                            _buildFeatureCard(
                              title: 'Еженедельный опыт',
                              subtitle: '$_weeklyXP XP',
                              icon: Icons.timeline_rounded,
                              color: Colors.blue,
                              isDark: isDark,
                              onTap: _openXPScreen,
                            ),
                          ],
                        ),
                      ),
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
    required String subtitle,
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
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.hintColor,
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