import 'product.dart';

/// One line in the cart: a product and how many of it.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// One cart line per product; adding it again raises the quantity.
  String get key => '${product.id}';

  double get lineTotal => product.price * quantity;

  /// Older saved carts also stored a colour and size; those fields are ignored.
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    product: Product.fromJson(j['product'] as Map<String, dynamic>),
    quantity: j['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };
}
