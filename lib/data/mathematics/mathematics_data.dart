import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'mathematics_ru_ru.dart' as ru_ru;

class MathematicsData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 1: ru_ru.mathematicsSubjects1,
      // 2: ru_ru.mathematicsSubjects2,
      // 3: ru_ru.mathematicsSubjects3,
      // 4: ru_ru.mathematicsSubjects4,
      // 5: ru_ru.mathematicsSubjects5,
      // 6: ru_ru.mathematicsSubjects6,
    },
  };

  static List<Subject> getMathematicsSubjects(BuildContext context, int grade) {
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

      print('✅ Loaded mathematics: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading mathematics data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getMathematicsSubjects1(BuildContext context) => getMathematicsSubjects(context, 1);
  static List<Subject> getMathematicsSubjects2(BuildContext context) => getMathematicsSubjects(context, 2);
  static List<Subject> getMathematicsSubjects3(BuildContext context) => getMathematicsSubjects(context, 3);
  static List<Subject> getMathematicsSubjects4(BuildContext context) => getMathematicsSubjects(context, 4);
  static List<Subject> getMathematicsSubjects5(BuildContext context) => getMathematicsSubjects(context, 5);
  static List<Subject> getMathematicsSubjects6(BuildContext context) => getMathematicsSubjects(context, 6);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Математика');
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