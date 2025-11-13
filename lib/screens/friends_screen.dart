// friends_screen.dart - РЕДИЗАЙН В MD3 БЕЗ ЗАГЛУШЕК
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import '../localization.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  bool _isLoading = true;
  final TextEditingController _usernameController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
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
      } else {
        setState(() {
          _friends = [];
          _pendingRequests = [];
        });
      }
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        _friends = [];
        _pendingRequests = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final response = await ApiService.searchUsers(username);

      if (response['success'] == true) {
        final usersData = response['users'] as List;
        setState(() {
          _searchResults = usersData.map((data) => User.fromJson(data)).toList();
        });
      } else {
        setState(() {
          _searchResults = [];
        });
        _showMessage(AppLocalizations.of(context)!.usersNotFound);
      }
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _searchResults = [];
      });
      _showMessage(AppLocalizations.of(context)!.searchError);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendFriendRequest(String username) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final response = await ApiService.sendFriendRequest(username);

      if (response['success'] == true) {
        _showSuccessMessage(localizations.friendRequestSent.replaceFirst('%s', username));
        _usernameController.clear();
        _searchResults.clear();
        await _loadFriends();
      } else {
        _showErrorMessage(response['message'] ?? localizations.requestFailed);
      }
    } catch (e) {
      _showErrorMessage('${localizations.error}: $e');
    }
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final response = await ApiService.acceptFriendRequest(requestId);

      if (response['success'] == true) {
        _showSuccessMessage(localizations.requestAccepted);
        await _loadFriends();
      } else {
        _showErrorMessage(response['message'] ?? localizations.acceptFailed);
      }
    } catch (e) {
      _showErrorMessage('${localizations.error}: $e');
    }
  }

  Future<void> _declineFriendRequest(String requestId) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final response = await ApiService.declineFriendRequest(requestId);

      if (response['success'] == true) {
        _showSuccessMessage(localizations.requestDeclined);
        await _loadFriends();
      } else {
        _showErrorMessage(response['message'] ?? localizations.declineFailed);
      }
    } catch (e) {
      _showErrorMessage('${localizations.error}: $e');
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.removeFriend),
        content: Text(localizations.removeFriend),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await ApiService.removeFriend(friendId);
                if (response['success'] == true) {
                  _showSuccessMessage(localizations.friendRemoved);
                  await _loadFriends();
                } else {
                  _showErrorMessage(response['message'] ?? localizations.removeFailed);
                }
              } catch (e) {
                _showErrorMessage('${localizations.error}: $e');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.removeFriend),
          ),
        ],
      ),
    );
  }

  void _openChat(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(friend: friend),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _clearSearch() {
    _usernameController.clear();
    _searchResults.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            localizations.friends,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                text: 'Друзья',
                icon: Badge(
                  label: Text(_friends.length.toString()),
                  isLabelVisible: _friends.isNotEmpty,
                  child: Icon(Icons.people_rounded),
                ),
              ),
              Tab(
                text: 'Заявки',
                icon: Badge(
                  label: Text(_pendingRequests.length.toString()),
                  isLabelVisible: _pendingRequests.isNotEmpty,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person_add_rounded),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: _isLoading ? null : _loadFriends,
              tooltip: 'Обновить',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : TabBarView(
          children: [
            _buildFriendsTab(localizations, theme),
            _buildRequestsTab(localizations, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Загрузка...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(AppLocalizations localizations, ThemeData theme) {
    return Column(
      children: [
        // Search section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(24), // Закругление поиска
                      ),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Введите имя пользователя',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded),
                          suffixIcon: _usernameController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear_rounded),
                            onPressed: _clearSearch,
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onSubmitted: (_) => _searchUsers(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _searchUsers,
                      icon: _isSearching
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Icon(Icons.search_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Результаты поиска (${_searchResults.length})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Friends list or search results
        Expanded(
          child: _searchResults.isNotEmpty
              ? _buildSearchResults(localizations, theme)
              : _friends.isEmpty
              ? _buildEmptyFriendsState(localizations, theme)
              : _buildFriendsList(localizations, theme),
        ),
      ],
    );
  }

  Widget _buildSearchResults(AppLocalizations localizations, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchCard(
          user: user,
          onAddFriend: () => _sendFriendRequest(user.username),
        );
      },
    );
  }

  Widget _buildEmptyFriendsState(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Пока нет друзей',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Найдите пользователей и добавьте их в друзья',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(AppLocalizations localizations, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _FriendCard(
          friend: friend,
          onRemove: () => _removeFriend(friend.id),
          onMessage: () => _openChat(friend),
        );
      },
    );
  }

  Widget _buildRequestsTab(AppLocalizations localizations, ThemeData theme) {
    return _pendingRequests.isEmpty
        ? _buildEmptyRequestsState(localizations, theme)
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _PendingRequestCard(
          request: request,
          onAccept: () => _acceptFriendRequest(request.id),
          onDecline: () => _declineFriendRequest(request.id),
        );
      },
    );
  }

  Widget _buildEmptyRequestsState(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Нет заявок в друзья',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь будут отображаться входящие заявки',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserSearchCard extends StatelessWidget {
  final User user;
  final VoidCallback onAddFriend;

  const _UserSearchCard({required this.user, required this.onAddFriend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildUserAvatar(user.avatar, user.username, 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLeagueColor(user.currentLeague).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.currentLeague,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getLeagueColor(user.currentLeague),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onAddFriend,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final VoidCallback onMessage;

  const _FriendCard({
    required this.friend,
    required this.onRemove,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                _buildUserAvatar(friend.avatar, friend.username, 52),
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
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          friend.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (friend.isOnline)
                        Text(
                          'online',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${friend.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: '${friend.streakDays}д',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatItem(
                        icon: Icons.check_circle_rounded,
                        value: '${friend.completedTopics}т',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _StatItem(
                        icon: Icons.emoji_events_rounded,
                        value: '${friend.weeklyXP}XP',
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onMessage,
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_rounded,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(localizations.removeFriend),
                        ],
                      ),
                      onTap: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildUserAvatar(request.avatar, request.username, 52),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${request.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLeagueColor(request.currentLeague).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          request.currentLeague,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getLeagueColor(request.currentLeague),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${request.weeklyXP} XP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onAccept,
                    icon: Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onDecline,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildUserAvatar(String avatar, String username, double size) {
  if (avatar.startsWith('/') || (avatar.contains('.') && !avatar.contains('👤'))) {
    try {
      final file = File(avatar);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.transparent,
          backgroundImage: FileImage(file),
        );
      }
    } catch (e) {
      print('Error loading avatar file: $e');
    }
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          _getAvatarColor(username),
          _getAvatarColor(username + '2'),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        avatar.length > 2 ? avatar.substring(0, 2) : avatar,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
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

Color _getLeagueColor(String league) {
  switch (league.toLowerCase()) {
    case 'золото':
      return Colors.amber.shade700;
    case 'серебро':
      return Colors.grey.shade600;
    case 'бронза':
      return Colors.orange.shade800;
    default:
      return Colors.blue;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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