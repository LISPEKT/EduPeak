import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../data/subjects_data.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'topic_popup.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  // Ключ для принудительного обновления списка
  final GlobalKey<_OptimizedTopicsListViewState> _topicsListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
          _avatar = prefs.getString('user_avatar_path') ?? '👤';
          _dailyCompleted = stats.dailyCompletion[DateTime.now().toIso8601String().split('T')[0]] ?? false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _refreshData() async {
    _topicsListKey.currentState?._clearCache(); // Очищаем кэш при обновлении
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
    } else {
      return allTopics;
    }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicPopup(
        topic: topic is _TopicWithGrade ? topic.topic : topic,
        currentGrade: topic is _TopicWithGrade ? topic.grade : _selectedGrade,
        currentSubject: _selectedSubject,
      ),
    );
  }

  bool _isPhotoAvatar() {
    return _avatar.startsWith('/');
  }

  void _onGradeChanged(int? value) {
    setState(() {
      _selectedGrade = value;
      final subjects = _availableSubjects;
      if (subjects.isNotEmpty && !subjects.contains(_selectedSubject)) {
        _selectedSubject = subjects.first;
      }
      _topicsListKey.currentState?._clearCache(); // Очищаем кэш при изменении фильтров
    });
  }

  void _onSubjectChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedSubject = value;
        _topicsListKey.currentState?._clearCache(); // Очищаем кэш при изменении фильтров
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _topicsListKey.currentState?._clearCache(); // Очищаем кэш при поиске
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с профилем
            _ProfileHeader(
              avatar: _avatar,
              isPhotoAvatar: _isPhotoAvatar(),
              username: _username,
              dailyCompleted: _dailyCompleted,
              streakDays: _userStats.streakDays,
              onSettingsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      onLogout: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                              (route) => false,
                        );
                      },
                      currentAvatar: _avatar,
                      onAvatarUpdate: (newAvatar) {
                        setState(() {
                          _avatar = newAvatar;
                        });
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('user_avatar_path', newAvatar);
                        });
                      },
                      onUsernameUpdate: (newUsername) {
                        setState(() {
                          _username = newUsername;
                        });
                      },
                    ),
                  ),
                ).then((_) => _refreshData());
              },
            ),

            // Выбор класса и предмета
            _GradeSubjectSelector(
              selectedGrade: _selectedGrade,
              selectedSubject: _selectedSubject,
              availableSubjects: _availableSubjects,
              onGradeChanged: _onGradeChanged,
              onSubjectChanged: _onSubjectChanged,
            ),

            // Поиск
            _SearchField(
              onChanged: _onSearchChanged,
            ),

            // ОПТИМИЗИРОВАННЫЙ список тем
            Expanded(
              child: _OptimizedTopicsList(
                filteredTopics: _filteredTopics,
                isTopicCompleted: _isTopicCompleted,
                onTopicTap: (topic) => _showTopicPopup(context, topic),
                onRefresh: _refreshData,
                listKey: _topicsListKey, // Передаем ключ для управления состоянием
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ОПТИМИЗИРОВАННЫЙ список тем с ленивой загрузкой
class _OptimizedTopicsList extends StatelessWidget {
  final List<dynamic> filteredTopics;
  final bool Function(String) isTopicCompleted;
  final Function(dynamic) onTopicTap;
  final Future<void> Function() onRefresh;
  final GlobalKey<_OptimizedTopicsListViewState> listKey;

  const _OptimizedTopicsList({
    required this.filteredTopics,
    required this.isTopicCompleted,
    required this.onTopicTap,
    required this.onRefresh,
    required this.listKey,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: filteredTopics.isEmpty
          ? _EmptyState()
          : _OptimizedTopicsListView(
        key: listKey, // Используем переданный ключ
        filteredTopics: filteredTopics,
        isTopicCompleted: isTopicCompleted,
        onTopicTap: onTopicTap,
      ),
    );
  }
}

// ОПТИМИЗИРОВАННЫЙ ListView с кэшированием
class _OptimizedTopicsListView extends StatefulWidget {
  final List<dynamic> filteredTopics;
  final bool Function(String) isTopicCompleted;
  final Function(dynamic) onTopicTap;

  const _OptimizedTopicsListView({
    super.key,
    required this.filteredTopics,
    required this.isTopicCompleted,
    required this.onTopicTap,
  });

  @override
  State<_OptimizedTopicsListView> createState() => _OptimizedTopicsListViewState();
}

class _OptimizedTopicsListViewState extends State<_OptimizedTopicsListView> {
  // Кэш для уже созданных карточек тем
  final Map<String, Widget> _topicCardCache = {};

  // Метод для очистки кэша
  void _clearCache() {
    _topicCardCache.clear();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = widget.filteredTopics[index];
        final topicName = _getTopicName(topic);
        final cacheKey = '${topicName}_$index';

        return _LazyTopicCard(
          key: ValueKey(cacheKey),
          topic: topic,
          isCompleted: widget.isTopicCompleted(topicName),
          grade: _getTopicGrade(topic),
          onTap: () => widget.onTopicTap(topic),
          cache: _topicCardCache,
          cacheKey: cacheKey,
        );
      },
    );
  }

  // Вспомогательные методы для безопасного получения данных
  String _getTopicName(dynamic topic) {
    if (topic is _TopicWithGrade) {
      return topic.topic.name;
    } else {
      return topic.name;
    }
  }

  int? _getTopicGrade(dynamic topic) {
    if (topic is _TopicWithGrade) {
      return topic.grade;
    } else {
      return null;
    }
  }
}

