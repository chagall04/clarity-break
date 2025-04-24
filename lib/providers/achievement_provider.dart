// lib/providers/achievement_provider.dart
import 'package:flutter/material.dart';
import '../services/journal_service.dart';
import '../services/break_service.dart';

class AchievementProvider with ChangeNotifier {
  // Dummy stub: load achievements from usage patterns / streaks
  void load() {
    // TODO: implement actual persistence
    notifyListeners();
  }

// TODO: methods to track journal entries, completed breaks, milestones, etc.
}
