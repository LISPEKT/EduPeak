// data/dictionary.dart
import 'package:flutter/material.dart';
import 'subjects_data.dart';
import 'subjects_manager.dart';
import 'package:edu_peak/screens/main_screen.dart';

class DictionaryTerm {
  final String id;
  final String term;
  final String definition;
  final String category;
  final String addedDate;

  DictionaryTerm({
    required this.id,
    required this.term,
    required this.definition,
    required this.category,
    required this.addedDate,
  });
}

// Функция для получения цвета по категории
Color getCategoryColor(String category) {
  switch (category) {
    case 'Русский язык':
      return Color(0xFFEA4335);
    case 'Математика':
      return Color(0xFF4285F4);
    case 'Алгебра':
      return Color(0xFF2196F3);
    case 'Геометрия':
      return Color(0xFF3F51B5);
    case 'Статистика и вероятность':
      return Color(0xFF00BCD4);
    case 'Физика':
      return Color(0xFF9C27B0);
    case 'Химия':
      return Color(0xFFFF9800);
    case 'Биология':
      return Color(0xFF4CAF50);
    case 'География':
      return Color(0xFF00BCD4);
    case 'История':
      return Color(0xFF34A853);
    case 'Обществознание':
      return Color(0xFF8E44AD);
    case 'Литература':
      return Color(0xFFFBBC05);
    case 'Информатика':
      return Color(0xFF607D8B);
    default:
      return Colors.grey;
  }
}

