// lib/services/achievement_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class AchievementService {
  static const _storageKey = 'achievements';

  /// List of all possible badges, templates only.
  final List<Achievement> _templates = [
    Achievement(
      id: 'break_7',
      title: 'One Week Strong',
      description: 'Complete a 7-day clarity break',
      iconAsset: 'assets/badges/week7.png',
    ),
    Achievement(
      id: 'break_14',
      title: 'Two Weeks In',
      description: 'Complete a 14-day clarity break',
      iconAsset: 'assets/badges/week14.png',
    ),
    Achievement(
      id: 'break_21',
      title: 'Three Weeks Up',
      description: 'Complete a 21-day clarity break',
      iconAsset: 'assets/badges/week21.png',
    ),
    Achievement(
      id: 'journal_10',
      title: 'Consistent Logger',
      description: 'Log 10 journal entries',
      iconAsset: 'assets/badges/journal10.png',
    ),
    // Add more templates here...
  ];

  Future<List<Achievement>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return _templates.map((t) => Achievement(
        id: t.id,
        title: t.title,
        description: t.description,
        iconAsset: t.iconAsset,
      )).toList();
    }
    final Map<String, dynamic> data = jsonDecode(raw);
    return _templates.map((template) {
      final json = data[template.id] as Map<String, dynamic>? ?? {};
      return Achievement.fromJson(json, template);
    }).toList();
  }

  Future<void> saveAll(List<Achievement> list) async {
    final prefs = await SharedPreferences.getInstance();
    final map = { for (var a in list) a.id : a.toJson() };
    await prefs.setString(_storageKey, jsonEncode(map));
  }
}
