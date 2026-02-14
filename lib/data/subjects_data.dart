// lib/data/subjects_data.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'social_studies/social_studies_data.dart';
import 'history/history_data.dart';
import '../models/subject.dart';
import '../services/region_manager.dart';
import '../language_manager.dart';

// Основные данные предметов с поддержкой регионов и языков
Map<int, List<Subject>> getSubjectsByGrade(BuildContext context) {
  try {
    final regionManager = Provider.of<RegionManager>(context, listen: false);
    final regionId = regionManager.currentRegion.id;

    // Базовые данные для всех регионов
    Map<int, List<Subject>> baseData = {
      1: _getGrade1Subjects(context, regionId),
      2: _getGrade2Subjects(context, regionId),
      3: _getGrade3Subjects(context, regionId),
      4: _getGrade4Subjects(context, regionId),
      5: _getGrade5Subjects(context, regionId),
      6: _getGrade6Subjects(context, regionId),
      7: _getGrade7Subjects(context, regionId),
      8: _getGrade8Subjects(context, regionId),
      9: _getGrade9Subjects(context, regionId),
      10: _getGrade10Subjects(context, regionId),
      11: _getGrade11Subjects(context, regionId),
    };

    // Добавляем 12 класс для регионов, где он есть (например, Литва)
    if (regionManager.currentRegion.totalGrades >= 12) {
      baseData[12] = _getGrade12Subjects(context, regionId);
    }

    // Загружаем специализированные данные для истории и обществознания
    _loadSpecializedSubjects(context, baseData);

    return baseData;
  } catch (e) {
    print('⚠️ Error getting subjects by grade: $e');
    return _getFallbackSubjects();
  }
}

// Метод для загрузки специализированных предметов (история, обществознание)
void _loadSpecializedSubjects(BuildContext context, Map<int, List<Subject>> baseData) {
  try {
    // Загружаем историю для классов 5-12
    for (int grade = 5; grade <= 12; grade++) {
      if (baseData.containsKey(grade)) {
        final historySubjects = HistoryData.getHistorySubjects(context, grade);

        // Обновляем предмет "История" в базовых данных
        for (final subject in baseData[grade]!) {
          if (subject.name == 'История' && historySubjects.isNotEmpty) {
            // Находим соответствующий предмет истории
            for (final historySubject in historySubjects) {
              if (historySubject.name == 'История' && historySubject.topicsByGrade[grade] != null) {
                // Обновляем темы
                subject.topicsByGrade[grade] = List.from(historySubject.topicsByGrade[grade]!);
                print('✅ Loaded history topics for grade $grade: ${subject.topicsByGrade[grade]?.length} topics');
                break;
              }
            }
          }
        }
      }
    }

    // Загружаем обществознание для классов 6-11
    for (int grade = 6; grade <= 11; grade++) {
      if (baseData.containsKey(grade)) {
        final socialStudiesSubjects = SocialStudiesData.getSocialStudiesSubjects(context, grade);

        // Обновляем предмет "Обществознание" в базовых данных
        for (final subject in baseData[grade]!) {
          if (subject.name == 'Обществознание' && socialStudiesSubjects.isNotEmpty) {
            // Находим соответствующий предмет обществознания
            for (final socialSubject in socialStudiesSubjects) {
              if (socialSubject.name == 'Обществознание' && socialSubject.topicsByGrade[grade] != null) {
                // Обновляем темы
                subject.topicsByGrade[grade] = List.from(socialSubject.topicsByGrade[grade]!);
                print('✅ Loaded social studies topics for grade $grade: ${subject.topicsByGrade[grade]?.length} topics');
                break;
              }
            }
          }
        }
      }
    }
  } catch (e) {
    print('⚠️ Error loading specialized subjects: $e');
  }
}

// Методы для каждого класса с учетом региона
List<Subject> _getGrade1Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 1);
  return subjects;
}

List<Subject> _getGrade2Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 2);
  return subjects;
}

List<Subject> _getGrade3Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 3);
  return subjects;
}

List<Subject> _getGrade4Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 4);
  return subjects;
}

List<Subject> _getGrade5Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 5);
  return subjects;
}

List<Subject> _getGrade6Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 6);
  return subjects;
}

List<Subject> _getGrade7Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 7);
  return subjects;
}

List<Subject> _getGrade8Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 8);
  return subjects;
}

List<Subject> _getGrade9Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 9);
  return subjects;
}

List<Subject> _getGrade10Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 10);
  return subjects;
}

List<Subject> _getGrade11Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 11);
  return subjects;
}

