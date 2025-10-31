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
    _addTestFriends();
  }

  void _addTestFriends() {
    final testFriends = [
      Friend(
        id: '1',
        name: 'Алексей Петров',
        username: 'alexey_p',
        streakDays: 7,
        completedTopics: 12,
        correctAnswers: 45,
        avatar: '👨‍💻',
        currentLeague: 'Серебро',
        weeklyXP: 250,
      ),
      Friend(
        id: '2',
        name: 'Мария Иванова',
        username: 'maria_i',
        streakDays: 3,
        completedTopics: 8,
        correctAnswers: 32,
        avatar: '👩‍🎓',
        currentLeague: 'Бронза',
        weeklyXP: 180,
      ),
      Friend(
        id: '3',
        name: 'Дмитрий Сидоров',
        username: 'dmitry_s',
        streakDays: 15,
        completedTopics: 25,
        correctAnswers: 89,
        avatar: '🧑‍🔬',
        currentLeague: 'Золото',
        weeklyXP: 420,
      ),
      Friend(
        id: '4',
        name: 'Екатерина Козлова',
        username: 'ekaterina_k',
        streakDays: 5,
        completedTopics: 10,
        correctAnswers: 38,
        avatar: '👩‍🏫',
        currentLeague: 'Серебро',
        weeklyXP: 210,
      ),
      Friend(
        id: '5',
        name: 'Иван Николаев',
        username: 'ivan_n',
        streakDays: 21,
        completedTopics: 30,
        correctAnswers: 112,
        avatar: '👨‍🔧',
        currentLeague: 'Платина',
        weeklyXP: 580,
      ),
    ];

    if (_friends.isEmpty) {
      setState(() {
        _friends.addAll(testFriends);
      });
    }
  }

  void _addTestRequests() {
    final testRequests = [
      FriendRequest(
        id: 'req1',
        name: 'Сергей Волков',
        username: 'sergey_v',
        streakDays: 2,
        completedTopics: 5,
        correctAnswers: 18,
        avatar: '👨‍💼',
        currentLeague: 'Бронза',
        weeklyXP: 120,
      ),
      FriendRequest(
        id: 'req2',
        name: 'Ольга Смирнова',
        username: 'olga_s',
        streakDays: 8,
        completedTopics: 15,
        correctAnswers: 52,
        avatar: '👩‍💻',
        currentLeague: 'Серебро',
        weeklyXP: 280,
      ),
    ];

    if (_pendingRequests.isEmpty) {
      setState(() {
        _pendingRequests.addAll(testRequests);
      });
    }
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

        if (_friends.isEmpty) {
          _addTestFriends();
        }
        if (_pendingRequests.isEmpty) {
          _addTestRequests();
        }
      } else {
        _addTestFriends();
        _addTestRequests();
      }
    } catch (e) {
      print('Error loading friends: $e');
      _addTestFriends();
      _addTestRequests();
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
  }

  void _openChat(Friend friend) {
    // Временно закомментируем навигацию до создания ChatScreen
     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(friend: friend),
        ),
     );

    // Временно показываем сообщение
    _showMessage('Чат с ${friend.name} будет доступен после создания экрана чата');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.friends),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '${localizations.friends} (${_friends.length})'),
              Tab(text: '${localizations.pendingRequests} (${_pendingRequests.length})'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadFriends,
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // Friends tab
            Column(
              children: [
                // User search
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: localizations.enterUsername,
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                              ),
                              onSubmitted: (_) => _searchUsers(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_searchResults.isNotEmpty || _usernameController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _clearSearch,
                            ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: _searchUsers,
                            mini: true,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: _isSearching
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Icon(Icons.search, color: Colors.white),
                          ),
                        ],
                      ),
                      if (_searchResults.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${localizations.searchResults}:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Search results or friends list
                Expanded(
                  child: _searchResults.isNotEmpty
                      ? _searchResults.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          localizations.usersNotFound,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return _UserSearchCard(
                        user: user,
                        onAddFriend: () => _sendFriendRequest(user.username),
                      );
                    },
                  )
                      : _friends.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          localizations.noFriends,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          localizations.findUsersAndAdd,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
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
                  ),
                ),
              ],
            ),

            // Requests tab
            _pendingRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    localizations.noRequests,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    localizations.incomingRequests,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
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
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: _buildUserAvatar(user.avatar, user.username),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('@${user.username}'),
        trailing: ElevatedButton(
          onPressed: onAddFriend,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(localizations.addFriend),
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
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: _buildUserAvatar(friend.avatar, friend.username),
        title: Text(
          friend.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${friend.username} • ${friend.currentLeague}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatItem(
                  icon: Icons.local_fire_department,
                  value: '${friend.streakDays}${localizations.daysShort}',
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  icon: Icons.check_circle,
                  value: '${friend.completedTopics}${localizations.topicsShort}',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  icon: Icons.emoji_events,
                  value: '${friend.weeklyXP}XP',
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onMessage,
              icon: Icon(Icons.message, color: Theme.of(context).primaryColor),
              tooltip: localizations.sendMessage,
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(localizations.removeFriend),
                  onTap: onRemove,
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
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: _buildUserAvatar(request.avatar, request.username),
        title: Text(
          request.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${request.username}'),
            Text('${request.currentLeague} • ${request.weeklyXP} XP'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onAccept,
              icon: Icon(Icons.check, color: Colors.green),
              tooltip: localizations.acceptRequest,
            ),
            IconButton(
              onPressed: onDecline,
              icon: Icon(Icons.close, color: Colors.red),
              tooltip: localizations.declineRequest,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildUserAvatar(String avatar, String username) {
  if (avatar.startsWith('/') || (avatar.contains('.') && !avatar.contains('👤'))) {
    try {
      final file = File(avatar);
      if (file.existsSync()) {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: FileImage(file),
        );
      }
    } catch (e) {
      print('Error loading avatar file: $e');
    }
  }

  return CircleAvatar(
    backgroundColor: _getAvatarColor(username),
    child: Text(
      avatar.length > 2 ? avatar.substring(0, 2) : avatar,
      style: TextStyle(fontSize: 16),
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