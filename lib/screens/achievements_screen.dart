import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import '../localization.dart';

class AchievementCount {
  final int completed;
  final int total;

  AchievementCount({
    required this.completed,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'total': total,
    };
  }

  static AchievementCount fromJson(Map<String, dynamic> json) {
    return AchievementCount(
      completed: json['completed'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class AchievementsScreen extends StatefulWidget {
  final Function(AchievementCount)? onAchievementsLoaded;

  const AchievementsScreen({
    Key? key,
    this.onAchievementsLoaded,
  }) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  Map<String, int> _progress = {};
  int _completedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  AchievementCount get achievementCount {
    return AchievementCount(
      completed: _completedCount,
      total: _totalCount,
    );
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getAchievements();
      final progressResponse = await ApiService.getAchievementProgress();

      if (response['success'] == true && progressResponse['success'] == true) {
        final achievementsData = response['achievements'] as List;
        final progressData = progressResponse['progress'] as Map<String, dynamic>;

        setState(() {
          _achievements = achievementsData.map((data) {
            final achievement = Achievement.fromJson(data);
            final progressKey = _getProgressKey(achievement.type);
            final currentValue = progressData[progressKey] ?? 0;
            return achievement.copyWith(currentValue: currentValue);
          }).toList();
          _progress = progressData.map((key, value) => MapEntry(key, value as int));

          // Обновляем счетчики
          _completedCount = _achievements.where((a) => a.isUnlocked).length;
          _totalCount = _achievements.length;
        });

        // Уведомляем о загрузке данных
        if (widget.onAchievementsLoaded != null) {
          widget.onAchievementsLoaded!(achievementCount);
        }
      } else {
        await _loadLocalAchievements();
      }

      await _checkAndUnlockAchievements();
    } catch (e) {
      print('Error loading achievements: $e');
      await _loadLocalAchievements();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalAchievements() async {
    final stats = await UserDataStorage.getUserStatsOverview();
    final localizations = AppLocalizations.of(context)!;

    List<Achievement> localAchievements = [
      // Tests and learning
      Achievement(
        id: 'first_test',
        name: localizations.firstStep,
        description: localizations.completeFirstTest,
        icon: Icons.flag_rounded,
        iconColor: Colors.red,
        requiredValue: 1,
        currentValue: stats['completedTopics'] ?? 0,
        type: AchievementType.testsCompleted,
      ),
      Achievement(
        id: 'test_master',
        name: localizations.testMaster,
        description: localizations.complete10Tests,
        icon: Icons.menu_book_rounded,
        iconColor: Colors.blue,
        requiredValue: 10,
        currentValue: stats['completedTopics'] ?? 0,
        type: AchievementType.testsCompleted,
      ),
      Achievement(
        id: 'test_expert',
        name: localizations.testExpert,
        description: localizations.complete50Tests,
        icon: Icons.emoji_events_rounded,
        iconColor: Colors.amber,
        requiredValue: 50,
        currentValue: stats['completedTopics'] ?? 0,
        type: AchievementType.testsCompleted,
      ),
      Achievement(
        id: 'test_legend',
        name: localizations.testLegend,
        description: localizations.complete100Tests,
        icon: Icons.king_bed_rounded,
        iconColor: Colors.yellow[700]!,
        requiredValue: 100,
        currentValue: stats['completedTopics'] ?? 0,
        type: AchievementType.testsCompleted,
      ),

      // Streaks
      Achievement(
        id: 'streak_3',
        name: localizations.journeyStart,
        description: localizations.study3Days,
        icon: Icons.local_fire_department_rounded,
        iconColor: Colors.orange,
        requiredValue: 3,
        currentValue: stats['streakDays'] ?? 0,
        type: AchievementType.streakDays,
      ),
      Achievement(
        id: 'streak_7',
        name: localizations.weekOfStrength,
        description: localizations.study7Days,
        icon: Icons.fitness_center_rounded,
        iconColor: Colors.deepOrange,
        requiredValue: 7,
        currentValue: stats['streakDays'] ?? 0,
        type: AchievementType.streakDays,
      ),
      Achievement(
        id: 'streak_14',
        name: localizations.twoWeeks,
        description: localizations.study14Days,
        icon: Icons.star_rounded,
        iconColor: Colors.purple,
        requiredValue: 14,
        currentValue: stats['streakDays'] ?? 0,
        type: AchievementType.streakDays,
      ),
      Achievement(
        id: 'streak_30',
        name: localizations.monthOfDiscipline,
        description: localizations.study30Days,
        icon: Icons.military_tech_rounded,
        iconColor: Colors.brown,
        requiredValue: 30,
        currentValue: stats['streakDays'] ?? 0,
        type: AchievementType.streakDays,
      ),
      Achievement(
        id: 'streak_90',
        name: localizations.quarterChampion,
        description: localizations.study90Days,
        icon: Icons.workspace_premium_rounded,
        iconColor: Colors.teal,
        requiredValue: 90,
        currentValue: stats['streakDays'] ?? 0,
        type: AchievementType.streakDays,
      ),

      // Perfect results
      Achievement(
        id: 'perfectionist',
        name: localizations.perfectionist,
        description: localizations.get100Percent,
        icon: Icons.grade_rounded,
        iconColor: Colors.yellow[700]!,
        requiredValue: 1,
        currentValue: 0,
        type: AchievementType.perfectTests,
      ),
      Achievement(
        id: 'perfect_5',
        name: localizations.flawless,
        description: localizations.get100Percent5Tests,
        icon: Icons.auto_awesome_rounded,
        iconColor: Colors.pink,
        requiredValue: 5,
        currentValue: 0,
        type: AchievementType.perfectTests,
      ),
      Achievement(
        id: 'perfect_20',
        name: localizations.perfectResult,
        description: localizations.get100Percent20Tests,
        icon: Icons.auto_awesome_motion_rounded,
        iconColor: Colors.deepPurple,
        requiredValue: 20,
        currentValue: 0,
        type: AchievementType.perfectTests,
      ),

      // Subjects
      Achievement(
        id: 'subject_expert',
        name: localizations.subjectExpert,
        description: localizations.completeAllTopics,
        icon: Icons.school_rounded,
        iconColor: Colors.green,
        requiredValue: 1,
        currentValue: 0,
        type: AchievementType.subjectsCompleted,
      ),
      Achievement(
        id: 'subject_master',
        name: localizations.subjectMaster,
        description: localizations.completeAllTopics3Subjects,
        icon: Icons.psychology_rounded,
        iconColor: Colors.deepPurple,
        requiredValue: 3,
        currentValue: 0,
        type: AchievementType.subjectsCompleted,
      ),
      Achievement(
        id: 'subject_grandmaster',
        name: localizations.grandmaster,
        description: localizations.completeAllTopics5Subjects,
        icon: Icons.extension_rounded,
        iconColor: Colors.indigo,
        requiredValue: 5,
        currentValue: 0,
        type: AchievementType.subjectsCompleted,
      ),

      // Activity
      Achievement(
        id: 'fast_learner',
        name: localizations.fastLearner,
        description: localizations.complete5TestsDay,
        icon: Icons.flash_on_rounded,
        iconColor: Colors.yellow[700]!,
        requiredValue: 5,
        currentValue: 0,
        type: AchievementType.testsInOneDay,
      ),
      Achievement(
        id: 'marathon',
        name: localizations.marathoner,
        description: localizations.complete10TestsDay,
        icon: Icons.directions_run_rounded,
        iconColor: Colors.blue,
        requiredValue: 10,
        currentValue: 0,
        type: AchievementType.testsInOneDay,
      ),
      Achievement(
        id: 'daily_warrior',
        name: localizations.dailyWarrior,
        description: localizations.studyEveryDayWeek,
        icon: Icons.shield_rounded,
        iconColor: Colors.grey[700]!,
        requiredValue: 7,
        currentValue: 0,
        type: AchievementType.dailyActivity,
      ),

      // XP and leagues
      Achievement(
        id: 'knowledge_seeker',
        name: localizations.knowledgeSeeker,
        description: localizations.earn1000XP,
        icon: Icons.search_rounded,
        iconColor: Colors.blueGrey,
        requiredValue: 1000,
        currentValue: stats['totalXP'] ?? 0,
        type: AchievementType.totalXP,
      ),
      Achievement(
        id: 'wisdom_keeper',
        name: localizations.wisdomKeeper,
        description: localizations.earn5000XP,
        icon: Icons.book_rounded,
        iconColor: Colors.brown,
        requiredValue: 5000,
        currentValue: stats['totalXP'] ?? 0,
        type: AchievementType.totalXP,
      ),
      Achievement(
        id: 'knowledge_master',
        name: localizations.knowledgeMaster,
        description: localizations.earn10000XP,
        icon: Icons.celebration_rounded,
        iconColor: Colors.orange,
        requiredValue: 10000,
        currentValue: stats['totalXP'] ?? 0,
        type: AchievementType.totalXP,
      ),
      Achievement(
        id: 'bronze_league',
        name: localizations.bronzeFighter,
        description: localizations.reachBronzeLeague,
        icon: Icons.lens_rounded,
        iconColor: Color(0xFFCD7F32),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Бронзовая', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'silver_league',
        name: localizations.silverStrategist,
        description: localizations.reachSilverLeague,
        icon: Icons.lens_rounded,
        iconColor: Color(0xFFC0C0C0),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Серебряная', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'gold_league',
        name: localizations.goldChampion,
        description: localizations.reachGoldLeague,
        icon: Icons.lens_rounded,
        iconColor: Color(0xFFFFD700),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Золотая', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'platinum_league',
        name: localizations.platinumGenius,
        description: localizations.reachPlatinumLeague,
        icon: Icons.diamond_rounded,
        iconColor: Color(0xFFE5E4E2),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Платиновая', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'diamond_league',
        name: localizations.diamondMaster,
        description: localizations.reachDiamondLeague,
        icon: Icons.diamond_rounded,
        iconColor: Color(0xFFB9F2FF),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Бриллиантовая', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'elite_league',
        name: 'Элитный воин',
        description: 'Достигните Элитной лиги',
        icon: Icons.star_rounded,
        iconColor: Color(0xFF7F7F7F),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Элитная', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'legendary_league',
        name: 'Легендарный герой',
        description: 'Достигните Легендарной лиги',
        icon: Icons.whatshot_rounded,
        iconColor: Color(0xFFFF4500),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Легендарная', stats) ? 1 : 0,
        type: AchievementType.league,
      ),
      Achievement(
        id: 'unreal_league',
        name: 'Нереальный гений',
        description: 'Достигните Нереальной лиги',
        icon: Icons.auto_awesome_rounded,
        iconColor: Color(0xFFE6E6FA),
        requiredValue: 1,
        currentValue: _isLeagueAchieved('Нереальная', stats) ? 1 : 0,
        type: AchievementType.league,
      ),

      // Correct answers
      Achievement(
        id: 'correct_100',
        name: localizations.accurateAnswer,
        description: localizations.give100Correct,
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
        requiredValue: 100,
        currentValue: stats['totalCorrectAnswers'] ?? 0,
        type: AchievementType.correctAnswers,
      ),
      Achievement(
        id: 'correct_500',
        name: localizations.erudite,
        description: localizations.give500Correct,
        icon: Icons.assignment_rounded,
        iconColor: Colors.blueGrey,
        requiredValue: 500,
        currentValue: stats['totalCorrectAnswers'] ?? 0,
        type: AchievementType.correctAnswers,
      ),
      Achievement(
        id: 'correct_1000',
        name: localizations.knowItAll,
        description: localizations.give1000Correct,
        icon: Icons.workspace_premium_rounded,
        iconColor: Colors.amber,
        requiredValue: 1000,
        currentValue: stats['totalCorrectAnswers'] ?? 0,
        type: AchievementType.correctAnswers,
      ),
      Achievement(
        id: 'correct_5000',
        name: localizations.walkingEncyclopedia,
        description: localizations.give5000Correct,
        icon: Icons.school_rounded,
        iconColor: Colors.purple,
        requiredValue: 5000,
        currentValue: stats['totalCorrectAnswers'] ?? 0,
        type: AchievementType.correctAnswers,
      ),

      // Special
      Achievement(
        id: 'early_bird',
        name: localizations.earlyBird,
        description: localizations.studyMorning,
        icon: Icons.wb_sunny_rounded,
        iconColor: Colors.orange,
        requiredValue: 1,
        currentValue: 0,
        type: AchievementType.special,
      ),
      Achievement(
        id: 'night_owl',
        name: localizations.nightOwl,
        description: localizations.studyNight,
        icon: Icons.nightlight_rounded,
        iconColor: Colors.indigo,
        requiredValue: 1,
        currentValue: 0,
        type: AchievementType.special,
      ),
      Achievement(
        id: 'weekend_warrior',
        name: localizations.weekendWarrior,
        description: localizations.studyWeekends,
        icon: Icons.weekend_rounded,
        iconColor: Colors.red,
        requiredValue: 5,
        currentValue: 0,
        type: AchievementType.special,
      ),
    ];

    setState(() {
      _achievements = localAchievements;
      _completedCount = _achievements.where((a) => a.isUnlocked).length;
      _totalCount = _achievements.length;
    });

    // Уведомляем о загрузке данных
    if (widget.onAchievementsLoaded != null) {
      widget.onAchievementsLoaded!(achievementCount);
    }
  }

  bool _isLeagueAchieved(String league, Map<String, dynamic> stats) {
    final currentLeague = stats['currentLeague'] ?? 'Бронзовая';
    final leagueOrder = ['Бронзовая', 'Серебряная', 'Золотая', 'Платиновая', 'Бриллиантовая', 'Элитная', 'Легендарная', 'Нереальная'];
    final currentIndex = leagueOrder.indexOf(currentLeague);
    final targetIndex = leagueOrder.indexOf(league);
    return currentIndex >= targetIndex;
  }

  String _getProgressKey(AchievementType type) {
    switch (type) {
      case AchievementType.testsCompleted:
        return 'tests_completed';
      case AchievementType.streakDays:
        return 'streak_days';
      case AchievementType.perfectTests:
        return 'perfect_tests';
      case AchievementType.subjectsCompleted:
        return 'subjects_completed';
      case AchievementType.testsInOneDay:
        return 'tests_in_one_day';
      case AchievementType.totalXP:
        return 'total_xp';
      case AchievementType.league:
        return 'league';
      case AchievementType.correctAnswers:
        return 'correct_answers';
      case AchievementType.dailyActivity:
        return 'daily_activity';
      case AchievementType.special:
        return 'special';
      default:
        return 'tests_completed';
    }
  }

  Future<void> _checkAndUnlockAchievements() async {
    try {
      for (final achievement in _achievements) {
        if (!achievement.isUnlocked && achievement.currentValue >= achievement.requiredValue) {
          await ApiService.unlockAchievement(achievement.id);
          print('🎉 Achievement unlocked: ${achievement.name}');
          _showUnlockNotification(achievement);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  void _showUnlockNotification(Achievement achievement) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  color: achievement.iconColor,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.achievementUnlocked,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    achievement.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final completedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

    return Scaffold(
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
            stops: [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель с заголовком
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Кнопка назад
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
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Раздел',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            localizations.achievements,
                            style: TextStyle(
                              fontSize: 22,
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

              // Основной контент
              Expanded(
                child: _isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        '${localizations.loading}...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Статистика прогресса
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.emoji_events_rounded,
                                      color: primaryColor,
                                      size: 36,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Прогресс',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.hintColor,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '$completedCount/$totalCount',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: completedCount / totalCount,
                                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(4),
                                          minHeight: 10,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '$completedCount открыто • ${totalCount - completedCount} осталось',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Статистика в ряд
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Открыто',
                                value: completedCount.toString(),
                                color: Colors.green,
                                icon: Icons.check_circle_rounded,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'В прогрессе',
                                value: _achievements.where((a) => !a.isUnlocked && a.currentValue > 0).length.toString(),
                                color: Colors.orange,
                                icon: Icons.trending_up_rounded,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Заблокировано',
                                value: _achievements.where((a) => !a.isUnlocked && a.currentValue == 0).length.toString(),
                                color: Colors.grey,
                                icon: Icons.lock_rounded,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Сетка достижений
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          'Все достижения',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _achievements[index];
                            return _AchievementCard(
                              achievement: achievement,
                              onTap: () => _showAchievementDetails(achievement),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentValue / achievement.requiredValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка достижения
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    achievement.icon,
                    color: achievement.iconColor,
                    size: 36,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Название достижения
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              // Описание достижения
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              // Статус бейдж
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.green.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.green.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                      size: 18,
                      color: isUnlocked ? Colors.green : theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isUnlocked ? 'Достижение получено' : 'Достижение заблокировано',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isUnlocked
                            ? Colors.green
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isUnlocked && achievement.requiredValue > 1) ...[
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          Text(
                            '${achievement.currentValue}/${achievement.requiredValue}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 24),

              // Кнопка закрытия
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Закрыть',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentValue / achievement.requiredValue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? theme.cardColor : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Основной контент
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Иконка достижения
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? achievement.iconColor.withOpacity(0.1)
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          achievement.icon,
                          color: isUnlocked
                              ? achievement.iconColor
                              : achievement.iconColor.withOpacity(0.5),
                          size: 28,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Название достижения
                    Text(
                      achievement.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? theme.textTheme.titleMedium?.color
                            : theme.textTheme.titleMedium?.color?.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // Описание достижения
                    Expanded(
                      child: Text(
                        achievement.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Прогресс для заблокированных достижений
                    if (!isUnlocked && achievement.requiredValue > 1) ...[
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${achievement.currentValue}/${achievement.requiredValue}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Галочка для завершенных
            if (isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final int requiredValue;
  final int currentValue;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.requiredValue,
    required this.currentValue,
    required this.type,
  });

  bool get isUnlocked => currentValue >= requiredValue;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: _getIconFromString(json['icon'] ?? 'emoji_events'),
      iconColor: _getColorFromString(json['icon_color'] ?? '#FFD700'),
      requiredValue: json['required_value'],
      currentValue: json['current_value'] ?? 0,
      type: AchievementType.values.firstWhere(
            (e) => e.toString() == 'AchievementType.${json['type']}',
        orElse: () => AchievementType.testsCompleted,
      ),
    );
  }

  Achievement copyWith({
    int? currentValue,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      iconColor: iconColor,
      requiredValue: requiredValue,
      currentValue: currentValue ?? this.currentValue,
      type: type,
    );
  }
}

enum AchievementType {
  testsCompleted,
  streakDays,
  perfectTests,
  subjectsCompleted,
  testsInOneDay,
  totalXP,
  league,
  correctAnswers,
  dailyActivity,
  special,
}

// Вспомогательные функции для преобразования
IconData _getIconFromString(String iconName) {
  switch (iconName) {
    case 'flag_rounded': return Icons.flag_rounded;
    case 'menu_book_rounded': return Icons.menu_book_rounded;
    case 'emoji_events_rounded': return Icons.emoji_events_rounded;
    case 'king_bed_rounded': return Icons.king_bed_rounded;
    case 'local_fire_department_rounded': return Icons.local_fire_department_rounded;
    case 'fitness_center_rounded': return Icons.fitness_center_rounded;
    case 'star_rounded': return Icons.star_rounded;
    case 'military_tech_rounded': return Icons.military_tech_rounded;
    case 'workspace_premium_rounded': return Icons.workspace_premium_rounded;
    case 'grade_rounded': return Icons.grade_rounded;
    case 'auto_awesome_rounded': return Icons.auto_awesome_rounded;
    case 'auto_awesome_motion_rounded': return Icons.auto_awesome_motion_rounded;
    case 'school_rounded': return Icons.school_rounded;
    case 'psychology_rounded': return Icons.psychology_rounded;
    case 'extension_rounded': return Icons.extension_rounded;
    case 'flash_on_rounded': return Icons.flash_on_rounded;
    case 'directions_run_rounded': return Icons.directions_run_rounded;
    case 'shield_rounded': return Icons.shield_rounded;
    case 'search_rounded': return Icons.search_rounded;
    case 'book_rounded': return Icons.book_rounded;
    case 'celebration_rounded': return Icons.celebration_rounded;
    case 'lens_rounded': return Icons.lens_rounded;
    case 'diamond_rounded': return Icons.diamond_rounded;
    case 'whatshot_rounded': return Icons.whatshot_rounded;
    case 'check_circle_rounded': return Icons.check_circle_rounded;
    case 'assignment_rounded': return Icons.assignment_rounded;
    case 'wb_sunny_rounded': return Icons.wb_sunny_rounded;
    case 'nightlight_rounded': return Icons.nightlight_rounded;
    case 'weekend_rounded': return Icons.weekend_rounded;
    default: return Icons.emoji_events_rounded;
  }
}

Color _getColorFromString(String colorString) {
  try {
    return Color(int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000);
  } catch (e) {
    return Colors.amber;
  }
}