import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'geography_ru_ru.dart' as ru_ru;

class GeographyData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 5: ru_ru.geographySubjects5,
      // 6: ru_ru.geographySubjects6,
      // 7: ru_ru.geographySubjects7,
      // 8: ru_ru.geographySubjects8,
      // 9: ru_ru.geographySubjects9,
      // 10: ru_ru.geographySubjects10,
      // 11: ru_ru.geographySubjects11,
    },
  };

  static List<Subject> getGeographySubjects(BuildContext context, int grade) {
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

      print('✅ Loaded geography: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading geography data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getGeographySubjects5(BuildContext context) => getGeographySubjects(context, 5);
  static List<Subject> getGeographySubjects6(BuildContext context) => getGeographySubjects(context, 6);
  static List<Subject> getGeographySubjects7(BuildContext context) => getGeographySubjects(context, 7);
  static List<Subject> getGeographySubjects8(BuildContext context) => getGeographySubjects(context, 8);
  static List<Subject> getGeographySubjects9(BuildContext context) => getGeographySubjects(context, 9);
  static List<Subject> getGeographySubjects10(BuildContext context) => getGeographySubjects(context, 10);
  static List<Subject> getGeographySubjects11(BuildContext context) => getGeographySubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('География');
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