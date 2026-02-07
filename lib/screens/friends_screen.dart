// friends_screen.dart - МИНИМАЛИСТИЧНЫЙ МОДЕРН ДИЗАЙН
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../localization.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<User> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadFriends();
  }

  void _handleTabChange() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getFriends();
      if (response['success'] == true) {
        final friendsData = response['friends'] as List;
        final requestsData = response['pending_requests'] as List;

        setState(() {
          _friends = friendsData.map((data) => Friend.fromJson(data)).toList();
          _pendingRequests = requestsData.map((data) => FriendRequest.fromJson(data)).toList();
        });
      }
    } catch (e) {
      print('Error loading friends: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final response = await ApiService.searchUsers(query);
      if (response['success'] == true) {
        final usersData = response['users'] as List;
        setState(() {
          _searchResults = usersData.map((data) => User.fromJson(data)).toList();
        });
      }
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendFriendRequest(String username) async {
    try {
      final response = await ApiService.sendFriendRequest(username);
      if (response['success'] == true) {
        _showSnackBar('Запрос отправлен');
        _searchController.clear();
        _searchResults.clear();
        await _loadFriends();
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    try {
      final response = await ApiService.acceptFriendRequest(requestId);
      if (response['success'] == true) {
        _showSnackBar('Запрос принят');
        await _loadFriends();
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Future<void> _declineFriendRequest(String requestId) async {
    try {
      final response = await ApiService.declineFriendRequest(requestId);
      if (response['success'] == true) {
        _showSnackBar('Запрос отклонен');
        await _loadFriends();
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить друга'),
        content: Text('Вы уверены, что хотите удалить этого друга?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.removeFriend(friendId);
        if (response['success'] == true) {
          _showSnackBar('Друг удален');
          await _loadFriends();
        }
      } catch (e) {
        _showSnackBar('Ошибка: $e', isError: true);
      }
    }
  }

  void _openChat(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(friend: friend)),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            title: Text('Друзья', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded),
                onPressed: _isLoading ? null : _loadFriends,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск пользователей...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _searchResults.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _searchResults.clear();
                            setState(() {});
                          }
                        },
                        onSubmitted: (_) => _searchUsers(),
                      ),
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Друзья'),
                            if (_friends.isNotEmpty) ...[
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _friends.length.toString(),
                                  style: TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Заявки'),
                            if (_pendingRequests.isNotEmpty) ...[
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _pendingRequests.length.toString(),
                                  style: TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Friends tab
                _buildFriendsContent(),

                // Requests tab
                _buildRequestsContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsContent() {
    if (_isLoading) return _buildLoading();
    if (_friends.isEmpty) return _buildEmptyState('Нет друзей', 'Добавьте друзей, чтобы общаться');

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) => _buildFriendCard(_friends[index]),
      ),
    );
  }

  Widget _buildRequestsContent() {
    if (_isLoading) return _buildLoading();
    if (_pendingRequests.isEmpty) return _buildEmptyState('Нет заявок', 'Здесь будут ваши входящие заявки');

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) => _buildRequestCard(_pendingRequests[index]),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChat(friend),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    _buildAvatar(friend.avatar, friend.username, 52),
                    if (friend.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.cardColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              friend.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (friend.isOnline)
                            Text(
                              'online',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '@${friend.username}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatChip(
                            icon: Icons.local_fire_department_rounded,
                            label: '${friend.streakDays} дн.',
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          _buildStatChip(
                            icon: Icons.check_circle_rounded,
                            label: '${friend.completedTopics} тем',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.chat_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Написать'),
                        ],
                      ),
                      onTap: () => _openChat(friend),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Удалить', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => _removeFriend(friend.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(FriendRequest request) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(request.avatar, request.username, 52),
              SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@${request.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLeagueColor(request.currentLeague).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.currentLeague,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getLeagueColor(request.currentLeague),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                children: [
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.check_rounded, color: Colors.green, size: 20),
                    ),
                    onPressed: () => _acceptFriendRequest(request.id),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    ),
                    onPressed: () => _declineFriendRequest(request.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatar, String username, double size) {
    if (avatar.startsWith('/') || (avatar.contains('.') && !avatar.contains('👤'))) {
      try {
        final file = File(avatar);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (e) {
        print('Error loading avatar: $e');
      }
    }

    // Fallback to colored circle with initials
    final colors = [
      Color(0xFFF44336), Color(0xFFE91E63), Color(0xFF9C27B0),
      Color(0xFF673AB7), Color(0xFF3F51B5), Color(0xFF2196F3),
    ];
    final index = username.codeUnits.fold(0, (a, b) => a + b) % colors.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[index],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username.length > 2 ? username.substring(0, 2).toUpperCase() : username,
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getLeagueColor(String league) {
    switch (league.toLowerCase()) {
      case 'золото': return Colors.amber.shade700;
      case 'серебро': return Colors.grey.shade600;
      case 'бронза': return Colors.orange.shade800;
      default: return Colors.blue;
    }
  }
}

// Модели данных (без изменений)
class Friend {
  final String id;
  final String name;
  final String username;
  final int streakDays;
  final int completedTopics;
  final int correctAnswers;
  final String avatar;
  final String currentLeague;
  final int weeklyXP;
  final bool isOnline;

  Friend({
    required this.id,
    required this.name,
    required this.username,
    required this.streakDays,
    required this.completedTopics,
    required this.correctAnswers,
    required this.avatar,
    required this.currentLeague,
    required this.weeklyXP,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      streakDays: json['streak_days'] ?? 0,
      completedTopics: json['completed_topics'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      avatar: json['avatar'] ?? '👤',
      currentLeague: json['current_league'] ?? 'Бронза',
      weeklyXP: json['weekly_xp'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}

class FriendRequest {
  final String id;
  final String name;
  final String username;
  final int streakDays;
  final int completedTopics;
  final int correctAnswers;
  final String avatar;
  final String currentLeague;
  final int weeklyXP;

  FriendRequest({
    required this.id,
    required this.name,
    required this.username,
    required this.streakDays,
    required this.completedTopics,
    required this.correctAnswers,
    required this.avatar,
    required this.currentLeague,
    required this.weeklyXP,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      streakDays: json['streak_days'] ?? 0,
      completedTopics: json['completed_topics'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      avatar: json['avatar'] ?? '👤',
      currentLeague: json['current_league'] ?? 'Бронза',
      weeklyXP: json['weekly_xp'] ?? 0,
    );
  }
}

class User {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String currentLeague;
  final int weeklyXP;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.currentLeague,
    required this.weeklyXP,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      avatar: json['avatar'] ?? '👤',
      currentLeague: json['current_league'] ?? 'Бронза',
      weeklyXP: json['weekly_xp'] ?? 0,
    );
  }
}