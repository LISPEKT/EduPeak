import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'statistics_probability_ru_ru.dart' as ru_ru;

class StatisticsProbabilityData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 7: ru_ru.statisticsProbabilitySubjects7,
      // 8: ru_ru.statisticsProbabilitySubjects8,
      // 9: ru_ru.statisticsProbabilitySubjects9,
      // 10: ru_ru.statisticsProbabilitySubjects10,
      // 11: ru_ru.statisticsProbabilitySubjects11,
    },
  };

  static List<Subject> getStatisticsProbabilitySubjects(BuildContext context, int grade) {
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

      print('✅ Loaded statistics & probability: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading statistics & probability data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getStatisticsProbabilitySubjects7(BuildContext context) => getStatisticsProbabilitySubjects(context, 7);
  static List<Subject> getStatisticsProbabilitySubjects8(BuildContext context) => getStatisticsProbabilitySubjects(context, 8);
  static List<Subject> getStatisticsProbabilitySubjects9(BuildContext context) => getStatisticsProbabilitySubjects(context, 9);
  static List<Subject> getStatisticsProbabilitySubjects10(BuildContext context) => getStatisticsProbabilitySubjects(context, 10);
  static List<Subject> getStatisticsProbabilitySubjects11(BuildContext context) => getStatisticsProbabilitySubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Статистика и вероятность');
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