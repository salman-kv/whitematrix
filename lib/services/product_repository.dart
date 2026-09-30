import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/product.dart';
import 'mock_data.dart';

/// Loads the product catalogue from the public DummyJSON API
/// (https://dummyjson.com) and caches it for the lifetime of the app.
/// If the network is unavailable it falls back to bundled mock data.
class ProductRepository {
  ProductRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  Future<List<Product>>? _cache;

  /// True when the last load could not reach the API.
  bool usedFallback = false;

  static const _fields =
      'id,title,description,category,price,'
      'discountPercentage,rating,brand,thumbnail,images,stock';

  Future<List<Product>> getAll({bool force = false}) {
    if (force) _cache = null;
    return _cache ??= _load();
  }

  Future<List<Product>> _load() async {
    try {
      final res = await _client
          .get(
            Uri.parse('https://dummyjson.com/products?limit=0&select=$_fields'),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final all = (data['products'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .where((p) => ShopCategory.allSlugs.contains(p.category))
          .toList();
      // The API returns items grouped by category; shuffle with a fixed seed so
      // the default feed is varied but identical on every launch.
      all.shuffle(Random(7));
      usedFallback = false;
      return all;
    } catch (_) {
      usedFallback = true;
      return MockData.products()..shuffle(Random(7));
    }
  }
}
