// lib/screens/multiplayer/friends_screen.dart

import 'package:flutter/material.dart';
import '../../services/multiplayer_service.dart';
import '../../localization.dart';
import '../../data/user_data_storage.dart';
import 'create_game_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with AutomaticKeepAliveClientMixin {
  final _multiplayerService = MultiplayerService();
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  int _selectedTab = 0; // 0 - друзья, 1 - запросы, 2 - поиск

  final RefreshIndicator _refreshIndicator = RefreshIndicator(
    onRefresh: () async {},
    child: Container(),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void didUpdateWidget(FriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем данные при возврате на экран
    if (mounted) {
      _loadFriends();
    }
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    try {
      final response = await _multiplayerService.getFriends();
      print('📥 Ответ от getFriends: $response');

      if (response['success'] == true) {
        setState(() {
          _friends = List<Map<String, dynamic>>.from(response['friends'] ?? []);
          _pendingRequests = List<Map<String, dynamic>>.from(response['pending_requests'] ?? []);
        });
        print('✅ Загружено друзей: ${_friends.length}, запросов: ${_pendingRequests.length}');
      }
    } catch (e) {
      print('❌ Error loading friends: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadFriends();
    if (_selectedTab == 2 && _searchQuery.isNotEmpty) {
      await _searchUsers(_searchQuery);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    try {
      print('🔍 Поиск: $query');
      final response = await _multiplayerService.searchUsers(query);
      print('📥 Ответ поиска: $response');

      if (response['success'] == true) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response['users'] ?? []);
        });
        print('✅ Найдено результатов: ${_searchResults.length}');
      } else {
        print('❌ Ошибка поиска: ${response['message']}');
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print('❌ Исключение при поиске: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    final response = await _multiplayerService.sendFriendRequest(userId);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Запрос отправлен'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Обновляем поиск
      _searchUsers(_searchQuery);
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    final response = await _multiplayerService.acceptFriendRequest(requestId);

    if (response['success'] == true) {
      _loadFriends();
    }
  }

  Future<void> _declineRequest(int requestId) async {
    final response = await _multiplayerService.declineFriendRequest(requestId);

    if (response['success'] == true) {
      _loadFriends();
    }
  }

  void _inviteToGame(Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGameScreen(
          gameType: 'duel_friend',
          title: 'Пригласить ${friend['name']}',
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

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
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
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
                            'Социальное',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Друзья',
                            style: TextStyle(
                              fontSize: 28,
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
                    _buildTab(0, 'Друзья', _friends.length),
                    _buildTab(1, 'Запросы', _pendingRequests.length),
                    _buildTab(2, 'Поиск', null),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Контент с обновлением при смене вкладки
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildRefreshableFriendsList(),
                    _buildRefreshableRequestsList(),
                    _buildRefreshableSearchList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title, int? count) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
          // Обновляем данные при смене вкладки
          if (index == 0 || index == 1) {
            _loadFriends();
          } else if (index == 2 && _searchQuery.isNotEmpty) {
            _searchUsers(_searchQuery);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              count != null ? '$title ($count)' : title,
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

  Widget _buildRefreshableFriendsList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _buildFriendsList(),
    );
  }

  Widget _buildRefreshableRequestsList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _buildRequestsList(),
    );
  }

  Widget _buildRefreshableSearchList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_searchQuery.isNotEmpty) {
          await _searchUsers(_searchQuery);
        } else {
          await _refreshData();
        }
      },
      child: _buildSearchList(),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'У вас пока нет друзей',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Найдите друзей в поиске',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                setState(() {
                  _selectedTab = 2;
                });
              },
              child: const Text('Найти друзей'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildRequestsList() {
    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет входящих запросов',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildSearchList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: _searchUsers,
            decoration: InputDecoration(
              hintText: 'Поиск по имени или email',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        Expanded(
          child: _isSearching
              ? Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Введите имя для поиска'
                      : 'Ничего не найдено',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              return _buildSearchResultCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final theme = Theme.of(context);
    final leagueColor = _getLeagueColor(friend['league'] ?? 'Бронзовая');

    return GestureDetector(
      onTap: () {
        // Открываем чат при нажатии на карточку друга
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(friend: friend),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Аватар
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: leagueColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: leagueColor,
                  width: 2,
                ),
              ),
              child: friend['avatar'] != null
                  ? ClipOval(
                child: Image.network(
                  friend['avatar'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_rounded,
                    color: leagueColor,
                  ),
                ),
              )
                  : Icon(
                Icons.person_rounded,
                color: leagueColor,
              ),
            ),
            const SizedBox(width: 12),
            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        friend['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: friend['is_online'] == true ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: leagueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          friend['league'] ?? 'Бронзовая',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: leagueColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${friend['xp']} XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Кнопки действий
            Row(
              children: [
                // Кнопка чата
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(friend: friend),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Кнопка пригласить
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.sports_esports_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: () => _inviteToGame(friend),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final theme = Theme.of(context);
    final user = request['user'] ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Пользователь',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Хочет добавить вас в друзья',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_rounded, color: Colors.green),
                onPressed: () => _acceptRequest(request['id']),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.red),
                onPressed: () => _declineRequest(request['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final leagueColor = _getLeagueColor(user['league'] ?? 'Бронзовая');
    final isAlreadyFriend = _friends.any((f) => f['id'] == user['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: leagueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['league'] ?? 'Бронзовая',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: leagueColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user['xp']} XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isAlreadyFriend)
            FilledButton(
              onPressed: () => _sendFriendRequest(user['id']),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Добавить'),
            ),
        ],
      ),
    );
  }
}