List<Subject> _getGrade12Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];
  _addRegionalSubjects(subjects, context, regionId, 12);
  return subjects;
}

// Добавление региональных предметов
void _addRegionalSubjects(List<Subject> subjects, BuildContext context, String regionId, int grade) {
  switch (regionId) {
    case 'ru': // Россия
      _addRussianSubjects(subjects, grade);
      break;
    case 'lt': // Литва
      _addLithuanianSubjects(subjects, grade);
      break;
    case 'kz': // Казахстан
      _addKazakhSubjects(subjects, grade);
      break;
    case 'vn': // Вьетнам
      _addVietnameseSubjects(subjects, grade);
      break;
    default:
      _addRussianSubjects(subjects, grade); // По умолчанию русские предметы
  }
}

// Российские предметы
void _addRussianSubjects(List<Subject> subjects, int grade) {
  // Базовые предметы для России
  if (grade >= 1 && grade <= 4) {
    subjects.add(Subject(
      name: 'Русский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Математика',
      topicsByGrade: {grade: []},
    ));
    if (grade >= 2) {
      subjects.add(Subject(
        name: 'Английский язык',
        topicsByGrade: {grade: []},
      ));
    }
  } else if (grade >= 5 && grade <= 6) {
    subjects.add(Subject(
      name: 'Русский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Математика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Английский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'История',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'География',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Биология',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Литература',
      topicsByGrade: {grade: []},
    ));
    // Убираем Обществознание для 5-6 классов
    // subjects.add(Subject(
    //   name: 'Обществознание',
    //   topicsByGrade: {grade: []},
    // ));
  } else if (grade >= 7 && grade <= 9) {
    subjects.add(Subject(
      name: 'Русский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Алгебра',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Геометрия',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Английский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'История',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'География',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Биология',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Физика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Химия',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Литература',
      topicsByGrade: {grade: []},
    ));
    // Добавляем Обществознание только с 8 класса
    if (grade >= 8) {
      subjects.add(Subject(
        name: 'Обществознание',
        topicsByGrade: {grade: []},
      ));
    }
    subjects.add(Subject(
      name: 'Информатика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Статистика и вероятность',
      topicsByGrade: {grade: []},
    ));
  } else if (grade >= 10 && grade <= 11) {
    subjects.add(Subject(
      name: 'Русский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Алгебра',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Геометрия',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Английский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'История',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'География',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Биология',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Физика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Химия',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Литература',
      topicsByGrade: {grade: []},
    ));
    // Обществознание для 10-11 классов (оставляем)
    subjects.add(Subject(
      name: 'Обществознание',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Информатика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Статистика и вероятность',
      topicsByGrade: {grade: []},
    ));
  } else if (grade == 12) {
    subjects.add(Subject(
      name: 'Русский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Алгебра',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Геометрия',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Английский язык',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'История',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Физика',
      topicsByGrade: {grade: []},
    ));
    subjects.add(Subject(
      name: 'Химия',
      topicsByGrade: {grade: []},
    ));
  }
}

// Литовские предметы
void _addLithuanianSubjects(List<Subject> subjects, int grade) {
  subjects.add(Subject(
    name: 'Литовский язык',
    topicsByGrade: {grade: []},
  ));
  subjects.add(Subject(
    name: 'Математика',
    topicsByGrade: {grade: []},
  ));
  if (grade >= 5) {
    subjects.add(Subject(
      name: 'История Литвы',
      topicsByGrade: {grade: []},
    ));
  }
  // Добавляем остальные предметы как в России
  _addRussianSubjects(subjects, grade);
}

// Казахские предметы
void _addKazakhSubjects(List<Subject> subjects, int grade) {
  subjects.add(Subject(
    name: 'Казахский язык',
    topicsByGrade: {grade: []},
  ));
  subjects.add(Subject(
    name: 'Русский язык',
    topicsByGrade: {grade: []},
  ));
  subjects.add(Subject(
    name: 'Математика',
    topicsByGrade: {grade: []},
  ));
  if (grade >= 5) {
    subjects.add(Subject(
      name: 'История Казахстана',
      topicsByGrade: {grade: []},
    ));
  }
  // Добавляем остальные предметы как в России
  _addRussianSubjects(subjects, grade);
}

// Вьетнамские предметы
void _addVietnameseSubjects(List<Subject> subjects, int grade) {
  subjects.add(Subject(
    name: 'Вьетнамский язык',
    topicsByGrade: {grade: []},
  ));
  subjects.add(Subject(
    name: 'Математика',
    topicsByGrade: {grade: []},
  ));
  if (grade >= 5) {
    subjects.add(Subject(
      name: 'История Вьетнама',
      topicsByGrade: {grade: []},
    ));
  }
  // Добавляем остальные предметы как в России
  _addRussianSubjects(subjects, grade);
}

