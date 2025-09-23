import 'question.dart';

class Topic {
  final String name;
  final String imageAsset;
  final String description;
  final String explanation;
  final List<Question> questions;

  Topic({
    required this.name,
    required this.imageAsset,
    required this.description,
    required this.explanation,
    required this.questions,
  });
}