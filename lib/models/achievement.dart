// lib/models/achievement.dart

import 'package:flutter/foundation.dart';

/// Defines a single badge/achievement the user can earn.
class Achievement {
  final String id;                // Unique key
  final String title;             // Display name
  final String description;       // What it represents
  final String iconAsset;         // Path to badge icon
  bool unlocked;                  // Whether it's earned
  DateTime? dateUnlocked;         // When it was earned

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.unlocked = false,
    this.dateUnlocked,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlocked': unlocked,
    'dateUnlocked': dateUnlocked?.toIso8601String(),
  };

  static Achievement fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      id: template.id,
      title: template.title,
      description: template.description,
      iconAsset: template.iconAsset,
      unlocked: json['unlocked'] as bool? ?? false,
      dateUnlocked: json['dateUnlocked'] != null
          ? DateTime.parse(json['dateUnlocked'] as String)
          : null,
    );
  }
}