// Fallback данные
Map<int, List<Subject>> _getFallbackSubjects() {
  return {
    1: [
      Subject(name: 'Русский язык', topicsByGrade: {1: []}),
      Subject(name: 'Математика', topicsByGrade: {1: []}),
    ],
    2: [
      Subject(name: 'Русский язык', topicsByGrade: {2: []}),
      Subject(name: 'Математика', topicsByGrade: {2: []}),
      Subject(name: 'Английский язык', topicsByGrade: {2: []}),
    ],
    3: [
      Subject(name: 'Русский язык', topicsByGrade: {3: []}),
      Subject(name: 'Математика', topicsByGrade: {3: []}),
      Subject(name: 'Английский язык', topicsByGrade: {3: []}),
    ],
    4: [
      Subject(name: 'Русский язык', topicsByGrade: {4: []}),
      Subject(name: 'Математика', topicsByGrade: {4: []}),
      Subject(name: 'Английский язык', topicsByGrade: {4: []}),
    ],
    5: [
      Subject(name: 'Русский язык', topicsByGrade: {5: []}),
      Subject(name: 'Математика', topicsByGrade: {5: []}),
      Subject(name: 'Английский язык', topicsByGrade: {5: []}),
      Subject(name: 'История', topicsByGrade: {5: []}),
      Subject(name: 'География', topicsByGrade: {5: []}),
      Subject(name: 'Биология', topicsByGrade: {5: []}),
      Subject(name: 'Литература', topicsByGrade: {5: []}),
      Subject(name: 'Обществознание', topicsByGrade: {5: []}),
    ],
    6: [
      Subject(name: 'Русский язык', topicsByGrade: {6: []}),
      Subject(name: 'Математика', topicsByGrade: {6: []}),
      Subject(name: 'Английский язык', topicsByGrade: {6: []}),
      Subject(name: 'История', topicsByGrade: {6: []}),
      Subject(name: 'География', topicsByGrade: {6: []}),
      Subject(name: 'Биология', topicsByGrade: {6: []}),
      Subject(name: 'Литература', topicsByGrade: {6: []}),
      Subject(name: 'Обществознание', topicsByGrade: {6: []}),
    ],
    7: [
      Subject(name: 'Русский язык', topicsByGrade: {7: []}),
      Subject(name: 'Алгебра', topicsByGrade: {7: []}),
      Subject(name: 'Геометрия', topicsByGrade: {7: []}),
      Subject(name: 'Английский язык', topicsByGrade: {7: []}),
      Subject(name: 'История', topicsByGrade: {7: []}),
      Subject(name: 'География', topicsByGrade: {7: []}),
      Subject(name: 'Биология', topicsByGrade: {7: []}),
      Subject(name: 'Физика', topicsByGrade: {7: []}),
      Subject(name: 'Химия', topicsByGrade: {7: []}),
      Subject(name: 'Литература', topicsByGrade: {7: []}),
      Subject(name: 'Обществознание', topicsByGrade: {7: []}),
      Subject(name: 'Информатика', topicsByGrade: {7: []}),
      Subject(name: 'Статистика и вероятность', topicsByGrade: {7: []}),
    ],
    8: [
      Subject(name: 'Русский язык', topicsByGrade: {8: []}),
      Subject(name: 'Алгебра', topicsByGrade: {8: []}),
      Subject(name: 'Геометрия', topicsByGrade: {8: []}),
      Subject(name: 'Английский язык', topicsByGrade: {8: []}),
      Subject(name: 'История', topicsByGrade: {8: []}),
      Subject(name: 'География', topicsByGrade: {8: []}),
      Subject(name: 'Биология', topicsByGrade: {8: []}),
      Subject(name: 'Физика', topicsByGrade: {8: []}),
      Subject(name: 'Химия', topicsByGrade: {8: []}),
      Subject(name: 'Литература', topicsByGrade: {8: []}),
      Subject(name: 'Обществознание', topicsByGrade: {8: []}),
      Subject(name: 'Информатика', topicsByGrade: {8: []}),
      Subject(name: 'Статистика и вероятность', topicsByGrade: {8: []}),
    ],
    9: [
      Subject(name: 'Русский язык', topicsByGrade: {9: []}),
      Subject(name: 'Алгебра', topicsByGrade: {9: []}),
      Subject(name: 'Геометрия', topicsByGrade: {9: []}),
      Subject(name: 'Английский язык', topicsByGrade: {9: []}),
      Subject(name: 'История', topicsByGrade: {9: []}),
      Subject(name: 'География', topicsByGrade: {9: []}),
      Subject(name: 'Биология', topicsByGrade: {9: []}),
      Subject(name: 'Физика', topicsByGrade: {9: []}),
      Subject(name: 'Химия', topicsByGrade: {9: []}),
      Subject(name: 'Литература', topicsByGrade: {9: []}),
      Subject(name: 'Обществознание', topicsByGrade: {9: []}),
      Subject(name: 'Информатика', topicsByGrade: {9: []}),
      Subject(name: 'Статистика и вероятность', topicsByGrade: {9: []}),
    ],
    10: [
      Subject(name: 'Русский язык', topicsByGrade: {10: []}),
      Subject(name: 'Алгебра', topicsByGrade: {10: []}),
      Subject(name: 'Геометрия', topicsByGrade: {10: []}),
      Subject(name: 'Английский язык', topicsByGrade: {10: []}),
      Subject(name: 'История', topicsByGrade: {10: []}),
      Subject(name: 'География', topicsByGrade: {10: []}),
      Subject(name: 'Биология', topicsByGrade: {10: []}),
      Subject(name: 'Физика', topicsByGrade: {10: []}),
      Subject(name: 'Химия', topicsByGrade: {10: []}),
      Subject(name: 'Литература', topicsByGrade: {10: []}),
      Subject(name: 'Обществознание', topicsByGrade: {10: []}),
      Subject(name: 'Информатика', topicsByGrade: {10: []}),
      Subject(name: 'Статистика и вероятность', topicsByGrade: {10: []}),
    ],
    11: [
      Subject(name: 'Русский язык', topicsByGrade: {11: []}),
      Subject(name: 'Алгебра', topicsByGrade: {11: []}),
      Subject(name: 'Геометрия', topicsByGrade: {11: []}),
      Subject(name: 'Английский язык', topicsByGrade: {11: []}),
      Subject(name: 'История', topicsByGrade: {11: []}),
      Subject(name: 'География', topicsByGrade: {11: []}),
      Subject(name: 'Биология', topicsByGrade: {11: []}),
      Subject(name: 'Физика', topicsByGrade: {11: []}),
      Subject(name: 'Химия', topicsByGrade: {11: []}),
      Subject(name: 'Литература', topicsByGrade: {11: []}),
      Subject(name: 'Обществознание', topicsByGrade: {11: []}),
      Subject(name: 'Информатика', topicsByGrade: {11: []}),
      Subject(name: 'Статистика и вероятность', topicsByGrade: {11: []}),
    ],
  };
}

