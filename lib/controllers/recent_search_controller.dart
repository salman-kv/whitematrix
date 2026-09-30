import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class RecentSearchController extends ChangeNotifier {
  RecentSearchController(this._storage)
    : _items = _storage.readRecentSearches();

  final StorageService _storage;
  final List<String> _items;

  List<String> get items => List.unmodifiable(_items);

  /// Re-reads the active account's searches (after login / logout).
  void reload() {
    _items
      ..clear()
      ..addAll(_storage.readRecentSearches());
    notifyListeners();
  }

  void add(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    _items.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    _items.insert(0, t);
    if (_items.length > 8) _items.removeLast();
    _save();
  }

  void remove(String term) {
    _items.remove(term);
    _save();
  }

  void clear() {
    _items.clear();
    _save();
  }

  void _save() {
    _storage.saveRecentSearches(_items);
    notifyListeners();
  }
}
