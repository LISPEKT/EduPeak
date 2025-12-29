// lib/screens/xp_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization.dart';
import '../data/user_data_storage.dart';

enum TimePeriod {
  week,
  month,
  year,
}

class XPStatsScreen extends StatefulWidget {
  final Map<DateTime, int>? dailyXP;

  const XPStatsScreen({
    Key? key,
    this.dailyXP,
  }) : super(key: key);

  @override
  State<XPStatsScreen> createState() => _XPStatsScreenState();
}

class _XPStatsScreenState extends State<XPStatsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  Map<DateTime, int> _dailyXP = {};
  int _maxXP = 0;
  int _totalXP = 0;
  int _weeklyXP = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadXPData();
  }

  Future<void> _loadXPData() async {
    try {
      final stats = await UserDataStorage.getUserStats();
      final statsOverview = await UserDataStorage.getUserStatsOverview();

      setState(() {
        _totalXP = stats.totalXP;
        _weeklyXP = stats.weeklyXP;
        _dailyXP = widget.dailyXP ?? _generateXPHistory();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading XP data: $e');
      setState(() {
        _totalXP = 0;
        _weeklyXP = 0;
        _dailyXP = {};
        _isLoading = false;
      });
    }
  }

  Map<DateTime, int> _generateXPHistory() {
    final today = DateTime.now();
    final history = <DateTime, int>{};

    // Простая генерация данных
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Случайные значения для демонстрации
      if (i % 3 == 0) {
        history[dateKey] = (50 + i * 10) % 200;
      }
    }

    // Сегодняшний день - текущий weeklyXP
    final todayKey = DateTime(today.year, today.month, today.day);
    history[todayKey] = _weeklyXP;

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final chartData = _prepareChartData();
    _maxXP = chartData.fold(0, (max, data) {
      final xp = data['xp'] as int;
      return xp > max ? xp : max;
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Статистика опыта'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка с общей информацией
            _buildTotalXPInfo(),
            const SizedBox(height: 24),

            // Переключатель периода
            _buildPeriodSelector(),
            const SizedBox(height: 24),

            // График
            _buildChart(chartData),
            const SizedBox(height: 24),

            // Статистика
            _buildStatistics(chartData),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalXPInfo() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Всего опыта',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$_totalXP XP',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _totalXP > 10000 ? 1.0 : _totalXP / 10000,
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 XP',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '10000 XP',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('7 дней', TimePeriod.week, 'Каждый день'),
          _buildPeriodButton('Месяц', TimePeriod.month, 'Каждая неделя'),
          _buildPeriodButton('Год', TimePeriod.year, 'Каждый месяц'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title, TimePeriod period, String subtitle) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chartData) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTitleForPeriod(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitleForPeriod(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Сам график
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                final xp = data['xp'] as int;
                final label = data['label'] as String;
                final subLabel = data['subLabel'] as String?;

                final barHeight = _maxXP > 0
                    ? (xp / _maxXP) * 160
                    : 0;
                final height = barHeight > 0 ? barHeight + 4 : 4;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: xp > 0 ? Colors.blue : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        gradient: xp > 0 ? LinearGradient(
                          colors: [
                            Colors.lightBlue.withOpacity(0.8),
                            Colors.blue,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ) : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Значение
                    Text(
                      '$xp',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Основная метка
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),

                    // Дополнительная метка
                    if (subLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Map<String, dynamic>> chartData) {
    final activeDays = chartData.where((data) => data['xp'] as int > 0).length;
    final totalXPSum = chartData.fold(0, (sum, data) => sum + (data['xp'] as int));
    final average = activeDays > 0 ? (totalXPSum / activeDays).round() : 0;
    final maxDailyXP = chartData.fold(0, (max, data) {
      final xp = data['xp'] as int;
      return xp > max ? xp : max;
    });

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatItem(
                'Активных дней',
                '$activeDays/${chartData.length}',
                Icons.calendar_today_rounded,
                Colors.green,
              ),
              _buildStatItem(
                'Всего XP',
                '$totalXPSum',
                Icons.star_rounded,
                Colors.blue,
              ),
              _buildStatItem(
                'Максимум',
                '$maxDailyXP XP',
                Icons.arrow_upward_rounded,
                Colors.orange,
              ),
              _buildStatItem(
                'Средний XP',
                '$average',
                Icons.timeline_rounded,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _prepareChartData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    switch (_selectedPeriod) {
      case TimePeriod.week:
      // 7 дней назад
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayKey = DateTime(date.year, date.month, date.day);
          final xp = _dailyXP[dayKey] ?? 0;

          data.add({
            'date': date,
            'xp': xp,
            'label': DateFormat('E').format(date)[0], // Пн, Вт и т.д.
            'subLabel': '${date.day}',
          });
        }
        break;

      case TimePeriod.month:
      // 4 недели назад
        for (int i = 3; i >= 0; i--) {
          final startDate = now.subtract(Duration(days: i * 7 + 6));
          final endDate = now.subtract(Duration(days: i * 7));

          // Суммируем XP за неделю
          int weeklyXP = 0;
          for (int day = 0; day < 7; day++) {
            final date = startDate.add(Duration(days: day));
            final dayKey = DateTime(date.year, date.month, date.day);
            weeklyXP += _dailyXP[dayKey] ?? 0;
          }

          data.add({
            'date': endDate,
            'xp': weeklyXP,
            'label': 'Н${i + 1}',
            'subLabel': '${startDate.day}.${startDate.month}',
          });
        }
        break;

      case TimePeriod.year:
      // 12 месяцев назад
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);

          // Суммируем XP за месяц
          int monthlyXP = 0;
          final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

          for (int day = 1; day <= daysInMonth; day++) {
            final date = DateTime(monthDate.year, monthDate.month, day);
            final dayKey = DateTime(date.year, date.month, date.day);
            monthlyXP += _dailyXP[dayKey] ?? 0;
          }

          data.add({
            'date': monthDate,
            'xp': monthlyXP,
            'label': DateFormat('MMM').format(monthDate),
            'subLabel': '${monthDate.year}',
          });
        }
        break;
    }

    return data;
  }

  String _getTitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'Опыт за 7 дней';
      case TimePeriod.month:
        return 'Опыт за месяц';
      case TimePeriod.year:
        return 'Опыт за год';
    }
  }

  String _getSubtitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'Каждый столбец показывает опыт за один день';
      case TimePeriod.month:
        return 'Каждый столбец показывает опыт за неделю';
      case TimePeriod.year:
        return 'Каждый столбец показывает опыт за месяц';
    }
  }
}