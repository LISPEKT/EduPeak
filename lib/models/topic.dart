// topic.dart
import 'question.dart';

class Topic {
  final String id;
  final String name;
  final String imageAsset;
  final String description;
  final String explanation;
  final List<Question> questions;
  final String paragraph; // Добавляем поле для параграфа

  const Topic({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.description,
    required this.explanation,
    required this.questions,
    this.paragraph = '', // По умолчанию пустая строка
  });

  @override
  String toString() => 'Topic(id: $id, name: $name, paragraph: $paragraph)';
}