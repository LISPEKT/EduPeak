import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import '../localization.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  Map<String, int> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
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
        });
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

    setState(() {
      _achievements = [
        // Tests and learning
        Achievement(
          id: 'first_test',
          name: localizations.firstStep,
          description: localizations.completeFirstTest,
          imageAsset: '🎯',
          requiredValue: 1,
          currentValue: stats['completedTopics'] ?? 0,
          type: AchievementType.testsCompleted,
        ),
        Achievement(
          id: 'test_master',
          name: localizations.testMaster,
          description: localizations.complete10Tests,
          imageAsset: '📚',
          requiredValue: 10,
          currentValue: stats['completedTopics'] ?? 0,
          type: AchievementType.testsCompleted,
        ),
        Achievement(
          id: 'test_expert',
          name: localizations.testExpert,
          description: localizations.complete50Tests,
          imageAsset: '🏆',
          requiredValue: 50,
          currentValue: stats['completedTopics'] ?? 0,
          type: AchievementType.testsCompleted,
        ),
        Achievement(
          id: 'test_legend',
          name: localizations.testLegend,
          description: localizations.complete100Tests,
          imageAsset: '👑',
          requiredValue: 100,
          currentValue: stats['completedTopics'] ?? 0,
          type: AchievementType.testsCompleted,
        ),

        // Streaks
        Achievement(
          id: 'streak_3',
          name: localizations.journeyStart,
          description: localizations.study3Days,
          imageAsset: '🔥',
          requiredValue: 3,
          currentValue: stats['streakDays'] ?? 0,
          type: AchievementType.streakDays,
        ),
        Achievement(
          id: 'streak_7',
          name: localizations.weekOfStrength,
          description: localizations.study7Days,
          imageAsset: '💪',
          requiredValue: 7,
          currentValue: stats['streakDays'] ?? 0,
          type: AchievementType.streakDays,
        ),
        Achievement(
          id: 'streak_14',
          name: localizations.twoWeeks,
          description: localizations.study14Days,
          imageAsset: '🌟',
          requiredValue: 14,
          currentValue: stats['streakDays'] ?? 0,
          type: AchievementType.streakDays,
        ),
        Achievement(
          id: 'streak_30',
          name: localizations.monthOfDiscipline,
          description: localizations.study30Days,
          imageAsset: '🎖️',
          requiredValue: 30,
          currentValue: stats['streakDays'] ?? 0,
          type: AchievementType.streakDays,
        ),
        Achievement(
          id: 'streak_90',
          name: localizations.quarterChampion,
          description: localizations.study90Days,
          imageAsset: '🏅',
          requiredValue: 90,
          currentValue: stats['streakDays'] ?? 0,
          type: AchievementType.streakDays,
        ),

        // Perfect results
        Achievement(
          id: 'perfectionist',
          name: localizations.perfectionist,
          description: localizations.get100Percent,
          imageAsset: '⭐',
          requiredValue: 1,
          currentValue: 0,
          type: AchievementType.perfectTests,
        ),
        Achievement(
          id: 'perfect_5',
          name: localizations.flawless,
          description: localizations.get100Percent5Tests,
          imageAsset: '✨',
          requiredValue: 5,
          currentValue: 0,
          type: AchievementType.perfectTests,
        ),
        Achievement(
          id: 'perfect_20',
          name: localizations.perfectResult,
          description: localizations.get100Percent20Tests,
          imageAsset: '💫',
          requiredValue: 20,
          currentValue: 0,
          type: AchievementType.perfectTests,
        ),

        // Subjects
        Achievement(
          id: 'subject_expert',
          name: localizations.subjectExpert,
          description: localizations.completeAllTopics,
          imageAsset: '🎓',
          requiredValue: 1,
          currentValue: 0,
          type: AchievementType.subjectsCompleted,
        ),
        Achievement(
          id: 'subject_master',
          name: localizations.subjectMaster,
          description: localizations.completeAllTopics3Subjects,
          imageAsset: '🧠',
          requiredValue: 3,
          currentValue: 0,
          type: AchievementType.subjectsCompleted,
        ),
        Achievement(
          id: 'subject_grandmaster',
          name: localizations.grandmaster,
          description: localizations.completeAllTopics5Subjects,
          imageAsset: '🧩',
          requiredValue: 5,
          currentValue: 0,
          type: AchievementType.subjectsCompleted,
        ),

        // Activity
        Achievement(
          id: 'fast_learner',
          name: localizations.fastLearner,
          description: localizations.complete5TestsDay,
          imageAsset: '⚡',
          requiredValue: 5,
          currentValue: 0,
          type: AchievementType.testsInOneDay,
        ),
        Achievement(
          id: 'marathon',
          name: localizations.marathoner,
          description: localizations.complete10TestsDay,
          imageAsset: '🏃',
          requiredValue: 10,
          currentValue: 0,
          type: AchievementType.testsInOneDay,
        ),
        Achievement(
          id: 'daily_warrior',
          name: localizations.dailyWarrior,
          description: localizations.studyEveryDayWeek,
          imageAsset: '🛡️',
          requiredValue: 7,
          currentValue: 0,
          type: AchievementType.dailyActivity,
        ),

        // XP and leagues
        Achievement(
          id: 'knowledge_seeker',
          name: localizations.knowledgeSeeker,
          description: localizations.earn1000XP,
          imageAsset: '🔍',
          requiredValue: 1000,
          currentValue: stats['totalXP'] ?? 0,
          type: AchievementType.totalXP,
        ),
        Achievement(
          id: 'wisdom_keeper',
          name: localizations.wisdomKeeper,
          description: localizations.earn5000XP,
          imageAsset: '📖',
          requiredValue: 5000,
          currentValue: stats['totalXP'] ?? 0,
          type: AchievementType.totalXP,
        ),
        Achievement(
          id: 'knowledge_master',
          name: localizations.knowledgeMaster,
          description: localizations.earn10000XP,
          imageAsset: '🎇',
          requiredValue: 10000,
          currentValue: stats['totalXP'] ?? 0,
          type: AchievementType.totalXP,
        ),
        Achievement(
          id: 'bronze_league',
          name: localizations.bronzeFighter,
          description: localizations.reachBronzeLeague,
          imageAsset: '🥉',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Бронзовая', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'silver_league',
          name: localizations.silverStrategist,
          description: localizations.reachSilverLeague,
          imageAsset: '🥈',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Серебряная', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'gold_league',
          name: localizations.goldChampion,
          description: localizations.reachGoldLeague,
          imageAsset: '🥇',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Золотая', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'platinum_league',
          name: localizations.platinumGenius,
          description: localizations.reachPlatinumLeague,
          imageAsset: '💎',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Платиновая', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'diamond_league',
          name: localizations.diamondMaster,
          description: localizations.reachDiamondLeague,
          imageAsset: '💠',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Бриллиантовая', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'elite_league',
          name: 'Элитный воин',
          description: 'Достигните Элитной лиги',
          imageAsset: '⭐',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Элитная', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'legendary_league',
          name: 'Легендарный герой',
          description: 'Достигните Легендарной лиги',
          imageAsset: '🔥',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Легендарная', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'unreal_league',
          name: 'Нереальный гений',
          description: 'Достигните Нереальной лиги',
          imageAsset: '🌌',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Нереальная', stats) ? 1 : 0,
          type: AchievementType.league,
        ),

        // Correct answers
        Achievement(
          id: 'correct_100',
          name: localizations.accurateAnswer,
          description: localizations.give100Correct,
          imageAsset: '✅',
          requiredValue: 100,
          currentValue: stats['totalCorrectAnswers'] ?? 0,
          type: AchievementType.correctAnswers,
        ),
        Achievement(
          id: 'correct_500',
          name: localizations.erudite,
          description: localizations.give500Correct,
          imageAsset: '📝',
          requiredValue: 500,
          currentValue: stats['totalCorrectAnswers'] ?? 0,
          type: AchievementType.correctAnswers,
        ),
        Achievement(
          id: 'correct_1000',
          name: localizations.knowItAll,
          description: localizations.give1000Correct,
          imageAsset: '🏅',
          requiredValue: 1000,
          currentValue: stats['totalCorrectAnswers'] ?? 0,
          type: AchievementType.correctAnswers,
        ),
        Achievement(
          id: 'correct_5000',
          name: localizations.walkingEncyclopedia,
          description: localizations.give5000Correct,
          imageAsset: '🎓',
          requiredValue: 5000,
          currentValue: stats['totalCorrectAnswers'] ?? 0,
          type: AchievementType.correctAnswers,
        ),

        // Special
        Achievement(
          id: 'early_bird',
          name: localizations.earlyBird,
          description: localizations.studyMorning,
          imageAsset: '🌅',
          requiredValue: 1,
          currentValue: 0,
          type: AchievementType.special,
        ),
        Achievement(
          id: 'night_owl',
          name: localizations.nightOwl,
          description: localizations.studyNight,
          imageAsset: '🌙',
          requiredValue: 1,
          currentValue: 0,
          type: AchievementType.special,
        ),
        Achievement(
          id: 'weekend_warrior',
          name: localizations.weekendWarrior,
          description: localizations.studyWeekends,
          imageAsset: '🎯',
          requiredValue: 5,
          currentValue: 0,
          type: AchievementType.special,
        ),
      ];
    });
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
                child: Text(
                  achievement.imageAsset,
                  style: TextStyle(fontSize: 20),
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
                  child: Text(
                    achievement.imageAsset,
                    style: TextStyle(fontSize: 36),
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
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          achievement.imageAsset,
                          style: TextStyle(fontSize: 24),
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
  final String imageAsset;
  final int requiredValue;
  final int currentValue;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
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
      imageAsset: json['image_asset'] ?? '🏆',
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
      imageAsset: imageAsset,
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