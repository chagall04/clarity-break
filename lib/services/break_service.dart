// lib/services/break_service.dart
import 'dart:convert'; // For jsonEncode/Decode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/break_details.dart'; // Model for current break state
import '../models/past_break.dart'; // Model for history entries
// Removed import for post_break_log.dart

// Service responsible for managing break state and history persistence
class BreakService {
  // Keys used for storing data in SharedPreferences
  static const String _isActiveKey = 'isBreakActive';
  static const String _startDateKey = 'breakStartDate';
  static const String _userWhyKey = 'userWhy';
  static const String _historyKey = 'breakHistoryList'; // Key for storing break history
  // Removed _postBreakLogsKey

  // --- Public Methods ---

  // Retrieves the details of the currently active break, if any
  Future<BreakDetails> getCurrentBreakDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_isActiveKey) ?? false; // Check if a break is active

    if (!isActive) {
      return BreakDetails.none; // Return default 'no break' state
    }

    // If active, load start date and reason
    final startDateMillis = prefs.getInt(_startDateKey);
    final userWhy = prefs.getString(_userWhyKey);

    return BreakDetails(
      isActive: true,
      startDate: startDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(startDateMillis) // Convert stored millis to DateTime
          : null, // Handle unlikely case where date is missing
      userWhy: userWhy,
    );
  }

  // Starts a new tolerance break, saving its details
  Future<void> startBreak(String userWhy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isActiveKey, true); // Mark break as active
    await prefs.setInt(_startDateKey, DateTime.now().millisecondsSinceEpoch); // Store start time
    await prefs.setString(_userWhyKey, userWhy); // Store user's reason
  }

  // Ends the current break, saves it to history, and clears active break state
  Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final bool wasActive = prefs.getBool(_isActiveKey) ?? false;

    // Only proceed if a break was actually active
    if (wasActive) {
      // Retrieve details before clearing them
      final startDateMillis = prefs.getInt(_startDateKey);
      final userWhy = prefs.getString(_userWhyKey) ?? ''; // Default to empty string if null
      final endDate = DateTime.now(); // End date is the current time

      if (startDateMillis != null) {
        final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
        // Calculate duration in days (add 1 to include the start day)
        final duration = endDate.difference(startDate).inDays;
        final durationAchieved = (duration < 0 ? 0 : duration) + 1;
        const fullDuration = 28; // V1 fixed duration goal
        final completedFull = durationAchieved >= fullDuration; // Check if full duration was met

        // Create a record for the completed break
        final pastBreak = PastBreak(
          startDate: startDate,
          endDate: endDate,
          durationAchieved: durationAchieved,
          userWhy: userWhy,
          completedFullDuration: completedFull,
        );

        // Save this completed break to the history list
        await _saveBreakToHistory(pastBreak);
      }

      // Mark break as inactive and clear current break data from storage
      await prefs.setBool(_isActiveKey, false);
      await prefs.remove(_startDateKey);
      await prefs.remove(_userWhyKey);
    }
  }

  // Retrieves the list of past completed breaks from storage
  Future<List<PastBreak>> getBreakHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey); // Get history JSON string

    if (jsonString == null || jsonString.isEmpty) {
      return []; // Return empty list if no history saved
    }

    try {
      // Decode the JSON string into a List<dynamic> (list of maps)
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Map the JSON list to a List<PastBreak> using the model's factory constructor
      final List<PastBreak> history = jsonList
          .map((jsonItem) => PastBreak.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      // Ensure history is sorted newest first (although saving logic tries to maintain this)
      history.sort((a, b) => b.endDate.compareTo(a.endDate));
      return history;
    } catch (e) {
      // Handle errors during decoding (e.g., corrupted data)
      print('Error decoding break history: $e');
      return []; // Return empty list on error
    }
  }

  // --- Internal Helper Methods ---

  // Helper method to add a completed break to the history list in SharedPreferences
  Future<void> _saveBreakToHistory(PastBreak pastBreak) async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve existing history (already sorted newest first)
    final List<PastBreak> currentHistory = await getBreakHistory();
    // Add the new break to the beginning of the list
    currentHistory.insert(0, pastBreak);
    // Encode the updated list back to a JSON string
    final String jsonString = jsonEncode(
        currentHistory.map((breakItem) => breakItem.toJson()).toList()
    );
    // Save the updated JSON string
    await prefs.setString(_historyKey, jsonString);
  }

// TODO: Implement clearHistory method if needed for data reset feature
// Future<void> clearHistory() async { ... }

// Removed getPostBreakLogs, addPostBreakLog, clearPostBreakLogs methods
}