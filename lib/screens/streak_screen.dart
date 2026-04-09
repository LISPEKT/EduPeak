// lib/screens/streak_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization.dart';

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
  late DateTime _currentMonth;
  int _selectedYear = 0;
  int _selectedMonth = 0;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedYear = _currentMonth.year;
    _selectedMonth = _currentMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Статистика
    final totalActiveDays = widget.dailyActivity.values.where((v) => v > 0).length;
    final totalDays = widget.dailyActivity.length;
    final bestStreak = _calculateBestStreak();
    final currentStreak = widget.streakDays;

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
              _buildHeader(theme, isDark, primaryColor),
              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Карточка стрика
                      _buildStreakCard(theme, isDark, currentStreak),
                      const SizedBox(height: 24),
                      // Статистика - три одинаковые плашки
                      _buildStatsRow(theme, isDark, totalActiveDays, totalDays, bestStreak),
                      const SizedBox(height: 24),
                      // Календарь
                      _buildCalendar(theme, isDark, primaryColor),
                      const SizedBox(height: 24),
                      // Легенда
                      _buildLegend(theme, isDark),
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

  Widget _buildHeader(ThemeData theme, bool isDark, Color primaryColor) {
    return Padding(
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
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
                Text(
                  'Раздел',
                  style: TextStyle(fontSize: 14, color: theme.hintColor),
                ),
                Text(
                  'Календарь активности',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme, bool isDark, int streakDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Текущий стрик',
                  style: TextStyle(fontSize: 14, color: theme.hintColor),
                ),
                Text(
                  '$streakDays ${_getDaysWord(streakDays)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: streakDays / 30,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 дней',
                      style: TextStyle(fontSize: 10, color: theme.hintColor),
                    ),
                    Text(
                      '30 дней',
                      style: TextStyle(fontSize: 10, color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      ThemeData theme,
      bool isDark,
      int totalActiveDays,
      int totalDays,
      int bestStreak,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            'Активных дней',
            '$totalActiveDays',
            Icons.check_circle_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            'Всего дней',
            '$totalDays',
            Icons.calendar_today_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            'Рекордный стрик',
            '$bestStreak ${_getDaysWord(bestStreak)}',
            Icons.emoji_events_rounded,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      ThemeData theme,
      bool isDark,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      height: 120, // Фиксированная высота для всех карточек
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: theme.hintColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, bool isDark, Color primaryColor) {
    // Получаем первый день месяца
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);

    // Получаем день недели первого дня (1 - понедельник, 7 - воскресенье)
    int firstWeekday = firstDayOfMonth.weekday;
    // Преобразуем в формат где понедельник = 0
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    // Получаем количество дней в месяце
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    // Строим сетку дней
    final List<DateTime?> days = [];
    // Пустые ячейки в начале
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    // Дни месяца
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(_selectedYear, _selectedMonth, day));
    }

    // Названия дней недели
    final weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    // Форматируем название месяца в именительном падеже
    String getMonthName(int month, int year) {
      final date = DateTime(year, month, 15);
      final formatter = DateFormat('LLLL', 'ru');
      return formatter.format(date);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Заголовок с навигацией по месяцам
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: primaryColor),
                onPressed: () {
                  setState(() {
                    if (_selectedMonth == 1) {
                      _selectedMonth = 12;
                      _selectedYear--;
                    } else {
                      _selectedMonth--;
                    }
                  });
                },
              ),
              Text(
                getMonthName(_selectedMonth, _selectedYear),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: primaryColor),
                onPressed: () {
                  setState(() {
                    if (_selectedMonth == 12) {
                      _selectedMonth = 1;
                      _selectedYear++;
                    } else {
                      _selectedMonth++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Дни недели
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  weekDays[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Календарь
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) {
                return Container();
              }

              final isActive = _isDayActive(date);
              final isToday = _isToday(date);
              final dayNumber = date.day;

              return GestureDetector(
                onTap: () {
                  _showDayDetails(date, isActive);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.orange
                        : (isDark ? theme.cardColor : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(color: primaryColor, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[700]),
                          ),
                        ),
                        if (isActive)
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.hintColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
              'Активный день',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Неактивный день',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(DateTime date, bool isActive) {
    final activityCount = widget.dailyActivity[DateTime(date.year, date.month, date.day)] ?? 0;

    // Форматируем дату с правильным падежом
    String getFormattedDate(DateTime date) {
      final day = date.day;
      final month = DateFormat('LLLL', 'ru').format(date);
      final year = date.year;
      return '$day $month $year';
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 48,
                color: isActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                getFormattedDate(date),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isActive
                    ? 'Вы были активны в этот день'
                    : 'В этот день активности не было',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.hintColor,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Выполнено заданий: $activityCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Закрыть'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isDayActive(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return (widget.dailyActivity[key] ?? 0) > 0;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _calculateBestStreak() {
    if (widget.dailyActivity.isEmpty) return 0;

    final sortedDates = widget.dailyActivity.keys.toList()
      ..sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (widget.dailyActivity[date] == 0) {
        currentStreak = 0;
        continue;
      }

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 1) {
          currentStreak++;
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }

      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      lastDate = date;
    }

    return maxStreak;
  }

  String _getDaysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) return 'дня';
    return 'дней';
  }
}