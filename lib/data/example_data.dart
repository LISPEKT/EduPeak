import '../../../models/topic.dart';
import '../../../models/question.dart';
import '../../../models/subject.dart';

// === КЛАСС [номер класса] ===
final List<Subject> [subjectName]Subjects[classNumber] = [
  Subject(
    name: '[Название предмета на русском]',
    topicsByGrade: {
      [номер класса]: [
        // ===== ТЕМА 1 =====
        Topic(
          id: "[subject]_[language]_[class]_[topicNumber]",
          paragraph: "[Глава или раздел, если есть]",
          name: '§[номер] [Название темы]',
          imageAsset: '[эмодзи или путь к изображению]',
          description: '[Краткое описание темы]',
          explanation: '''[Развёрнутое объяснение темы
• Ключевые понятия
• Основные даты
• Важные факты]''',
          questions: [
            Question(
              text: '[Текст вопроса]',
              options: [
                'Вариант 1',
                'Вариант 2',
                'Вариант 3',
                'Вариант 4',
                'Вариант 5'
              ],
              correctIndex: 0, // или [0, 1] для multiple_choice
              explanation: '[Объяснение правильного ответа]',
              answerType: 'single_choice', // или 'multiple_choice'
            ),
            // Добавлять вопросы по аналогии...
          ],
        ),
        // ===== ТЕМА 2 =====
        Topic(
          id: "[subject]_[language]_[class]_[topicNumber]",
          paragraph: "[Глава или раздел]",
          name: '§[номер] [Название темы]',
          imageAsset: '[эмодзи]',
          description: '[Описание]',
          explanation: '''[Развёрнутое объяснение]''',
          questions: [
            // Вопросы по теме...
          ],
        ),
        // Добавлять темы по аналогии...
      ],
    },
  ),
];