// Локализованные названия предметов с учетом региона
Map<String, String> getLocalizedSubjectNames(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  final regionManager = Provider.of<RegionManager>(context, listen: false);
  final regionId = regionManager.currentRegion.id;

  // Базовые названия на русском
  Map<String, String> baseNames = {
    'Русский язык': 'Русский язык',
    'Математика': 'Математика',
    'Алгебра': 'Алгебра',
    'Геометрия': 'Геометрия',
    'История': 'История',
    'Физика': 'Физика',
    'Химия': 'Химия',
    'Биология': 'Биология',
    'География': 'География',
    'Английский язык': 'Английский язык',
    'Литература': 'Литература',
    'Обществознание': 'Обществознание',
    'Информатика': 'Информатика',
    'Статистика и вероятность': 'Статистика и вероятность',
    'Литовский язык': 'Литовский язык',
    'Казахский язык': 'Казахский язык',
    'Вьетнамский язык': 'Вьетнамский язык',
    'История Литвы': 'История Литвы',
    'История Казахстана': 'История Казахстана',
    'История Вьетнама': 'История Вьетнама',
  };

  // Английская локализация
  if (locale == 'en') {
    baseNames = {
      'Русский язык': 'Russian Language',
      'Математика': 'Mathematics',
      'Алгебра': 'Algebra',
      'Геометрия': 'Geometry',
      'История': 'History',
      'Физика': 'Physics',
      'Химия': 'Chemistry',
      'Биология': 'Biology',
      'География': 'Geography',
      'Английский язык': 'English Language',
      'Литература': 'Literature',
      'Обществознание': 'Social Studies',
      'Информатика': 'Computer Science',
      'Статистика и вероятность': 'Statistics and Probability',
      'Литовский язык': 'Lithuanian Language',
      'Казахский язык': 'Kazakh Language',
      'Вьетнамский язык': 'Vietnamese Language',
      'История Литвы': 'History of Lithuania',
      'История Казахстана': 'History of Kazakhstan',
      'История Вьетнама': 'History of Vietnam',
    };
  }
  // Немецкая локализация
  else if (locale == 'de') {
    baseNames = {
      'Русский язык': 'Russische Sprache',
      'Математика': 'Mathematik',
      'Алгебра': 'Algebra',
      'Геометрия': 'Geometrie',
      'История': 'Geschichte',
      'Физика': 'Physik',
      'Химия': 'Chemie',
      'Биология': 'Biologie',
      'География': 'Geographie',
      'Английский язык': 'Englische Sprache',
      'Литература': 'Literatur',
      'Обществознание': 'Sozialkunde',
      'Информатика': 'Informatik',
      'Статистика и вероятность': 'Statistik und Wahrscheinlichkeit',
      'Литовский язык': 'Litauische Sprache',
      'Казахский язык': 'Kasachische Sprache',
      'Вьетнамский язык': 'Vietnamesische Sprache',
      'История Литвы': 'Geschichte Litauens',
      'История Казахстана': 'Geschichte Kasachstans',
      'История Вьетнама': 'Geschichte Vietnams',
    };
  }
  // Литовская локализация
  else if (locale == 'lt') {
    baseNames = {
      'Русский язык': 'Rusų kalba',
      'Математика': 'Matematika',
      'Алгебра': 'Algebra',
      'Геометрия': 'Geometrija',
      'История': 'Istorija',
      'Физика': 'Fizika',
      'Химия': 'Chemija',
      'Биология': 'Biologija',
      'География': 'Geografija',
      'Английский язык': 'Anglų kalba',
      'Литература': 'Literatūra',
      'Обществознание': 'Socialiniai mokslai',
      'Информатика': 'Informatika',
      'Статистика и вероятность': 'Statistika ir tikimybė',
      'Литовский язык': 'Lietuvių kalba',
      'Казахский язык': 'Kazachų kalba',
      'Вьетнамский язык': 'Vietnamiečių kalba',
      'История Литвы': 'Lietuvos istorija',
      'История Казахстана': 'Kazachstano istorija',
      'История Вьетнама': 'Vietnamo istorija',
    };
  }
  // Вьетнамская локализация
  else if (locale == 'vi') {
    baseNames = {
      'Русский язык': 'Tiếng Nga',
      'Математика': 'Toán học',
      'Алгебра': 'Đại số',
      'Геометрия': 'Hình học',
      'История': 'Lịch sử',
      'Физика': 'Vật lý',
      'Химия': 'Hóa học',
      'Биология': 'Sinh học',
      'География': 'Địa lý',
      'Английский язык': 'Tiếng Anh',
      'Литература': 'Văn học',
      'Обществознание': 'Khoa học xã hội',
      'Информатика': 'Tin học',
      'Статистика и вероятность': 'Thống kê и xác suất',
      'Литовский язык': 'Tiếng Lithuania',
      'Казахский язык': 'Tiếng Kazakhstan',
      'Вьетнамский язык': 'Tiếng Việt',
      'История Литвы': 'Lịch sử Lithuania',
      'История Казахстана': 'Lịch sử Kazakhstan',
      'История Вьетнама': 'Lịch sử Việt Nam',
    };
  }
  // Казахская локализация
  else if (locale == 'kz') {
    baseNames = {
      'Русский язык': 'Орыс тілі',
      'Математика': 'Математика',
      'Алгебра': 'Алгебра',
      'Геометрия': 'Геометрия',
      'История': 'Тарих',
      'Физика': 'Физика',
      'Химия': 'Химия',
      'Биология': 'Биология',
      'География': 'География',
      'Английский язык': 'Ағылшын тілі',
      'Литература': 'Әдебиет',
      'Обществознание': 'Әлеуметтану',
      'Информатика': 'Информатика',
      'Статистика и вероятность': 'Статистика және ықтималдық',
      'Литовский язык': 'Литва тілі',
      'Казахский язык': 'Қазақ тілі',
      'Вьетнамский язык': 'Вьетнам тілі',
      'История Литвы': 'Литва тарихы',
      'История Казахстана': 'Қазақстан тарихы',
      'История Вьетнама': 'Вьетнам тарихы',
    };
  }

  return baseNames;
}

// Реактивная версия для использования в виджетах
Map<int, List<Subject>> getReactiveSubjectsByGrade(BuildContext context) {
  return getSubjectsByGrade(context);
}