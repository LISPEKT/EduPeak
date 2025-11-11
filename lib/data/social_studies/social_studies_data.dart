// lib/data/social_studies/social_studies_data.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../../services/region_manager.dart';
import '../../language_manager.dart';

// Импорты для каждого региона и языка
import 'social_studies_ru_ru.dart' as ru_ru;
import 'social_studies_ru_en.dart' as ru_en;
//import 'social_studies_ru_de.dart' as ru_de;
//import 'social_studies_lt_lt.dart' as lt_lt;
//import 'social_studies_lt_en.dart' as lt_en;
//import 'social_studies_de_de.dart' as de_de;
//import 'social_studies_de_en.dart' as de_en;
//import 'social_studies_kz_ru.dart' as kz_ru;
//import 'social_studies_kz_en.dart' as kz_en;
//import 'social_studies_kz_kk.dart' as kz_kk;
//import 'social_studies_vn_vi.dart' as vn_vi;
//import 'social_studies_vn_en.dart' as vn_en;

class SocialStudiesData {
  // Данные по регионам и языкам в формате Region_Language
  static final Map<String, Map<int, List<Subject>>> _regionalData = {
    // Россия
    'ru_ru': {
      6: ru_ru.socialStudiesSubjects6,
      7: ru_ru.socialStudiesSubjects7,
      //8: ru_ru.socialStudiesSubjects8,
      //9: ru_ru.socialStudiesSubjects9,
      //10: ru_ru.socialStudiesSubjects10,
      //11: ru_ru.socialStudiesSubjects11,
    },
    'ru_en': {
      6: ru_en.socialStudiesSubjects6,
      //7: ru_en.socialStudiesSubjects7,
      //8: ru_en.socialStudiesSubjects8,
      //9: ru_en.socialStudiesSubjects9,
      //10: ru_en.socialStudiesSubjects10,
      //11: ru_en.socialStudiesSubjects11,
    },
    'ru_de': {
      //6: ru_de.socialStudiesSubjects6,
      //7: ru_de.socialStudiesSubjects7,
      //8: ru_de.socialStudiesSubjects8,
      //9: ru_de.socialStudiesSubjects9,
      //10: ru_de.socialStudiesSubjects10,
      //11: ru_de.socialStudiesSubjects11,
    },

    // Литва
    'lt_lt': {
      //6: lt_lt.socialStudiesSubjects6,
      //7: lt_lt.socialStudiesSubjects7,
      //8: lt_lt.socialStudiesSubjects8,
      //9: lt_lt.socialStudiesSubjects9,
      //10: lt_lt.socialStudiesSubjects10,
      //11: lt_lt.socialStudiesSubjects11,
      //12: lt_lt.socialStudiesSubjects12,
    },
    'lt_en': {
      //6: lt_en.socialStudiesSubjects6,
      //7: lt_en.socialStudiesSubjects7,
      //8: lt_en.socialStudiesSubjects8,
      //9: lt_en.socialStudiesSubjects9,
      //10: lt_en.socialStudiesSubjects10,
      //11: lt_en.socialStudiesSubjects11,
      //12: lt_en.socialStudiesSubjects12,
    },

    // Германия
    'de_de': {
      //6: de_de.socialStudiesSubjects6,
      //7: de_de.socialStudiesSubjects7,
      //8: de_de.socialStudiesSubjects8,
      //9: de_de.socialStudiesSubjects9,
      //10: de_de.socialStudiesSubjects10,
      //11: de_de.socialStudiesSubjects11,
      //12: de_de.socialStudiesSubjects12,
    },
    'de_en': {
      //6: de_en.socialStudiesSubjects6,
      //7: de_en.socialStudiesSubjects7,
      //8: de_en.socialStudiesSubjects8,
      //9: de_en.socialStudiesSubjects9,
      //10: de_en.socialStudiesSubjects10,
      //11: de_en.socialStudiesSubjects11,
      //12: de_en.socialStudiesSubjects12,
    },

    // Казахстан
    'kz_ru': {
      //6: kz_ru.socialStudiesSubjects6,
      //7: kz_ru.socialStudiesSubjects7,
      //8: kz_ru.socialStudiesSubjects8,
      //9: kz_ru.socialStudiesSubjects9,
      //10: kz_ru.socialStudiesSubjects10,
      //11: kz_ru.socialStudiesSubjects11,
    },
    'kz_en': {
      //6: kz_en.socialStudiesSubjects6,
      //7: kz_en.socialStudiesSubjects7,
      //8: kz_en.socialStudiesSubjects8,
      //9: kz_en.socialStudiesSubjects9,
      //10: kz_en.socialStudiesSubjects10,
      //11: kz_en.socialStudiesSubjects11,
    },
    'kz_kz': {
      //6: kz_kk.socialStudiesSubjects6,
      //7: kz_kk.socialStudiesSubjects7,
      //8: kz_kk.socialStudiesSubjects8,
      //9: kz_kk.socialStudiesSubjects9,
      //10: kz_kk.socialStudiesSubjects10,
      //11: kz_kk.socialStudiesSubjects11,
    },

    // Вьетнам
    'vn_vi': {
      //6: vn_vi.socialStudiesSubjects6,
      //7: vn_vi.socialStudiesSubjects7,
      //8: vn_vi.socialStudiesSubjects8,
      //9: vn_vi.socialStudiesSubjects9,
      //10: vn_vi.socialStudiesSubjects10,
      //11: vn_vi.socialStudiesSubjects11,
      //12: vn_vi.socialStudiesSubjects12,
    },
    'vn_en': {
      //6: vn_en.socialStudiesSubjects6,
      //7: vn_en.socialStudiesSubjects7,
      //8: vn_en.socialStudiesSubjects8,
      //9: vn_en.socialStudiesSubjects9,
      //10: vn_en.socialStudiesSubjects10,
      //11: vn_en.socialStudiesSubjects11,
      //12: vn_en.socialStudiesSubjects12,
    },
  };

