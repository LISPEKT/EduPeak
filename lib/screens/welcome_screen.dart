import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      icon: Icons.school_rounded,
      title: 'EduPeak',
      description: 'Ваш персональный помощник в обучении. Достигайте новых высот вместе с нами!',
      color: const Color(0xFF4CAF50),
    ),
    WelcomePageData(
      icon: Icons.library_books_rounded,
      title: 'Множество предметов',
      description: 'Математика, физика, история, языки и многое другое. Выберите то, что хотите изучать.',
      color: const Color(0xFF2196F3),
    ),
    WelcomePageData(
      icon: Icons.trending_up_rounded,
      title: 'Отслеживайте прогресс',
      description: 'Подробная статистика, XP и уровни. Следите за своими достижениями.',
      color: const Color(0xFFFF9800),
    ),
    WelcomePageData(
      icon: Icons.emoji_events_rounded,
      title: 'Соревнуйтесь',
      description: 'Вступайте в лиги, зарабатывайте очки и поднимайтесь по таблице лидеров!',
      color: const Color(0xFFE91E63),
    ),
    WelcomePageData(
      icon: Icons.star_rounded,
      title: 'EduPeak +',
      description: 'Расширенные возможности для максимального результата в обучении.',
      color: const Color(0xFF9C27B0),
      isPremium: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthSelectionScreen()),
      );
    }
  }

  Future<void> _next() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPageData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка пропустить
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Пропустить',
                  style: TextStyle(
                    color: currentPageData.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Карусель
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], isDark, theme);
                },
              ),
            ),

            // Индикаторы и кнопка
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Точки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Кнопка с плавной сменой цвета
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPageData.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Начать'
                            : 'Далее',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPage(WelcomePageData page, bool isDark, ThemeData theme) {
    if (page.isPremium) {
      // Экран подписки
      return _buildSubscriptionPage(isDark, theme, page);
    }

    // Обычные страницы
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Иконка
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          // Заголовок
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          // Описание
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.hintColor,
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPage(bool isDark, ThemeData theme, WelcomePageData page) {
    final primaryColor = page.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Иконка премиум
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: primaryColor,
              size: 60,
            ),
          ),

          const SizedBox(height: 24),

          // Заголовок EduPeak +
          Text(
            'EduPeak +',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 8),

          // Цена
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '299₽ / месяц',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Все преимущества в одном контейнере
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Что входит в подписку:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.offline_bolt_rounded,
                  title: 'Офлайн режим',
                  description: 'Занимайтесь без интернета',
                  color: Colors.blue,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.analytics_rounded,
                  title: 'Расширенная статистика',
                  description: 'Детальная аналитика прогресса',
                  color: Colors.green,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.palette_rounded,
                  title: 'Эксклюзивные темы',
                  description: 'Уникальный дизайн приложения',
                  color: Colors.purple,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Приоритетная поддержка',
                  description: 'Быстрые ответы на вопросы',
                  color: Colors.orange,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.ads_click_rounded,
                  title: 'Без рекламы',
                  description: 'Фокус на обучении',
                  color: Colors.red,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.cloud_download_rounded,
                  title: 'Расширенные материалы',
                  description: 'Дополнительные ресурсы',
                  color: Colors.teal,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    final color = _pages[_currentPage].color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class WelcomePageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isPremium;

  WelcomePageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isPremium = false,
  });
}