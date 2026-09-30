import '../models/category.dart';
import '../models/product.dart';

/// Offline fallback catalogue, used only when the public API is unreachable.
/// Products have no images, so the UI shows its placeholder artwork.
class MockData {
  MockData._();

  static const _names = {
    'mens-shirts': ['Casual Shirt', 'Denim Jacket', 'Oxford Shirt', 'Polo Tee'],
    'mens-shoes': ['Running Shoes', 'Street Sneakers', 'Leather Loafers'],
    'mens-watches': ['Classic Watch', 'Sport Watch'],
    'sunglasses': ['Aviator Shades', 'Retro Sunglasses'],
    'womens-dresses': ['Summer Dress', 'Evening Gown', 'Floral Dress'],
    'womens-shoes': ['Air Max Pink', 'Ballet Flats', 'Block Heels'],
    'womens-bags': ['Tote Bag', 'Sling Bag'],
    'womens-jewellery': ['Gold Necklace', 'Pearl Earrings'],
    'womens-watches': ['Rose Gold Watch', 'Minimal Watch'],
    'tops': ['Crop Top', 'Linen Top'],
    'smartphones': ['Pro Phone 15', 'Lite Phone 9'],
    'laptops': ['UltraBook 14', 'Gaming Laptop'],
    'tablets': ['Tab Air', 'Tab Mini'],
    'mobile-accessories': [
      'Wireless Earbuds',
      'Headphones WH-1000',
      'Power Bank',
    ],
    'furniture': ['Lounge Chair', 'Coffee Table'],
    'home-decoration': ['Table Lamp', 'Wall Clock'],
    'kitchen-accessories': ['Knife Set', 'Coffee Maker'],
    'groceries': ['Organic Honey', 'Fresh Apples'],
    'beauty': ['Matte Lipstick', 'Eyeshadow Palette'],
    'skin-care': ['Face Serum', 'Moisturiser'],
    'fragrances': ['Eau de Parfum', 'Cologne'],
    'sports-accessories': ['Yoga Mat', 'Football', 'Dumbbell Set'],
  };

  static List<Product> products() {
    final list = <Product>[];
    var id = 1;
    for (final slug in ShopCategory.allSlugs) {
      for (final name in _names[slug] ?? const <String>[]) {
        list.add(
          Product(
            id: id,
            title: name,
            description:
                '$name — premium quality with all-day comfort and a modern, '
                'lightweight design. Offline demo product.',
            category: slug,
            brand: 'ShopEase',
            price: 9.99 + (id * 37 % 240),
            discountPercentage: (id * 7 % 25).toDouble(),
            rating: 3.6 + (id % 14) / 10,
            thumbnail: '',
            images: const [],
            stock: 20,
          ),
        );
        id++;
      }
    }
    return list;
  }
}
