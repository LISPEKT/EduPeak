// lib/data/subjects_data.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'social_studies/social_studies_data.dart';
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

    return baseData;
  } catch (e) {
    print('⚠️ Error getting subjects by grade: $e');
    return _getFallbackSubjects();
  }
}

// Методы для каждого класса с учетом региона
List<Subject> _getGrade1Subjects(BuildContext context, String regionId) {
  return [];
}

List<Subject> _getGrade2Subjects(BuildContext context, String regionId) {
  return [];
}

List<Subject> _getGrade3Subjects(BuildContext context, String regionId) {
  return [];
}

List<Subject> _getGrade4Subjects(BuildContext context, String regionId) {
  return [];
}

List<Subject> _getGrade5Subjects(BuildContext context, String regionId) {
  return [];
}

List<Subject> _getGrade6Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects6(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 6);

  return subjects;
}

List<Subject> _getGrade7Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects7(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 7);

  return subjects;
}

List<Subject> _getGrade8Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects8(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 8);

  return subjects;
}

List<Subject> _getGrade9Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects9(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 9);

  return subjects;
}

List<Subject> _getGrade10Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects10(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 10);

  return subjects;
}

List<Subject> _getGrade11Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects11(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 11);

  return subjects;
}

List<Subject> _getGrade12Subjects(BuildContext context, String regionId) {
  final List<Subject> subjects = [];

  // Добавляем обществознание если оно доступно в регионе
  if (SocialStudiesData.isAvailableInRegion(context)) {
    subjects.addAll(SocialStudiesData.getSocialStudiesSubjects12(context));
  }

  // Добавляем региональные предметы
  _addRegionalSubjects(subjects, context, regionId, 12);

  return subjects;
}

// Добавление региональных предметов
void _addRegionalSubjects(List<Subject> subjects, BuildContext context, String regionId, int grade) {
  final regionManager = Provider.of<RegionManager>(context, listen: false);

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
  } else if (grade >= 5 && grade <= 9) {
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
      name: 'История',
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
}

// Fallback данные
Map<int, List<Subject>> _getFallbackSubjects() {
  return {
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
    7: [],
    8: [],
    9: [],
    10: [],
    11: [],
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