class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String answerType; // 'choice' or 'text'

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.answerType = 'choice',
  });
}