import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_test',
      name: 'Первый шаг',
      description: 'Пройдите первый тест',
      imageAsset: '🎯',
      requiredValue: 1,
      currentValue: 1,
      type: AchievementType.testsCompleted,
    ),
    Achievement(
      id: 'test_master',
      name: 'Мастер тестов',
      description: 'Пройдите 10 тестов',
      imageAsset: '📚',
      requiredValue: 10,
      currentValue: 3,
      type: AchievementType.testsCompleted,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Неделя силы',
      description: 'Занимайтесь 7 дней подряд',
      imageAsset: '🔥',
      requiredValue: 7,
      currentValue: 2,
      type: AchievementType.streakDays,
    ),
    Achievement(
      id: 'perfectionist',
      name: 'Перфекционист',
      description: 'Получите 100% в тесте',
      imageAsset: '⭐',
      requiredValue: 1,
      currentValue: 0,
      type: AchievementType.perfectTests,
    ),
    Achievement(
      id: 'subject_master',
      name: 'Эксперт предмета',
      description: 'Завершите все темы по предмету',
      imageAsset: '🎓',
      requiredValue: 1,
      currentValue: 0,
      type: AchievementType.subjectsCompleted,
    ),
    Achievement(
      id: 'fast_learner',
      name: 'Быстрый ученик',
      description: 'Пройдите 5 тестов за один день',
      imageAsset: '⚡',
      requiredValue: 5,
      currentValue: 2,
      type: AchievementType.testsInOneDay,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _achievements.where((a) => a.currentValue >= a.requiredValue).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Достижения'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Статистика достижений
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
                  total: _achievements.length,
                  label: 'Получено',
                  color: Theme.of(context).primaryColor,
                ),
                _StatItem(
                  count: _achievements.length - completedCount,
                  total: _achievements.length,
                  label: 'Осталось',
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Прогресс бар
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Общий прогресс',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${((completedCount / _achievements.length) * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completedCount / _achievements.length,
                  backgroundColor: Colors.grey[300],
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Сетка достижений
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
                  final isCompleted = achievement.currentValue >= achievement.requiredValue;

                  return _AchievementCard(
                    achievement: achievement,
                    isCompleted: isCompleted,
                  );
                },
              ),
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

  const _StatItem({
    required this.count,
    required this.total,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
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
  final bool isCompleted;

  const _AchievementCard({
    required this.achievement,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Фон для завершенных
          if (isCompleted) ...[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ],

          // Основной контент
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
              crossAxisAlignment: CrossAxisAlignment.center, // Центрируем по горизонтали
              children: [
                // Иконка достижения
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    child: Center( // Центрируем иконку
                      child: Text(
                        achievement.imageAsset,
                        style: TextStyle(
                          fontSize: 42, // Немного уменьшил для лучшей центровки
                          color: isCompleted
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Название достижения
                Container(
                  width: double.infinity, // Занимает всю ширину
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    achievement.name,
                    textAlign: TextAlign.center, // Центрируем текст
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Описание как получить
                Container(
                  width: double.infinity, // Занимает всю ширину
                  margin: const EdgeInsets.only(top: 6),
                  child: Text(
                    achievement.description,
                    textAlign: TextAlign.center, // Центрируем текст
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isCompleted
                          ? Theme.of(context).primaryColor.withOpacity(0.8)
                          : Colors.grey[600],
                      fontSize: 10,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Прогресс для незавершенных
          if (!isCompleted) ...[
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

          // Галочка для завершенных
          if (isCompleted) ...[
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
}

enum AchievementType {
  testsCompleted,
  streakDays,
  perfectTests,
  subjectsCompleted,
  testsInOneDay,
  subjectTests,
}