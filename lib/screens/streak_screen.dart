import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization.dart';

enum TimePeriod {
  week,
  month,
  year,
}

class StreakScreen extends StatefulWidget {
  final Map<DateTime, int> dailyActivity;
  final int streakDays;

  const StreakScreen({
    Key? key,
    required this.dailyActivity,
    required this.streakDays,
  }) : super(key: key);

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  int _maxActivity = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Подготавливаем данные в зависимости от выбранного периода
    final chartData = _prepareChartData();
    _maxActivity = chartData.fold(0, (max, data) {
      final activity = data['activity'] as int;
      return activity > max ? activity : max;
    });

    // Вычисляем статистику
    final activeCount = chartData.where((data) => data['activity'] as int > 0).length;
    final totalTasks = chartData.fold(0, (sum, data) => sum + (data['activity'] as int));
    final average = activeCount > 0 ? (totalTasks / activeCount).round() : 0;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'График активности',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
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
            // Информация о стрике
            Container(
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
                            'Текущий стрик',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${widget.streakDays} дней',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: widget.streakDays / 30,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 дней',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '30 дней',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Переключатель периода
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodButton(
                    context,
                    '7 дней',
                    TimePeriod.week,
                    'Каждый день отдельно',
                  ),
                  _buildPeriodButton(
                    context,
                    'Месяц',
                    TimePeriod.month,
                    'Каждая неделя отдельно',
                  ),
                  _buildPeriodButton(
                    context,
                    'Год',
                    TimePeriod.year,
                    'Каждый месяц отдельно',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // График
            Container(
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

                  // Сам график - ИСПРАВЛЕННАЯ ВЕРСТКА
                  SizedBox(
                    height: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: chartData.map((data) {
                        final date = data['date'] as DateTime;
                        final activity = data['activity'] as int;
                        final label = data['label'] as String;
                        final subLabel = data['subLabel'] as String?;

                        // Вычисляем высоту столбца
                        final barHeight = _maxActivity > 0
                            ? (activity / _maxActivity) * 120
                            : 0;
                        final height = barHeight > 0 ? barHeight + 4 : 4;

                        return SizedBox(
                          width: 28,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Столбец
                              Container(
                                width: 20,
                                height: height.toDouble(),
                                decoration: BoxDecoration(
                                  color: activity > 0 ? Colors.orange : theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: activity > 0 ? LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.8),
                                      Colors.orange,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ) : null,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Основная метка
                              Text(
                                label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Дополнительная метка (если есть)
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              // Значение активности
                              const SizedBox(height: 2),
                              Text(
                                '$activity',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Легенда
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Выполнено задание',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Заданий не было',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Статистика
            Container(
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
                    'Статистика активности',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatItem(
                        context,
                        'Активных периодов',
                        '$activeCount/${chartData.length}',
                        Icons.calendar_today_rounded,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        context,
                        'Всего заданий',
                        '$totalTasks',
                        Icons.check_circle_rounded,
                        Colors.green,
                      ),
                      _buildStatItem(
                        context,
                        'Максимум за период',
                        '$_maxActivity',
                        Icons.arrow_upward_rounded,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        context,
                        'Среднее за активный период',
                        '$average',
                        Icons.timeline_rounded,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
      BuildContext context,
      String title,
      TimePeriod period,
      String subtitle,
      ) {
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

  List<Map<String, dynamic>> _prepareChartData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];

    switch (_selectedPeriod) {
      case TimePeriod.week:
      // 7 дней: каждый день отдельно
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayKey = DateTime(date.year, date.month, date.day);
          final activity = widget.dailyActivity[dayKey] ?? 0;

          data.add({
            'date': date,
            'activity': activity,
            'label': DateFormat('E').format(date)[0], // Пн, Вт и т.д.
            'subLabel': '${date.day}',
          });
        }
        break;

      case TimePeriod.month:
      // Месяц: каждая неделя отдельно (последние 4 недели)
        for (int i = 3; i >= 0; i--) {
          final startDate = now.subtract(Duration(days: i * 7 + 6));
          final endDate = now.subtract(Duration(days: i * 7));

          // Суммируем активность за неделю
          int weeklyActivity = 0;
          for (int day = 0; day < 7; day++) {
            final date = startDate.add(Duration(days: day));
            final dayKey = DateTime(date.year, date.month, date.day);
            weeklyActivity += widget.dailyActivity[dayKey] ?? 0;
          }

          data.add({
            'date': endDate,
            'activity': weeklyActivity,
            'label': 'Н${i + 1}',
            'subLabel': '${startDate.day}.${startDate.month}',
          });
        }
        break;

      case TimePeriod.year:
      // Год: каждый месяц отдельно (последние 12 месяцев)
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);

          // Суммируем активность за месяц
          int monthlyActivity = 0;
          final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

          for (int day = 1; day <= daysInMonth; day++) {
            final date = DateTime(monthDate.year, monthDate.month, day);
            final dayKey = DateTime(date.year, date.month, date.day);
            monthlyActivity += widget.dailyActivity[dayKey] ?? 0;
          }

          data.add({
            'date': monthDate,
            'activity': monthlyActivity,
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
        return 'Активность за 7 дней';
      case TimePeriod.month:
        return 'Активность за месяц';
      case TimePeriod.year:
        return 'Активность за год';
    }
  }

  String _getSubtitleForPeriod() {
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return 'Каждый столбец показывает активность за один день';
      case TimePeriod.month:
        return 'Каждый столбец показывает активность за неделю';
      case TimePeriod.year:
        return 'Каждый столбец показывает активность за месяц';
    }
  }

  Widget _buildStatItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
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
                  maxLines: 2,
                ),
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
}