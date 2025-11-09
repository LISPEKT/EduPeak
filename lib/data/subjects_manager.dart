// lib/data/subjects_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subjects_data.dart';
import '../models/subject.dart';

class SubjectsManager with ChangeNotifier {
  Map<int, List<Subject>> _subjectsByGrade = {};
  BuildContext? _context;

  SubjectsManager();

  void setContext(BuildContext context) {
    _context = context;
    _loadSubjects();
  }

  Map<int, List<Subject>> get subjectsByGrade => _subjectsByGrade;

  void _loadSubjects() {
    if (_context != null) {
      _subjectsByGrade = getSubjectsByGrade(_context!);
      notifyListeners();
    }
  }

  void updateSubjectsForLanguage(BuildContext context) {
    _context = context;
    _loadSubjects();
  }

  List<Subject> getSubjectsForGrade(int grade) {
    return _subjectsByGrade[grade] ?? [];
  }

  List<String> getSubjectNamesForGrade(int grade) {
    return _subjectsByGrade[grade]?.map((s) {
      final localizedNames = getLocalizedSubjectNames(_context!);
      final localizedName = localizedNames[s.name] ?? s.name;
      return localizedName;
    }).where((name) => name.isNotEmpty).toList() ?? [];
  }

  Subject? getSubjectByName(String name, int grade) {
    final subjects = getSubjectsForGrade(grade);
    final localizedNames = getLocalizedSubjectNames(_context!);

    for (final subject in subjects) {
      final localizedName = localizedNames[subject.name] ?? subject.name;
      if (localizedName == name) {
        return subject;
      }
    }

    try {
      return subjects.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  String getLocalizedSubjectName(String subjectName) {
    if (_context == null) return subjectName;
    final localizedNames = getLocalizedSubjectNames(_context!);
    return localizedNames[subjectName] ?? subjectName;
  }
}