import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'english_ru_ru.dart' as ru_ru;

class EnglishData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 2: ru_ru.englishSubjects2,
      // 3: ru_ru.englishSubjects3,
      // 4: ru_ru.englishSubjects4,
      // 5: ru_ru.englishSubjects5,
      // 6: ru_ru.englishSubjects6,
      // 7: ru_ru.englishSubjects7,
      // 8: ru_ru.englishSubjects8,
      // 9: ru_ru.englishSubjects9,
      // 10: ru_ru.englishSubjects10,
      // 11: ru_ru.englishSubjects11,
    },
  };

  static List<Subject> getEnglishSubjects(BuildContext context, int grade) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      final languageManager = Provider.of<LanguageManager>(context, listen: false);

      final regionId = regionManager.currentRegion.id;
      final languageCode = languageManager.currentLanguageCode;

      String dataKey = '${regionId}_$languageCode';

      if (!_regionalData.containsKey(dataKey)) {
        final englishKey = '${regionId}_en';
        if (_regionalData.containsKey(englishKey)) {
          dataKey = englishKey;
          print('⚠️ Using English data for region $regionId (no data for $languageCode)');
        }
        else if (_regionalData.containsKey('${regionId}_ru')) {
          dataKey = '${regionId}_ru';
          print('⚠️ Using Russian data for region $regionId (no data for $languageCode or en)');
        }
        else {
          dataKey = 'ru_ru';
          print('⚠️ Using default Russian data (no data for region $regionId)');
        }
      }

      final gradeData = _regionalData[dataKey] ?? {};
      final subjects = gradeData[grade] ?? [];

      print('✅ Loaded english: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading english data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getEnglishSubjects2(BuildContext context) => getEnglishSubjects(context, 2);
  static List<Subject> getEnglishSubjects3(BuildContext context) => getEnglishSubjects(context, 3);
  static List<Subject> getEnglishSubjects4(BuildContext context) => getEnglishSubjects(context, 4);
  static List<Subject> getEnglishSubjects5(BuildContext context) => getEnglishSubjects(context, 5);
  static List<Subject> getEnglishSubjects6(BuildContext context) => getEnglishSubjects(context, 6);
  static List<Subject> getEnglishSubjects7(BuildContext context) => getEnglishSubjects(context, 7);
  static List<Subject> getEnglishSubjects8(BuildContext context) => getEnglishSubjects(context, 8);
  static List<Subject> getEnglishSubjects9(BuildContext context) => getEnglishSubjects(context, 9);
  static List<Subject> getEnglishSubjects10(BuildContext context) => getEnglishSubjects(context, 10);
  static List<Subject> getEnglishSubjects11(BuildContext context) => getEnglishSubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Английский язык');
    } catch (e) {
      return true;
    }
  }

  static List<String> getAvailableRegionLanguageCombinations() {
    return _regionalData.keys.toList();
  }

  static bool hasDataForRegionLanguage(String regionId, String languageCode) {
    return _regionalData.containsKey('${regionId}_$languageCode');
  }
}