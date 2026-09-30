class Product {
  final int id;
  final String title;
  final String description;
  final String category; // DummyJSON slug, e.g. "mens-shoes"
  final String brand;
  final double price; // selling price
  final double discountPercentage;
  final double rating;
  final String thumbnail;
  final List<String> images;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.thumbnail,
    required this.images,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as int,
    title: j['title'] as String,
    description: (j['description'] ?? '') as String,
    category: (j['category'] ?? '') as String,
    brand: (j['brand'] ?? '') as String,
    price: (j['price'] as num).toDouble(),
    discountPercentage: ((j['discountPercentage'] ?? 0) as num).toDouble(),
    rating: ((j['rating'] ?? 0) as num).toDouble(),
    thumbnail: (j['thumbnail'] ?? '') as String,
    images: List<String>.from(j['images'] ?? const []),
    stock: ((j['stock'] ?? 0) as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'brand': brand,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'thumbnail': thumbnail,
    'images': images,
    'stock': stock,
  };

  /// Price before the discount was applied (shown struck-through).
  double get originalPrice =>
      discountPercentage > 0 ? price / (1 - discountPercentage / 100) : price;

  int get discountRounded => discountPercentage.round();
  bool get hasDiscount => discountRounded > 0;

  /// The API has no review counts, so a stable pseudo count is derived from id.
  int get reviewCount => 80 + (id * 137) % 2400;

  /// The API has no colour or size data, so every product offers exactly one
  /// honest default choice. (Real variants would need a data source that also
  /// supplies an image for each colour.)
  String get colorOption => 'Default';
  String get sizeOption => 'One size';

  List<String> get gallery {
    final all = <String>{if (thumbnail.isNotEmpty) thumbnail, ...images};
    return all.toList();
  }
}
