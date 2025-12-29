// get_xp_screen.dart - РЕДИЗАЙН В MD3 с исправлением бесконечного начисления XP и улучшенной анимацией
import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';
import '../services/api_service.dart';
import '../localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _startXP = 0; // XP до начала теста
  Map<String, dynamic> _userStats = {};
  bool _isSyncing = false;
  bool _animationCompleted = false;
  bool _isLoading = true;
  bool _shouldAwardXP = true;
  int _actualEarnedXP = 0;
  bool _xpAlreadyAdded = false;
  bool _xpAddingInProgress = false;
  double _leagueProgressStart = 0.0; // Начальный прогресс лиги
  double _leagueProgressEnd = 0.0; // Конечный прогресс лиги

  @override
  void initState() {
    super.initState();
    _displayXP = 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserData();
      await _addXPOnceIfNeeded();
      await _startAnimation();
    });
  }

  Future<void> _loadUserData() async {
    try {
      await _checkIfShouldAwardXP();

      try {
        final response = await ApiService.getUserXPStats();
        if (response['success'] == true) {
          setState(() {
            _userStats = response;
            _currentXP = (response['totalXP'] as int?) ?? 0;
            _startXP = _currentXP - _actualEarnedXP; // Вычисляем XP до теста
            if (_startXP < 0) _startXP = 0;
            _displayXP = _startXP; // Начинаем отображение с XP до теста

            // Вычисляем прогресс лиги до и после теста
            _leagueProgressStart = _calculateLeagueProgress(_startXP);
            _leagueProgressEnd = _calculateLeagueProgress(_currentXP + _actualEarnedXP);
            _isLoading = false;
          });
        } else {
          throw Exception('Server response not successful');
        }
      } catch (e) {
        print('⚠️ Server data failed: $e, using local data');
        final localStats = await UserDataStorage.getUserStatsOverview();
        setState(() {
          _userStats = localStats;
          _currentXP = (localStats['totalXP'] as int?) ?? 0;
          _startXP = _currentXP - _actualEarnedXP;
          if (_startXP < 0) _startXP = 0;
          _displayXP = _startXP;

          _leagueProgressStart = _calculateLeagueProgress(_startXP);
          _leagueProgressEnd = _calculateLeagueProgress(_currentXP + _actualEarnedXP);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _userStats = {};
        _currentXP = 0;
        _startXP = 0;
        _displayXP = 0;
        _leagueProgressStart = 0;
        _leagueProgressEnd = _calculateLeagueProgress(_actualEarnedXP);
        _isLoading = false;
      });
    }
  }

  double _calculateLeagueProgress(int xp) {
    if (xp >= 5000) return 1.0;
    if (xp >= 4000) return (xp - 4000) / 1000.0;
    if (xp >= 3000) return (xp - 3000) / 1000.0;
    if (xp >= 2000) return (xp - 2000) / 1000.0;
    if (xp >= 1500) return (xp - 1500) / 500.0;
    if (xp >= 1000) return (xp - 1000) / 500.0;
    if (xp >= 500) return (xp - 500) / 500.0;
    return xp / 500.0;
  }

  Future<void> _checkIfShouldAwardXP() async {
    if (widget.topicId == null || widget.subjectName == null) {
      setState(() {
        _shouldAwardXP = widget.earnedXP > 0;
        _actualEarnedXP = widget.earnedXP;
      });
      return;
    }

    try {
      final topicProgress = await UserDataStorage.getTopicProgressById(widget.topicId!);
      final oldProgress = topicProgress;
      final newProgress = widget.questionsCount;

      print('📊 Topic progress check: old=$oldProgress, new=$newProgress');

      setState(() {
        _shouldAwardXP = widget.earnedXP > 0;
        _actualEarnedXP = widget.earnedXP;
      });

      if (newProgress > oldProgress && widget.subjectName != null) {
        await UserDataStorage.saveTopicProgress(
            widget.subjectName!,
            widget.topicId!,
            newProgress
        );
      }

      print('✅ XP calculation: shouldAward=$_shouldAwardXP, xp=$_actualEarnedXP');
    } catch (e) {
      print('❌ Error checking topic progress: $e');
      setState(() {
        _shouldAwardXP = widget.earnedXP > 0;
        _actualEarnedXP = widget.earnedXP;
      });
    }
  }

  Future<void> _addXPOnceIfNeeded() async {
    if (_xpAlreadyAdded || _xpAddingInProgress) {
      print('⚠️ XP already added or adding in progress, skipping');
      return;
    }

    if (!_shouldAwardXP || _actualEarnedXP <= 0) {
      print('⚠️ No XP to award or should not award');
      return;
    }

    _xpAddingInProgress = true;
    print('💰 Attempting to add XP once: +${_actualEarnedXP} XP');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = 'xp_awarded_${widget.topicId}_${widget.earnedXP}_${DateTime.now().millisecondsSinceEpoch ~/ 60000}';

      if (prefs.containsKey(sessionKey)) {
        print('⚠️ XP already awarded in the last minute for this session');
        _xpAlreadyAdded = true;
        _xpAddingInProgress = false;
        return;
      }

      await UserDataStorage.addUserXP(_actualEarnedXP);

      _xpAlreadyAdded = true;
      await prefs.setString(sessionKey, DateTime.now().toIso8601String());
      await prefs.setInt('last_xp_amount', _actualEarnedXP);
      await prefs.setString('last_xp_topic_id', widget.topicId ?? 'unknown');

      print('✅ XP added successfully to local storage');

      _syncXPWithServerInBackground();

    } catch (e) {
      print('❌ Error adding XP: $e');
      _xpAlreadyAdded = true;
    } finally {
      _xpAddingInProgress = false;
    }
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Запускаем анимации
    await _controller.forward();

    final targetXP = _currentXP + _actualEarnedXP;

    if (_actualEarnedXP <= 0) {
      setState(() {
        _displayXP = targetXP;
        _animationCompleted = true;
      });
      return;
    }

    // Плавная анимация увеличения XP
    final duration = 1800;
    final steps = (_actualEarnedXP > 100) ? 100 : _actualEarnedXP;
    final xpPerStep = _actualEarnedXP / steps;
    final durationPerStep = duration ~/ steps;

    double currentValue = _startXP.toDouble();

    for (int i = 0; i <= steps; i++) {
      if (!mounted) break;
      await Future.delayed(Duration(milliseconds: durationPerStep.clamp(15, 40)));
      if (mounted) {
        setState(() {
          currentValue = _startXP + (i * xpPerStep);
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

  Future<void> _syncXPWithServerInBackground() async {
    if (!_shouldAwardXP || _actualEarnedXP <= 0) return;

    print('🔄 Starting background XP sync: +${_actualEarnedXP} XP');

    setState(() => _isSyncing = true);

    try {
      final response = await ApiService.addXP(_actualEarnedXP, 'test_completion');
      if (response['success'] == true) {
        print('✅ XP synced with server in background');
      } else {
        print('⚠️ Server sync failed in background: ${response['message']}');
      }
    } catch (e) {
      print('❌ Background XP sync error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Бронзовая': return Color(0xFFCD7F32);
      case 'Серебряная': return Color(0xFFC0C0C0);
      case 'Золотая': return Color(0xFFFFD700);
      case 'Платиновая': return Color(0xFFE5E4E2);
      case 'Бриллиантовая': return Color(0xFFB9F2FF);
      case 'Элитная': return Color(0xFF7F7F7F);
      case 'Легендарная': return Color(0xFFFF4500);
      case 'Нереальная': return Color(0xFFE6E6FA);
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  String _getCurrentLeagueByXP(int xp) {
    if (xp >= 5000) return 'Нереальная';
    if (xp >= 4000) return 'Легендарная';
    if (xp >= 3000) return 'Элитная';
    if (xp >= 2000) return 'Бриллиантовая';
    if (xp >= 1500) return 'Платиновая';
    if (xp >= 1000) return 'Золотая';
    if (xp >= 500) return 'Серебряная';
    return 'Бронзовая';
  }

  double _getCurrentLeagueProgress(int xp) {
    final league = _getCurrentLeagueByXP(xp);
    final leagueXP = xp - _getLeagueMinXP(league);
    final leagueRange = _getLeagueRange(league);

    if (leagueRange == 0) return 1.0;
    return (leagueXP / leagueRange).clamp(0.0, 1.0);
  }

  int _getLeagueMinXP(String league) {
    switch (league) {
      case 'Бронзовая': return 0;
      case 'Серебряная': return 500;
      case 'Золотая': return 1000;
      case 'Платиновая': return 1500;
      case 'Бриллиантовая': return 2000;
      case 'Элитная': return 3000;
      case 'Легендарная': return 4000;
      case 'Нереальная': return 5000;
      default: return 0;
    }
  }

  int _getLeagueRange(String league) {
    switch (league) {
      case 'Бронзовая': return 500;
      case 'Серебряная': return 500;
      case 'Золотая': return 500;
      case 'Платиновая': return 500;
      case 'Бриллиантовая': return 1000;
      case 'Элитная': return 1000;
      case 'Легендарная': return 1000;
      case 'Нереальная': return 5000; // Условно
      default: return 500;
    }
  }

  String _getNextLeague(String currentLeague) {
    switch (currentLeague) {
      case 'Бронзовая': return 'Серебряная';
      case 'Серебряная': return 'Золотая';
      case 'Золотая': return 'Платиновая';
      case 'Платиновая': return 'Бриллиантовая';
      case 'Бриллиантовая': return 'Элитная';
      case 'Элитная': return 'Легендарная';
      case 'Легендарная': return 'Нереальная';
      case 'Нереальная': return 'Нереальная';
      default: return 'Серебряная';
    }
  }

  int _getXPToNextLeague(int xp) {
    final currentLeague = _getCurrentLeagueByXP(xp);
    final nextLeagueMinXP = _getLeagueMinXP(_getNextLeague(currentLeague));

    if (nextLeagueMinXP == 0) return 0;
    return (nextLeagueMinXP - xp).clamp(0, nextLeagueMinXP);
  }

  @override
  void dispose() {
    _xpAlreadyAdded = false;
    _xpAddingInProgress = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }

    final currentLeague = _getCurrentLeagueByXP(_displayXP);
    final targetXP = _currentXP + _actualEarnedXP;
    final targetLeague = _getCurrentLeagueByXP(targetXP);
    final weeklyXP = (_userStats['weeklyXP'] as int?) ?? 0;
    final leagueColor = _getLeagueColor(currentLeague);
    final nextLeague = _getNextLeague(currentLeague);
    final xpToNext = _getXPToNextLeague(_displayXP);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок
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
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Уведомление о повторном прохождении
              if (!_shouldAwardXP)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.testAlreadyCompleted,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Основной круг с прогрессом
              Stack(
                alignment: Alignment.center,
                children: [
                  // Фоновый круг
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),

                  // Прогресс лиги с анимацией от начального до конечного
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final animatedProgress = _leagueProgressStart + (_leagueProgressEnd - _leagueProgressStart) * _progressAnimation.value;
                        return CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 8,
                          color: leagueColor,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),

                  // Центральный контент
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
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: leagueColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              '$_displayXP',
                              key: ValueKey(_displayXP),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: leagueColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                          Text(
                            'XP',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          if (_shouldAwardXP && _actualEarnedXP > 0 && currentLeague != targetLeague)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '↑ $targetLeague',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Индикатор синхронизации
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

              // Статистика
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        title: '${localizations.questionsCompleted}:',
                        value: '${widget.questionsCount}',
                        icon: Icons.quiz_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.experienceEarned}:',
                        value: _shouldAwardXP ? '+${_actualEarnedXP} XP' : '0 XP (${localizations.alreadyCompleted})',
                        valueColor: _shouldAwardXP ? leagueColor : Theme.of(context).colorScheme.onSurfaceVariant,
                        icon: Icons.bolt_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.currentLeague}:',
                        value: currentLeague,
                        valueColor: leagueColor,
                        icon: Icons.emoji_events_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.totalExperience}:',
                        value: '$_displayXP XP',
                        icon: Icons.star_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.weeklyExperience}:',
                        value: '$weeklyXP XP',
                        icon: Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.leagueProgress}:',
                        value: '${(_getCurrentLeagueProgress(_displayXP) * 100).round()}%',
                        valueColor: leagueColor,
                        icon: Icons.timeline_rounded,
                      ),
                      if (xpToNext > 0) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          title: '${localizations.toNextLeague} $nextLeague:',
                          value: '$xpToNext XP',
                          valueColor: leagueColor,
                          icon: Icons.flag_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Уведомление о награде
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
                    width: double.infinity,
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
                            size: 24,
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
                              if (currentLeague != targetLeague)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Поздравляем! Вы достигли новой лиги: $targetLeague',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: leagueColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
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

              const Spacer(),

              // Кнопка продолжения
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
                  child: FilledButton(
                    onPressed: _animationCompleted ? () {
                      print('🎯 Continue button pressed, navigating to /main');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false,
                      );
                    } : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _animationCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      foregroundColor: _animationCompleted
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _animationCompleted ? localizations.continueLearning : localizations.animationInProgress,
                      style: const TextStyle(
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
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}