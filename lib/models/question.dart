// question.dart
class Question {
  final String text;
  final List<String> options;
  final dynamic correctIndex; // int для одного варианта, List<int> для нескольких
  final String explanation;
  final String answerType; // 'single_choice', 'multiple_choice', 'text'

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.answerType,
  });

  bool get isSingleChoice => answerType == 'single_choice';
  bool get isMultipleChoice => answerType == 'multiple_choice';
  bool get isTextAnswer => answerType == 'text';
}