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
  const XPStatsScreen({Key? key}) : super(key: key);

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
      _updateFilteredData();
    } catch (e) {
      print('❌ Error loading XP data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateFilteredData() {
    if (_userStats == null) return;

    final now = DateTime.now();
    Map<DateTime, int> data = {};

    switch (_selectedPeriod) {
      case TimePeriod.week:
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final xp = _userStats!.getDailyXP(date);
          data[DateTime(date.year, date.month, date.day)] = xp;
        }
        break;
      case TimePeriod.month:
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
      if (data.isNotEmpty) {
        _maxXP = data.values.reduce((a, b) => a > b ? a : b);
        if (_maxXP < 100) _maxXP = 100;
      } else {
        _maxXP = 100;
      }
    });
  }

  List<Map<String, dynamic>> _prepareChartData() {
    final entries = _filteredData.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    final List<Map<String, dynamic>> data = [];
    for (final entry in entries) {
      final date = entry.key;
      final xp = entry.value;
      String label = '';
      String? subLabel = '';

      switch (_selectedPeriod) {
        case TimePeriod.week:
          label = DateFormat('E').format(date)[0];
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
      data.add({'date': date, 'xp': xp, 'label': label, 'subLabel': subLabel});
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final chartData = _prepareChartData();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Раздел', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                          Text('Статистика опыта', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTotalXPInfo(theme, isDark),
                      const SizedBox(height: 24),
                      _buildPeriodSelector(theme, isDark),
                      const SizedBox(height: 24),
                      _buildChart(chartData, theme, isDark),
                      const SizedBox(height: 24),
                      _buildStatistics(chartData, theme, isDark),
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

  Widget _buildTotalXPInfo(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.star_rounded, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Всего опыта', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                Text('$_totalXP XP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _totalXP > 10000 ? 1.0 : _totalXP / 10000,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 XP', style: TextStyle(fontSize: 10, color: theme.hintColor)),
                    Text('10000 XP', style: TextStyle(fontSize: 10, color: theme.hintColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodButton('7 дней', TimePeriod.week, 'Каждый день', theme, isDark),
          const SizedBox(width: 8),
          _buildPeriodButton('Месяц', TimePeriod.month, 'Каждая неделя', theme, isDark),
          const SizedBox(width: 8),
          _buildPeriodButton('Год', TimePeriod.year, 'Каждый месяц', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title, TimePeriod period, String subtitle, ThemeData theme, bool isDark) {
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : (isDark ? theme.cardColor : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : theme.hintColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chartData, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getTitleForPeriod(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 4),
          Text(_getSubtitleForPeriod(), style: TextStyle(fontSize: 12, color: theme.hintColor)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                final xp = data['xp'] as int;
                final label = data['label'] as String;
                final subLabel = data['subLabel'] as String?;
                final barHeight = _maxXP > 0 ? (xp / _maxXP) * 160 : 0;
                final height = barHeight > 4 ? barHeight : 4;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: xp > 0 ? Colors.blue : (isDark ? Colors.grey[800] : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8),
                        gradient: xp > 0
                            ? LinearGradient(
                          colors: [Colors.lightBlue, Colors.blue],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.hintColor)),
                    if (subLabel != null) Text(subLabel, style: TextStyle(fontSize: 9, color: theme.hintColor.withOpacity(0.7))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Map<String, dynamic>> chartData, ThemeData theme, bool isDark) {
    final activeDays = chartData.where((data) => data['xp'] as int > 0).length;
    final totalXPSum = chartData.fold(0, (sum, data) => sum + (data['xp'] as int));
    final average = activeDays > 0 ? (totalXPSum / activeDays).round() : 0;
    final maxDailyXP = chartData.fold(0, (max, data) => (data['xp'] as int) > max ? (data['xp'] as int) : max);
    final xpStats = _userStats?.getXpStatistics() ?? {};
    final last7DaysXP = xpStats['last7DaysXP'] ?? 0;
    final last30DaysXP = xpStats['last30DaysXP'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Статистика', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatItem('Активных дней', '$activeDays/${chartData.length}', Icons.calendar_today_rounded, Colors.green, theme, isDark),
              _buildStatItem('Всего XP', '$totalXPSum', Icons.star_rounded, Colors.blue, theme, isDark),
              _buildStatItem('Максимум', '$maxDailyXP XP', Icons.arrow_upward_rounded, Colors.orange, theme, isDark),
              _buildStatItem('Средний XP', '$average', Icons.timeline_rounded, Colors.purple, theme, isDark),
              if (_selectedPeriod == TimePeriod.week) _buildStatItem('Недельный XP', '$_currentWeeklyXP', Icons.weekend_rounded, Colors.amber, theme, isDark),
              if (_selectedPeriod == TimePeriod.month) _buildStatItem('За 7 дней', '$last7DaysXP', Icons.today_rounded, Colors.lightBlue, theme, isDark),
              if (_selectedPeriod == TimePeriod.year) _buildStatItem('За 30 дней', '$last30DaysXP', Icons.calendar_month_rounded, Colors.deepOrange, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.7) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week: return 'Опыт за 7 дней';
      case TimePeriod.month: return 'Опыт за 4 недели';
      case TimePeriod.year: return 'Опыт за 12 месяцев';
    }
  }

  String _getSubtitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week: return 'Каждый столбец — опыт за день';
      case TimePeriod.month: return 'Каждый столбец — опыт за неделю';
      case TimePeriod.year: return 'Каждый столбец — опыт за месяц';
    }
  }
}