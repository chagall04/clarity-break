// lib/services/break_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/break_details.dart';
import '../models/past_break.dart';

/// Service responsible for managing break state and history persistence.
class BreakService {
  // Keys used for storing data in SharedPreferences
  static const String _isActiveKey = 'isBreakActive';
  static const String _startDateKey = 'breakStartDate';
  static const String _userWhyKey = 'userWhy';
  static const String _durationKey = 'breakDuration';
  static const String _historyKey = 'breakHistoryList';

  /// Retrieves the details of the currently active break.
  Future<BreakDetails> getCurrentBreakDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_isActiveKey) ?? false;

    if (!isActive) {
      // No active break → return default
      return BreakDetails.none;
    }

    final startMillis = prefs.getInt(_startDateKey);
    final userWhy = prefs.getString(_userWhyKey);
    // Load the planned duration (fallback to 28 days)
    final totalDuration = prefs.getInt(_durationKey) ?? 28;

    return BreakDetails(
      isActive: true,
      startDate: startMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(startMillis)
          : null,
      userWhy: userWhy,
      totalDuration: totalDuration,
    );
  }

  /// Starts a new tolerance break, saving its reason and planned duration.
  Future<void> startBreak(String userWhy, int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isActiveKey, true);
    await prefs.setInt(
        _startDateKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_userWhyKey, userWhy);
    await prefs.setInt(_durationKey, duration);
    debugPrint("Break started: $duration days, why: $userWhy");
  }

  /// Ends the current break, records it in history, and clears active state.
  Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final wasActive = prefs.getBool(_isActiveKey) ?? false;
    if (!wasActive) {
      debugPrint("No active break to end.");
      return;
    }

    final startMillis = prefs.getInt(_startDateKey);
    final userWhy = prefs.getString(_userWhyKey) ?? '';
    final intendedDuration = prefs.getInt(_durationKey) ?? 28;
    final endDate = DateTime.now();

    if (startMillis != null) {
      final startDate =
      DateTime.fromMillisecondsSinceEpoch(startMillis);
      final rawDays = endDate.difference(startDate).inDays;
      final durationAchieved = (rawDays < 0 ? 0 : rawDays) + 1;
      final completedFull = durationAchieved >= intendedDuration;

      final pastBreak = PastBreak(
        startDate: startDate,
        endDate: endDate,
        durationAchieved: durationAchieved,
        intendedDuration: intendedDuration,
        userWhy: userWhy,
        completedFullDuration: completedFull,
      );

      await _saveBreakToHistory(pastBreak);
      debugPrint(
          "Saved to history: $durationAchieved / $intendedDuration days.");
    } else {
      debugPrint("Cannot save history: start date missing.");
    }

    // Clear active break data
    await prefs.setBool(_isActiveKey, false);
    await prefs.remove(_startDateKey);
    await prefs.remove(_userWhyKey);
    await prefs.remove(_durationKey);
    debugPrint("Cleared active break state.");
  }

  /// Loads the list of past breaks from storage.
  Future<List<PastBreak>> getBreakHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final history = decoded
          .map((e) => PastBreak.fromJson(e as Map<String, dynamic>))
          .toList();
      history.sort((a, b) => b.endDate.compareTo(a.endDate));
      return history;
    } catch (e) {
      debugPrint("Error decoding history: $e");
      return [];
    }
  }

  /// Clears the entire break history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    debugPrint("Break history cleared.");
  }

  /// Internal: inserts a completed break at the front of history and saves.
  Future<void> _saveBreakToHistory(PastBreak b) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBreakHistory();
    current.insert(0, b);
    final encoded =
    jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }
}
