// subjects_data.dart
import 'package:flutter/material.dart';
import 'history/history_data.dart';
import '../models/subject.dart';

// Основные данные предметов с поддержкой локализации
Map<int, List<Subject>> getSubjectsByGrade(BuildContext context) {
  return {
    1: [
      //...russianSubjects1,
      //...mathematicsSubjects1,
    ],
    2: [
      //...russianSubjects2,
      //...mathematicsSubjects2,
    ],
    3: [
      //...russianSubjects3,
      //...mathematicsSubjects3,
    ],
    4: [
      //...russianSubjects4,
      //...mathematicsSubjects4,
    ],
    5: [
      //...russianSubjects5,
      //...algebraSubjects5,
      ...HistoryData.getHistorySubjects5(context),
    ],
    6: [
      //...russianSubjects6,
      //...algebraSubjects6,
      ...HistoryData.getHistorySubjects6(context),
    ],
    7: [
      //...russianSubjects7,
      //...algebraSubjects7,
      //...physicsSubjects7,
      ...HistoryData.getHistorySubjects7(context),
    ],
    8: [
      //...russianSubjects8,
      //...algebraSubjects8,
      //...physicsSubjects8,
      ...HistoryData.getHistorySubjects8(context),
    ],
    9: [
      //...russianSubjects9,
      //...algebraSubjects9,
      //...physicsSubjects9,
      ...HistoryData.getHistorySubjects9(context),
    ],
    10: [
      //...russianSubjects10,
      //...algebraSubjects10,
      //...physicsSubjects10,
      ...HistoryData.getHistorySubjects10(context),
    ],
    11: [
      //...russianSubjects11,
      //...algebraSubjects11,
      //...physicsSubjects11,
      ...HistoryData.getHistorySubjects11(context),
    ],
  };
}

// Локализованные названия предметов (упрощенная версия)
Map<String, String> getLocalizedSubjectNames(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;

  if (locale == 'en') {
    return {
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
    };
  } else if (locale == 'de') {
    return {
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
    };
  }

  // По умолчанию русские названия
  return {
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
  };
}

// Emojis для предметов
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

// Реактивная версия для использования в виджетах
Map<int, List<Subject>> getReactiveSubjectsByGrade(BuildContext context) {
  return getSubjectsByGrade(context);
}