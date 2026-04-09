// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/central_data_manager.dart';
import '../services/multiplayer_service.dart'; // Добавить этот импорт
import '../localization.dart';
import 'profile_editor_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'eduleague_screen.dart';
import 'streak_screen.dart';
import 'xp_stats_screen.dart';
import 'settings_screen.dart';
import 'multiplayer/friends_screen.dart';
import 'package:edu_peak/screens/admin/admin_panel_screen.dart';
import 'package:edu_peak/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int) onBottomNavTap;
  final int currentIndex;
  final VoidCallback onLogout;

  const ProfileScreen({
    Key? key,
    required this.onBottomNavTap,
    required this.currentIndex,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime? _registrationDate;
  int _friendsCount = 0;
  final MultiplayerService _multiplayerService = MultiplayerService(); // Добавить сервис

  @override
  void initState() {
    super.initState();
    _loadRegistrationDate();
    _loadFriendsCount();
  }

  Future<void> _loadRegistrationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final registrationTimestamp = prefs.getInt('registrationDate') ?? DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _registrationDate = DateTime.fromMillisecondsSinceEpoch(registrationTimestamp);
    });
  }

  Future<void> _loadFriendsCount() async {
    try {
      // Используем тот же MultiplayerService, что и в FriendsScreen
      final response = await _multiplayerService.getFriends();
      print('📥 ProfileScreen - Ответ от getFriends: $response');

      if (response['success'] == true) {
        final friendsList = response['friends'] as List? ?? [];
        setState(() {
          _friendsCount = friendsList.length;
        });
        print('✅ ProfileScreen - Загружено друзей: $_friendsCount');
      } else {
        print('❌ ProfileScreen - Ошибка загрузки друзей: ${response['message']}');
        // Пробуем альтернативный метод через ApiService
        await _loadFriendsCountAlternative();
      }
    } catch (e) {
      print('❌ ProfileScreen - Ошибка загрузки друзей: $e');
      // Пробуем альтернативный метод через ApiService
      await _loadFriendsCountAlternative();
    }
  }

  // Альтернативный метод загрузки через ApiService
  Future<void> _loadFriendsCountAlternative() async {
    try {
      final response = await ApiService.getFriends();
      if (response['success'] == true) {
        final friendsList = response['friends'] as List? ?? [];
        setState(() {
          _friendsCount = friendsList.length;
        });
        print('✅ ProfileScreen (alternative) - Загружено друзей: $_friendsCount');
      }
    } catch (e) {
      print('❌ ProfileScreen (alternative) - Ошибка: $e');
      // Если совсем ничего не работает, показываем 0
      setState(() {
        _friendsCount = 0;
      });
    }
  }

  // Публичный метод для обновления счетчика друзей (вызывается после возвращения с экрана друзей)
  Future<void> refreshFriendsCount() async {
    await _loadFriendsCount();
  }

  String _formatRegistrationDate() {
    if (_registrationDate == null) return AppLocalizations.of(context).unknown;
    final appLocalizations = AppLocalizations.of(context);
    final formatter = DateFormat('dd.MM.yyyy');
    return '${appLocalizations.since} ${formatter.format(_registrationDate!)}';
  }

  bool _isPhotoAvatar() {
    final avatar = Provider.of<CentralDataManager>(context, listen: false).avatar;
    return avatar.startsWith('/') || avatar.contains('.');
  }

  IconData _getLeagueIcon(String league) {
    switch (league) {
      case 'Нереальная': return Icons.auto_awesome_rounded;
      case 'Легендарная': return Icons.whatshot_rounded;
      case 'Элитная': return Icons.star_rounded;
      case 'Бриллиантовая': return Icons.diamond_rounded;
      case 'Платиновая': return Icons.lens_rounded;
      case 'Золотая': return Icons.lens_rounded;
      case 'Серебряная': return Icons.lens_rounded;
      case 'Бронзовая': return Icons.lens_rounded;
      default: return Icons.lens_rounded;
    }
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Нереальная': return const Color(0xFFE6E6FA);
      case 'Легендарная': return const Color(0xFFFF4500);
      case 'Элитная': return const Color(0xFF7F7F7F);
      case 'Бриллиантовая': return const Color(0xFFB9F2FF);
      case 'Платиновая': return const Color(0xFFE5E4E2);
      case 'Золотая': return const Color(0xFFFFD700);
      case 'Серебряная': return const Color(0xFFC0C0C0);
      case 'Бронзовая': return const Color(0xFFCD7F32);
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  void _openStatisticsScreen() {
    final dataManager = Provider.of<CentralDataManager>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(userStats: dataManager.userStats),
      ),
    );
  }

  void _openAchievementsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(
          onAchievementsLoaded: (count) {
            // Обновление через CentralDataManager не требуется,
            // так как менеджер сам синхронизирует достижения
          },
        ),
      ),
    ).then((_) {
      // Обновляем данные после возвращения
      Provider.of<CentralDataManager>(context, listen: false).refresh();
    });
  }

  void _openFriendsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendsScreen(),
      ),
    ).then((_) {
      // Обновляем счетчик друзей после возвращения с экрана друзей
      refreshFriendsCount();
    });
  }

  void _openLeagueScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EduLeagueScreen(),
      ),
    );
  }

  void _openStreakScreen() {
    final dataManager = Provider.of<CentralDataManager>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StreakScreen(
          dailyActivity: dataManager.userStats.getDailyActivityMap(),
          streakDays: dataManager.streakDays,
        ),
      ),
    );
  }

  void _openXPScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => XPStatsScreen()),
    );
  }

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(onLogout: widget.onLogout),
      ),
    );
  }

  void _openProfileEditor() async {
    final dataManager = Provider.of<CentralDataManager>(context, listen: false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditorScreen(
          currentAvatar: dataManager.avatar,
          onAvatarUpdate: (newAvatar) {
            dataManager.updateProfile(avatar: newAvatar);
          },
          onUsernameUpdate: (newUsername) {
            dataManager.updateProfile(username: newUsername);
          },
          onBottomNavTap: widget.onBottomNavTap,
          currentIndex: widget.currentIndex,
        ),
      ),
    );

    if (result == true) {
      await dataManager.refresh();
      await refreshFriendsCount(); // Также обновляем счетчик друзей
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CentralDataManager>(
      builder: (context, dataManager, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final primaryColor = theme.colorScheme.primary;
        final appLocalizations = AppLocalizations.of(context);

        // Показываем индикатор загрузки
        if (!dataManager.isInitialized && dataManager.isSyncing) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка профиля...',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          );
        }

        // Показываем ошибку
        if (dataManager.hasError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки данных',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      dataManager.errorMessage ?? 'Неизвестная ошибка',
                      style: TextStyle(color: theme.hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => dataManager.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        // Основной контент
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLocalizations.section,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              appLocalizations.profile,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
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
                            icon: Icon(Icons.settings_rounded, color: primaryColor),
                            onPressed: _openSettingsScreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Остальной контент в скролле
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refreshFriendsCount, // Добавляем Pull-to-Refresh
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Основная карточка профиля
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  children: [
                                    // Аватар
                                    GestureDetector(
                                      onTap: _openProfileEditor,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: _isPhotoAvatar()
                                            ? ClipOval(
                                          child: Image.file(
                                            File(dataManager.avatar),
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person_rounded,
                                                color: primaryColor,
                                                size: 36,
                                              );
                                            },
                                          ),
                                        )
                                            : Icon(
                                          Icons.person_rounded,
                                          color: primaryColor,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Информация профиля
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dataManager.username.isNotEmpty
                                                ? dataManager.username
                                                : appLocalizations.noName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: theme.textTheme.titleMedium?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatRegistrationDate(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.hintColor,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Друзья - теперь показывает актуальное количество
                                          GestureDetector(
                                            onTap: _openFriendsScreen,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.people_rounded,
                                                    size: 16,
                                                    color: primaryColor,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '$_friendsCount ${appLocalizations.friendsCount}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Статистика в ряд
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Text(
                                appLocalizations.statisticsPlural,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: appLocalizations.daysInRow,
                                      value: '${dataManager.streakDays}',
                                      color: Colors.orange,
                                      icon: Icons.local_fire_department_rounded,
                                      isDark: isDark,
                                      onTap: _openStreakScreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: appLocalizations.xpEarned,
                                      value: '${dataManager.totalXP}',
                                      color: Colors.green,
                                      icon: Icons.leaderboard_rounded,
                                      isDark: isDark,
                                      onTap: _openXPScreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: appLocalizations.topicsCompleted,
                                      value: '${dataManager.completedTopics}',
                                      color: Colors.blue,
                                      icon: Icons.check_circle_rounded,
                                      isDark: isDark,
                                      onTap: _openStatisticsScreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Изучаемые предметы
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    appLocalizations.studiedSubjects,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${dataManager.selectedSubjects.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: dataManager.selectedSubjects.length,
                                  itemBuilder: (context, index) {
                                    final subject = dataManager.selectedSubjects[index];
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        subject,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Дополнительная статистика
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                              child: Column(
                                children: [
                                  // Достижения
                                  _buildFeatureCard(
                                    title: appLocalizations.achievements,
                                    subtitle: '${dataManager.achievementsCompleted}/${dataManager.totalAchievements} ${appLocalizations.achievementsCompleted}',
                                    icon: Icons.emoji_events_rounded,
                                    color: Colors.amber,
                                    isDark: isDark,
                                    onTap: _openAchievementsScreen,
                                  ),
                                  const SizedBox(height: 12),

                                  // Лига
                                  _buildFeatureCard(
                                    title: appLocalizations.league,
                                    subtitle: dataManager.currentLeague,
                                    icon: _getLeagueIcon(dataManager.currentLeague),
                                    color: _getLeagueColor(dataManager.currentLeague),
                                    isDark: isDark,
                                    onTap: _openLeagueScreen,
                                  ),

                                  // Админ-панель (только для администраторов)
                                  FutureBuilder<bool>(
                                    future: ApiService.isAdmin(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data == true) {
                                        return Column(
                                          children: [
                                            const SizedBox(height: 12),
                                            _buildFeatureCard(
                                              title: 'Админ-панель',
                                              subtitle: 'Управление пользователями, контентом и статистикой',
                                              icon: Icons.admin_panel_settings_rounded,
                                              color: Colors.deepPurple,
                                              isDark: isDark,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Отступ для BottomNavigationBar
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}