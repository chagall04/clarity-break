// lib/services/break_service.dart
import 'dart:convert'; // For jsonEncode/Decode
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import '../models/break_details.dart'; // Model for current break state
import '../models/past_break.dart'; // Model for history entries

// Service responsible for managing break state and history persistence using SharedPreferences
class BreakService {
  // Keys used for storing data
  static const String _isActiveKey = 'isBreakActive';
  static const String _startDateKey = 'breakStartDate';
  static const String _userWhyKey = 'userWhy';
  static const String _historyKey = 'breakHistoryList'; // Key for storing break history list

  // --- Public Methods ---

  // Retrieves the details of the currently active break, if any
  Future<BreakDetails> getCurrentBreakDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_isActiveKey) ?? false; // Check if a break is active

    if (!isActive) {
      return BreakDetails.none; // Return default 'no break' state if inactive
    }

    // If active, load start date (stored as millis) and user's reason
    final startDateMillis = prefs.getInt(_startDateKey);
    final userWhy = prefs.getString(_userWhyKey);

    return BreakDetails(
      isActive: true,
      startDate: startDateMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(startDateMillis) // Convert stored millis to DateTime
          : null, // Handle case where date might be missing (shouldn't happen ideally)
      userWhy: userWhy,
    );
  }

  // Starts a new tolerance break, saving its details
  Future<void> startBreak(String userWhy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isActiveKey, true); // Mark break as active
    await prefs.setInt(_startDateKey, DateTime.now().millisecondsSinceEpoch); // Store start time as millis
    await prefs.setString(_userWhyKey, userWhy); // Store user's reason
    debugPrint("Break started. Why: $userWhy");
  }

  // Ends the current break, saves it to history, and clears active break state
  Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final bool wasActive = prefs.getBool(_isActiveKey) ?? false; // Check if a break was active

    // Only proceed if a break was actually active
    if (wasActive) {
      debugPrint("Ending active break...");
      // Retrieve details before clearing them
      final startDateMillis = prefs.getInt(_startDateKey);
      final userWhy = prefs.getString(_userWhyKey) ?? ''; // Default to empty string if null
      final endDate = DateTime.now(); // End date is the current time

      if (startDateMillis != null) {
        final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
        // Calculate duration in days (add 1 to include the start day)
        final duration = endDate.difference(startDate).inDays;
        final durationAchieved = (duration < 0 ? 0 : duration) + 1; // Ensure non-negative duration
        const fullDuration = 28; // V1 fixed duration goal
        final completedFull = durationAchieved >= fullDuration; // Check if goal was met

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
        debugPrint("Break saved to history. Duration: $durationAchieved days.");
      } else {
        debugPrint("Warning: Could not save break to history, start date missing.");
      }

      // Mark break as inactive and clear current break data from storage
      await prefs.setBool(_isActiveKey, false);
      await prefs.remove(_startDateKey);
      await prefs.remove(_userWhyKey);
      debugPrint("Active break state cleared.");
    } else {
      debugPrint("Attempted to end break, but no break was active.");
    }
  }

  // Retrieves the list of past completed breaks from storage
  Future<List<PastBreak>> getBreakHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey); // Get stored history JSON

    if (jsonString == null || jsonString.isEmpty) {
      return []; // Return empty list if no history is saved
    }

    try {
      // Decode the JSON string into a List of Maps
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Map each JSON Map to a PastBreak object using the factory constructor
      final List<PastBreak> history = jsonList
          .map((jsonItem) => PastBreak.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      // Ensure history is sorted newest first (end date descending)
      history.sort((a, b) => b.endDate.compareTo(a.endDate));
      return history;
    } catch (e) {
      // Handle potential errors during JSON decoding
      debugPrint('Error decoding break history: $e');
      // Consider clearing corrupted data: await prefs.remove(_historyKey);
      return []; // Return empty list on error
    }
  }

  // --- NEW: Clears the saved break history list ---
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey); // Remove the history data from storage
    debugPrint("Break history cleared.");
  }

  // --- Internal Helper Methods ---

  // Helper method to add a completed break to the history list in SharedPreferences
  Future<void> _saveBreakToHistory(PastBreak pastBreak) async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve existing history (already sorted newest first from getBreakHistory)
    final List<PastBreak> currentHistory = await getBreakHistory();
    // Add the new break to the beginning of the list to maintain order
    currentHistory.insert(0, pastBreak);
    // Encode the updated list back to a JSON string
    final String jsonString = jsonEncode(
        currentHistory.map((breakItem) => breakItem.toJson()).toList()
    );
    // Save the updated JSON string back to SharedPreferences
    await prefs.setString(_historyKey, jsonString);
  }
}