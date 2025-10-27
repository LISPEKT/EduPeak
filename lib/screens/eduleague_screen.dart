import 'package:flutter/material.dart';

class EduLeagueScreen extends StatefulWidget {
  @override
  State<EduLeagueScreen> createState() => _EduLeagueScreenState();
}

class _EduLeagueScreenState extends State<EduLeagueScreen> {
  final List<League> _leagues = [
    League(
      name: 'Бронза',
      minXp: 0,
      maxXp: 100,
      color: Color(0xFFCD7F32),
      icon: '🥉',
    ),
    League(
      name: 'Серебро',
      minXp: 101,
      maxXp: 300,
      color: Color(0xFFC0C0C0),
      icon: '🥈',
    ),
    League(
      name: 'Золото',
      minXp: 301,
      maxXp: 500,
      color: Color(0xFFFFD700),
      icon: '🥇',
    ),
    League(
      name: 'Платина',
      minXp: 501,
      maxXp: 1000,
      color: Color(0xFFE5E4E2),
      icon: '💎',
    ),
    League(
      name: 'Бриллиант',
      minXp: 1001,
      maxXp: 9999,
      color: Color(0xFFB9F2FF),
      icon: '💠',
    ),
  ];

  int _selectedLeagueIndex = 0;
  final Map<String, List<User>> _leagueUsers = {
    'Бронза': [
      User(name: 'Иван Петров', xp: 45, avatar: '👦'),
      User(name: 'Анна Сидорова', xp: 78, avatar: '👧'),
      User(name: 'Петр Иванов', xp: 92, avatar: '👨'),
    ],
    'Серебро': [
      User(name: 'Мария Козлова', xp: 156, avatar: '👩'),
      User(name: 'Алексей Смирнов', xp: 234, avatar: '🧑'),
    ],
    'Золото': [
      User(name: 'Елена Новикова', xp: 389, avatar: '👩‍🦰'),
    ],
    'Платина': [
      User(name: 'Дмитрий Волков', xp: 678, avatar: '👨‍🦱'),
    ],
    'Бриллиант': [
      User(name: 'Ольга Белова', xp: 1245, avatar: '👩‍🦳'),
      User(name: 'Сергей Ковалев', xp: 1567, avatar: '👨‍💼'),
      User(name: 'Наталья Орлова', xp: 1432, avatar: '👩‍🔬'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedLeague = _leagues[_selectedLeagueIndex];
    // Сортируем пользователей по XP в порядке убывания (чем больше XP - тем выше)
    final usersInLeague = (_leagueUsers[selectedLeague.name] ?? [])
      ..sort((a, b) => b.xp.compareTo(a.xp));

    return Scaffold(
      appBar: AppBar(
        title: Text('EduLeague'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Горизонтальный список лиг - КВАДРАТНЫЕ КНОПКИ
          Container(
            height: 100, // Высота для квадратных кнопок
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index];
                final isSelected = index == _selectedLeagueIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLeagueIndex = index;
                    });
                  },
                  child: Container(
                    width: 80, // Ширина квадрата
                    height: 80, // Высота квадрата
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
                        // Иконка лиги
                        Text(
                          league.icon,
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        // Название лиги
                        Text(
                          league.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? league.color : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Описание лиги с количеством XP
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selectedLeague.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedLeague.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedLeague.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      selectedLeague.icon,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLeague.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: selectedLeague.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${selectedLeague.minXp} - ${selectedLeague.maxXp} XP в неделю',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selectedLeague.color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Заголовок списка пользователей
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Игроки в лиге (${usersInLeague.length})',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Список пользователей в лиге (отсортированный по убыванию XP)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: usersInLeague.length,
              itemBuilder: (context, index) {
                final user = usersInLeague[index];
                final rank = index + 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Theme.of(context).cardColor,
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
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selectedLeague.color,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${user.xp} XP'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedLeague.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.avatar,
                        style: TextStyle(fontSize: 20),
                      ),
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
  final String name;
  final int xp;
  final String avatar;

  User({
    required this.name,
    required this.xp,
    required this.avatar,
  });
}