// lib/screens/eduleague_screen.dart

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
  Map<String, dynamic> _leagueData = {};
  List<Map<String, dynamic>> _groupMembers = [];
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic> _currentLeague = {};
  Map<String, dynamic>? _groupInfo;
  List<Map<String, dynamic>> _allLeagues = [];

  bool _isLoading = true;
  int _selectedTab = 0; // 0 - группа, 1 - история

  String _userAvatar = '👤';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLeagueData();
    _loadAllLeagues();
  }

  Future<void> _loadUserData() async {
    final avatar = await UserDataStorage.getAvatar();
    final username = await UserDataStorage.getUsername();
    setState(() {
      _userAvatar = avatar;
      _username = username;
    });
  }

  Future<void> _loadAllLeagues() async {
    try {
      final response = await ApiService.getAvailableLeagues();
      if (response['success'] == true) {
        setState(() {
          _allLeagues = List<Map<String, dynamic>>.from(response['leagues'] ?? []);
        });
      }
    } catch (e) {
      print('Ошибка загрузки списка лиг: $e');
    }
  }

  Future<void> _loadLeagueData() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getCurrentLeague();

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _leagueData = data;
          _currentLeague = data['current_league'] ?? {};
          _groupInfo = data['group'];
          _groupMembers = List<Map<String, dynamic>>.from(data['members'] ?? []);
          _history = List<Map<String, dynamic>>.from(data['history'] ?? []);
        });
      } else {
        _loadLocalData();
      }
    } catch (e) {
      _loadLocalData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadLocalData() {
    setState(() {
      _currentLeague = {
        'name': 'Бронзовая',
        'icon': '🥉',
        'color': '#CD7F32',
        'id': 'bronze',
      };
      _groupInfo = null;
      _groupMembers = [];
    });
  }

  void _showLeaguesDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Все лиги',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _allLeagues.length,
                itemBuilder: (context, index) {
                  final league = _allLeagues[index];
                  final isCurrent = league['id'] == _currentLeague['id'];
                  final leagueColor = _parseColor(league['color'] ?? '#CD7F32');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? leagueColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? leagueColor : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: leagueColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: leagueColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        league['name'] ?? 'Лига',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? leagueColor : null,
                        ),
                      ),
                      trailing: isCurrent
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: leagueColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Текущая',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildUserAvatar(String avatar, String username, {bool isCurrentUser = false, double size = 40}) {
    final leagueColor = _parseColor(_currentLeague['color'] ?? '#CD7F32');

    bool isNetworkAvatar = avatar.startsWith('http');
    bool isLocalFile = avatar.startsWith('/') && !isNetworkAvatar;

    if (isNetworkAvatar) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(color: leagueColor, width: 2) : null,
        ),
        child: ClipOval(
          child: Image.network(
            avatar,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(username, isCurrentUser, size);
            },
          ),
        ),
      );
    } else if (isLocalFile) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrentUser ? Border.all(color: leagueColor, width: 2) : null,
        ),
        child: ClipOval(
          child: Image.file(
            File(avatar),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(username, isCurrentUser, size);
            },
          ),
        ),
      );
    } else {
      return _buildDefaultAvatar(username, isCurrentUser, size);
    }
  }

  Widget _buildDefaultAvatar(String username, bool isCurrentUser, double size) {
    final leagueColor = _parseColor(_currentLeague['color'] ?? '#CD7F32');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: leagueColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: isCurrentUser ? Border.all(color: leagueColor, width: 2) : null,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: leagueColor,
          ),
        ),
      ),
    );
  }

  String _getDaysLeftText(dynamic daysLeft) {
    if (daysLeft == null) return 'Неизвестно';

    final days = daysLeft is double ? daysLeft.toInt() : daysLeft;

    if (days < 0) return 'Завершена';
    if (days == 0) return 'Сегодня последний день!';
    if (days == 1) return 'Остался 1 день';
    return 'Осталось $days дней';
  }

  // Получаем цвет статуса для пользователя с учетом лиги
  Color _getStatusColor(int rank, int size, int topCount, int bottomCount, String leagueId) {
    final isBronze = leagueId == 'bronze';
    final isUnreal = leagueId == 'unreal';

    final isInTop = rank <= topCount;
    final isInBottom = rank > size - bottomCount;

    if (isInTop && !isUnreal) {
      return const Color(0xFF4CAF50); // Темно-салатовый/зеленый - повышение
    } else if (isInBottom && !isBronze) {
      return const Color(0xFFFF6B6B); // Бледно-красный - вылет
    } else {
      return const Color(0xFFA9A9A9); // Серый - остаются
    }
  }

  // Получаем текст статуса для пользователя с учетом лиги
  String _getStatusText(int rank, int size, int topCount, int bottomCount, String leagueId) {
    final isBronze = leagueId == 'bronze';
    final isUnreal = leagueId == 'unreal';

    final isInTop = rank <= topCount;
    final isInBottom = rank > size - bottomCount;

    if (isInTop && !isUnreal) {
      return 'Повышение';
    } else if (isInBottom && !isBronze) {
      return 'Вылет';
    } else {
      return 'Остается';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final leagueColor = _parseColor(_currentLeague['color'] ?? '#CD7F32');
    final localizations = AppLocalizations.of(context)!;
    final leagueId = _currentLeague['id'] ?? 'bronze';

    // Получаем данные для статусов
    final topCount = _groupInfo != null ? (_groupInfo!['top_count'] is double ? (_groupInfo!['top_count'] as double).toInt() : _groupInfo!['top_count'] as int) : 0;
    final bottomCount = _groupInfo != null ? (_groupInfo!['bottom_count'] is double ? (_groupInfo!['bottom_count'] as double).toInt() : _groupInfo!['bottom_count'] as int) : 0;
    final size = _groupInfo != null ? (_groupInfo!['size'] is double ? (_groupInfo!['size'] as double).toInt() : _groupInfo!['size'] as int) : 0;
    final userWeeklyXP = _groupInfo?['user_weekly_xp'] ?? 0;
    final daysLeft = _groupInfo?['days_left'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              leagueColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              leagueColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
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
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.section,
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

              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
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
                  child: Column(
                    children: [
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
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Кнопка выбора лиги
                              Flexible(
                                child: GestureDetector(
                                  onTap: _showLeaguesDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: leagueColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: leagueColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _currentLeague['name'] ?? 'Бронзовая',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: leagueColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: leagueColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Плашка с днями
                              if (daysLeft != null)
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: leagueColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 12,
                                            color: leagueColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              _getDaysLeftText(daysLeft),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: leagueColor,
                                                height: 1.2,
                                              ),
                                              softWrap: true,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Табы
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildTab(0, 'Группа', _groupMembers.length),
                            _buildTab(1, 'История', _history.length),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Контент
                      Expanded(
                        child: IndexedStack(
                          index: _selectedTab,
                          children: [
                            _buildGroupList(topCount, bottomCount, size, leagueId),
                            _buildHistoryList(),
                          ],
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

  double _getDaysTextFontSize(String text) {
    final length = text.length;
    if (length <= 15) return 12;
    if (length <= 25) return 11;
    if (length <= 35) return 10;
    return 9;
  }

  Widget _buildTab(int index, String title, int count) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);
    final leagueColor = _parseColor(_currentLeague['color'] ?? '#CD7F32');

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? leagueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              count > 0 ? '$title ($count)' : title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.hintColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList(int topCount, int bottomCount, int size, String leagueId) {
    if (_groupMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет участников в группе',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeagueData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _groupMembers.length,
        itemBuilder: (context, index) {
          final member = _groupMembers[index];
          final isCurrentUser = member['is_current_user'] == true;
          final rank = member['rank'] is double ? (member['rank'] as double).toInt() : member['rank'] as int;
          final leagueColor = _parseColor(_currentLeague['color'] ?? '#CD7F32');

          // Получаем цвет и текст статуса с учетом лиги
          final statusColor = _getStatusColor(rank, size, topCount, bottomCount, leagueId);
          final statusText = _getStatusText(rank, size, topCount, bottomCount, leagueId);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? leagueColor.withOpacity(0.1)
                  : (Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : Colors.white),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    rank > 0 ? '$rank' : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      member['name'] ?? 'Пользователь',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${member['weekly_xp'] ?? 0} XP',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              trailing: _buildUserAvatar(
                member['avatar'] ?? '👤',
                member['name'] ?? '',
                isCurrentUser: isCurrentUser,
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'История пуста',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'После первой недели здесь появится история перемещений',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final record = _history[index];
        final isPromotion = record['old_league'] != record['new_league'] &&
            _getLeagueLevel(record['new_league']) > _getLeagueLevel(record['old_league']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isPromotion ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPromotion ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isPromotion ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record['old_league']} → ${record['new_league']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record['weekly_xp']} XP • ${record['rank']}-е место из ${record['group_size']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                record['date'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getLeagueLevel(String leagueName) {
    const leagues = {
      'Бронзовая': 1,
      'Серебряная': 2,
      'Золотая': 3,
      'Платиновая': 4,
      'Бриллиантовая': 5,
      'Элитная': 6,
      'Легендарная': 7,
      'Нереальная': 8,
    };
    return leagues[leagueName] ?? 1;
  }
}