  // Основной метод получения данных с учетом региона и языка
  static List<Subject> getSocialStudiesSubjects(BuildContext context, int grade) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      final languageManager = Provider.of<LanguageManager>(context, listen: false);

      final regionId = regionManager.currentRegion.id;
      final languageCode = languageManager.currentLanguageCode;

      // Формируем ключ в формате region_language
      String dataKey = '${regionId}_$languageCode';

      // Если данных для текущей комбинации региона и языка нет, используем fallback
      if (!_regionalData.containsKey(dataKey)) {
        // Сначала пробуем английский как международный язык
        final englishKey = '${regionId}_en';
        if (_regionalData.containsKey(englishKey)) {
          dataKey = englishKey;
          print('⚠️ Using English data for region $regionId (no data for $languageCode)');
        }
        // Если английского тоже нет, используем русский как последний fallback
        else if (_regionalData.containsKey('${regionId}_ru')) {
          dataKey = '${regionId}_ru';
          print('⚠️ Using Russian data for region $regionId (no data for $languageCode or en)');
        }
        // Если вообще нет данных для региона, используем российские данные на русском
        else {
          dataKey = 'ru_ru';
          print('⚠️ Using default Russian data (no data for region $regionId)');
        }
      }

      final gradeData = _regionalData[dataKey] ?? {};
      final subjects = gradeData[grade] ?? [];

      print('✅ Loaded social studies: $dataKey, grade $grade, ${subjects.length} subjects');

      return subjects;
    } catch (e) {
      print('❌ Error loading social studies data for grade $grade: $e');
      return _regionalData['ru_ru']?[grade] ?? [];
    }
  }

  // Статические методы для всех классов
  static List<Subject> getSocialStudiesSubjects6(BuildContext context) => getSocialStudiesSubjects(context, 6);
  static List<Subject> getSocialStudiesSubjects7(BuildContext context) => getSocialStudiesSubjects(context, 7);
  static List<Subject> getSocialStudiesSubjects8(BuildContext context) => getSocialStudiesSubjects(context, 8);
  static List<Subject> getSocialStudiesSubjects9(BuildContext context) => getSocialStudiesSubjects(context, 9);
  static List<Subject> getSocialStudiesSubjects10(BuildContext context) => getSocialStudiesSubjects(context, 10);
  static List<Subject> getSocialStudiesSubjects11(BuildContext context) => getSocialStudiesSubjects(context, 11);
  static List<Subject> getSocialStudiesSubjects12(BuildContext context) => getSocialStudiesSubjects(context, 12);

  // Метод для проверки доступности предмета в текущем регионе
  static bool isAvailableInRegion(BuildContext context) {
    try {
      final regionManager = Provider.of<RegionManager>(context, listen: false);
      return regionManager.hasSubject('Обществознание');
    } catch (e) {
      return true; // По умолчанию доступно
    }
  }

  // Метод для получения доступных комбинаций региона и языка
  static List<String> getAvailableRegionLanguageCombinations() {
    return _regionalData.keys.toList();
  }

  // Метод для проверки наличия данных для конкретной комбинации
  static bool hasDataForRegionLanguage(String regionId, String languageCode) {
    return _regionalData.containsKey('${regionId}_$languageCode');
  }
}