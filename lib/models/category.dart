import 'package:flutter/material.dart';

/// App-level category. Each one groups one or more DummyJSON category slugs.
class ShopCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color; // pastel tint used for the icon bubble
  final Color accent;
  final List<String> slugs;

  /// Filter chip this category belongs to on the Categories screen.
  final String group;

  const ShopCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.accent,
    required this.slugs,
    required this.group,
  });

  static const _menSlugs = [
    'mens-shirts',
    'mens-shoes',
    'mens-watches',
    'sunglasses',
  ];
  static const _womenSlugs = [
    'womens-dresses',
    'womens-shoes',
    'womens-bags',
    'womens-jewellery',
    'womens-watches',
    'tops',
  ];
  static const _electronicsSlugs = [
    'smartphones',
    'laptops',
    'tablets',
    'mobile-accessories',
  ];
  static const _homeSlugs = [
    'furniture',
    'home-decoration',
    'kitchen-accessories',
    'groceries',
  ];
  static const _beautySlugs = ['beauty', 'skin-care', 'fragrances'];
  static const _sportsSlugs = ['sports-accessories'];

  /// Every slug the app shows (vehicles etc. are intentionally excluded).
  static const allSlugs = [
    ..._menSlugs,
    ..._womenSlugs,
    ..._electronicsSlugs,
    ..._homeSlugs,
    ..._beautySlugs,
    ..._sportsSlugs,
  ];

  // --- Categories screen (6 cards, as in the design) ---
  static const men = ShopCategory(
    id: 'men',
    name: "Men's Fashion",
    icon: Icons.checkroom_rounded,
    color: Color(0xFFE0ECFF),
    accent: Color(0xFF1F64F2),
    slugs: _menSlugs,
    group: 'Fashion',
  );
  static const women = ShopCategory(
    id: 'women',
    name: "Women's Fashion",
    icon: Icons.dry_cleaning_rounded,
    color: Color(0xFFFFE4EC),
    accent: Color(0xFFE11D74),
    slugs: _womenSlugs,
    group: 'Fashion',
  );
  static const electronics = ShopCategory(
    id: 'electronics',
    name: 'Electronics',
    icon: Icons.devices_rounded,
    color: Color(0xFFDDEBFF),
    accent: Color(0xFF2563EB),
    slugs: _electronicsSlugs,
    group: 'Electronics',
  );
  static const home = ShopCategory(
    id: 'home',
    name: 'Home & Living',
    icon: Icons.chair_alt_rounded,
    color: Color(0xFFD9F5EA),
    accent: Color(0xFF059669),
    slugs: _homeSlugs,
    group: 'Home',
  );
  static const beauty = ShopCategory(
    id: 'beauty',
    name: 'Beauty & Personal Care',
    icon: Icons.spa_rounded,
    color: Color(0xFFFFE6DC),
    accent: Color(0xFFEA580C),
    slugs: _beautySlugs,
    group: 'Beauty',
  );
  static const sports = ShopCategory(
    id: 'sports',
    name: 'Sports & Outdoor',
    icon: Icons.sports_basketball_rounded,
    color: Color(0xFFEAE3FF),
    accent: Color(0xFF7C3AED),
    slugs: _sportsSlugs,
    group: 'Sports',
  );

  static const all = [men, women, electronics, home, beauty, sports];

  static const groups = [
    'All',
    'Fashion',
    'Electronics',
    'Home',
    'Beauty',
    'Sports',
  ];

  // --- Home screen quick-access bubbles ---
  static const homeShortcuts = [
    ShopCategory(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFFFE4EC),
      accent: Color(0xFFE11D74),
      slugs: [..._menSlugs, ..._womenSlugs],
      group: 'Fashion',
    ),
    ShopCategory(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFFDDEBFF),
      accent: Color(0xFF2563EB),
      slugs: _electronicsSlugs,
      group: 'Electronics',
    ),
    ShopCategory(
      id: 'home',
      name: 'Home',
      icon: Icons.home_rounded,
      color: Color(0xFFD9F5EA),
      accent: Color(0xFF059669),
      slugs: _homeSlugs,
      group: 'Home',
    ),
    ShopCategory(
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.spa_rounded,
      color: Color(0xFFFFE6DC),
      accent: Color(0xFFEA580C),
      slugs: _beautySlugs,
      group: 'Beauty',
    ),
    ShopCategory(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_basketball_rounded,
      color: Color(0xFFEAE3FF),
      accent: Color(0xFF7C3AED),
      slugs: _sportsSlugs,
      group: 'Sports',
    ),
  ];
}
