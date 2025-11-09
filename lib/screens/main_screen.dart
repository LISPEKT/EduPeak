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
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'subscription_screen.dart';
import '../services/api_service.dart';
import '../localization.dart';
import '../data/subjects_manager.dart';
import 'xp_screen.dart';
import 'friends_screen.dart';
import 'achievements_screen.dart';
import 'eduleague_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? _selectedGrade;
  String _selectedSubject = 'История';
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

  final GlobalKey<_OptimizedTopicsListViewState> _topicsListKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Получаем данные предметов через контекст
  Map<int, List<Subject>> get _subjectsData {
    try {
      return getSubjectsByGrade(context);
    } catch (e) {
      print('❌ Error getting subjects data: $e');
      // Возвращаем данные по умолчанию
      return {
        5: [Subject(name: 'История', topicsByGrade: {5: []})],
      };
    }
  }

  // Добавьте методы для навигации в класс _MainScreenState:
  void _openAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsScreen()),
    );
  }

  void _openFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FriendsScreen()),
    );
  }

  void _openEduLeague() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EduLeagueScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadLastSelected();
    // _loadUserData() и _debugCheckTopics() будут вызваны после построения
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Загружаем данные когда контекст готов для Provider
    if (_username.isEmpty) { // Загружаем только один раз
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserData();
        _debugCheckTopics();
      });
    }
  }

  // Загружаем последние выбранные класс и предмет
  Future<void> _loadLastSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastGrade = prefs.getInt('lastSelectedGrade');
      final lastSubject = prefs.getString('lastSelectedSubject');

      if (mounted) {
        setState(() {
          _selectedGrade = lastGrade ?? 5; // По умолчанию 5 класс
          _selectedSubject = lastSubject ?? 'История'; // По умолчанию История
        });
      }

      print('📝 Loaded last selected - Grade: $_selectedGrade, Subject: $_selectedSubject');
    } catch (e) {
      print('❌ Error loading last selected: $e');
      if (mounted) {
        setState(() {
          _selectedGrade = 5;
          _selectedSubject = 'История';
        });
      }
    }
  }

  // Сохраняем выбранные класс и предмет
  Future<void> _saveLastSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSelectedGrade', _selectedGrade ?? 5);
      await prefs.setString('lastSelectedSubject', _selectedSubject);
      print('💾 Saved last selected - Grade: $_selectedGrade, Subject: $_selectedSubject');
    } catch (e) {
      print('❌ Error saving last selected: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final username = await UserDataStorage.getUsername();
      final avatar = await UserDataStorage.getAvatar();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _username = username;
          _avatar = avatar;
          _dailyCompleted = stats.dailyCompletion[DateTime.now().toIso8601String().split('T')[0]] ?? false;

          // Автоматически выбираем первый доступный предмет если текущий не доступен
          final subjects = _availableSubjects;
          if (subjects.isNotEmpty && !subjects.contains(_selectedSubject)) {
            _selectedSubject = subjects.first;
            _saveLastSelected();
          }
        });
      }

      print('👤 User data loaded - Username: $username, Streak: ${stats.streakDays} days');
      print('📊 User progress: ${stats.topicProgress}');
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  void _debugCheckTopics() {
    print('🔍 DEBUG: Checking all topics in data');
    int totalTopics = 0;

    for (final grade in _subjectsData.keys) {
      final subjects = _subjectsData[grade] ?? [];
      for (final subject in subjects) {
        final topics = subject.topicsByGrade[grade] ?? [];
        print('   Grade $grade, Subject: ${subject.name}, Topics: ${topics.length}');
        for (final topic in topics) {
          print('     - ${topic.name} (ID: ${topic.id})');
          totalTopics++;
        }
      }
    }
    print('🔍 DEBUG: Total topics found: $totalTopics');
  }

  Future<void> _refreshData() async {
    _topicsListKey.currentState?._clearCache();
    await _loadUserData();
  }

  List<String> get _availableSubjects {
    if (_selectedGrade != null) {
      final subjects = _subjectsData[_selectedGrade] ?? [];
      final subjectNames = subjects.map((s) => s.name).toList();

      // Убираем дубликаты
      final uniqueSubjects = subjectNames.toSet().toList();
      print('📖 Subjects for grade $_selectedGrade: $uniqueSubjects');
      return uniqueSubjects;
    } else {
      final allSubjects = <String>{};
      for (final grade in _subjectsData.keys) {
        final subjects = _subjectsData[grade] ?? [];
        for (final subject in subjects) {
          allSubjects.add(subject.name);
        }
      }
      final result = allSubjects.toList();
      print('📖 All subjects: $result');
      return result;
    }
  }

  List<dynamic> get _filteredTopics {
    final List<dynamic> allTopics = [];

    if (_selectedGrade != null) {
      final subjects = _subjectsData[_selectedGrade];
      if (subjects != null) {
        for (final subject in subjects) {
          if (subject.name == _selectedSubject) {
            final topics = subject.topicsByGrade[_selectedGrade] ?? [];
            allTopics.addAll(topics);
            print('📚 Found ${topics.length} topics for $subject');
            break;
          }
        }
      }
    } else {
      for (final grade in _subjectsData.keys) {
        final subjects = _subjectsData[grade] ?? [];
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
      final filtered = allTopics.where((topic) {
        final topicData = topic is _TopicWithGrade ? topic.topic : topic;
        return topicData.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            topicData.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      print('🔍 Filtered ${filtered.length} topics for search: "$_searchQuery"');
      return filtered;
    } else {
      print('📚 Total topics found: ${allTopics.length}');
      return allTopics;
    }
  }

  bool _isTopicCompleted(String topicName) {
    final topic = _findTopicInAllSubjects(topicName);
    if (topic == null) {
      print('❌ Topic not found: $topicName');
      return false;
    }

    final topicId = topic.id;

    print('🔍 Checking completion for topic: $topicName (ID: $topicId)');

    for (final subjectName in _userStats.topicProgress.keys) {
      final subjectProgress = _userStats.topicProgress[subjectName];
      if (subjectProgress != null && subjectProgress.containsKey(topicId)) {
        final topicCorrectAnswers = subjectProgress[topicId] ?? 0;
        final totalQuestions = topic.questions.length;
        final isCompleted = topicCorrectAnswers >= totalQuestions;

        print('📊 Progress found - Subject: $subjectName, Correct: $topicCorrectAnswers/$totalQuestions, Completed: $isCompleted');
        return isCompleted;
      }
    }

    print('📊 No progress found for topic: $topicName (ID: $topicId)');
    return false;
  }

  dynamic _findTopicInAllSubjects(String topicName) {
    for (final grade in _subjectsData.keys) {
      final subjects = _subjectsData[grade] ?? [];
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
    final topicGrade = topic is _TopicWithGrade ? topic.grade : _selectedGrade;

    print('🎯 Showing topic popup:');
    print('   Topic: ${topicData.name} (ID: ${topicData.id})');
    print('   Grade: $topicGrade');
    print('   Subject: $_selectedSubject');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicPopup(
        topic: topicData,
        currentGrade: topicGrade,
        currentSubject: _selectedSubject,
      ),
    );
  }

  bool _isPhotoAvatar() {
    if (_avatar == '👤') return false;

    try {
      final file = File(_avatar);
      return file.existsSync();
    } catch (e) {
      print('❌ Error checking avatar file: $e');
      return false;
    }
  }

  void _onGradeChanged(int? value) {
    setState(() {
      _selectedGrade = value;
      final subjects = _availableSubjects;
      if (subjects.isNotEmpty) {
        _selectedSubject = subjects.first;
      }
      _topicsListKey.currentState?._clearCache();
      _saveLastSelected(); // Сохраняем выбор
      print('🎓 Grade changed to: $value, subjects: $subjects');
    });
  }

  void _onSubjectChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedSubject = value;
        _topicsListKey.currentState?._clearCache();
        _saveLastSelected(); // Сохраняем выбор
        print('📖 Subject changed to: $value');
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _topicsListKey.currentState?._clearCache();
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          currentAvatar: _avatar,
          onAvatarUpdate: (newAvatar) {
            setState(() {
              _avatar = newAvatar;
            });
            UserDataStorage.saveAvatar(newAvatar);
          },
          onUsernameUpdate: (newUsername) {
            setState(() {
              _username = newUsername;
            });
            UserDataStorage.saveUsername(newUsername);
          },
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _openStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(userStats: _userStats),
      ),
    );
  }

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onLogout: () {
            widget.onLogout();
          },
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(appLocalizations),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              avatar: _avatar,
              isPhotoAvatar: _isPhotoAvatar(),
              username: _username,
              dailyCompleted: _dailyCompleted,
              streakDays: _userStats.streakDays,
              onAvatarPressed: _openDrawer,
              appLocalizations: appLocalizations,
            ),
            _GradeSubjectSelector(
              selectedGrade: _selectedGrade,
              selectedSubject: _selectedSubject,
              availableSubjects: _availableSubjects,
              onGradeChanged: _onGradeChanged,
              onSubjectChanged: _onSubjectChanged,
              appLocalizations: appLocalizations,
            ),
            _SearchField(
              onChanged: _onSearchChanged,
              appLocalizations: appLocalizations,
            ),
            Expanded(
              child: _OptimizedTopicsList(
                filteredTopics: _filteredTopics,
                isTopicCompleted: _isTopicCompleted,
                onTopicTap: (topic) => _showTopicPopup(context, topic),
                onRefresh: _refreshData,
                listKey: _topicsListKey,
                appLocalizations: appLocalizations,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // В методе _buildDrawer замените существующий код после Statistics на:
  _buildDrawer(AppLocalizations appLocalizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileColor = isDark
        ? const Color(0xFF2D4A2D)
        : const Color(0xFFE8F5E8);

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: profileColor,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: profileColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _openProfile,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                    backgroundImage: _isPhotoAvatar()
                        ? FileImage(File(_avatar)) as ImageProvider
                        : null,
                    child: _isPhotoAvatar()
                        ? null
                        : Icon(
                      Icons.person,
                      size: 30,
                      color: isDark ? Colors.white : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _username.isNotEmpty ? '${appLocalizations.hello}, $_username!' : '${appLocalizations.hello}!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appLocalizations.clickToEdit,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.star,
            title: 'EduPeak+',
            subtitle: appLocalizations.premiumFeatures,
            color: Colors.amber,
            onTap: _openSubscription,
          ),
          _DrawerItem(
            icon: Icons.analytics,
            title: appLocalizations.statistics,
            subtitle: appLocalizations.learningProgress,
            color: Colors.green,
            onTap: _openStatistics,
          ),
          _DrawerItem(
            icon: Icons.emoji_events,
            title: appLocalizations.achievements,
            subtitle: appLocalizations.achievements,
            color: Colors.orange,
            onTap: _openAchievements,
          ),
          _DrawerItem(
            icon: Icons.people,
            title: appLocalizations.friends,
            subtitle: appLocalizations.friends,
            color: Colors.blue,
            onTap: _openFriends,
          ),
          _DrawerItem(
            icon: Icons.leaderboard,
            title: appLocalizations.educationalLeague,
            subtitle: appLocalizations.educationalLeague,
            color: Colors.purple,
            onTap: _openEduLeague,
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.settings,
            title: appLocalizations.settings,
            subtitle: appLocalizations.appSettings,
            color: Colors.blue,
            onTap: _openSettings,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
              },
              icon: const Icon(Icons.logout),
              label: Text(appLocalizations.logout),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String avatar;
  final bool isPhotoAvatar;
  final String username;
  final bool dailyCompleted;
  final int streakDays;
  final VoidCallback onAvatarPressed;
  final AppLocalizations appLocalizations;

  const _ProfileHeader({
    required this.avatar,
    required this.isPhotoAvatar,
    required this.username,
    required this.dailyCompleted,
    required this.streakDays,
    required this.onAvatarPressed,
    required this.appLocalizations,
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
          GestureDetector(
            onTap: onAvatarPressed,
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? '${appLocalizations.hello}, $username!' : '${appLocalizations.hello}!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dailyCompleted ? appLocalizations.todayCompleted : appLocalizations.startLessonText,
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
  final AppLocalizations appLocalizations;

  const _GradeSubjectSelector({
    required this.selectedGrade,
    required this.selectedSubject,
    required this.availableSubjects,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Классы - уже
          Container(
            width: MediaQuery.of(context).size.width * 0.35, // 35% ширины
            child: _GradeDropdown(
              selectedGrade: selectedGrade,
              onChanged: onGradeChanged,
              appLocalizations: appLocalizations,
            ),
          ),
          const SizedBox(width: 16),
          // Предметы - шире
          Expanded(
            child: _SubjectDropdown(
              selectedSubject: selectedSubject,
              availableSubjects: availableSubjects,
              onChanged: onSubjectChanged,
              appLocalizations: appLocalizations,
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
  final AppLocalizations appLocalizations;

  const _GradeDropdown({
    required this.selectedGrade,
    required this.onChanged,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    final availableGrades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<int?>(
          value: selectedGrade,
          isExpanded: true,
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                appLocalizations.allGrades,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
              ),
            ),
            ...availableGrades.map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(
                  '$grade ${appLocalizations.grade}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
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
  final AppLocalizations appLocalizations;

  const _SubjectDropdown({
    required this.selectedSubject,
    required this.availableSubjects,
    required this.onChanged,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    final subjectEmojis = {
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

    // Убедимся, что нет дублирующихся предметов
    final uniqueSubjects = availableSubjects.toSet().toList();

    // Если выбранный предмет не в списке, выберем первый доступный
    final currentSubject = uniqueSubjects.contains(selectedSubject)
        ? selectedSubject
        : (uniqueSubjects.isNotEmpty ? uniqueSubjects.first : '');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: currentSubject.isEmpty ? null : currentSubject,
          isExpanded: true,
          underline: const SizedBox(),
          items: uniqueSubjects.map((subject) {
            final emoji = subjectEmojis[subject] ?? '📚';
            return DropdownMenuItem<String>(
              value: subject,
              child: Text(
                '$emoji $subject',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
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
          hint: Text(
            appLocalizations.selectSubject,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final AppLocalizations appLocalizations;

  const _SearchField({
    required this.onChanged,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: appLocalizations.searchTopics,
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

class _OptimizedTopicsList extends StatelessWidget {
  final List<dynamic> filteredTopics;
  final bool Function(String) isTopicCompleted;
  final Function(dynamic) onTopicTap;
  final Future<void> Function() onRefresh;
  final GlobalKey<_OptimizedTopicsListViewState> listKey;
  final AppLocalizations appLocalizations;

  const _OptimizedTopicsList({
    required this.filteredTopics,
    required this.isTopicCompleted,
    required this.onTopicTap,
    required this.onRefresh,
    required this.listKey,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: filteredTopics.isEmpty
          ? _EmptyState(appLocalizations: appLocalizations)
          : _OptimizedTopicsListView(
        key: listKey,
        filteredTopics: filteredTopics,
        isTopicCompleted: isTopicCompleted,
        onTopicTap: onTopicTap,
      ),
    );
  }
}

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
  State<StatefulWidget> createState() => _OptimizedTopicsListViewState();
}

class _OptimizedTopicsListViewState extends State<_OptimizedTopicsListView> {
  final Map<String, Widget> _topicCardCache = {};

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.cache.containsKey(widget.cacheKey)) {
      return widget.cache[widget.cacheKey]!;
    }

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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: isCompleted
          ? (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B5E20)
          : const Color(0xFFE8F5E8))
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Иконка темы
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFC8E6C9))
                      : Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFC8E6C9))
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    topicData.imageAsset,
                    style: TextStyle(
                      fontSize: 24,
                      color: isCompleted
                          ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF2E7D32))
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и статус
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Класс (если есть)
                              if (grade != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$grade ${AppLocalizations.of(context).grade}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              // Название темы
                              Text(
                                topicData.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87)
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Иконка статуса выполнения
                        if (isCompleted)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Описание
                    Text(
                      topicData.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCompleted
                            ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54)
                            : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Стрелка навигации
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isCompleted
                    ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black38)
                    : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations appLocalizations;

  const _EmptyState({required this.appLocalizations});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations.noTopicsFound,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.tryDifferentSearch,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicWithGrade {
  final dynamic topic;
  final int grade;

  _TopicWithGrade({required this.topic, required this.grade});
}