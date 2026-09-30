import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

enum LoadStatus { loading, ready, error }

/// Holds the whole catalogue once and derives the curated home-page lists
/// (best deals, banners, category covers) from it.
class CatalogController extends ChangeNotifier {
  CatalogController(this._repo);

  final ProductRepository _repo;

  LoadStatus _status = LoadStatus.loading;
  List<Product> _all = [];
  Map<int, Product> _byId = {};

  LoadStatus get status => _status;
  bool get isOffline => _repo.usedFallback;

  Product? byId(int id) => _byId[id];

  Future<void> load({bool force = false}) async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _all = await _repo.getAll(force: force);
      _byId = {for (final p in _all) p.id: p};
      _status = LoadStatus.ready;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Products with the biggest discounts, for the "Best Deals" strip.
  List<Product> get bestDeals {
    final list = [..._all]
      ..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return list.take(10).toList();
  }

  Iterable<Product> _inCategory(ShopCategory c) =>
      _all.where((p) => c.slugs.contains(p.category));

  int countFor(ShopCategory c) => _inCategory(c).length;

  String? coverFor(ShopCategory c) {
    final list = _inCategory(c).where((p) => p.thumbnail.isNotEmpty).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.isEmpty ? null : list.first.thumbnail;
  }
}
