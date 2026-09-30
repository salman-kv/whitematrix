import '../models/product.dart';

enum SortOption {
  relevance('Relevance'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low'),
  rating('Customer Rating'),
  discount('Biggest Discount');

  final String label;
  const SortOption(this.label);
}

/// Pure filtering + sorting logic (no Flutter, no I/O) so it is easy to test.
class ProductQuery {
  final String search;
  final Set<String> slugs; // empty = every category
  final SortOption sort;
  final double minPrice;
  final double? maxPrice; // null = no upper limit

  const ProductQuery({
    this.search = '',
    this.slugs = const {},
    this.sort = SortOption.relevance,
    this.minPrice = 0,
    this.maxPrice,
  });

  ProductQuery copyWith({
    String? search,
    Set<String>? slugs,
    SortOption? sort,
    double? minPrice,
    Object? maxPrice = _keep,
  }) => ProductQuery(
    search: search ?? this.search,
    slugs: slugs ?? this.slugs,
    sort: sort ?? this.sort,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as double?,
  );

  static const _keep = Object();

  bool get hasPriceFilter => minPrice > 0 || maxPrice != null;
  bool get hasActiveFilters => sort != SortOption.relevance || hasPriceFilter;

  List<Product> apply(List<Product> all) {
    final q = search.trim().toLowerCase();
    final result = all.where((p) {
      if (slugs.isNotEmpty && !slugs.contains(p.category)) return false;
      if (p.price < minPrice) return false;
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (q.isNotEmpty && _score(p, q) == 0) return false;
      return true;
    }).toList();

    switch (sort) {
      case SortOption.relevance:
        if (q.isNotEmpty) {
          result.sort((a, b) => _score(b, q).compareTo(_score(a, q)));
        }
      case SortOption.priceLowHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHighLow:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.discount:
        result.sort(
          (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
        );
    }
    return result;
  }

  /// Higher = better match. 0 = no match.
  static int _score(Product p, String q) {
    final title = p.title.toLowerCase();
    if (title.startsWith(q)) return 100;
    if (title.contains(q)) return 80;
    if (p.brand.toLowerCase().contains(q)) return 60;
    if (p.category.replaceAll('-', ' ').contains(q)) return 40;
    if (p.description.toLowerCase().contains(q)) return 20;
    return 0;
  }
}
