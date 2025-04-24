// lib/services/break_service.dart
import 'dart:convert'; // For jsonEncode/Decode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/break_details.dart';
import '../models/past_break.dart';
import '../models/post_break_log.dart'; // Import Log model

class BreakService {
  // Keys for SharedPreferences
  static const String _isActiveKey = 'isBreakActive';
  static const String _startDateKey = 'breakStartDate';
  static const String _userWhyKey = 'userWhy';
  static const String _historyKey = 'breakHistoryList';
  static const String _postBreakLogsKey = 'postBreakLogsList'; // Key for logs

  // --- Break Management Methods (Keep existing getCurrentBreakDetails, startBreak, endBreak, getBreakHistory, _saveBreakToHistory) ---
  Future<BreakDetails> getCurrentBreakDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_isActiveKey) ?? false;

    if (!isActive) {
      return BreakDetails.none;
    }

    final startDateMillis = prefs.getInt(_startDateKey);
    final userWhy = prefs.getString(_userWhyKey);

    return BreakDetails(
      isActive: true,
      startDate: startDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(startDateMillis)
          : null,
      userWhy: userWhy,
    );
  }

  Future<void> startBreak(String userWhy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isActiveKey, true);
    await prefs.setInt(_startDateKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_userWhyKey, userWhy);
    // *** Optional: Clear previous logs when starting a new break? ***
    // Consider if logs should persist across multiple breaks or reset.
    // For V1 simplicity, let's NOT clear them automatically here.
    // await clearPostBreakLogs();
  }

  Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final bool wasActive = prefs.getBool(_isActiveKey) ?? false;

    if (wasActive) {
      final startDateMillis = prefs.getInt(_startDateKey);
      final userWhy = prefs.getString(_userWhyKey) ?? '';
      final endDate = DateTime.now();

      if (startDateMillis != null) {
        final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
        final duration = endDate.difference(startDate).inDays;
        final durationAchieved = (duration < 0 ? 0 : duration) + 1;
        const fullDuration = 28;
        final completedFull = durationAchieved >= fullDuration;

        final pastBreak = PastBreak(
          startDate: startDate,
          endDate: endDate,
          durationAchieved: durationAchieved,
          userWhy: userWhy,
          completedFullDuration: completedFull,
        );
        await _saveBreakToHistory(pastBreak);
      }

      await prefs.setBool(_isActiveKey, false);
      await prefs.remove(_startDateKey);
      await prefs.remove(_userWhyKey);
    }
  }

  Future<List<PastBreak>> getBreakHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<PastBreak> history = jsonList
          .map((jsonItem) => PastBreak.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      history.sort((a, b) => b.endDate.compareTo(a.endDate)); // Sort newest first
      return history;
    } catch (e) {
      print('Error decoding break history: $e');
      return [];
    }
  }

  Future<void> _saveBreakToHistory(PastBreak pastBreak) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PastBreak> currentHistory = await getBreakHistory(); // Retrieve sorted
    // Insert at the beginning to maintain sort order easily
    currentHistory.insert(0, pastBreak);
    final String jsonString = jsonEncode(
        currentHistory.map((breakItem) => breakItem.toJson()).toList()
    );
    await prefs.setString(_historyKey, jsonString);
  }

  // --- NEW: Post-Break Logging Methods ---

  // Retrieve all saved post-break logs
  Future<List<PostBreakLog>> getPostBreakLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_postBreakLogsKey); // Get logs JSON

    if (jsonString == null || jsonString.isEmpty) {
      return []; // Return empty list if no logs saved
    }

    try {
      // Decode JSON string to List<dynamic> (list of maps)
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Map JSON to List<PostBreakLog>
      final List<PostBreakLog> logs = jsonList
          .map((jsonItem) => PostBreakLog.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      // Sort logs chronologically (newest first)
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    } catch (e) {
      print('Error decoding post-break logs: $e');
      // Optionally clear corrupted logs: await prefs.remove(_postBreakLogsKey);
      return []; // Return empty list on error
    }
  }

  // Add a new log entry to the list
  Future<void> addPostBreakLog(PostBreakLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PostBreakLog> currentLogs = await getPostBreakLogs(); // Retrieve sorted logs
    // Add the new log to the beginning to maintain sort order
    currentLogs.insert(0, log);
    // Encode the updated list back to JSON
    final String jsonString = jsonEncode(
        currentLogs.map((logItem) => logItem.toJson()).toList()
    );
    // Save the updated JSON string
    await prefs.setString(_postBreakLogsKey, jsonString);
  }

  // Optional: Method to clear all post-break logs
  Future<void> clearPostBreakLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postBreakLogsKey);
    print("Post-break logs cleared.");
  }
}