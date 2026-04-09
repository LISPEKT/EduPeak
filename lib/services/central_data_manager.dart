// lib/services/central_data_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../data/user_data_storage.dart';
import 'api_service.dart';

class CentralDataManager extends ChangeNotifier {
  static final CentralDataManager _instance = CentralDataManager._internal();
  factory CentralDataManager() => _instance;
  CentralDataManager._internal();

  // Состояние загрузки
  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _hasError = false;
  String? _errorMessage;

  // Кэшированные данные
  UserStats _userStats = UserStats.defaultStats();
  String _username = '';
  String _avatar = '👤';
  int _totalXP = 0;
  int _weeklyXP = 0;
  int _streakDays = 0;
  String _currentLeague = 'Бронзовая';
  List<String> _selectedSubjects = [];
  int _completedTopics = 0;
  int _correctAnswers = 0;
  int _achievementsCompleted = 0;
  int _totalAchievements = 36;

  // Геттеры
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  UserStats get userStats => _userStats;
  String get username => _username;
  String get avatar => _avatar;
  int get totalXP => _totalXP;
  int get weeklyXP => _weeklyXP;
  int get streakDays => _streakDays;
  String get currentLeague => _currentLeague;
  List<String> get selectedSubjects => _selectedSubjects;
  int get completedTopics => _completedTopics;
  int get correctAnswers => _correctAnswers;
  int get achievementsCompleted => _achievementsCompleted;
  int get totalAchievements => _totalAchievements;

  // Инициализация
  Future<void> initialize({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) return;
    if (_isSyncing) return;

    _isSyncing = true;
    _hasError = false;
    _errorMessage = null;

    try {
      print('🔄 CentralDataManager: Загрузка данных...');

      // 1. Сначала загружаем из кэша
      await _loadFromCache();

      // 2. Затем синхронизируем с сервером
      await _syncWithServer();

      // 3. Загружаем выбранные предметы
      await _loadSelectedSubjects();

      _isInitialized = true;
      print('✅ CentralDataManager: Инициализация завершена. XP=$_totalXP');

    } catch (e) {
      print('❌ CentralDataManager: Ошибка: $e');
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Загрузка из кэша
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Загружаем данные из SharedPreferences
      _username = prefs.getString('username') ?? '';
      _totalXP = prefs.getInt('cached_total_xp') ?? 0;
      _weeklyXP = prefs.getInt('cached_weekly_xp') ?? 0;
      _streakDays = prefs.getInt('cached_streak_days') ?? 0;
      _currentLeague = _determineLeagueByXP(_totalXP);

      // Загружаем аватар
      final avatarPath = prefs.getString('user_avatar_path');
      if (avatarPath != null && avatarPath.isNotEmpty && !avatarPath.startsWith('http')) {
        _avatar = avatarPath;
      } else {
        _avatar = '👤';
      }

      // Загружаем статистику
      _completedTopics = prefs.getInt('cached_completed_topics') ?? 0;
      _correctAnswers = prefs.getInt('cached_correct_answers') ?? 0;
      _achievementsCompleted = prefs.getInt('cached_achievements_completed') ?? 0;

      // Загружаем полную статистику из UserStats
      _userStats = await UserDataStorage.getUserStats();
      if (_userStats.totalXP > 0 && _totalXP == 0) {
        _totalXP = _userStats.totalXP;
        _weeklyXP = _userStats.weeklyXP;
        _streakDays = _userStats.streakDays;
      }

      print('📦 CentralDataManager: Данные из кэша: XP=$_totalXP, Имя=$_username');

    } catch (e) {
      print('❌ CentralDataManager: Ошибка загрузки кэша: $e');
    }
  }

  // Синхронизация с сервером
  Future<void> _syncWithServer() async {
    try {
      final isLoggedIn = await UserDataStorage.isLoggedIn();
      if (!isLoggedIn) {
        print('⚠️ CentralDataManager: Пользователь не авторизован');
        return;
      }

      print('🔄 CentralDataManager: Синхронизация с сервером...');

      final prefs = await SharedPreferences.getInstance();

      // Используем рабочий эндпоинт /api/sync/all
      final syncResponse = await ApiService.syncAllUserData();

      if (syncResponse['success'] == true && syncResponse['data'] != null) {
        final data = syncResponse['data'];
        final xpData = data['xp'] ?? {};
        final profileData = data['profile'] ?? {};

        // Обновляем XP
        final serverTotalXP = xpData['totalXP'] as int? ?? 0;
        final serverWeeklyXP = xpData['weeklyXP'] as int? ?? 0;
        final serverStreakDays = xpData['streakDays'] as int? ?? 0;
        final serverLeague = xpData['currentLeague'] as String? ?? 'Бронзовая';

        if (serverTotalXP > 0) {
          _totalXP = serverTotalXP;
          _weeklyXP = serverWeeklyXP;
          _streakDays = serverStreakDays;
          _currentLeague = serverLeague;

          // Сохраняем в кэш
          await prefs.setInt('cached_total_xp', _totalXP);
          await prefs.setInt('cached_weekly_xp', _weeklyXP);
          await prefs.setInt('cached_streak_days', _streakDays);

          // Обновляем UserStats
          _userStats.totalXP = _totalXP;
          _userStats.weeklyXP = _weeklyXP;
          _userStats.streakDays = _streakDays;
          await UserDataStorage.saveUserStats(_userStats);

          print('✅ CentralDataManager: XP обновлен: $_totalXP, Лига: $_currentLeague');
        }

        // Обновляем имя пользователя
        if (profileData['name'] != null && profileData['name'] != _username) {
          _username = profileData['name'];
          await prefs.setString('username', _username);
          await UserDataStorage.saveUsername(_username);
        }

        // Обновляем аватар
        if (profileData['avatar'] != null) {
          final avatarUrl = profileData['avatar'];
          if (avatarUrl is String && avatarUrl.isNotEmpty) {
            await prefs.setString('user_avatar_url', avatarUrl);
          }
        }
      } else {
        print('⚠️ CentralDataManager: syncAllUserData вернул ошибку');
      }

      print('✅ CentralDataManager: Синхронизация завершена. XP=$_totalXP');

    } catch (e) {
      print('❌ CentralDataManager: Ошибка синхронизации: $e');
    }
  }

