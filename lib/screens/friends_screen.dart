import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final List<Friend> _friends = [
    Friend(
      name: 'Алексей Иванов',
      email: 'alex@example.com',
      streakDays: 7,
      completedTopics: 12,
      correctAnswers: 45,
      avatar: '👨‍🎓',
      status: FriendStatus.accepted,
    ),
    Friend(
      name: 'Мария Петрова',
      email: 'maria@example.com',
      streakDays: 3,
      completedTopics: 8,
      correctAnswers: 32,
      avatar: '👩‍🎓',
      status: FriendStatus.accepted,
    ),
  ];

  final List<Friend> _pendingRequests = [
    Friend(
      name: 'Дмитрий Сидоров',
      email: 'dmitry@example.com',
      streakDays: 15,
      completedTopics: 25,
      correctAnswers: 89,
      avatar: '🧑‍🎓',
      status: FriendStatus.pending,
    ),
  ];

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Друзья'),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Друзья (${_friends.length})'),
              Tab(text: 'Запросы (${_pendingRequests.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Вкладка друзей
            Column(
              children: [
                // Поиск и добавление друга
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Введите email друга',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: _sendFriendRequest,
                        mini: true,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.person_add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      return _FriendCard(friend: friend);
                    },
                  ),
                ),
              ],
            ),
            // Вкладка запросов
            _pendingRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Нет pending запросов',
                    style: Theme.of(context).textTheme.bodyLarge,
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
                  onAccept: () => _acceptFriendRequest(request),
                  onDecline: () => _declineFriendRequest(request),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendFriendRequest() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _pendingRequests.add(Friend(
        name: 'Пользователь',
        email: email,
        streakDays: 0,
        completedTopics: 0,
        correctAnswers: 0,
        avatar: '👤',
        status: FriendStatus.pending,
      ));
    });

    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрос на дружбу отправлен'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _acceptFriendRequest(Friend request) {
    setState(() {
      _pendingRequests.remove(request);
      _friends.add(Friend(
        name: request.name,
        email: request.email,
        streakDays: request.streakDays,
        completedTopics: request.completedTopics,
        correctAnswers: request.correctAnswers,
        avatar: request.avatar,
        status: FriendStatus.accepted,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрос принят'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineFriendRequest(Friend request) {
    setState(() {
      _pendingRequests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запрос отклонен'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;

  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(friend.avatar),
        ),
        title: Text(
          friend.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(friend.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatItem(
                  icon: Icons.local_fire_department,
                  value: '${friend.streakDays}д',
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  icon: Icons.check_circle,
                  value: '${friend.completedTopics}т',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatItem(
                  icon: Icons.emoji_events,
                  value: '${friend.correctAnswers}в',
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final Friend request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(request.avatar),
        ),
        title: Text(
          request.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(request.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onAccept,
              icon: Icon(Icons.check, color: Colors.green),
              tooltip: 'Принять',
            ),
            IconButton(
              onPressed: onDecline,
              icon: Icon(Icons.close, color: Colors.red),
              tooltip: 'Отклонить',
            ),
          ],
        ),
      ),
    );
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
  final String name;
  final String email;
  final int streakDays;
  final int completedTopics;
  final int correctAnswers;
  final String avatar;
  final FriendStatus status;

  Friend({
    required this.name,
    required this.email,
    required this.streakDays,
    required this.completedTopics,
    required this.correctAnswers,
    required this.avatar,
    required this.status,
  });
}

enum FriendStatus {
  pending,
  accepted,
}