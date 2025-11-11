// lib/services/region_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/region.dart';

class RegionManager with ChangeNotifier {
  static const String _currentRegionKey = 'current_region';

  final List<Region> _availableRegions = [
    Region(
      id: 'ru',
      name: 'Россия',
      flag: '🇷🇺',
      totalGrades: 11,
      curriculum: {
        'Математика': 'Российская программа по математике',
        'Русский язык': 'Программа для российских школ',
        'История': 'История России и всемирная история',
        'Обществознание': 'Российская программа',
        'Физика': 'Российская программа по физике',
        'Химия': 'Российская программа по химии',
        'Биология': 'Российская программа по биологии',
        'География': 'География России и мира',
        'Литература': 'Русская и зарубежная литература',
        'Английский язык': 'Программа по английскому языку',
        'Информатика': 'Российская программа',
      },
      supportedLanguages: ['ru', 'en'],
      defaultLanguage: 'ru',
    ),
    Region(
      id: 'lt',
      name: 'Литва',
      flag: '🇱🇹',
      totalGrades: 12,
      curriculum: {
        'Математика': 'Литовская программа по математике',
        'Литовский язык': 'Государственный язык Литвы',
        'История': 'История Литвы и Европы',
        'Обществознание': 'Европейская программа',
        'Физика': 'Европейская программа по физике',
        'Химия': 'Европейская программа по химии',
        'Биология': 'Европейская программа по биологии',
        'География': 'География Европы и мира',
        'Литература': 'Литовская и европейская литература',
        'Английский язык': 'Программа ЕС по английскому',
        'Информатика': 'Европейская программа',
      },
      supportedLanguages: ['lt', 'en'],
      defaultLanguage: 'lt',
    ),
    Region(
      id: 'de',
      name: 'Германия',
      flag: '🇩🇪',
      totalGrades: 12,
      curriculum: {
        'Математика': 'Немецкая программа по математике',
        'Немецкий язык': 'Государственный язык Германии',
        'История': 'История Германии и Европы',
        'Обществознание': 'Европейская программа',
        'Физика': 'Европейская программа по физике',
        'Химия': 'Европейская программа по химии',
        'Биология': 'Европейская программа по биологии',
        'География': 'География Европы и мира',
        'Литература': 'Немецкая и европейская литература',
        'Английский язык': 'Программа ЕС по английскому',
        'Информатика': 'Европейская программа',
      },
      supportedLanguages: ['de', 'en'],
      defaultLanguage: 'de',
    ),
    Region(
      id: 'kz',
      name: 'Казахстан',
      flag: '🇰🇿',
      totalGrades: 11,
      curriculum: {
        'Математика': 'Казахстанская программа по математике',
        'Русский язык': 'Язык межнационального общения',
        'Казахский язык': 'Государственный язык',
        'История': 'История Казахстана и мира',
        'Обществознание': 'Программа РК',
        'Физика': 'Казахстанская программа по физике',
        'Химия': 'Казахстанская программа по химии',
        'Биология': 'Казахстанская программа по биологии',
        'География': 'География Казахстана и мира',
        'Литература': 'Казахская и русская литература',
        'Английский язык': 'Международная программа',
        'Информатика': 'Казахстанская программа',
      },
      supportedLanguages: ['ru', 'en', 'kz'],
      defaultLanguage: 'ru',
    ),
    Region(
      id: 'vn',
      name: 'Вьетнам',
      flag: '🇻🇳',
      totalGrades: 12,
      curriculum: {
        'Математика': 'Вьетнамская программа по математике',
        'Вьетнамский язык': 'Государственный язык',
        'История': 'История Вьетнама и Азии',
        'Обществознание': 'Азиатская программа',
        'Физика': 'Азиатская программа по физике',
        'Химия': 'Азиатская программа по химии',
        'Биология': 'Азиатская программа по биологии',
        'География': 'География Азии и мира',
        'Литература': 'Вьетнамская и азиатская литература',
        'Английский язык': 'Международная программа',
        'Информатика': 'Азиатская программа',
      },
      supportedLanguages: ['vi', 'en'],
      defaultLanguage: 'vi',
    ),
    Region(
      id: 'by',
      name: 'Беларусь',
      flag: '🇧🇾',
      totalGrades: 11,
      curriculum: {
        'Математика': 'Белорусская программа по математике',
        'Русский язык': 'Государственный язык',
        'Белорусский язык': 'Государственный язык',
        'История': 'История Беларуси и мира',
        'Обществознание': 'Белорусская программа',
        'Физика': 'Белорусская программа по физике',
        'Химия': 'Белорусская программа по химии',
        'Биология': 'Белорусская программа по биологии',
        'География': 'География Беларуси и мира',
        'Литература': 'Белорусская и русская литература',
        'Английский язык': 'Международная программа',
        'Информатика': 'Белорусская программа',
      },
      supportedLanguages: ['ru', 'en', 'be'],
      defaultLanguage: 'ru',
    ),
  ];

