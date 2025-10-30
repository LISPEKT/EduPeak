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
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshAchievements() async {
    await _loadAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final completedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.achievements),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
          // Achievement statistics
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  count: completedCount,
                  total: totalCount,
                  label: localizations.completedAchievements,
                  color: Theme.of(context).primaryColor,
                ),
                _StatItem(
                  count: totalCount - completedCount,
                  total: totalCount,
                  label: localizations.remainingAchievements,
                  color: Colors.grey,
                ),
                _StatItem(
                  count: progressPercentage.round(),
                  total: 100,
                  label: localizations.overallProgress,
                  color: Colors.orange,
                  isPercentage: true,
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.achievementProgress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completedCount/$totalCount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completedCount / totalCount,
                  backgroundColor: Colors.grey[300],
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  '${progressPercentage.round()}% ${localizations.completed}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Achievements grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          achievement.name,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                achievement.imageAsset,
                style: TextStyle(fontSize: 48),
              ),
            ),
            SizedBox(height: 16),
            Text(
              achievement.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (!achievement.isUnlocked) ...[
              LinearProgressIndicator(
                value: achievement.currentValue / achievement.requiredValue,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 8),
              Text(
                '${localizations.progress}: ${achievement.currentValue}/${achievement.requiredValue}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      localizations.unlocked,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancel,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final int total;
  final String label;
  final Color color;
  final bool isPercentage;

  const _StatItem({
    required this.count,
    required this.total,
    required this.label,
    required this.color,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isPercentage ? '$count%' : '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background for completed
            if (isUnlocked) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.05),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            ],

            // Main content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Achievement icon
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          achievement.imageAsset,
                          style: TextStyle(
                            fontSize: 42,
                            color: isUnlocked
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Achievement name
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnlocked
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      achievement.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Description
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6),
                    child: Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isUnlocked
                            ? Theme.of(context).primaryColor.withOpacity(0.8)
                            : Colors.grey[600],
                        fontSize: 10,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Progress bar for locked
                  if (!isUnlocked && achievement.requiredValue > 1) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      minHeight: 4,
                    ),
                  ],
                ],
              ),
            ),

            // Progress for locked
            if (!isUnlocked) ...[
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${achievement.currentValue}/${achievement.requiredValue}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],

            // Checkmark for completed
            if (isUnlocked) ...[
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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