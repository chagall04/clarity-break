// lib/services/data_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

class DataService {
  static const _historyKey = 'breakHistoryList';
  static const _journalKey = 'journalEntriesList';

  /// Exports both history and journal JSON into a single file and shares it.
  static Future<void> exportData() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clarity_break_backup.json');
      // Assume you gather both prefs keys into one map
      final Map<String, dynamic> backup = {
        'history': await _loadKey(_historyKey),
        'journal': await _loadKey(_journalKey),
      };
      await file.writeAsString(jsonEncode(backup));
      await Share.shareXFiles([XFile(file.path)],
          text: 'Here is my Clarity Break backup.');
    } catch (e) {
      debugPrint('Export failed: $e');
      rethrow;
    }
  }

  /// Prompts user to pick a JSON file, loads it, and writes into prefs.
  static Future<bool> importData() async {
    try {
      // Use file_selector instead of file_picker:
      final typeGroup = XTypeGroup(label: 'json', extensions: ['json']);
      final XFile? picked =
      await openFile(acceptedTypeGroups: [typeGroup], confirmButtonText: 'Import');
      if (picked == null) return false;

      final content = await picked.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      await _saveKey(_historyKey, data['history']);
      await _saveKey(_journalKey, data['journal']);
      return true;
    } catch (e) {
      debugPrint('Import failed: $e');
      return false;
    }
  }

  static Future<dynamic> _loadKey(String key) async {
    // TODO: implement your SharedPreferences loading
    return null;
  }

  static Future<void> _saveKey(String key, dynamic value) async {
    // TODO: implement your SharedPreferences saving
  }
}