  late Region _currentRegion;
  bool _isLoading = false;

  Region get currentRegion => _currentRegion;
  List<Region> get availableRegions => _availableRegions;
  bool get isLoading => _isLoading;

  RegionManager() {
    _currentRegion = _availableRegions.first;
    _loadCurrentRegion();
  }

  Future<void> _loadCurrentRegion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regionId = prefs.getString(_currentRegionKey) ?? 'ru';

      final region = _availableRegions.firstWhere(
            (r) => r.id == regionId,
        orElse: () => _availableRegions.first,
      );

      _currentRegion = region;
      notifyListeners();
      print('✅ Region loaded: ${region.name}');
    } catch (e) {
      print('❌ Error loading region: $e');
    }
  }

  Future<String?> setCurrentRegion(String regionId, {String? currentLanguage}) async {
    if (_isLoading) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final region = _availableRegions.firstWhere(
            (r) => r.id == regionId,
        orElse: () => _availableRegions.first,
      );

      final oldRegion = _currentRegion;
      _currentRegion = region;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentRegionKey, regionId);

      print('✅ Region changed to: ${region.name}');

      // Проверяем поддержку текущего языка в новом регионе
      String? languageChangeMessage;
      if (currentLanguage != null && !region.supportedLanguages.contains(currentLanguage)) {
        final defaultLanguage = region.defaultLanguage;
        languageChangeMessage = 'Текущий язык не поддерживается в регионе ${region.name}. Язык изменен на $defaultLanguage.';
      }

      notifyListeners();
      return languageChangeMessage;
    } catch (e) {
      print('❌ Error changing region: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Region getRegionById(String regionId) {
    return _availableRegions.firstWhere(
          (r) => r.id == regionId,
      orElse: () => _availableRegions.first,
    );
  }

  List<int> getAvailableGrades() {
    return List.generate(currentRegion.totalGrades, (index) => index + 1);
  }

  bool hasSubject(String subjectName) {
    return currentRegion.curriculum.containsKey(subjectName);
  }

  List<String> getAvailableSubjects() {
    return currentRegion.curriculum.keys.toList();
  }

  List<String> getSupportedLanguagesForCurrentRegion() {
    return currentRegion.supportedLanguages;
  }

  bool isLanguageSupportedInCurrentRegion(String languageCode) {
    return currentRegion.supportedLanguages.contains(languageCode);
  }

  String getDefaultLanguageForCurrentRegion() {
    return currentRegion.defaultLanguage;
  }

  String getCurriculumDescription(String subjectName) {
    return currentRegion.curriculum[subjectName] ?? 'Стандартная программа';
  }

  // Получить все доступные языки для всех регионов (уникальные)
  List<String> getAllAvailableLanguages() {
    final allLanguages = <String>{};
    for (final region in _availableRegions) {
      allLanguages.addAll(region.supportedLanguages);
    }
    return allLanguages.toList();
  }

  // Получить регионы, поддерживающие определенный язык
  List<Region> getRegionsSupportingLanguage(String languageCode) {
    return _availableRegions.where((region) => region.supportedLanguages.contains(languageCode)).toList();
  }

  // Проверить, доступен ли предмет в текущем регионе
  bool isSubjectAvailable(String subjectName) {
    return hasSubject(subjectName);
  }

  // Получить информацию о регионе в виде строки
  String getRegionInfo() {
    return '${currentRegion.name} ${currentRegion.flag} - ${currentRegion.totalGrades} классов, ${currentRegion.curriculum.length} предметов';
  }

  // Сбросить регион к значению по умолчанию
  Future<void> resetToDefault() async {
    await setCurrentRegion('ru');
  }

  // Получить список всех ID регионов
  List<String> getAllRegionIds() {
    return _availableRegions.map((region) => region.id).toList();
  }

  // Получить регион по индексу
  Region getRegionByIndex(int index) {
    if (index >= 0 && index < _availableRegions.length) {
      return _availableRegions[index];
    }
    return _availableRegions.first;
  }

  // Получить индекс текущего региона
  int getCurrentRegionIndex() {
    return _availableRegions.indexWhere((region) => region.id == _currentRegion.id);
  }

  // Проверить, является ли регион текущим
  bool isCurrentRegion(String regionId) {
    return _currentRegion.id == regionId;
  }
}

// Extension для удобного доступа в виджетах
extension RegionManagerExtension on BuildContext {
  RegionManager get regionManager => RegionManager();
  Region get currentRegion => RegionManager().currentRegion;
  List<Region> get availableRegions => RegionManager().availableRegions;
}