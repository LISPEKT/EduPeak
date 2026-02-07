import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'russian_ru_ru.dart' as ru_ru;

class RussianData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 1: ru_ru.russianSubjects1,
      // 2: ru_ru.russianSubjects2,
      // 3: ru_ru.russianSubjects3,
      // 4: ru_ru.russianSubjects4,
      // 5: ru_ru.russianSubjects5,
      // 6: ru_ru.russianSubjects6,
      // 7: ru_ru.russianSubjects7,
      // 8: ru_ru.russianSubjects8,
      // 9: ru_ru.russianSubjects9,
      // 10: ru_ru.russianSubjects10,
      // 11: ru_ru.russianSubjects11,
    },
  };

  static List<Subject> getRussianSubjects(BuildContext context, int grade) {
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

      print('✅ Loaded russian: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading russian data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getRussianSubjects1(BuildContext context) => getRussianSubjects(context, 1);
  static List<Subject> getRussianSubjects2(BuildContext context) => getRussianSubjects(context, 2);
  static List<Subject> getRussianSubjects3(BuildContext context) => getRussianSubjects(context, 3);
  static List<Subject> getRussianSubjects4(BuildContext context) => getRussianSubjects(context, 4);
  static List<Subject> getRussianSubjects5(BuildContext context) => getRussianSubjects(context, 5);
  static List<Subject> getRussianSubjects6(BuildContext context) => getRussianSubjects(context, 6);
  static List<Subject> getRussianSubjects7(BuildContext context) => getRussianSubjects(context, 7);
  static List<Subject> getRussianSubjects8(BuildContext context) => getRussianSubjects(context, 8);
  static List<Subject> getRussianSubjects9(BuildContext context) => getRussianSubjects(context, 9);
  static List<Subject> getRussianSubjects10(BuildContext context) => getRussianSubjects(context, 10);
  static List<Subject> getRussianSubjects11(BuildContext context) => getRussianSubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Русский язык');
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