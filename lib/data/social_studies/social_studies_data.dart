// lib/data/social_studies/social_studies_data.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import 'package:edu_peak/language_manager.dart';
import 'social_studies_data_ru.dart' as ru;
import 'social_studies_data_en.dart' as en;
import 'social_studies_data_de.dart' as de;

class SocialStudiesData {
  static final Map<String, Map<int, List<Subject>>> _localizedData = {
    'ru': {
      1: [], // Для других классов можно добавить данные позже
      2: [],
      3: [],
      4: [],
      5: [],
      6: ru.socialStudiesSubjects6,
      7: [],
      8: [],
      9: [],
      10: [],
      11: [],
    },
    'en': {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: en.socialStudiesSubjects6,
      7: [],
      8: [],
      9: [],
      10: [],
      11: [],
    },
    'de': {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: de.socialStudiesSubjects6,
      7: [],
      8: [],
      9: [],
      10: [],
      11: [],
    },
  };

  // Реактивный метод с контекстом
  static List<Subject> getSocialStudiesSubjects(BuildContext context, int grade) {
    try {
      final languageManager = Provider.of<LanguageManager>(context, listen: false);
      final currentLanguage = languageManager.currentLanguageCode;
      final gradeData = _localizedData[currentLanguage] ?? _localizedData['ru']!;
      return gradeData[grade] ?? [];
    } catch (e) {
      print('⚠️ Using default social studies data for grade $grade: $e');
      return _localizedData['ru']![grade] ?? [];
    }
  }

  // Статические методы для всех классов
  static List<Subject> getSocialStudiesSubjects1(BuildContext context) => getSocialStudiesSubjects(context, 1);
  static List<Subject> getSocialStudiesSubjects2(BuildContext context) => getSocialStudiesSubjects(context, 2);
  static List<Subject> getSocialStudiesSubjects3(BuildContext context) => getSocialStudiesSubjects(context, 3);
  static List<Subject> getSocialStudiesSubjects4(BuildContext context) => getSocialStudiesSubjects(context, 4);
  static List<Subject> getSocialStudiesSubjects5(BuildContext context) => getSocialStudiesSubjects(context, 5);
  static List<Subject> getSocialStudiesSubjects6(BuildContext context) => getSocialStudiesSubjects(context, 6);
  static List<Subject> getSocialStudiesSubjects7(BuildContext context) => getSocialStudiesSubjects(context, 7);
  static List<Subject> getSocialStudiesSubjects8(BuildContext context) => getSocialStudiesSubjects(context, 8);
  static List<Subject> getSocialStudiesSubjects9(BuildContext context) => getSocialStudiesSubjects(context, 9);
  static List<Subject> getSocialStudiesSubjects10(BuildContext context) => getSocialStudiesSubjects(context, 10);
  static List<Subject> getSocialStudiesSubjects11(BuildContext context) => getSocialStudiesSubjects(context, 11);
}