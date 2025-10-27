import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/topic.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import 'package:edu_peak/language_manager.dart';
import 'history_data_ru.dart' as ru;
import 'history_data_en.dart' as en;
import 'history_data_de.dart' as de;

class HistoryData {
  static final Map<String, Map<int, List<Subject>>> _localizedData = {
    'ru': {
      5: ru.historySubjects5,
      6: ru.historySubjects6,
      7: ru.historySubjects7,
      8: ru.historySubjects8,
      9: ru.historySubjects9,
      10: ru.historySubjects10,
      11: ru.historySubjects11,
    },
    'en': {
      5: en.historySubjects5,
      6: en.historySubjects6,
      7: en.historySubjects7,
      8: en.historySubjects8,
      9: en.historySubjects9,
      10: en.historySubjects10,
      11: en.historySubjects11,
    },
    'de': {
      5: de.historySubjects5,
      6: de.historySubjects6,
      7: de.historySubjects7,
      8: de.historySubjects8,
      9: de.historySubjects9,
      10: de.historySubjects10,
      11: de.historySubjects11,
    },
  };

  // Реактивный метод с контекстом
  static List<Subject> getHistorySubjects(BuildContext context, int grade) {
    final languageManager = Provider.of<LanguageManager>(context, listen: true);
    final currentLanguage = languageManager.currentLanguageCode;
    final gradeData = _localizedData[currentLanguage] ?? _localizedData['ru']!;
    return gradeData[grade] ?? [];
  }

  // Статические методы для обратной совместимости (тоже реактивные)
  static List<Subject> getHistorySubjects5(BuildContext context) => getHistorySubjects(context, 5);
  static List<Subject> getHistorySubjects6(BuildContext context) => getHistorySubjects(context, 6);
  static List<Subject> getHistorySubjects7(BuildContext context) => getHistorySubjects(context, 7);
  static List<Subject> getHistorySubjects8(BuildContext context) => getHistorySubjects(context, 8);
  static List<Subject> getHistorySubjects9(BuildContext context) => getHistorySubjects(context, 9);
  static List<Subject> getHistorySubjects10(BuildContext context) => getHistorySubjects(context, 10);
  static List<Subject> getHistorySubjects11(BuildContext context) => getHistorySubjects(context, 11);
}