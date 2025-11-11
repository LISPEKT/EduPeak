// lib/models/review_item.dart
import '../models/topic.dart';

class ReviewItem {
  final dynamic question;
  final Topic topic;
  final String subject;
  final int grade;
  final int questionIndex;

  ReviewItem({
    required this.question,
    required this.topic,
    required this.subject,
    required this.grade,
    required this.questionIndex,
  });
}
