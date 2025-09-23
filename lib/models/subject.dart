import 'topic.dart';

class Subject {
  final String name;
  final Map<int, List<Topic>> topicsByGrade;

  Subject({
    required this.name,
    required this.topicsByGrade,
  });
}