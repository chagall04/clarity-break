// lib/services/bookmark_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarkedArticles';
  Future<Set<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<bool> isBookmarked(String id) async =>
      (await _load()).contains(id);

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await _load();
    if (!set.remove(id)) set.add(id);
    await prefs.setStringList(_key, set.toList());
  }
}
