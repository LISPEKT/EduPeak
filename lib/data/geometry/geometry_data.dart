import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// Импорт данных для России на русском
// import 'geometry_ru_ru.dart' as ru_ru;

class GeometryData {
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    'ru_ru': {
      // 7: ru_ru.geometrySubjects7,
      // 8: ru_ru.geometrySubjects8,
      // 9: ru_ru.geometrySubjects9,
      // 10: ru_ru.geometrySubjects10,
      // 11: ru_ru.geometrySubjects11,
    },
  };

  static List<Subject> getGeometrySubjects(BuildContext context, int grade) {
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

      print('✅ Loaded geometry: $dataKey, grade $grade, ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('❌ Error loading geometry data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  static List<Subject> getGeometrySubjects7(BuildContext context) => getGeometrySubjects(context, 7);
  static List<Subject> getGeometrySubjects8(BuildContext context) => getGeometrySubjects(context, 8);
  static List<Subject> getGeometrySubjects9(BuildContext context) => getGeometrySubjects(context, 9);
  static List<Subject> getGeometrySubjects10(BuildContext context) => getGeometrySubjects(context, 10);
  static List<Subject> getGeometrySubjects11(BuildContext context) => getGeometrySubjects(context, 11);

  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Геометрия');
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