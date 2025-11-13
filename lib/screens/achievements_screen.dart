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
          currentValue: _isLeagueAchieved('Бронза', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'silver_league',
          name: localizations.silverStrategist,
          description: localizations.reachSilverLeague,
          imageAsset: '🥈',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Серебро', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'gold_league',
          name: localizations.goldChampion,
          description: localizations.reachGoldLeague,
          imageAsset: '🥇',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Золото', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'platinum_league',
          name: localizations.platinumGenius,
          description: localizations.reachPlatinumLeague,
          imageAsset: '💎',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Платина', stats) ? 1 : 0,
          type: AchievementType.league,
        ),
        Achievement(
          id: 'diamond_league',
          name: localizations.diamondMaster,
          description: localizations.reachDiamondLeague,
          imageAsset: '💠',
          requiredValue: 1,
          currentValue: _isLeagueAchieved('Бриллиант', stats) ? 1 : 0,
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
    final currentLeague = stats['currentLeague'] ?? 'Бронза';
    final leagueOrder = ['Бронза', 'Серебро', 'Золото', 'Платина', 'Бриллиант'];
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
            Text(achievement.imageAsset, style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.achievementUnlocked,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    achievement.name,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _refreshAchievements() async {
    await _loadAchievements();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final completedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          localizations.achievements,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _refreshAchievements,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '${localizations.loading}...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Progress overview
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.achievementProgress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completedCount/$totalCount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Progress bar
                LinearProgressIndicator(
                  value: completedCount / totalCount,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 12,
                ),
                SizedBox(height: 8),

                // Progress percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progressPercentage.round()}% ${localizations.completed}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${totalCount - completedCount} ${localizations.remainingAchievements}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: localizations.completed,
                    value: completedCount,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: localizations.overallProgress,
                    value: _achievements.where((a) => !a.isUnlocked && a.currentValue > 0).length,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: localizations.locked,
                    value: _achievements.where((a) => !a.isUnlocked && a.currentValue == 0).length,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Achievements grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
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
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
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

              // Achievement name
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              // Achievement description
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  achievement.isUnlocked ? 'Достижение получено' : 'Достижение заблокировано',
                  style: TextStyle(
                    color: achievement.isUnlocked
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
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
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentValue / achievement.requiredValue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main content - занимает всю площадь карточки
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                  crossAxisAlignment: CrossAxisAlignment.center, // Центрируем по горизонтали
                  children: [
                    // Achievement icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
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

                    // Achievement name
                    Text(
                      achievement.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // Achievement description
                    Expanded(
                      child: Text(
                        achievement.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Progress for locked achievements
                    if (!isUnlocked && achievement.requiredValue > 1) ...[
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${achievement.currentValue}/${achievement.requiredValue}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Checkmark for completed
            if (isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Классы Achievement, AchievementType остаются без изменений
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