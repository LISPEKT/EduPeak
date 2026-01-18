import 'package:flutter/material.dart';
import '../localization.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  int _selectedNewsIndex = -1;

  List<NewsItem> _newsItems = [
    NewsItem(
      id: 1,
      title: 'Полная поддержка 2 языков в обновлении 0.42.1',
      description: 'Мы рады представить полную локализацию приложения! Теперь интерфейс доступен на английском и немецком языках. Смена языка доступна в настройках.',
      date: '18 января 2026',
      imageUrl: 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=Локализация+0.42.1',
      category: 'Обновления',
      isRead: false,
    ),
    NewsItem(
      id: 2,
      title: 'Добавлен экран новостей в обновлении 0.42.0',
      description: 'Мы рады сообщить о выходе обновления 0.42.0! Теперь в приложении появился новый раздел "Новости", где вы можете следить за всеми обновлениями и важными анонсами.',
      date: '18 января 2026',
      imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Обновление+0.42.0',
      category: 'Обновления',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openNewsDetail(int index) {
    setState(() {
      _selectedNewsIndex = index;
      // Помечаем новость как прочитанную при открытии
      if (index >= 0 && index < _newsItems.length) {
        _newsItems[index] = _newsItems[index].copyWith(isRead: true);
      }
    });
    _animationController.forward();
  }

  void _closeNewsDetail() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedNewsIndex = -1;
      });
    });
  }

  Widget _buildNewsCard(NewsItem news, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openNewsDetail(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Категория
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(news.category).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      news.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(news.category),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (!news.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      SizedBox(width: 8),
                      Text(
                        news.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Заголовок
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                news.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Краткое описание
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                news.description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.hintColor,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Кнопка "Подробнее"
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Подробнее',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
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

  Widget _buildNewsDetail() {
    if (_selectedNewsIndex == -1) return SizedBox.shrink();

    final news = _newsItems[_selectedNewsIndex];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с кнопкой закрытия
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded),
                      color: primaryColor,
                      onPressed: _closeNewsDetail,
                    ),
                  ),
                  Text(
                    'Новость',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(width: 44), // Для симметрии
                ],
              ),
            ),

            // Контент новости
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Категория и дата
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(news.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getCategoryColor(news.category).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            news.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(news.category),
                            ),
                          ),
                        ),
                        Text(
                          news.date,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Заголовок
                    Text(
                      news.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Изображение (заглушка)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: primaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.language_rounded,
                          size: 64,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Полное описание
                    Text(
                      news.id == 1
                          ? '${news.description}\n\nОбновление 0.42.1 принесло полную локализацию интерфейса приложения на два языка:\n\n• 🇺🇸 Английский\n• 🇩🇪 Немецкий\n\nКак сменить язык:\n1. Откройте настройки с экрана вашего профиля\n2. Пролистайте до раздела "Настройки языка"\n3. Выберите нужный язык из списка\n4. Приложение перезагрузится с новым языком\n\nЧто было локализовано:\n• Весь интерфейс приложения\n• Все экраны и меню\n• Тексты кнопок и подсказок\n• Сообщения об ошибках\n• Помощь и инструкции\n• Уведомления\n\nМы продолжаем работать над улучшением перевода и в будущем планируем добавить поддержку других популярных языков.\n\nЕсли вы заметили ошибки в переводе или у вас есть предложения по улучшению, пожалуйста, сообщите нам через раздел поддержки.'
                          : '${news.description}\n\nОбновление 0.42.0 принесло несколько важных изменений:\n\n• Новый раздел "Новости" - теперь вы всегда в курсе всех обновлений приложения\n• Улучшенный интерфейс главного экрана\n• Оптимизация производительности для более плавной работы\n• Исправлены мелкие ошибки и улучшена стабильность\n\nНовый экран новостей позволяет:\n• Следить за всеми обновлениями приложения\n• Узнавать о новых функциях первыми\n• Получать важные анонсы и объявления\n• Видеть историю всех изменений\n\nМы надеемся, что новое обновление понравится вам и сделает процесс обучения еще удобнее. Экран новостей доступен из главного меню и через вращающуюся плашку на главном экране.\n\nЕсли у вас есть предложения по улучшению или вы обнаружили ошибку, пожалуйста, сообщите нам через раздел поддержки в настройках приложения.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.titleMedium?.color,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Статус прочтения
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            news.isRead ? Icons.check_circle_rounded : Icons.info_rounded,
                            color: news.isRead ? Colors.green : primaryColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              news.isRead ? 'Вы прочитали эту новость' : 'Вы только что прочитали эту новость',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Обновления':
        return Color(0xFF3F51B5);
      case 'Новое':
        return Color(0xFF4CAF50);
      case 'Технологии':
        return Color(0xFF2196F3);
      case 'Развлечения':
        return Color(0xFF9C27B0);
      case 'Дизайн':
        return Color(0xFF607D8B);
      default:
        return Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            // Основной контент
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя панель
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Кнопка назад
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
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_rounded),
                            color: primaryColor,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Раздел',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.hintColor,
                                ),
                              ),
                              Text(
                                'Новости и обновления',
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
                  ),

                  // Статистика новостей
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.new_releases_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '${_newsItems.where((n) => !n.isRead).length} новых',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Всего: ${_newsItems.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Список новостей
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < _newsItems.length; i++)
                            _buildNewsCard(_newsItems[i], i),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Анимированная детальная новость
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * (1 - _cardAnimation.value)),
                  child: _buildNewsDetail(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NewsItem {
  final int id;
  final String title;
  final String description;
  final String date;
  final String imageUrl;
  final String category;
  final bool isRead;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.category,
    required this.isRead,
  });

  NewsItem copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? imageUrl,
    String? category,
    bool? isRead,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }
}