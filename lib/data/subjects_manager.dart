// subjects_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subjects_data.dart';
import '../models/subject.dart';

class SubjectsManager with ChangeNotifier {
  Map<int, List<Subject>> _subjectsByGrade = {};
  BuildContext? _context;

  SubjectsManager();

  // Устанавливаем контекст когда он доступен
  void setContext(BuildContext context) {
    _context = context;
    _loadSubjects();
  }

  Map<int, List<Subject>> get subjectsByGrade => _subjectsByGrade;

  void _loadSubjects() {
    if (_context != null) {
      _subjectsByGrade = getSubjectsByGrade(_context!);
      notifyListeners();
    }
  }

  // Метод для обновления данных при смене языка
  void updateSubjectsForLanguage(BuildContext context) {
    _context = context;
    _loadSubjects();
  }

  List<Subject> getSubjectsForGrade(int grade) {
    return _subjectsByGrade[grade] ?? [];
  }

  List<String> getSubjectNamesForGrade(int grade) {
    return _subjectsByGrade[grade]?.map((s) {
      // Получаем локализованное название предмета
      final localizedNames = getLocalizedSubjectNames(_context!);
      return localizedNames[s.name] ?? s.name;
    }).toList() ?? [];
  }

  // Получаем предмет по имени (учитывая локализацию)
  Subject? getSubjectByName(String name, int grade) {
    final subjects = getSubjectsForGrade(grade);
    final localizedNames = getLocalizedSubjectNames(_context!);

    // Ищем по локализованному имени
    for (final subject in subjects) {
      final localizedName = localizedNames[subject.name] ?? subject.name;
      if (localizedName == name) {
        return subject;
      }
    }

    // Если не нашли по локализованному, ищем по оригинальному
    try {
      return subjects.firstWhere((s) => s.name == name);
    } catch (e) {
      return null; // Возвращаем null если не нашли
    }
  }

  // Получаем emoji для предмета
  String getSubjectEmoji(String subjectName) {
    return subjectEmojis[subjectName] ?? '📚';
  }

  // Получаем локализованное название конкретного предмета
  String getLocalizedSubjectName(String subjectName) {
    if (_context == null) return subjectName;
    final localizedNames = getLocalizedSubjectNames(_context!);
    return localizedNames[subjectName] ?? subjectName;
  }
}

// Реактивная функция для получения названий предметов
List<String> getReactiveSubjectNamesForGrade(BuildContext context, int grade) {
  final reactiveSubjects = getReactiveSubjectsByGrade(context);
  final localizedNames = getLocalizedSubjectNames(context);

  return reactiveSubjects[grade]?.map((s) {
    return localizedNames[s.name] ?? s.name;
  }).toList() ?? [];
}

// Emojis для предметов (глобальная переменная)
final Map<String, String> subjectEmojis = {
  'Русский язык': '📚',
  'Математика': '🔢',
  'Алгебра': '𝑥²',
  'Геометрия': '△',
  'Английский язык': '🔤',
  'Литература': '📖',
  'Биология': '🌿',
  'Физика': '⚡',
  'Химия': '🧪',
  'География': '🌍',
  'История': '🏛️',
  'Обществознание': '👥',
  'Информатика': '💻',
  'Статистика и вероятность': '📊',
};

final List<int> availableGrades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];