// Данные словаря по школьным предметам
final List<DictionaryTerm> dictionaryTerms = [
  // Русский язык
  DictionaryTerm(
    id: 'rus1',
    term: 'Существительное',
    definition: 'Самостоятельная часть речи, обозначающая предмет и отвечающая на вопросы кто? что?',
    category: 'Русский язык',
    addedDate: '2024-01-15',
  ),
  DictionaryTerm(
    id: 'rus2',
    term: 'Глагол',
    definition: 'Часть речи, обозначающая действие или состояние предмета',
    category: 'Русский язык',
    addedDate: '2024-01-16',
  ),
  DictionaryTerm(
    id: 'rus3',
    term: 'Прилагательное',
    definition: 'Часть речи, обозначающая признак предмета',
    category: 'Русский язык',
    addedDate: '2024-01-17',
  ),

  // Математика
  DictionaryTerm(
    id: 'math1',
    term: 'Натуральное число',
    definition: 'Число, возникающее при естественном счёте предметов (1, 2, 3, 4...)',
    category: 'Математика',
    addedDate: '2024-01-18',
  ),
  DictionaryTerm(
    id: 'math2',
    term: 'Дробь',
    definition: 'Число, состоящее из одной или нескольких частей единицы',
    category: 'Математика',
    addedDate: '2024-01-19',
  ),
  DictionaryTerm(
    id: 'math3',
    term: 'Процент',
    definition: 'Сотая часть числа, обозначаемая знаком %',
    category: 'Математика',
    addedDate: '2024-01-20',
  ),

  // Алгебра
  DictionaryTerm(
    id: 'alg1',
    term: 'Уравнение',
    definition: 'Равенство, содержащее одну или несколько неизвестных величин',
    category: 'Алгебра',
    addedDate: '2024-01-21',
  ),
  DictionaryTerm(
    id: 'alg2',
    term: 'Функция',
    definition: 'Зависимость одной переменной величины от другой',
    category: 'Алгебра',
    addedDate: '2024-01-22',
  ),
  DictionaryTerm(
    id: 'alg3',
    term: 'Квадратное уравнение',
    definition: 'Уравнение вида ax² + bx + c = 0, где a ≠ 0',
    category: 'Алгебра',
    addedDate: '2024-01-23',
  ),

  // Геометрия
  DictionaryTerm(
    id: 'geom1',
    term: 'Треугольник',
    definition: 'Многоугольник с тремя сторонами и тремя углами',
    category: 'Геометрия',
    addedDate: '2024-01-24',
  ),
  DictionaryTerm(
    id: 'geom2',
    term: 'Окружность',
    definition: 'Множество всех точек плоскости, равноудаленных от заданной точки',
    category: 'Геометрия',
    addedDate: '2024-01-25',
  ),
  DictionaryTerm(
    id: 'geom3',
    term: 'Теорема Пифагора',
    definition: 'В прямоугольном треугольнике квадрат гипотенузы равен сумме квадратов катетов',
    category: 'Геометрия',
    addedDate: '2024-01-26',
  ),

  // Физика
  DictionaryTerm(
    id: 'phys1',
    term: 'Скорость',
    definition: 'Векторная величина, характеризующая быстроту перемещения и направление движения',
    category: 'Физика',
    addedDate: '2024-01-27',
  ),
  DictionaryTerm(
    id: 'phys2',
    term: 'Сила',
    definition: 'Векторная величина, мера взаимодействия тел',
    category: 'Физика',
    addedDate: '2024-01-28',
  ),
  DictionaryTerm(
    id: 'phys3',
    term: 'Энергия',
    definition: 'Скалярная физическая величина, являющаяся мерой способности тела совершать работу',
    category: 'Физика',
    addedDate: '2024-01-29',
  ),

  // Химия
  DictionaryTerm(
    id: 'chem1',
    term: 'Атом',
    definition: 'Наименьшая частица химического элемента, сохраняющая его свойства',
    category: 'Химия',
    addedDate: '2024-01-30',
  ),
  DictionaryTerm(
    id: 'chem2',
    term: 'Молекула',
    definition: 'Наименьшая частица вещества, сохраняющая его химические свойства',
    category: 'Химия',
    addedDate: '2024-01-31',
  ),
  DictionaryTerm(
    id: 'chem3',
    term: 'Реакция',
    definition: 'Процесс превращения одних веществ в другие',
    category: 'Химия',
    addedDate: '2024-02-01',
  ),

  // Биология
  DictionaryTerm(
    id: 'bio1',
    term: 'Клетка',
    definition: 'Элементарная единица строения и жизнедеятельности всех организмов',
    category: 'Биология',
    addedDate: '2024-02-02',
  ),
  DictionaryTerm(
    id: 'bio2',
    term: 'Фотосинтез',
    definition: 'Процесс образования органических веществ из неорганических с использованием энергии света',
    category: 'Биология',
    addedDate: '2024-02-03',
  ),
  DictionaryTerm(
    id: 'bio3',
    term: 'ДНК',
    definition: 'Молекула, хранящая генетическую информацию у живых организмов',
    category: 'Биология',
    addedDate: '2024-02-04',
  ),

  // История
  DictionaryTerm(
    id: 'hist1',
    term: 'Революция',
    definition: 'Коренное, качественное изменение в развитии общества',
    category: 'История',
    addedDate: '2024-02-05',
  ),
  DictionaryTerm(
    id: 'hist2',
    term: 'Империя',
    definition: 'Монархическое государство во главе с императором',
    category: 'История',
    addedDate: '2024-02-06',
  ),

  // Обществознание
  DictionaryTerm(
    id: 'soc1',
    term: 'Государство',
    definition: 'Политическая организация общества с определенной формой правления',
    category: 'Обществознание',
    addedDate: '2024-02-07',
  ),
  DictionaryTerm(
    id: 'soc2',
    term: 'Право',
    definition: 'Совокупность установленных государством общеобязательных правил поведения',
    category: 'Обществознание',
    addedDate: '2024-02-08',
  ),

  // Информатика
  DictionaryTerm(
    id: 'info1',
    term: 'Алгоритм',
    definition: 'Конечная последовательность шагов для решения задачи',
    category: 'Информатика',
    addedDate: '2024-02-09',
  ),
  DictionaryTerm(
    id: 'info2',
    term: 'Программирование',
    definition: 'Процесс создания компьютерных программ',
    category: 'Информатика',
    addedDate: '2024-02-10',
  ),
];