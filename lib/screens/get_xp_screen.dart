// get_xp_screen.dart - исправленная версия с правильной анимацией
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
  late Animation<double> _xpAnimation;
  int _displayXP = 0;
  int _startingXP = 0;
  int _endingXP = 0;
  int _actualEarnedXP = 0;
  bool _shouldAwardXP = true;
  bool _xpAlreadyAdded = false;
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _animationCompleted = false;
  String _currentLeague = 'Бронзовая';
  String _targetLeague = 'Бронзовая';
  Color _leagueColor = Color(0xFFCD7F32);
  double _leagueProgress = 0.0;
  int _weeklyXP = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _xpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      // Сначала определяем, нужно ли начислять XP
      await _checkIfShouldAwardXP();

      // Получаем текущий XP пользователя
      final stats = await UserDataStorage.getUserStats();

      setState(() {
        _startingXP = stats.totalXP;
        _actualEarnedXP = _shouldAwardXP ? widget.earnedXP : 0;
        _endingXP = _startingXP + _actualEarnedXP;
        _displayXP = _startingXP;

        // Определяем текущую лигу и цвет
        _currentLeague = _getLeagueForXP(_startingXP);
        _targetLeague = _getLeagueForXP(_endingXP);
        _leagueColor = _getLeagueColor(_currentLeague);
        _leagueProgress = _calculateLeagueProgress(_startingXP);

        _weeklyXP = stats.weeklyXP;
        _isLoading = false;
      });

      // Начисляем XP если нужно
      if (_shouldAwardXP && _actualEarnedXP > 0 && !_xpAlreadyAdded) {
        await _addXPOnce();
      }

      // Запускаем анимацию
      _startAnimation();

    } catch (e) {
      print('❌ Error initializing data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = 'xp_session_${widget.topicId}_${DateTime.now().millisecondsSinceEpoch ~/ 60000}';

      if (prefs.containsKey(sessionKey)) {
        // XP уже начислялся в этой сессии
        setState(() {
          _shouldAwardXP = false;
          _actualEarnedXP = 0;
        });
        return;
      }

      // Сохраняем сессию
      await prefs.setString(sessionKey, 'true');

      setState(() {
        _shouldAwardXP = true;
        _actualEarnedXP = widget.earnedXP;
      });

    } catch (e) {
      print('❌ Error checking XP session: $e');
      setState(() {
        _shouldAwardXP = widget.earnedXP > 0;
        _actualEarnedXP = widget.earnedXP;
      });
    }
  }

  Future<void> _addXPOnce() async {
    if (_xpAlreadyAdded || _actualEarnedXP <= 0) return;

    try {
      await UserDataStorage.addUserXP(_actualEarnedXP);
      _xpAlreadyAdded = true;

      // Фоновая синхронизация с сервером
      _syncWithServerInBackground();

    } catch (e) {
      print('❌ Error adding XP: $e');
    }
  }

  Future<void> _syncWithServerInBackground() async {
    if (_actualEarnedXP <= 0) return;

    setState(() => _isSyncing = true);

    try {
      final response = await ApiService.addXP(_actualEarnedXP, 'test_completion');
      if (response['success'] == true) {
        print('✅ XP synced with server');
      }
    } catch (e) {
      print('⚠️ Server sync failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _startAnimation() {
    // Запускаем анимацию с небольшой задержкой
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      _controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _animationCompleted = true;
          });
        }
      });

      // Анимация счетчика XP
      final duration = Duration(milliseconds: 1200);
      final startTime = DateTime.now().millisecondsSinceEpoch;

      void updateCounter() {
        if (!mounted) return;

        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final elapsed = currentTime - startTime;
        final progress = elapsed.clamp(0, duration.inMilliseconds) / duration.inMilliseconds;

        final animatedXP = _startingXP + (_actualEarnedXP * progress).round();

        setState(() {
          _displayXP = animatedXP;

          // Обновляем лигу в реальном времени
          _currentLeague = _getLeagueForXP(animatedXP);
          _leagueColor = _getLeagueColor(_currentLeague);
          _leagueProgress = _calculateLeagueProgress(animatedXP);
        });

        if (progress < 1.0) {
          Future.delayed(const Duration(milliseconds: 16), updateCounter);
        } else {
          setState(() {
            _displayXP = _endingXP;
            _currentLeague = _targetLeague;
            _leagueColor = _getLeagueColor(_targetLeague);
            _leagueProgress = _calculateLeagueProgress(_endingXP);
          });
        }
      }

      updateCounter();
    });
  }

  String _getLeagueForXP(int xp) {
    if (xp >= 5000) return 'Нереальная';
    if (xp >= 4000) return 'Легендарная';
    if (xp >= 3000) return 'Элитная';
    if (xp >= 2000) return 'Бриллиантовая';
    if (xp >= 1500) return 'Платиновая';
    if (xp >= 1000) return 'Золотая';
    if (xp >= 500) return 'Серебряная';
    return 'Бронзовая';
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
      default: return Colors.blue;
    }
  }

  double _calculateLeagueProgress(int xp) {
    final league = _getLeagueForXP(xp);
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
      case 'Нереальная': return 1000;
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
    final currentLeague = _getLeagueForXP(xp);
    final nextLeague = _getNextLeague(currentLeague);
    final nextLeagueMinXP = _getLeagueMinXP(nextLeague);

    return (nextLeagueMinXP - xp).clamp(0, nextLeagueMinXP);
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
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }

    final xpToNextLeague = _getXPToNextLeague(_displayXP);
    final nextLeague = _getNextLeague(_currentLeague);
    final hasLeagueChanged = _getLeagueForXP(_startingXP) != _targetLeague;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок
              AnimatedOpacity(
                opacity: _animationCompleted ? 1.0 : 0.7,
                duration: Duration(milliseconds: 300),
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

                  // Прогресс лиги
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _leagueProgress,
                      strokeWidth: 8,
                      color: _leagueColor,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Центральный контент
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _leagueColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Text(
                            '$_displayXP',
                            key: ValueKey(_displayXP),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _leagueColor,
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
                            color: _leagueColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentLeague,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _leagueColor,
                            ),
                          ),
                        ),
                        if (hasLeagueChanged && _animationCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '↑ $_targetLeague',
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
                            valueColor: AlwaysStoppedAnimation(_leagueColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Статистика
              Container(
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
                      value: _shouldAwardXP ? '+${_actualEarnedXP} XP' : '0 XP',
                      valueColor: _shouldAwardXP ? _leagueColor : Theme.of(context).colorScheme.onSurfaceVariant,
                      icon: Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      title: '${localizations.currentLeague}:',
                      value: _currentLeague,
                      valueColor: _leagueColor,
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
                      value: '$_weeklyXP XP',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      title: '${localizations.leagueProgress}:',
                      value: '${(_leagueProgress * 100).round()}%',
                      valueColor: _leagueColor,
                      icon: Icons.timeline_rounded,
                    ),
                    if (xpToNextLeague > 0) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: '${localizations.toNextLeague} $nextLeague:',
                        value: '$xpToNextLeague XP',
                        valueColor: _leagueColor,
                        icon: Icons.flag_rounded,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Уведомление о награде
              if (_shouldAwardXP && _actualEarnedXP > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _leagueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _leagueColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _leagueColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: _leagueColor,
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
                                color: _leagueColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${localizations.youEarnedXP} ${_actualEarnedXP} XP ${localizations.forTestCompletion}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _leagueColor.withOpacity(0.8),
                              ),
                            ),
                            if (hasLeagueChanged)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Поздравляем! Вы достигли новой лиги: $_targetLeague',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _leagueColor.withOpacity(0.8),
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

              const Spacer(),

              // Кнопка продолжения
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _animationCompleted ? () {
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