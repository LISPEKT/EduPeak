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
    League(name: 'Бронза', minXp: 0, maxXp: 100, color: Color(0xFFCD7F32), icon: '🥉'),
    League(name: 'Серебро', minXp: 101, maxXp: 300, color: Color(0xFFC0C0C0), icon: '🥈'),
    League(name: 'Золото', minXp: 301, maxXp: 500, color: Color(0xFFFFD700), icon: '🥇'),
    League(name: 'Платина', minXp: 501, maxXp: 1000, color: Color(0xFFE5E4E2), icon: '💎'),
    League(name: 'Бриллиант', minXp: 1001, maxXp: 9999, color: Color(0xFFB9F2FF), icon: '💠'),
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
      // Загружаем информацию о пользователе
      final userStats = await UserDataStorage.getUserStatsOverview();
      setState(() {
        _userStats = userStats;
      });

      // Загружаем информацию о лиге пользователя
      final userInfoResponse = await ApiService.getUserLeagueInfo();
      if (userInfoResponse['success'] == true) {
        setState(() {
          _userLeagueInfo = userInfoResponse;
        });
      } else {
        _loadLocalUserInfo();
      }

      // Загружаем лидерборд для выбранной лиги
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
        'current_league': _userStats['currentLeague'] ?? 'Бронза',
        'weekly_xp': _userStats['weeklyXP'] ?? 0,
        'rank': 0, // Без ранга пока нет данных
        'total_users': 0,
        'xp_to_next_league': _calculateXPToNextLeague(),
      };
    });
  }

  int _calculateXPToNextLeague() {
    final weeklyXP = _userStats['weeklyXP'] ?? 0;
    final currentLeague = _userStats['currentLeague'] ?? 'Бронза';

    switch (currentLeague) {
      case 'Бронза': return (101 - weeklyXP).toInt();
      case 'Серебро': return (301 - weeklyXP).toInt();
      case 'Золото': return (501 - weeklyXP).toInt();
      case 'Платина': return (1001 - weeklyXP).toInt();
      case 'Бриллиант': return 0;
      default: return (101 - weeklyXP).toInt();
    }
  }

  void _loadLocalData() {
    _loadLocalUserInfo();
    _loadLocalLeaderboard(_leagues[_selectedLeagueIndex].name);
  }

  Future<void> _loadLeaderboard(String leagueName) async {
    try {
      final response = await ApiService.getLeagueLeaderboard(leagueName);

      if (response['success'] == true) {
        final leaderboardData = response['leaderboard'] as List;
        List<User> users = leaderboardData.map((data) => User.fromJson(data)).toList();

        // Добавляем текущего пользователя в лидерборд если он в этой лиге
        final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза';
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
    final localizations = AppLocalizations.of(context);
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
    // Пустой список вместо заглушек
    List<User> users = [];

    // Добавляем текущего пользователя если он в этой лиге
    final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза';
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
      case 'Бронза': return Color(0xFFCD7F32);
      case 'Серебро': return Color(0xFFC0C0C0);
      case 'Золото': return Color(0xFFFFD700);
      case 'Платина': return Color(0xFFE5E4E2);
      case 'Бриллиант': return Color(0xFFB9F2FF);
      default: return Theme.of(context).primaryColor;
    }
  }

  String _getUserLeagueIcon(String league) {
    switch (league) {
      case 'Бронза': return '🥉';
      case 'Серебро': return '🥈';
      case 'Золото': return '🥇';
      case 'Платина': return '💎';
      case 'Бриллиант': return '💠';
      default: return '🏆';
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

    if (isPhoto) {
      // Реальная фото аватарка
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(
            color: _getLeagueColor(_userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза'),
            width: 3,
          ) : Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.file(
            File(avatar),
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      );
    } else {
      // Эмодзи или текст аватарка
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getAvatarColor(username),
          border: isCurrentUser ? Border.all(
            color: _getLeagueColor(_userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза'),
            width: 3,
          ) : Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            avatar.length > 2 ? avatar.substring(0, 2) : avatar,
            style: TextStyle(
              fontSize: isCurrentUser ? size * 0.4 : size * 0.35,
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
  }

  Color _getAvatarColor(String username) {
    final colors = [
      Color(0xFFF44336), Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF673AB7),
      Color(0xFF3F51B5), Color(0xFF2196F3), Color(0xFF03A9F4), Color(0xFF00BCD4),
      Color(0xFF009688), Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFCDDC39),
      Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFFF5722),
    ];

    final index = username.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final selectedLeague = _leagues[_selectedLeagueIndex];
    final userRank = _userLeagueInfo['rank'] ?? 0;
    final userXP = _userLeagueInfo['weekly_xp'] ?? _userStats['weeklyXP'] ?? 0;
    final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза';
    final xpToNext = _userLeagueInfo['xp_to_next_league'] ?? _calculateXPToNextLeague();
    final username = _userStats['username'] ?? localizations.you;

    // Принудительно черный цвет для всех текстов в светлой теме
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final Color primaryTextColor = isDarkTheme ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDarkTheme ? Colors.grey[400]! : Colors.grey[700]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.educationalLeague,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryTextColor),
            onPressed: _isLoading ? null : _loadLeagueData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Плашка пользователя
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getLeagueColor(userLeague).withOpacity(0.1),
                  _getLeagueColor(userLeague).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getLeagueColor(userLeague).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Аватар и иконка лиги
                Stack(
                  children: [
                    _buildUserAvatar(_userAvatar, username, isCurrentUser: true, size: 70),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getLeagueColor(userLeague),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _getUserLeagueIcon(userLeague),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Информация о пользователе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        '${localizations.league}: $userLeague',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _UserStatItem(
                            icon: Icons.emoji_events,
                            value: '$userXP XP',
                            color: _getLeagueColor(userLeague),
                            textColor: primaryTextColor,
                          ),
                          const SizedBox(width: 16),
                          _UserStatItem(
                            icon: Icons.leaderboard,
                            value: userRank > 0 ? '${localizations.rank} $userRank' : localizations.noRank,
                            color: _getLeagueColor(userLeague),
                            textColor: primaryTextColor,
                          ),
                        ],
                      ),
                      if (xpToNext > 0) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: userXP / 100,
                          backgroundColor: Colors.grey[300],
                          color: _getLeagueColor(userLeague),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${localizations.toNextLeague}: $xpToNext XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Горизонтальный список лиг
          Container(
            height: 110, // Увеличиваем высоту с 100 до 110
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index];
                final isSelected = index == _selectedLeagueIndex;
                final isCurrentLeague = league.name == userLeague;

                return GestureDetector(
                  onTap: () => _onLeagueSelected(index),
                  child: Container(
                    width: 80,
                    height: 90, // Уменьшаем высоту контейнера с 80 до 90
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? league.color.withOpacity(0.2)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? league.color : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          league.icon,
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          league.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? league.color : primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCurrentLeague) ...[
                          const SizedBox(height: 2),
                          Icon(Icons.star, size: 12, color: Colors.amber),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Заголовок списка пользователей
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${localizations.playersInLeague} ${selectedLeague.name} (${_leaderboard.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Список пользователей в лиге
          Expanded(
            child: _leaderboard.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: secondaryTextColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    localizations.noPlayersInLeague,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    localizations.beFirstInLeague,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final user = _leaderboard[index];
                final isCurrentUser = user.isCurrentUser;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? _getLeagueColor(selectedLeague.name).withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentUser
                          ? _getLeagueColor(selectedLeague.name).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedLeague.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.rank > 0 ? '${user.rank}' : '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selectedLeague.color,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: primaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      '@${user.username} • ${user.xp} XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryTextColor,
                      ),
                    ),
                    trailing: _buildUserAvatar(
                      user.avatar,
                      user.username,
                      isCurrentUser: isCurrentUser,
                      size: isCurrentUser ? 50 : 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color textColor;

  const _UserStatItem({
    required this.icon,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class League {
  final String name;
  final int minXp;
  final int maxXp;
  final Color color;
  final String icon;

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