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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'imageUrl': imageUrl,
      'category': category,
      'isRead': isRead,
    };
  }

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      isRead: map['isRead'],
    );
  }
}