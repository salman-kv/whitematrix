import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';

/// Thin wrapper over SharedPreferences.
///
/// The logged-in session is global, but cart, wishlist, orders and recent
/// searches are **scoped per account**: every key is prefixed with the active
/// account's e-mail, so each login sees its own data. With no active account
/// the per-user getters return empty values and the setters do nothing.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;
  String? _scope;

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  /// Selects whose data the per-user getters/setters work on.
  void useAccount(String? email) => _scope = email?.toLowerCase();

  String _k(String name) => '$_scope:$name';
  bool get _hasScope => _scope != null;

  // --- Session (global) ---
  AppUser? readUser() {
    final raw = _prefs.getString('user');
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AppUser? user) => user == null
      ? _prefs.remove('user')
      : _prefs.setString('user', jsonEncode(user.toJson()));

  // --- Preferences (global) ---
  /// 0 = light, 1 = dark, 2 = follow system.
  int readThemeMode() => _prefs.getInt('theme_mode') ?? 0;

  Future<void> saveThemeMode(int index) => _prefs.setInt('theme_mode', index);

  // --- Per-account data ---
  List<CartItem> readCart() {
    final raw = _hasScope ? _prefs.getString(_k('cart')) : null;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    if (!_hasScope) return;
    await _prefs.setString(
      _k('cart'),
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<Order> readOrders() {
    final raw = _hasScope ? _prefs.getString(_k('orders')) : null;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrders(List<Order> orders) async {
    if (!_hasScope) return;
    await _prefs.setString(
      _k('orders'),
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
  }

  Set<int> readWishlist() => _hasScope
      ? (_prefs.getStringList(_k('wishlist')) ?? []).map(int.parse).toSet()
      : <int>{};

  Future<void> saveWishlist(Set<int> ids) async {
    if (!_hasScope) return;
    await _prefs.setStringList(_k('wishlist'), ids.map((e) => '$e').toList());
  }

  List<String> readRecentSearches() =>
      _hasScope ? _prefs.getStringList(_k('recent')) ?? [] : <String>[];

  Future<void> saveRecentSearches(List<String> v) async {
    if (!_hasScope) return;
    await _prefs.setStringList(_k('recent'), v);
  }
}
