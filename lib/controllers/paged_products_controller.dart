import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_query.dart';
import '../services/product_repository.dart';
import 'catalog_controller.dart';

/// Drives every paginated product list in the app (home feed, best sellers,
/// category pages and search results).
///
/// INFINITE SCROLLING:
///  * The full query result lives in [_matches]; only [pageSize] more items
///    are moved into [items] each time [loadMore] is called.
///  * The view (PagedProductGrid) calls [loadMore] when the user scrolls near
///    the bottom, and shows a spinner while [isLoadingMore] is true.
///  * [_loadMoreDelay] simulates network latency so the loader is visible.
class PagedProductsController extends ChangeNotifier {
  PagedProductsController(
    this._repo, {
    ProductQuery query = const ProductQuery(),
    this.pageSize = 10,
    Duration loadMoreDelay = const Duration(milliseconds: 700),
  }) : _query = query,
       _loadMoreDelay = loadMoreDelay;

  final ProductRepository _repo;
  final int pageSize;
  final Duration _loadMoreDelay;

  ProductQuery _query;
  LoadStatus _status = LoadStatus.loading;
  List<Product> _matches = [];
  final List<Product> _items = [];
  bool _loadingMore = false;
  bool _everLoaded = false;
  bool _disposed = false;
  int _requestId = 0;

  /// Bumps whenever the list is rebuilt, so views can scroll back to the top.
  int generation = 0;

  ProductQuery get query => _query;
  LoadStatus get status => _status;
  List<Product> get items => List.unmodifiable(_items);
  int get totalMatches => _matches.length;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _items.length < _matches.length;
  bool get isEmpty => _status == LoadStatus.ready && _matches.isEmpty;

  /// (Re)loads the first page using the current query.
  Future<void> load({bool force = false}) async {
    final id = ++_requestId;
    if (!_everLoaded || force) {
      _status = LoadStatus.loading;
      _notify();
    }
    try {
      final all = await _repo.getAll(force: force);
      if (id != _requestId || _disposed) return;
      _matches = _query.apply(all);
      _items
        ..clear()
        ..addAll(_matches.take(pageSize));
      _status = LoadStatus.ready;
      _everLoaded = true;
      _loadingMore = false;
      generation++;
    } catch (_) {
      if (id != _requestId || _disposed) return;
      _status = LoadStatus.error;
    }
    _notify();
  }

  /// Appends the next page. Safe to call repeatedly from a scroll listener.
  Future<void> loadMore() async {
    if (_status != LoadStatus.ready || _loadingMore || !hasMore) return;
    final id = _requestId;
    _loadingMore = true;
    _notify();
    await Future<void>.delayed(_loadMoreDelay);
    if (_disposed || id != _requestId) return;
    _items.addAll(_matches.skip(_items.length).take(pageSize));
    _loadingMore = false;
    _notify();
  }

  /// Applies a new query (search text, filters, sort) and reloads page one.
  Future<void> updateQuery(ProductQuery q) {
    _query = q;
    return load();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