  // Загрузка выбранных предметов
  Future<void> _loadSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSubjects = prefs.getStringList('selectedSubjects');
      if (savedSubjects != null && savedSubjects.isNotEmpty) {
        _selectedSubjects = savedSubjects;
      } else {
        _selectedSubjects = await _getAllAvailableSubjects();
      }
      print('📚 CentralDataManager: Загружено предметов: ${_selectedSubjects.length}');
    } catch (e) {
      print('❌ CentralDataManager: Ошибка загрузки предметов: $e');
      _selectedSubjects = [];
    }
  }

  Future<List<String>> _getAllAvailableSubjects() async {
    return [
      'Математика', 'Русский язык', 'Литература', 'История',
      'Обществознание', 'География', 'Биология', 'Физика',
      'Химия', 'Английский язык', 'Информатика'
    ];
  }

  // Принудительное обновление
  Future<void> refresh() async {
    await initialize(forceRefresh: true);
  }

  // Добавление XP
  Future<void> addXP(int xp, String source) async {
    try {
      // Отправляем на сервер
      final response = await ApiService.addXP(xp, source);

      if (response['success'] == true) {
        _totalXP = response['new_total'] ?? (_totalXP + xp);
        _weeklyXP = response['new_weekly'] ?? (_weeklyXP + xp);
        _currentLeague = response['current_league'] ?? _determineLeagueByXP(_totalXP);

        if (response['streak_days'] != null) {
          _streakDays = response['streak_days'];
        }
      } else {
        // Если сервер не ответил, обновляем локально
        _totalXP += xp;
        _weeklyXP += xp;
        _currentLeague = _determineLeagueByXP(_totalXP);
      }

      // Обновляем UserStats
      _userStats.addXP(xp);
      await UserDataStorage.saveUserStats(_userStats);

      // Сохраняем в кэш
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_total_xp', _totalXP);
      await prefs.setInt('cached_weekly_xp', _weeklyXP);
      await prefs.setInt('cached_streak_days', _streakDays);

      notifyListeners();
      print('✅ CentralDataManager: Добавлено $xp XP. Всего: $_totalXP');

    } catch (e) {
      print('❌ CentralDataManager: Ошибка добавления XP: $e');
      // Локальное обновление в случае ошибки
      _totalXP += xp;
      _weeklyXP += xp;
      _userStats.addXP(xp);
      await UserDataStorage.saveUserStats(_userStats);
      notifyListeners();
    }
  }

  // Обновление профиля
  Future<void> updateProfile({String? username, String? avatar}) async {
    final prefs = await SharedPreferences.getInstance();

    if (username != null && username != _username) {
      _username = username;
      await UserDataStorage.saveUsername(username);
      await prefs.setString('username', username);

      // Обновляем на сервере
      if (await UserDataStorage.isLoggedIn()) {
        await ApiService.updateProfile(username, '');
      }
    }

    if (avatar != null && avatar != _avatar) {
      _avatar = avatar;
      await UserDataStorage.saveAvatar(avatar);
      await prefs.setString('user_avatar_path', avatar);
    }

    notifyListeners();
  }

  // Обновление выбранных предметов
  Future<void> updateSelectedSubjects(List<String> subjects) async {
    _selectedSubjects = subjects;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedSubjects', subjects);
    notifyListeners();
  }

  Future<void> clear() async {
    _userStats = UserStats.defaultStats();
    _username = '';
    _avatar = '👤';
    _totalXP = 0;
    _weeklyXP = 0;
    _streakDays = 0;
    _currentLeague = 'Бронзовая';
    _selectedSubjects = [];
    _completedTopics = 0;
    _correctAnswers = 0;
    _achievementsCompleted = 0;
    _isInitialized = false;
    notifyListeners();
  }

  String _determineLeagueByXP(int xp) {
    if (xp >= 5000) return 'Нереальная';
    if (xp >= 4000) return 'Легендарная';
    if (xp >= 3000) return 'Элитная';
    if (xp >= 2000) return 'Бриллиантовая';
    if (xp >= 1500) return 'Платиновая';
    if (xp >= 1000) return 'Золотая';
    if (xp >= 500) return 'Серебряная';
    return 'Бронзовая';
  }
}