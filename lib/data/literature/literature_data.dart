import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'literature_ru_ru.dart' as ru_ru;

class LiteratureData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 5: ru_ru.literatureSubjects5,
      // 6: ru_ru.literatureSubjects6,
      // 7: ru_ru.literatureSubjects7,
      // 8: ru_ru.literatureSubjects8,
      // 9: ru_ru.literatureSubjects9,
      // 10: ru_ru.literatureSubjects10,
      // 11: ru_ru.literatureSubjects11,
    },
  };

  static List<Subject> getLiteratureSubjects(BuildContext context, int grade) {
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

      print('✅ Loaded literature: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading literature data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getLiteratureSubjects5(BuildContext context) => getLiteratureSubjects(context, 5);
  static List<Subject> getLiteratureSubjects6(BuildContext context) => getLiteratureSubjects(context, 6);
  static List<Subject> getLiteratureSubjects7(BuildContext context) => getLiteratureSubjects(context, 7);
  static List<Subject> getLiteratureSubjects8(BuildContext context) => getLiteratureSubjects(context, 8);
  static List<Subject> getLiteratureSubjects9(BuildContext context) => getLiteratureSubjects(context, 9);
  static List<Subject> getLiteratureSubjects10(BuildContext context) => getLiteratureSubjects(context, 10);
  static List<Subject> getLiteratureSubjects11(BuildContext context) => getLiteratureSubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Литература');
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