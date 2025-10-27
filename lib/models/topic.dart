import 'question.dart';

class Topic {
  final String id; // Добавляем уникальный ID
  final String name;
  final String imageAsset;
  final String description;
  final String explanation;
  final List<Question> questions;

  const Topic({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.description,
    required this.explanation,
    required this.questions,
  });

  @override
  String toString() => 'Topic(id: $id, name: $name)';
}