// ЛЕНИВАЯ карточка темы - создается только когда видна
class _LazyTopicCard extends StatefulWidget {
  final dynamic topic;
  final bool isCompleted;
  final int? grade;
  final VoidCallback onTap;
  final Map<String, Widget> cache;
  final String cacheKey;

  const _LazyTopicCard({
    required Key key,
    required this.topic,
    required this.isCompleted,
    required this.grade,
    required this.onTap,
    required this.cache,
    required this.cacheKey,
  }) : super(key: key);

  @override
  State<_LazyTopicCard> createState() => _LazyTopicCardState();
}

class _LazyTopicCardState extends State<_LazyTopicCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Сохраняем состояние при скролле

  @override
  Widget build(BuildContext context) {
    super.build(context); // Обязательно для AutomaticKeepAliveClientMixin

    // Используем кэшированную версию если есть
    if (widget.cache.containsKey(widget.cacheKey)) {
      return widget.cache[widget.cacheKey]!;
    }

    // Создаем новую карточку и кэшируем
    final topicCard = _TopicCard(
      topic: widget.topic,
      isCompleted: widget.isCompleted,
      grade: widget.grade,
      onTap: widget.onTap,
    );

    widget.cache[widget.cacheKey] = topicCard;
    return topicCard;
  }
}

// ОСТАВЛЯЕМ ВСЕ СУЩЕСТВУЮЩИЕ ВИДЖЕТЫ БЕЗ ИЗМЕНЕНИЙ

class _ProfileHeader extends StatelessWidget {
  final String avatar;
  final bool isPhotoAvatar;
  final String username;
  final bool dailyCompleted;
  final int streakDays;
  final VoidCallback onSettingsPressed;

  const _ProfileHeader({
    required this.avatar,
    required this.isPhotoAvatar,
    required this.username,
    required this.dailyCompleted,
    required this.streakDays,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Аватар
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              image: isPhotoAvatar
                  ? DecorationImage(
                image: FileImage(File(avatar)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: isPhotoAvatar
                ? null
                : Center(
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? 'Привет, $username!' : 'Привет!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dailyCompleted ? 'Сегодня все сделал' : 'Начни урок',
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
                  '$streakDays',
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
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}

class _GradeSubjectSelector extends StatelessWidget {
  final int? selectedGrade;
  final String selectedSubject;
  final List<String> availableSubjects;
  final ValueChanged<int?> onGradeChanged;
  final ValueChanged<String?> onSubjectChanged;

  const _GradeSubjectSelector({
    required this.selectedGrade,
    required this.selectedSubject,
    required this.availableSubjects,
    required this.onGradeChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: _GradeDropdown(
              selectedGrade: selectedGrade,
              onChanged: onGradeChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SubjectDropdown(
              selectedSubject: selectedSubject,
              availableSubjects: availableSubjects,
              onChanged: onSubjectChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeDropdown extends StatelessWidget {
  final int? selectedGrade;
  final ValueChanged<int?> onChanged;

  const _GradeDropdown({
    required this.selectedGrade,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButton<int?>(
          value: selectedGrade,
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
          onChanged: onChanged,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  final String selectedSubject;
  final List<String> availableSubjects;
  final ValueChanged<String?> onChanged;

  const _SubjectDropdown({
    required this.selectedSubject,
    required this.availableSubjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButton<String>(
          value: selectedSubject,
          isExpanded: true,
          underline: const SizedBox(),
          items: availableSubjects.map((subject) {
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
          onChanged: onChanged,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Поиск по темам...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
    final topicData = topic is _TopicWithGrade ? topic.topic : topic;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isCompleted
          ? (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B5E20)
          : const Color(0xFFE8F5E8))
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted
                ? (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF4CAF50)
                : const Color(0xFFC8E6C9))
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
                color: isCompleted && Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
            ),
          ],
        ),
        subtitle: Text(
          topicData.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isCompleted && Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : null,
          ),
        ),
        trailing: isCompleted
            ? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF4CAF50)
                : const Color(0xFF4CAF50),
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