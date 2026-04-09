// lib/screens/news_screen.dart

import 'package:flutter/material.dart';
import '../localization.dart';
import '../services/api_service.dart';
import 'dart:async';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  int _selectedNewsIndex = -1;
  List<NewsItem> _newsItems = [];
  bool _isLoading = true;

  // Для хранения соотношений сторон изображений
  Map<int, double> _imageAspectRatios = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final newsFromServer = await ApiService.getNews();

      if (newsFromServer.isNotEmpty) {
        setState(() {
          _newsItems = newsFromServer.map((item) => NewsItem(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            content: item['content'] ?? item['description'],
            date: item['date'] ?? _formatDate(item['published_at']),
            imageUrl: item['image_url'] ?? '',
            category: item['category'] ?? 'Новости',
            isRead: false,
          )).toList();
        });

        // Загружаем соотношения сторон для изображений
        for (var news in _newsItems) {
          if (news.imageUrl.isNotEmpty) {
            _loadImageAspectRatio(news.id, news.imageUrl);
          }
        }
      }
    } catch (e) {
      print('Ошибка загрузки новостей: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImageAspectRatio(int newsId, String imageUrl) async {
    try {
      final completer = Completer<Size>();
      final image = Image.network(imageUrl);
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
          completer.complete(size);
        }, onError: (error, stackTrace) {
          completer.completeError(error);
        }),
      );

      final size = await completer.future;
      final aspectRatio = size.width / size.height;

      if (mounted) {
        setState(() {
          _imageAspectRatios[newsId] = aspectRatio;
        });
      }
    } catch (e) {
      print('Ошибка загрузки соотношения сторон для изображения $newsId: $e');
      // По умолчанию 16:9
      if (mounted) {
        setState(() {
          _imageAspectRatios[newsId] = 16 / 9;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openNewsDetail(int index) {
    setState(() {
      _selectedNewsIndex = index;
      _newsItems[index] = _newsItems[index].copyWith(isRead: true);
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
    final aspectRatio = _imageAspectRatios[news.id] ?? 16 / 9;

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
            // Изображение (если есть)
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.network(
                    news.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Категория и дата
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: news.imageUrl.isNotEmpty ? 12 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getCategoryColor(news.category).withOpacity(0.3)),
                    ),
                    child: Text(news.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _getCategoryColor(news.category))),
                  ),
                  Row(
                    children: [
                      if (!news.isRead)
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      SizedBox(width: 8),
                      Text(news.date, style: TextStyle(fontSize: 12, color: theme.hintColor)),
                    ],
                  ),
                ],
              ),
            ),

            // Заголовок
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(news.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),

            // Краткое описание
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(news.description, style: TextStyle(fontSize: 14, color: theme.hintColor, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            ),

            // Кнопка "Подробнее"
            Padding(
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
                            Text('Подробнее', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.primary)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: theme.colorScheme.primary),
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
    final aspectRatio = _imageAspectRatios[news.id] ?? 16 / 9;

    return Container(
      color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Верхняя панель
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: IconButton(icon: Icon(Icons.close_rounded), color: primaryColor, onPressed: _closeNewsDetail),
                  ),
                  Text('Новость', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                  SizedBox(width: 44),
                ],
              ),
            ),

            // Контент
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Изображение (если есть) с адаптивным соотношением сторон
                    if (news.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Image.network(
                            news.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    if (news.imageUrl.isNotEmpty) SizedBox(height: 20),

                    // Категория и дата
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(news.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getCategoryColor(news.category).withOpacity(0.3)),
                          ),
                          child: Text(news.category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _getCategoryColor(news.category))),
                        ),
                        Text(news.date, style: TextStyle(fontSize: 14, color: theme.hintColor)),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Заголовок
                    Text(news.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                    SizedBox(height: 24),

                    // Полный текст
                    Text(
                      news.content.isNotEmpty ? news.content : news.description,
                      style: TextStyle(fontSize: 16, color: theme.textTheme.titleMedium?.color, height: 1.6),
                    ),
                    SizedBox(height: 32),

                    // Статус прочтения
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(news.isRead ? Icons.check_circle_rounded : Icons.info_rounded, color: news.isRead ? Colors.green : primaryColor),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              news.isRead ? 'Вы прочитали эту новость' : 'Вы только что прочитали эту новость',
                              style: TextStyle(fontSize: 14, color: theme.textTheme.titleMedium?.color),
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
      case 'Обновления': return Color(0xFF3F51B5);
      case 'Новое': return Color(0xFF4CAF50);
      case 'Технологии': return Color(0xFF2196F3);
      case 'Развлечения': return Color(0xFF9C27B0);
      case 'Дизайн': return Color(0xFF607D8B);
      default: return Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: IconButton(icon: Icon(Icons.arrow_back_rounded), color: primaryColor, onPressed: () => Navigator.pop(context)),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Раздел', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                              Text('Новости и обновления', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Icon(Icons.new_releases_rounded, size: 16, color: primaryColor),
                              SizedBox(width: 6),
                              Text('${_newsItems.where((n) => !n.isRead).length} новых', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Text('Всего: ${_newsItems.length}', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _newsItems.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.newspaper_rounded, size: 64, color: theme.hintColor),
                          SizedBox(height: 16),
                          Text('Нет новостей', style: TextStyle(color: theme.hintColor)),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: _newsItems.length,
                      itemBuilder: (context, index) {
                        return _buildNewsCard(_newsItems[index], index);
                      },
                    ),
                  ),
                ],
              ),
            ),
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
  final String content;
  final String date;
  final String imageUrl;
  final String category;
  final bool isRead;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.date,
    required this.imageUrl,
    required this.category,
    required this.isRead,
  });

  NewsItem copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? date,
    String? imageUrl,
    String? category,
    bool? isRead,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }
}