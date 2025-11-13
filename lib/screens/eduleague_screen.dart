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
        'rank': 0,
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
      default: return Theme.of(context).colorScheme.primary;
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
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(
            color: _getLeagueColor(_userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза'),
            width: 3,
          ) : Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
      // Используем такой же стиль как в main_screen.dart
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(
            color: _getLeagueColor(_userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза'),
            width: 3,
          ) : Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: size * 0.5, // Пропорциональный размер иконки
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final selectedLeague = _leagues[_selectedLeagueIndex];
    final userRank = _userLeagueInfo['rank'] ?? 0;
    final userXP = _userLeagueInfo['weekly_xp'] ?? _userStats['weeklyXP'] ?? 0;
    final userLeague = _userLeagueInfo['current_league'] ?? _userStats['currentLeague'] ?? 'Бронза';
    final xpToNext = _userLeagueInfo['xp_to_next_league'] ?? _calculateXPToNextLeague();
    final username = _userStats['username'] ?? localizations.you;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          localizations.educationalLeague,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadLeagueData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '${localizations.loading}...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      )
          : Column(
        children: [
          // User info card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with league badge
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
                          border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
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
                SizedBox(width: 16),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$userLeague ${localizations.league}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Stats row
                      Row(
                        children: [
                          _UserStatItem(
                            icon: Icons.emoji_events_rounded,
                            value: '$userXP XP',
                            color: _getLeagueColor(userLeague),
                          ),
                          SizedBox(width: 16),
                          _UserStatItem(
                            icon: Icons.leaderboard_rounded,
                            value: userRank > 0 ? '${localizations.rank} $userRank' : localizations.noRank,
                            color: _getLeagueColor(userLeague),
                          ),
                        ],
                      ),

                      // Progress to next league
                      if (xpToNext > 0) ...[
                        SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: userXP / 100,
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              color: _getLeagueColor(userLeague),
                              borderRadius: BorderRadius.circular(8),
                              minHeight: 8,
                            ),
                            SizedBox(height: 6),
                            Text(
                              '${localizations.toNextLeague}: $xpToNext XP',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

          // Leagues horizontal list
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index];
                final isSelected = index == _selectedLeagueIndex;
                final isCurrentLeague = league.name == userLeague;

                return GestureDetector(
                  onTap: () => _onLeagueSelected(index),
                  child: Container(
                    width: 80,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
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
                        SizedBox(height: 6),
                        Text(
                          league.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isCurrentLeague) ...[
                          SizedBox(height: 2),
                          Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          // Leaderboard header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${localizations.playersInLeague} ${selectedLeague.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_leaderboard.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Leaderboard list
          Expanded(
            child: _leaderboard.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    localizations.noPlayersInLeague,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    localizations.beFirstInLeague,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final user = _leaderboard[index];
                final isCurrentUser = user.isCurrentUser;

                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          user.rank > 0 ? '${user.rank}' : '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '@${user.username} • ${user.xp} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  const _UserStatItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
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