import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// import 'computer_science_ru_ru.dart' as ru_ru;

class ComputerScienceData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 5: ru_ru.computerScienceSubjects5,
      // 6: ru_ru.computerScienceSubjects6,
      // 7: ru_ru.computerScienceSubjects7,
      // 8: ru_ru.computerScienceSubjects8,
      // 9: ru_ru.computerScienceSubjects9,
      // 10: ru_ru.computerScienceSubjects10,
      // 11: ru_ru.computerScienceSubjects11,
    },
  };

  static List<Subject> getComputerScienceSubjects(BuildContext context, int grade) {
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

      print('✅ Loaded computer science: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading computer science data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getComputerScienceSubjects5(BuildContext context) => getComputerScienceSubjects(context, 5);
  static List<Subject> getComputerScienceSubjects6(BuildContext context) => getComputerScienceSubjects(context, 6);
  static List<Subject> getComputerScienceSubjects7(BuildContext context) => getComputerScienceSubjects(context, 7);
  static List<Subject> getComputerScienceSubjects8(BuildContext context) => getComputerScienceSubjects(context, 8);
  static List<Subject> getComputerScienceSubjects9(BuildContext context) => getComputerScienceSubjects(context, 9);
  static List<Subject> getComputerScienceSubjects10(BuildContext context) => getComputerScienceSubjects(context, 10);
  static List<Subject> getComputerScienceSubjects11(BuildContext context) => getComputerScienceSubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Информатика');
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