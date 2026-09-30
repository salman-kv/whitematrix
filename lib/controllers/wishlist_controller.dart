import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Stores wishlisted product ids (persisted). Products are resolved from the
/// catalogue by the view.
class WishlistController extends ChangeNotifier {
  WishlistController(this._storage) : _ids = _storage.readWishlist();

  /// Re-reads the active account's wishlist (after login / logout).
  void reload() {
    _ids
      ..clear()
      ..addAll(_storage.readWishlist());
    notifyListeners();
  }

  final StorageService _storage;
  final Set<int> _ids;

  List<int> get ids => _ids.toList().reversed.toList(); // newest first
  bool contains(int id) => _ids.contains(id);

  void toggle(int id) {
    if (!_ids.remove(id)) _ids.add(id);
    _storage.saveWishlist(_ids);
    notifyListeners();
  }
}
