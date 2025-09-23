import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/subjects_data.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'topic_popup.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final Function(String)? onAvatarUpdate;
  final String? currentAvatar;

  const MainScreen({
    this.onLogout,
    this.onAvatarUpdate,
    this.currentAvatar,
    Key? key,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ВРЕМЕННЫЕ ПЕРЕМЕННЫЕ
  final List<int> availableGrades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  final Map<String, String> subjectEmojis = {
    'Русский язык': '📚',
    'Математика': '🔢',
    'Алгебра': '𝑥²',
    'Геометрия': '△',
    'Английский язык': '🔤',
    'Литература': '📖',
    'Биология': '🌿',
    'Физика': '⚡',
    'Химия': '🧪',
    'География': '🌍',
    'История': '🏛️',
    'Обществознание': '👥',
    'Информатика': '💻',
    'Статистика и вероятность': '📊',
  };

  int? _selectedGrade;
  String _selectedSubject = 'Русский язык';
  String _searchQuery = '';
  bool _dailyCompleted = false;
  String _username = '';
  String _avatar = '👤';
  UserStats _userStats = UserStats(
    streakDays: 0,
    lastActivity: DateTime.now(),
    topicProgress: {},
    dailyCompletion: {},
    username: '',
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final username = await UserDataStorage.getUsername();
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _username = username;
          _avatar = widget.currentAvatar ?? prefs.getString('user_avatar') ?? '👤';
          _dailyCompleted = stats.dailyCompletion[DateTime.now().toIso8601String().split('T')[0]] ?? false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  List<String> get _availableSubjects {
    if (_selectedGrade != null) {
      return subjectsByGrade[_selectedGrade]?.map((s) => s.name).toList() ?? [];
    } else {
      final allSubjects = <String>{};
      for (final grade in subjectsByGrade.keys) {
        final subjects = subjectsByGrade[grade] ?? [];
        for (final subject in subjects) {
          allSubjects.add(subject.name);
        }
      }
      return allSubjects.toList();
    }
  }

  List<dynamic> get _filteredTopics {
    final List<dynamic> allTopics = [];

    if (_selectedGrade != null) {
      final subjects = subjectsByGrade[_selectedGrade];
      if (subjects != null) {
        for (final subject in subjects) {
          if (subject.name == _selectedSubject) {
            final topics = subject.topicsByGrade[_selectedGrade] ?? [];
            allTopics.addAll(topics);
            break;
          }
        }
      }
    } else {
      for (final grade in subjectsByGrade.keys) {
        final subjects = subjectsByGrade[grade] ?? [];
        for (final subject in subjects) {
          if (subject.name == _selectedSubject) {
            final topics = subject.topicsByGrade[grade] ?? [];
            for (final topic in topics) {
              allTopics.add(_TopicWithGrade(topic: topic, grade: grade));
            }
          }
        }
      }
    }

    if (_searchQuery.isNotEmpty) {
      return allTopics.where((topic) {
        final topicData = topic is _TopicWithGrade ? topic.topic : topic;
        return topicData.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            topicData.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allTopics;
  }

  bool _isTopicCompleted(String topicName) {
    final topic = _findTopicInAllSubjects(topicName);
    if (topic == null) {
      return false;
    }

    for (final subjectName in _userStats.topicProgress.keys) {
      final subjectProgress = _userStats.topicProgress[subjectName];
      if (subjectProgress != null && subjectProgress.containsKey(topicName)) {
        final topicCorrectAnswers = subjectProgress[topicName] ?? 0;
        final totalQuestions = topic.questions.length;
        return topicCorrectAnswers >= totalQuestions;
      }
    }

    return false;
  }

  dynamic _findTopicInAllSubjects(String topicName) {
    for (final grade in subjectsByGrade.keys) {
      final subjects = subjectsByGrade[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        for (final topic in topics) {
          if (topic.name == topicName) {
            return topic;
          }
        }
      }
    }
    return null;
  }

  void _showTopicPopup(BuildContext context, dynamic topic) {
    final topicData = topic is _TopicWithGrade ? topic.topic : topic;
    final grade = topic is _TopicWithGrade ? topic.grade : _selectedGrade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicPopup(
        topic: topicData,
        currentGrade: grade,
        currentSubject: _selectedSubject,
      ),
    );
  }

  void _showAvatarSelectionDialog() {
    final avatars = ['🐳','😎','😭','👻','👾','🐁'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите аватар'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  final newAvatar = avatars[index];
                  setState(() {
                    _avatar = newAvatar;
                  });

                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString('user_avatar', newAvatar);
                  });

                  widget.onAvatarUpdate?.call(newAvatar);

                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _avatar == avatars[index]
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatars[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с профилем
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showAvatarSelectionDialog,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username.isNotEmpty ? 'Привет, $_username!' : 'Привет!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _dailyCompleted ? 'Сегодня все сделал' : 'Начни урок',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_userStats.streakDays}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(
                            onLogout: widget.onLogout ?? () {
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.remove('username');
                                prefs.remove('user_avatar');
                              });
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            },
                            currentAvatar: _avatar,
                            onAvatarUpdate: (newAvatar) {
                              setState(() {
                                _avatar = newAvatar;
                              });
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setString('user_avatar', newAvatar);
                              });
                              widget.onAvatarUpdate?.call(newAvatar);
                            },
                          ),
                        ),
                      ).then((_) => _refreshData());
                    },
                  ),
                ],
              ),
            ),

            // Выбор класса и предмета
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<int?>(
                          value: _selectedGrade,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'Все классы',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            ...availableGrades.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Text(
                                  '$grade класс',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGrade = value;
                              final subjects = _availableSubjects;
                              if (subjects.isNotEmpty) {
                                _selectedSubject = subjects.first;
                              }
                            });
                          },
                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<String>(
                          value: _selectedSubject,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _availableSubjects.map((subject) {
                            final emoji = subjectEmojis[subject] ?? '📚';
                            return DropdownMenuItem(
                              value: subject,
                              child: Text(
                                '$emoji $subject',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubject = value!;
                            });
                          },
                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Поиск по темам...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Список тем
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _filteredTopics.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Темы не найдены',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Попробуйте изменить поисковый запрос',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _filteredTopics[index];
                    final topicName = topic is _TopicWithGrade ? topic.topic.name : topic.name;
                    final isCompleted = _isTopicCompleted(topicName);
                    final grade = topic is _TopicWithGrade ? topic.grade : null;

                    return _TopicCard(
                      topic: topic,
                      isCompleted: isCompleted,
                      grade: grade,
                      onTap: () => _showTopicPopup(context, topic),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final dynamic topic;
  final bool isCompleted;
  final int? grade;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.isCompleted,
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topicData = topic is _TopicWithGrade ? topic.topic : topic;

    Color cardColor;
    if (isCompleted) {
      cardColor = isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E8);
    } else {
      cardColor = Theme.of(context).cardColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted
                ? (isDark ? const Color(0xFF4CAF50) : const Color(0xFFC8E6C9))
                : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              topicData.imageAsset,
              style: TextStyle(
                fontSize: 20,
                color: isCompleted ? Colors.white : null,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (grade != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$grade класс',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              topicData.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isCompleted && isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
        subtitle: Text(
          topicData.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isCompleted && isDark ? Colors.white70 : null,
          ),
        ),
        trailing: isCompleted
            ? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        )
            : Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _TopicWithGrade {
  final dynamic topic;
  final int grade;

  _TopicWithGrade({required this.topic, required this.grade});
}