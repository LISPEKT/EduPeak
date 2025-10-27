import 'package:flutter/material.dart';
import '../data/user_data_storage.dart';

class XPScreen extends StatefulWidget {
  final int earnedXP;
  final int questionsCount;

  const XPScreen({
    Key? key,
    required this.earnedXP,
    required this.questionsCount,
  }) : super(key: key);

  @override
  State<XPScreen> createState() => _XPScreenState();
}

class _XPScreenState extends State<XPScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _progressAnimation;
  int _displayXP = 0;
  int _totalXP = 0;
  int _weeklyXP = 0;
  String _currentLeague = 'Бронза';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  Future<void> _loadUserData() async {
    final stats = await UserDataStorage.getUserStats();
    setState(() {
      _totalXP = stats.totalXP;
      _weeklyXP = stats.weeklyXP;
      _currentLeague = stats.getCurrentLeague();
      _progressValue = (_totalXP % 100) / 100;
    });
  }

  Future<void> _startAnimation() async {
    // Ждем немного перед началом анимации
    await Future.delayed(const Duration(milliseconds: 300));

    // Запускаем анимации
    await _controller.forward();

    // Анимация прибавления XP
    for (int i = 0; i <= widget.earnedXP; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _displayXP = i;
        });
      }
    }

    // Сохраняем новый опыт
    await _saveXP();

    // Обновляем данные
    await _loadUserData();
  }

  Future<void> _saveXP() async {
    await UserDataStorage.addUserXP(widget.earnedXP);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leagueColor = _getLeagueColor(_currentLeague);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Опыт получен!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Круговая шкала прогресса с анимацией
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value * _progressValue,
                      strokeWidth: 12,
                      color: leagueColor,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _animation.value * 0.1,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$_displayXP',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: leagueColor,
                          ),
                        ),
                        Text(
                          'XP',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentLeague,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: leagueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Информация
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      title: 'Пройдено вопросов:',
                      value: '${widget.questionsCount}',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      title: 'Получено опыта:',
                      value: '+${widget.earnedXP} XP',
                      valueColor: leagueColor,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      title: 'Текущая лига:',
                      value: _currentLeague,
                      valueColor: leagueColor,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      title: 'Общий опыт:',
                      value: '$_totalXP XP',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      title: 'Недельный опыт:',
                      value: '$_weeklyXP XP',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Продолжить',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  const _InfoRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}