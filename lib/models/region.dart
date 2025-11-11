// lib/models/region.dart
class Region {
  final String id;
  final String name;
  final String flag;
  final int totalGrades;
  final Map<String, String> curriculum;
  final List<String> supportedLanguages;
  final String defaultLanguage;

  Region({
    required this.id,
    required this.name,
    required this.flag,
    required this.totalGrades,
    required this.curriculum,
    required this.supportedLanguages,
    required this.defaultLanguage,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      flag: json['flag'],
      totalGrades: json['totalGrades'],
      curriculum: Map<String, String>.from(json['curriculum']),
      supportedLanguages: List<String>.from(json['supportedLanguages']),
      defaultLanguage: json['defaultLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'flag': flag,
      'totalGrades': totalGrades,
      'curriculum': curriculum,
      'supportedLanguages': supportedLanguages,
      'defaultLanguage': defaultLanguage,
    };
  }

  @override
  String toString() => 'Region($name, $totalGrades классов)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Region &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}