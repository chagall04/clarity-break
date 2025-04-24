// lib/services/journal_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Use uuid package for unique IDs
import '../models/journal_entry.dart';

class JournalService {
  static const String _journalEntriesKey = 'journalEntriesList';
  final Uuid _uuid = const Uuid(); // Instance for generating IDs

  // Retrieve all journal entries, sorted newest first
  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_journalEntriesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<JournalEntry> entries = jsonList
          .map((jsonItem) => JournalEntry.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      // Sort entries by date, newest first
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      print('Error decoding journal entries: $e');
      // await prefs.remove(_journalEntriesKey); // Option: Clear corrupted data
      return [];
    }
  }

  // Add a new journal entry
  Future<void> addJournalEntry(JournalEntry entry) async {
    // Ensure entry has a unique ID (generate if needed, though constructor does it)
    final entryWithId = JournalEntry(
      id: entry.id.isEmpty ? _uuid.v4() : entry.id, // Use existing or generate v4 UUID
      date: entry.date,
      entryType: entry.entryType,
      moodRating: entry.moodRating,
      changesNoticed: entry.changesNoticed,
      cravingsPresentCheckin: entry.cravingsPresentCheckin,
      usageAmount: entry.usageAmount,
      usageType: entry.usageType,
      usagePotency: entry.usagePotency,
      usageEffects: entry.usageEffects,
      moodRatingUsage: entry.moodRatingUsage,
      cravingsPresentAbstinence: entry.cravingsPresentAbstinence,
      notes: entry.notes,
    );


    final prefs = await SharedPreferences.getInstance();
    final List<JournalEntry> currentEntries = await getJournalEntries(); // Get sorted list

    // Insert new entry at the beginning to maintain sort order easily
    currentEntries.insert(0, entryWithId);

    final String jsonString = jsonEncode(
        currentEntries.map((entryItem) => entryItem.toJson()).toList()
    );
    await prefs.setString(_journalEntriesKey, jsonString);
  }

  // Optional: Delete an entry by ID
  Future<void> deleteJournalEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<JournalEntry> currentEntries = await getJournalEntries();
    currentEntries.removeWhere((entry) => entry.id == id); // Remove matching entry

    final String jsonString = jsonEncode(
        currentEntries.map((entryItem) => entryItem.toJson()).toList()
    );
    await prefs.setString(_journalEntriesKey, jsonString);
  }


  // Optional: Clear all journal entries
  Future<void> clearAllJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_journalEntriesKey);
    print("All journal entries cleared.");
  }
}