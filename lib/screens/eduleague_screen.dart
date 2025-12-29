import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import '../localization.dart';

class EduLeagueScreen extends StatefulWidget {
  @override
  State<EduLeagueScreen> createState() => _EduLeagueScreenState();
}

class _EduLeagueScreenState extends State<EduLeagueScreen> {
  final List<League> _leagues = [
    League(
      name: 'Бронзовая',
      minXp: 0,
      maxXp: 499,
      color: Color(0xFFCD7F32),
      icon: Icons.circle_rounded,
    ),
    League(
      name: 'Серебряная',
      minXp: 500,
      maxXp: 999,
      color: Color(0xFFC0C0C0),
      icon: Icons.circle_rounded,
    ),
    League(
      name: 'Золотая',
      minXp: 1000,
      maxXp: 1499,
      color: Color(0xFFFFD700),
      icon: Icons.circle_rounded,
    ),
    League(
      name: 'Платиновая',
      minXp: 1500,
      maxXp: 1999,
      color: Color(0xFFE5E4E2),
      icon: Icons.circle_rounded,
    ),
    League(
      name: 'Бриллиантовая',
      minXp: 2000,
      maxXp: 2999,
      color: Color(0xFFB9F2FF),
      icon: Icons.diamond_rounded,
    ),
    League(
      name: 'Элитная',
      minXp: 3000,
      maxXp: 3999,
      color: Color(0xFF7F7F7F),
      icon: Icons.star_rounded,
    ),
    League(
      name: 'Легендарная',
      minXp: 4000,
      maxXp: 4999,
      color: Color(0xFFFF4500),
      icon: Icons.whatshot_rounded,
    ),
    League(
      name: 'Нереальная',
      minXp: 5000,
      maxXp: 99999,
      color: Color(0xFFE6E6FA),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  int _selectedLeagueIndex = 0;
  List<User> _leaderboard = [];
  Map<String, dynamic> _userLeagueInfo = {};
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  String _userAvatar = '👤';

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
    _loadLeagueData();
  }

  Future<void> _loadUserAvatar() async {
    final avatar = await UserDataStorage.getAvatar();
    setState(() {
      _userAvatar = avatar;
    });
  }

  Future<void> _loadLeagueData() async {
    setState(() => _isLoading = true);

    try {
      final userStats = await UserDataStorage.getUserStatsOverview();
      setState(() {
        _userStats = userStats;
      });

      final userInfoResponse = await ApiService.getUserLeagueInfo();
      if (userInfoResponse['success'] == true) {
        setState(() {
          _userLeagueInfo = userInfoResponse;
        });
      } else {
        _loadLocalUserInfo();
      }

      final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронзовая';
      final userLeagueIndex = _leagues.indexWhere((league) => league.name == userLeague);
      if (userLeagueIndex != -1) {
        _selectedLeagueIndex = userLeagueIndex;
      }

      await _loadLeaderboard(_leagues[_selectedLeagueIndex].name);
    } catch (e) {
      print('Error loading league data: $e');
      _loadLocalData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadLocalUserInfo() {
    setState(() {
      _userLeagueInfo = {
        'current_league': _userStats['currentLeague'] ?? 'Бронзовая',
        'weekly_xp': _userStats['weeklyXP'] ?? 0,
        'rank': 0,
        'total_users': 0,
        'xp_to_next_league': _calculateXPToNextLeague(),
      };
    });
  }

  int _calculateXPToNextLeague() {
    final weeklyXP = _userStats['weeklyXP'] ?? 0;
    final currentLeague = _userStats['currentLeague'] ?? 'Бронзовая';

    switch (currentLeague) {
      case 'Бронзовая': return (500 - weeklyXP).clamp(0, 500).toInt();
      case 'Серебряная': return (1000 - weeklyXP).clamp(0, 500).toInt();
      case 'Золотая': return (1500 - weeklyXP).clamp(0, 500).toInt();
      case 'Платиновая': return (2000 - weeklyXP).clamp(0, 500).toInt();
      case 'Бриллиантовая': return (3000 - weeklyXP).clamp(0, 1000).toInt();
      case 'Элитная': return (4000 - weeklyXP).clamp(0, 1000).toInt();
      case 'Легендарная': return (5000 - weeklyXP).clamp(0, 1000).toInt();
      case 'Нереальная': return 0;
      default: return (500 - weeklyXP).clamp(0, 500).toInt();
    }
  }

  void _loadLocalData() {
    _loadLocalUserInfo();

    final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронзовая';
    final userLeagueIndex = _leagues.indexWhere((league) => league.name == userLeague);
    if (userLeagueIndex != -1) {
      _selectedLeagueIndex = userLeagueIndex;
    }

    _loadLocalLeaderboard(_leagues[_selectedLeagueIndex].name);
  }

  Future<void> _loadLeaderboard(String leagueName) async {
    try {
      final response = await ApiService.getLeagueLeaderboard(leagueName);

      if (response['success'] == true) {
        final leaderboardData = response['leaderboard'] as List;
        List<User> users = leaderboardData.map((data) => User.fromJson(data)).toList();

        final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронзовая';
        if (userLeague == leagueName) {
          final currentUser = _createCurrentUser();
          if (!users.any((user) => user.id == 'current')) {
            users.add(currentUser);
          }
        }

        setState(() {
          _leaderboard = users;
        });
      } else {
        _loadLocalLeaderboard(leagueName);
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      _loadLocalLeaderboard(leagueName);
    }
  }

  User _createCurrentUser() {
    final localizations = AppLocalizations.of(context)!;
    final username = _userStats['username'] ?? localizations.you;
    final weeklyXP = _userStats['weeklyXP'] ?? 0;

    return User(
      id: 'current',
      name: username,
      username: username,
      xp: weeklyXP,
      avatar: _userAvatar,
      rank: _userLeagueInfo['rank'] ?? 0,
      isCurrentUser: true,
    );
  }

  void _loadLocalLeaderboard(String leagueName) {
    List<User> users = [];

    final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронзовая';
    if (userLeague == leagueName) {
      users.add(_createCurrentUser());
    }

    setState(() {
      _leaderboard = users;
    });
  }

  void _onLeagueSelected(int index) {
    setState(() {
      _selectedLeagueIndex = index;
    });
    _loadLeaderboard(_leagues[index].name);
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Бронзовая': return Color(0xFFCD7F32);
      case 'Серебряная': return Color(0xFFC0C0C0);
      case 'Золотая': return Color(0xFFFFD700);
      case 'Платиновая': return Color(0xFFE5E4E2);
      case 'Бриллиантовая': return Color(0xFFB9F2FF);
      case 'Элитная': return Color(0xFF7F7F7F);
      case 'Легендарная': return Color(0xFFFF4500);
      case 'Нереальная': return Color(0xFFE6E6FA);
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  bool _isPhotoAvatar(String avatar) {
    if (avatar == '👤') return false;

    try {
      final file = File(avatar);
      return file.existsSync();
    } catch (e) {
      print('❌ Error checking avatar file: $e');
      return false;
    }
  }

  Widget _buildUserAvatar(String avatar, String username, {bool isCurrentUser = false, double size = 40}) {
    final isPhoto = _isPhotoAvatar(avatar);
    final theme = Theme.of(context);

    if (isPhoto) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ) : Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.file(
            File(avatar),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ) : Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            color: theme.colorScheme.onPrimaryContainer,
            size: size * 0.5,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final localizations = AppLocalizations.of(context)!;
    final selectedLeague = _leagues[_selectedLeagueIndex];
    final userXP = _userLeagueInfo['weekly_xp'] ?? _userStats['weeklyXP'] ?? 0;
    final xpToNext = _userLeagueInfo['xp_to_next_league'] ?? _calculateXPToNextLeague();
    final username = _userStats['username'] ?? localizations.you;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель с заголовком
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Кнопка назад
                    Container(
                      width: 44,
                      height: 44,
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
                        icon: Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
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
                            localizations.educationalLeague,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          '${localizations.loading}...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Карточка пользователя
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                // Аватар
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.cardColor : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _buildUserAvatar(_userAvatar, username, isCurrentUser: true, size: 70),
                                ),
                                SizedBox(width: 16),

                                // Информация о пользователе
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.titleMedium?.color,
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      // Статистика в ряд
                                      Row(
                                        children: [
                                          _buildUserStatItem(
                                            icon: Icons.bolt_rounded,
                                            value: '$userXP XP',
                                            color: primaryColor,
                                          ),
                                        ],
                                      ),

                                      // Прогресс до следующей лиги
                                      if (xpToNext > 0) ...[
                                        SizedBox(height: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: _getLeagueProgress(userXP, _userStats['currentLeague'] ?? 'Бронзовая'),
                                              backgroundColor:
                                              isDark ? Colors.grey[800] : Colors.grey[200],
                                              color: primaryColor,
                                              borderRadius: BorderRadius.circular(4),
                                              minHeight: 8,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              '${localizations.toNextLeague}: $xpToNext XP',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.hintColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Список лиг с квадратными плашками
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            'Доступные лиги',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),

                        Container(
                          height: 110, // Увеличена высота для квадратных плашек
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _leagues.length,
                            itemBuilder: (context, index) {
                              final league = _leagues[index];
                              final isSelected = index == _selectedLeagueIndex;

                              return GestureDetector(
                                onTap: () => _onLeagueSelected(index),
                                child: Container(
                                  width: 90, // Ширина для квадратной плашки
                                  margin: EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getLeagueColor(league.name).withOpacity(0.2)
                                        : (isDark ? theme.cardColor : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? _getLeagueColor(league.name)
                                          : theme.colorScheme.outline.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        )
                                      else
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Иконка лиги в квадрате
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: _getLeagueColor(league.name).withOpacity(0.2),
                                          border: Border.all(
                                            color: _getLeagueColor(league.name),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            league.icon,
                                            size: 24,
                                            color: _getLeagueColor(league.name),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      // Название лиги
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          league.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? _getLeagueColor(league.name)
                                                : theme.textTheme.titleMedium?.color,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Диапазон XP
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${league.minXp}-${league.maxXp == 99999 ? '∞' : league.maxXp}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Заголовок таблицы лидеров
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${localizations.playersInLeague} ${selectedLeague.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getLeagueColor(selectedLeague.name).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_rounded,
                                      size: 14,
                                      color: _getLeagueColor(selectedLeague.name),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${_leaderboard.length}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getLeagueColor(selectedLeague.name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Список лидеров
                        if (_leaderboard.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 64,
                                  color: theme.hintColor,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  localizations.noPlayersInLeague,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  localizations.beFirstInLeague,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.hintColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _leaderboard.length,
                            itemBuilder: (context, index) {
                              final user = _leaderboard[index];
                              final isCurrentUser = user.isCurrentUser;

                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? primaryColor.withOpacity(0.1)
                                      : (isDark ? theme.cardColor : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(user.rank),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.rank > 0 ? '${user.rank}' : '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '@${user.username} • ${user.xp} XP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  trailing: _buildUserAvatar(
                                    user.avatar,
                                    user.username,
                                    isCurrentUser: isCurrentUser,
                                    size: 44,
                                  ),
                                ),
                              );
                            },
                          ),

                        SizedBox(height: 20),
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

  Widget _buildUserStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700);
      case 2:
        return Color(0xFFC0C0C0);
      case 3:
        return Color(0xFFCD7F32);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  double _getLeagueProgress(int xp, String league) {
    switch (league) {
      case 'Бронзовая':
        return (xp / 500).clamp(0.0, 1.0);
      case 'Серебряная':
        return ((xp - 500) / 500).clamp(0.0, 1.0);
      case 'Золотая':
        return ((xp - 1000) / 500).clamp(0.0, 1.0);
      case 'Платиновая':
        return ((xp - 1500) / 500).clamp(0.0, 1.0);
      case 'Бриллиантовая':
        return ((xp - 2000) / 1000).clamp(0.0, 1.0);
      case 'Элитная':
        return ((xp - 3000) / 1000).clamp(0.0, 1.0);
      case 'Легендарная':
        return ((xp - 4000) / 1000).clamp(0.0, 1.0);
      case 'Нереальная':
        return 1.0;
      default:
        return (xp / 500).clamp(0.0, 1.0);
    }
  }
}

class League {
  final String name;
  final int minXp;
  final int maxXp;
  final Color color;
  final IconData icon;

  League({
    required this.name,
    required this.minXp,
    required this.maxXp,
    required this.color,
    required this.icon,
  });
}

class User {
  final String id;
  final String name;
  final String username;
  final int xp;
  final String avatar;
  final int rank;
  final bool isCurrentUser;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.xp,
    required this.avatar,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      xp: json['xp'] ?? 0,
      avatar: json['avatar'] ?? '👤',
      rank: json['rank'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}