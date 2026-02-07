// lib/screens/xp_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/user_data_storage.dart';
import '../models/user_stats.dart';

enum TimePeriod {
  week,
  month,
  year,
}

class XPStatsScreen extends StatefulWidget {
  const XPStatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<XPStatsScreen> createState() => _XPStatsScreenState();
}

class _XPStatsScreenState extends State<XPStatsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  Map<DateTime, int> _filteredData = {};
  int _maxXP = 0;
  int _totalXP = 0;
  int _currentWeeklyXP = 0;
  bool _isLoading = true;
  UserStats? _userStats;

  @override
  void initState() {
    super.initState();
    _loadXPData();
  }

  Future<void> _loadXPData() async {
    try {
      _userStats = await UserDataStorage.getUserStats();
      setState(() {
        _totalXP = _userStats!.totalXP;
        _currentWeeklyXP = _userStats!.weeklyXP;
        _isLoading = false;
      });

      // Обновляем отфильтрованные данные
      _updateFilteredData();
    } catch (e) {
      print('❌ Error loading XP data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateFilteredData() {
    if (_userStats == null) return;

    final now = DateTime.now();
    Map<DateTime, int> data = {};

    switch (_selectedPeriod) {
      case TimePeriod.week:
      // 7 последних дней
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final xp = _userStats!.getDailyXP(date);
          data[DateTime(date.year, date.month, date.day)] = xp;
        }
        break;

      case TimePeriod.month:
      // 4 последние недели
        final today = DateTime.now();
        for (int week = 0; week < 4; week++) {
          final weekStart = today.subtract(Duration(days: week * 7 + 6));
          final weekEnd = today.subtract(Duration(days: week * 7));

          int weeklyXP = 0;
          for (int day = 0; day < 7; day++) {
            final date = weekStart.add(Duration(days: day));
            weeklyXP += _userStats!.getDailyXP(date);
          }
          data[DateTime(weekEnd.year, weekEnd.month, weekEnd.day)] = weeklyXP;
        }
        break;

      case TimePeriod.year:
      // 12 последних месяцев
        final today = DateTime.now();
        for (int month = 0; month < 12; month++) {
          final monthDate = DateTime(today.year, today.month - month, 1);
          final monthlyXP = _userStats!.getMonthlyXP(forDate: monthDate);
          data[DateTime(monthDate.year, monthDate.month, monthDate.day)] = monthlyXP;
        }
        break;
    }

    setState(() {
      _filteredData = data;
      // Находим максимальное значение для масштабирования графика
      if (data.isNotEmpty) {
        _maxXP = data.values.reduce((a, b) => a > b ? a : b);
        // Минимальная высота 100 для лучшей визуализации
        if (_maxXP < 100) _maxXP = 100;
      } else {
        _maxXP = 100;
      }
    });
  }

  List<Map<String, dynamic>> _prepareChartData() {
    final entries = _filteredData.entries.toList();
    // Сортируем по дате
    entries.sort((a, b) => a.key.compareTo(b.key));

    final List<Map<String, dynamic>> data = [];

    for (final entry in entries) {
      final date = entry.key;
      final xp = entry.value;

      String label = '';
      String? subLabel = '';

      switch (_selectedPeriod) {
        case TimePeriod.week:
          label = DateFormat('E').format(date)[0]; // Пн, Вт и т.д.
          subLabel = '${date.day}';
          break;
        case TimePeriod.month:
          final weekNumber = entries.indexOf(entry) + 1;
          label = 'Н$weekNumber';
          subLabel = '${date.day}.${date.month}';
          break;
        case TimePeriod.year:
          label = DateFormat('MMM').format(date);
          subLabel = '${date.year}';
          break;
      }

      data.add({
        'date': date,
        'xp': xp,
        'label': label,
        'subLabel': subLabel,
      });
    }

    return data;
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
            // Карточка с общей информацией - ТОЛЬКО ОПЫТ
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
            _updateFilteredData();
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
                final height = barHeight > 4 ? barHeight : 4;

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
                    if (subLabel != null && subLabel.isNotEmpty) ...[
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

    // Получаем дополнительные статистики
    final xpStats = _userStats?.getXpStatistics() ?? {};
    final last7DaysXP = xpStats['last7DaysXP'] ?? 0;
    final last30DaysXP = xpStats['last30DaysXP'] ?? 0;

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
              if (_selectedPeriod == TimePeriod.week)
                _buildStatItem(
                  'Недельный XP',
                  '$_currentWeeklyXP',
                  Icons.weekend_rounded,
                  Colors.amber,
                ),
              if (_selectedPeriod == TimePeriod.month)
                _buildStatItem(
                  'За 7 дней',
                  '$last7DaysXP',
                  Icons.today_rounded,
                  Colors.lightBlue,
                ),
              if (_selectedPeriod == TimePeriod.year)
                _buildStatItem(
                  'За 30 дней',
                  '$last30DaysXP',
                  Icons.calendar_month_rounded,
                  Colors.deepOrange,
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

  String _getTitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'Опыт за 7 дней';
      case TimePeriod.month:
        return 'Опыт за 4 недели';
      case TimePeriod.year:
        return 'Опыт за 12 месяцев';
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