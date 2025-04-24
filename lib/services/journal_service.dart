// lib/services/journal_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';

class JournalService {
  static const String _journalEntriesKey = 'journalEntriesList';
  final Uuid _uuid = const Uuid();

  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_journalEntriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final entries = jsonList
          .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      debugPrint('Error decoding journal entries: $e');
      return [];
    }
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    final entryWithId = JournalEntry(
      id: entry.id.isEmpty ? _uuid.v4() : entry.id,
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
    final current = await getJournalEntries();
    current.insert(0, entryWithId);
    final jsonString = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_journalEntriesKey, jsonString);
  }

  Future<void> deleteJournalEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getJournalEntries();
    current.removeWhere((entry) => entry.id == id);
    final jsonString = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_journalEntriesKey, jsonString);
  }

  Future<void> clearAllJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_journalEntriesKey);
    debugPrint("All journal entries cleared.");
  }
}
