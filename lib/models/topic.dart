import 'question.dart';

class Topic {
  final String id;
  final String name;
  final String imageAsset;
  final String description;
  final String explanation;
  final List<Question> questions;
  final String paragraph;

  const Topic({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.description,
    required this.explanation,
    required this.questions,
    this.paragraph = '',
  });

  // Метод для получения количества вопросов
  int get questionCount => questions.length;

  // Метод для проверки, пройдена ли тема на 100%
  bool isCompleted(int correctAnswers) {
    return questions.isNotEmpty && correctAnswers >= questions.length;
  }

  // Метод для расчета процента выполнения
  double getCompletionPercentage(int correctAnswers) {
    if (questions.isEmpty) return 0.0;
    return (correctAnswers / questions.length).clamp(0.0, 1.0);
  }

  // Метод для получения XP за прохождение
  int calculateXP(int correctAnswers) {
    final percentage = getCompletionPercentage(correctAnswers);

    if (percentage == 1.0) {
      // 100% - максимальная награда
      return 100 + (questions.length * 10);
    } else if (percentage >= 0.8) {
      return 80 + (questions.length * 8);
    } else if (percentage >= 0.6) {
      return 60 + (questions.length * 6);
    } else {
      return 40 + (questions.length * 4);
    }
  }

  @override
  String toString() => 'Topic(id: $id, name: $name, paragraph: $paragraph, questions: ${questions.length})';
}