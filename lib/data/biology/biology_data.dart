import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'biology_ru_ru.dart' as ru_ru;

class BiologyData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 5: ru_ru.biologySubjects5,
      // 6: ru_ru.biologySubjects6,
      // 7: ru_ru.biologySubjects7,
      // 8: ru_ru.biologySubjects8,
      // 9: ru_ru.biologySubjects9,
      // 10: ru_ru.biologySubjects10,
      // 11: ru_ru.biologySubjects11,
    },
  };

  static List<Subject> getBiologySubjects(BuildContext context, int grade) {
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

      print('✅ Loaded biology: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading biology data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getBiologySubjects5(BuildContext context) => getBiologySubjects(context, 5);
  static List<Subject> getBiologySubjects6(BuildContext context) => getBiologySubjects(context, 6);
  static List<Subject> getBiologySubjects7(BuildContext context) => getBiologySubjects(context, 7);
  static List<Subject> getBiologySubjects8(BuildContext context) => getBiologySubjects(context, 8);
  static List<Subject> getBiologySubjects9(BuildContext context) => getBiologySubjects(context, 9);
  static List<Subject> getBiologySubjects10(BuildContext context) => getBiologySubjects(context, 10);
  static List<Subject> getBiologySubjects11(BuildContext context) => getBiologySubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Биология');
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