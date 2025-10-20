// lib/models/user_profile.dart
class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl;
  final int streak;
  final DateTime? lastActivity;

  UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.streak = 0,
    this.lastActivity,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      streak: json['streak'] ?? 0,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'streak': streak,
      'last_activity': lastActivity?.toIso8601String(),
    };
  }
}