import 'algebra_data.dart';
import 'mathematics_data.dart';
import 'russian_data.dart';
import 'physics_data.dart';
// Пока закомментируем остальные, чтобы избежать ошибок
// import 'geometry_data.dart';
// import 'computer_science_data.dart';
// import 'english_data.dart';
// import 'literature_data.dart';
// import 'biology_data.dart';
// import 'chemistry_data.dart';
// import 'geography_data.dart';
import 'history_data.dart';
// import 'social_studies_data.dart';
// import 'statistics_probability_data.dart';
import '../models/subject.dart';

final Map<int, List<Subject>> subjectsByGrade = {
  1: [
    ...russianSubjects1,
    ...mathematicsSubjects1,
  ],
  2: [
    ...russianSubjects2,
    ...mathematicsSubjects2,
  ],
  3: [
    ...russianSubjects3,
    ...mathematicsSubjects3,
  ],
  4: [
    ...russianSubjects4,
    ...mathematicsSubjects4,
  ],
  5: [
    ...russianSubjects5,
    ...algebraSubjects5,
    ...mathematicsSubjects5,
    // ...geometrySubjects5,
    // ...englishSubjects5,
    // ...literatureSubjects5,
    // ...biologySubjects5,
    ...historySubjects5,
    // ...geographySubjects5,
  ],
  6: [
    ...russianSubjects6,
    ...algebraSubjects6,
    ...mathematicsSubjects6,
    // ...geometrySubjects6,
    // ...englishSubjects6,
    // ...literatureSubjects6,
    // ...biologySubjects6,
    ...historySubjects6,
    // ...geographySubjects6,
    // ...socialStudiesSubjects6,
  ],
  7: [
    ...russianSubjects7,
    ...algebraSubjects7,
    ...mathematicsSubjects7,
    ...physicsSubjects7,
    // ...geometrySubjects7,
    // ...englishSubjects7,
    // ...literatureSubjects7,
    // ...biologySubjects7,
    ...historySubjects7,
    // ...geographySubjects7,
    // ...socialStudiesSubjects7,
  ],
  8: [
    ...russianSubjects8,
    ...algebraSubjects8,
    ...mathematicsSubjects8,
    ...physicsSubjects8,
    // ...geometrySubjects8,
    // ...englishSubjects8,
    // ...literatureSubjects8,
    // ...biologySubjects8,
    // ...chemistrySubjects8,
    ...historySubjects8,
    // ...geographySubjects8,
    // ...socialStudiesSubjects8,
  ],
  9: [
    ...russianSubjects9,
    ...algebraSubjects9,
    ...mathematicsSubjects9,
    ...physicsSubjects9,
    // ...geometrySubjects9,
    // ...englishSubjects9,
    // ...literatureSubjects9,
    // ...biologySubjects9,
    // ...chemistrySubjects9,
    ...historySubjects9,
    // ...geographySubjects9,
    // ...socialStudiesSubjects9,
  ],
  10: [
    ...russianSubjects10,
    ...algebraSubjects10,
    ...mathematicsSubjects10,
    ...physicsSubjects10,
    // ...geometrySubjects10,
    // ...englishSubjects10,
    // ...literatureSubjects10,
    // ...biologySubjects10,
    // ...chemistrySubjects10,
    ...historySubjects10,
    // ...geographySubjects10,
    // ...socialStudiesSubjects10,
    // ...computerScienceSubjects10,
    // ...statisticsProbabilitySubjects10,
  ],
  11: [
    ...russianSubjects11,
    ...algebraSubjects11,
    ...mathematicsSubjects11,
    ...physicsSubjects11,
    // ...geometrySubjects11,
    // ...englishSubjects11,
    // ...literatureSubjects11,
    // ...biologySubjects11,
    // ...chemistrySubjects11,
    ...historySubjects11,
    // ...geographySubjects11,
    // ...socialStudiesSubjects11,
    // ...computerScienceSubjects11,
    // ...statisticsProbabilitySubjects11,
  ],
};

final Map<String, String> subjectEmojis = {
  'Русский язык': '📚',
  'Математика': '🔢',
  'Алгебра': '𝑥²',
  'Геометрия': '△',
  'Английский язык': '🔤',
  'Литература': '📖',
  'Биология': '🌿',
  'Физика': '⚡',
  'Химия': '🧪',
  'География': '🌍',
  'История России': '🇷🇺',
  'Всеобщая история': '🏛️',
  'Обществознание': '👥',
  'Информатика': '💻',
  'Статистика и вероятность': '📊',
};

final List<int> availableGrades = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];