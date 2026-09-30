import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class CartController extends ChangeNotifier {
  CartController(this._storage) {
    _load();
  }

  final StorageService _storage;
  final List<CartItem> _items = [];
  final List<Order> _orders = [];

  static const double freeShippingThreshold = 50;
  static const double flatShipping = 4.99;

  List<CartItem> get items => List.unmodifiable(_items);
  List<Order> get orders => List.unmodifiable(_orders.reversed);
  bool get isEmpty => _items.isEmpty;
  int get totalQuantity => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get shipping =>
      _items.isEmpty || subtotal >= freeShippingThreshold ? 0 : flatShipping;
  double get total => subtotal + shipping;

  void _load() {
    // Carts saved by older versions could hold one line per colour of the same
    // product; merge them so each product appears once.
    final merged = <String, CartItem>{};
    for (final line in _storage.readCart()) {
      final existing = merged[line.key];
      if (existing == null) {
        merged[line.key] = line;
      } else {
        existing.quantity += line.quantity;
      }
    }
    _items
      ..clear()
      ..addAll(merged.values);
    _orders
      ..clear()
      ..addAll(_storage.readOrders());
  }

  /// Re-reads the active account's cart and orders (after login / logout).
  void reload() {
    _load();
    notifyListeners();
  }

  void add(Product product, {int qty = 1}) {
    final probe = CartItem(product: product);
    final existing = _items.where((i) => i.key == probe.key);
    if (existing.isNotEmpty) {
      existing.first.quantity += qty;
    } else {
      probe.quantity = qty;
      _items.add(probe);
    }
    _changed();
  }

  void increment(CartItem item) {
    item.quantity++;
    _changed();
  }

  void decrement(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      _changed();
    }
  }

  /// Returns the index the item was removed from so the UI can offer "Undo".
  int remove(CartItem item) {
    final index = _items.indexOf(item);
    if (index >= 0) {
      _items.removeAt(index);
      _changed();
    }
    return index;
  }

  void restore(CartItem item, int index) {
    _items.insert(index.clamp(0, _items.length), item);
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  /// Turns the cart into an in-memory order and empties the cart.
  Order placeOrder() {
    final order = Order(
      id: 'SE${DateTime.now().millisecondsSinceEpoch % 1000000}',
      items: List.of(_items),
      total: total,
      placedAt: DateTime.now(),
    );
    _orders.add(order);
    _storage.saveOrders(_orders);
    clear();
    return order;
  }

  void _changed() {
    _storage.saveCart(_items);
    notifyListeners();
  }
}
