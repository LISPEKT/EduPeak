import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';
import '../services/api_service.dart';
import '../localization.dart';

class XPScreen extends StatefulWidget {
  final int earnedXP;
  final int questionsCount;
  final String? topicId;
  final String? subjectName;

  const XPScreen({
    Key? key,
    required this.earnedXP,
    required this.questionsCount,
    this.topicId,
    this.subjectName,
  }) : super(key: key);

  @override
  State<XPScreen> createState() => _XPScreenState();
}

class _XPScreenState extends State<XPScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _progressAnimation;
  int _displayXP = 0;
  int _currentXP = 0;
  Map<String, dynamic> _userStats = {};
  bool _isSyncing = false;
  bool _animationCompleted = false;
  bool _isLoading = true;
  bool _shouldAwardXP = true;
  int _actualEarnedXP = 0;

  @override
  void initState() {
    super.initState();
    _displayXP = 0;
    _loadUserData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  Future<void> _loadUserData() async {
    try {
      await _checkIfShouldAwardXP();

      final response = await ApiService.getUserXPStats();
      if (response['success'] == true) {
        setState(() {
          _userStats = response;
          _currentXP = (response['totalXP'] as int?) ?? 0;
          _displayXP = _currentXP;
          _isLoading = false;
        });
        _startAnimation();
      } else {
        final localStats = await UserDataStorage.getUserStatsOverview();
        setState(() {
          _userStats = localStats;
          _currentXP = (localStats['totalXP'] as int?) ?? 0;
          _displayXP = _currentXP;
          _isLoading = false;
        });
        _startAnimation();
      }
    } catch (e) {
      print('Error loading user data: $e');
      final localStats = await UserDataStorage.getUserStatsOverview();
      setState(() {
        _userStats = localStats;
        _currentXP = (localStats['totalXP'] as int?) ?? 0;
        _displayXP = _currentXP;
        _isLoading = false;
      });
      _startAnimation();
    }
  }

  Future<void> _checkIfShouldAwardXP() async {
    if (widget.topicId == null || widget.subjectName == null) {
      setState(() {
        _shouldAwardXP = true;
        _actualEarnedXP = widget.earnedXP;
      });
      return;
    }

    try {
      final userStats = await UserDataStorage.getUserStats();
      final topicProgress = userStats.getTopicProgress(widget.topicId!);

      print('🔍 Checking topic progress for ${widget.topicId}: $topicProgress');

      if (topicProgress > 0) {
        setState(() {
          _shouldAwardXP = false;
          _actualEarnedXP = 0;
        });
        print('ℹ️ Topic already completed, no XP awarded');
      } else {
        setState(() {
          _shouldAwardXP = true;
          _actualEarnedXP = widget.earnedXP;
        });
        print('✅ First time completing topic, XP will be awarded: ${widget.earnedXP}');

        await UserDataStorage.updateTopicProgress(
            widget.subjectName!,
            widget.topicId!,
            widget.questionsCount
        );
      }
    } catch (e) {
      print('❌ Error checking topic progress: $e');
      setState(() {
        _shouldAwardXP = true;
        _actualEarnedXP = widget.earnedXP;
      });
    }
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_shouldAwardXP && _actualEarnedXP > 0) {
      await _syncXPWithServer();
    } else {
      await _loadUserData();
    }

    await _controller.forward();

    final targetXP = _currentXP + _actualEarnedXP;

    if (_actualEarnedXP <= 0) {
      setState(() {
        _displayXP = targetXP;
        _animationCompleted = true;
      });
      return;
    }

    final maxSteps = 100;
    final steps = _actualEarnedXP > maxSteps ? maxSteps : _actualEarnedXP;
    final xpPerStep = _actualEarnedXP / steps;
    final durationPerStep = 2000 ~/ steps;

    double currentValue = _currentXP.toDouble();

    for (int i = 0; i <= steps; i++) {
      if (!mounted) break;

      await Future.delayed(Duration(milliseconds: durationPerStep.clamp(20, 100)));

      if (mounted) {
        setState(() {
          currentValue = _currentXP + (i * xpPerStep);
          _displayXP = currentValue.round();
        });
      }
    }

    if (mounted) {
      setState(() {
        _displayXP = targetXP;
        _animationCompleted = true;
      });
    }

    await _loadUserData();
  }

  Future<void> _syncXPWithServer() async {
    if (!_shouldAwardXP || _actualEarnedXP <= 0) {
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final response = await ApiService.addXP(_actualEarnedXP, 'test_completion');

      if (response['success'] == true) {
        print('✅ XP synced with server: +${_actualEarnedXP} XP');
      } else {
        await UserDataStorage.addUserXP(_actualEarnedXP);
        print('✅ XP saved locally: +${_actualEarnedXP} XP');
      }
    } catch (e) {
      print('❌ Error syncing XP with server: $e');
      await UserDataStorage.addUserXP(_actualEarnedXP);
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Бронза': return Color(0xFFCD7F32);
      case 'Серебро': return Color(0xFFC0C0C0);
      case 'Золото': return Color(0xFFFFD700);
      case 'Платина': return Color(0xFFE5E4E2);
      case 'Бриллиант': return Color(0xFFB9F2FF);
      default: return Theme.of(context).primaryColor;
    }
  }

  double _getLeagueProgress() {
    final weeklyXP = (_userStats['weeklyXP'] as int?) ?? 0;
    if (weeklyXP >= 1001) return 1.0;
    if (weeklyXP >= 501) return (weeklyXP - 501) / 500.0;
    if (weeklyXP >= 301) return (weeklyXP - 301) / 200.0;
    if (weeklyXP >= 101) return (weeklyXP - 101) / 200.0;
    return weeklyXP / 100.0;
  }

  String _getNextLeague(String currentLeague) {
    switch (currentLeague) {
      case 'Бронза': return 'Серебро';
      case 'Серебро': return 'Золото';
      case 'Золото': return 'Платина';
      case 'Платина': return 'Бриллиант';
      case 'Бриллиант': return 'Бриллиант';
      default: return 'Серебро';
    }
  }

  int _getXPToNextLeague() {
    final weeklyXP = (_userStats['weeklyXP'] as int?) ?? 0;
    final currentLeague = (_userStats['currentLeague'] as String?) ?? 'Бронза';

    switch (currentLeague) {
      case 'Бронза':
        final result = 101 - weeklyXP;
        return result > 0 ? result : 0;
      case 'Серебро':
        final result = 301 - weeklyXP;
        return result > 0 ? result : 0;
      case 'Золото':
        final result = 501 - weeklyXP;
        return result > 0 ? result : 0;
      case 'Платина':
        final result = 1001 - weeklyXP;
        return result > 0 ? result : 0;
      case 'Бриллиант': return 0;
      default:
        final result = 101 - weeklyXP;
        return result > 0 ? result : 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    final currentLeague = (_userStats['currentLeague'] as String?) ?? 'Бронза';
    final totalXP = (_userStats['totalXP'] as int?) ?? 0;
    final weeklyXP = (_userStats['weeklyXP'] as int?) ?? 0;
    final leagueColor = _getLeagueColor(currentLeague);
    final leagueProgress = _getLeagueProgress();
    final nextLeague = _getNextLeague(currentLeague);
    final xpToNext = _getXPToNextLeague();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _animation.value) * 20),
                    child: Opacity(
                      opacity: _animation.value,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _shouldAwardXP ? localizations.experienceEarned : localizations.testCompleted,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (!_shouldAwardXP)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.testAlreadyCompleted,
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100]?.withOpacity(0.5),
                    ),
                  ),

                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _progressAnimation.value * leagueProgress,
                          strokeWidth: 14,
                          color: leagueColor,
                          backgroundColor: Colors.grey[300]?.withOpacity(0.3),
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + _animation.value * 0.2,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: leagueColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_displayXP',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: leagueColor,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'XP',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: leagueColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentLeague,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: leagueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isSyncing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(110),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(leagueColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _animation.value) * 30),
                    child: Opacity(
                      opacity: _animation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        title: '${localizations.questionsCompleted}:',
                        value: '${widget.questionsCount}',
                        icon: Icons.quiz_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.experienceEarned}:',
                        value: _shouldAwardXP ? '+${_actualEarnedXP} XP' : '0 XP (${localizations.alreadyCompleted})',
                        valueColor: _shouldAwardXP ? leagueColor : Colors.grey,
                        icon: Icons.bolt_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.currentLeague}:',
                        value: currentLeague,
                        valueColor: leagueColor,
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.totalExperience}:',
                        value: '$totalXP XP',
                        icon: Icons.star_outline,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.weeklyExperience}:',
                        value: '$weeklyXP XP',
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.leagueProgress}:',
                        value: '${(leagueProgress * 100).round()}%',
                        valueColor: leagueColor,
                        icon: Icons.timeline_outlined,
                      ),
                      if (xpToNext > 0) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          title: '${localizations.toNextLeague} $nextLeague:',
                          value: '$xpToNext XP',
                          valueColor: leagueColor,
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_shouldAwardXP && _actualEarnedXP > 0)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _animation.value) * 20),
                      child: Opacity(
                        opacity: _animation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: leagueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: leagueColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: leagueColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: leagueColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.excellentWork,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: leagueColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${localizations.youEarnedXP} ${_actualEarnedXP} XP ${localizations.forTestCompletion}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: leagueColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _animation.value) * 10),
                    child: Opacity(
                      opacity: _animation.value,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _animationCompleted ? () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false,
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _animationCompleted
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: _animationCompleted
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Colors.grey,
                    ),
                    child: Text(
                      _animationCompleted ? localizations.continueLearning : localizations.animationInProgress,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final IconData icon;

  const _InfoRow({
    required this.title,
    required this.value,
    this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}