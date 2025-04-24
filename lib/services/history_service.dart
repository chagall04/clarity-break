// lib/services/history_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _viewKey = 'recentViews';
  static const _searchKey = 'recentSearches';
  Future<List<String>> _load(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(key) ?? [];
  }

  Future<void> addView(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = (await _load(_viewKey));
    list.remove(id);
    list.insert(0, id);
    if (list.length > 10) list.removeLast();
    await p.setStringList(_viewKey, list);
  }

  Future<List<String>> getViews() => _load(_viewKey);

  Future<void> addSearch(String term) async {
    final p = await SharedPreferences.getInstance();
    final list = (await _load(_searchKey));
    list.remove(term);
    list.insert(0, term);
    if (list.length > 10) list.removeLast();
    await p.setStringList(_searchKey, list);
  }

  Future<List<String>> getSearches() => _load(_searchKey);
}
