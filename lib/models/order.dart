import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime placedAt;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.placedAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'] as String,
    items: (j['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: (j['total'] as num).toDouble(),
    placedAt: DateTime.parse(j['placedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'placedAt': placedAt.toIso8601String(),
  };
}
