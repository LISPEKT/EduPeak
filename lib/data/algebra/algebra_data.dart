import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'algebra_ru_ru.dart' as ru_ru;

class AlgebraData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 7: ru_ru.algebraSubjects7,
      // 8: ru_ru.algebraSubjects8,
      // 9: ru_ru.algebraSubjects9,
      // 10: ru_ru.algebraSubjects10,
      // 11: ru_ru.algebraSubjects11,
    },
  };

  static List<Subject> getAlgebraSubjects(BuildContext context, int grade) {
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

      print('✅ Loaded algebra: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading algebra data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getAlgebraSubjects7(BuildContext context) => getAlgebraSubjects(context, 7);
  static List<Subject> getAlgebraSubjects8(BuildContext context) => getAlgebraSubjects(context, 8);
  static List<Subject> getAlgebraSubjects9(BuildContext context) => getAlgebraSubjects(context, 9);
  static List<Subject> getAlgebraSubjects10(BuildContext context) => getAlgebraSubjects(context, 10);
  static List<Subject> getAlgebraSubjects11(BuildContext context) => getAlgebraSubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Алгебра');
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