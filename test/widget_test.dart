import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salmankvwhitematrix/services/storage_service.dart';
import 'package:salmankvwhitematrix/models/cart_item.dart';
import 'package:salmankvwhitematrix/models/product.dart';
import 'package:salmankvwhitematrix/controllers/paged_products_controller.dart';
import 'package:salmankvwhitematrix/controllers/cart_controller.dart';
import 'package:salmankvwhitematrix/controllers/theme_controller.dart';
import 'package:flutter/widgets.dart' show Brightness;
import 'package:salmankvwhitematrix/controllers/catalog_controller.dart';
import 'package:salmankvwhitematrix/core/demo_accounts.dart';
import 'package:salmankvwhitematrix/core/validators.dart';
import 'package:salmankvwhitematrix/services/mock_data.dart';
import 'package:salmankvwhitematrix/services/product_query.dart';
import 'package:salmankvwhitematrix/services/product_repository.dart';

class _FakeRepo extends ProductRepository {
  @override
  Future<List<Product>> getAll({bool force = false}) async =>
      MockData.products();
}

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });
    test('phone', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('9876543210'), isNull);
    });
    test('password', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('DemoAccounts', () {
    test('every account logs in with its email or phone', () {
      for (final a in DemoAccounts.all) {
        expect(DemoAccounts.authenticate(a.email, a.password), a);
        expect(DemoAccounts.authenticate(a.phone, a.password), a);
      }
    });
    test('email match ignores case and spaces', () {
      expect(
        DemoAccounts.authenticate(' SALMAN@gmail.com ', 'Shop@123'),
        DemoAccounts.salman,
      );
    });
    test('rejects wrong password, or another accounts password', () {
      expect(DemoAccounts.authenticate('salman@gmail.com', 'nope123'), isNull);
      expect(
        DemoAccounts.authenticate('salman@gmail.com', 'Aisha@456'),
        isNull,
      );
      expect(DemoAccounts.authenticate('x@y.com', 'Shop@123'), isNull);
    });
  });

  group('Per-account data', () {
    test('cart, wishlist and orders are isolated per account', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(await SharedPreferences.getInstance());
      final product = MockData.products().first;

      // A brand-new account has nothing.
      storage.useAccount(DemoAccounts.aisha.email);
      expect(storage.readWishlist(), isEmpty);
      expect(storage.readCart(), isEmpty);
      expect(storage.readOrders(), isEmpty);

      // Aisha saves a wishlist item and a cart line.
      await storage.saveWishlist({product.id});
      await storage.saveCart([CartItem(product: product, quantity: 2)]);

      // Rahul sees none of it.
      storage.useAccount(DemoAccounts.rahul.email);
      expect(storage.readWishlist(), isEmpty);
      expect(storage.readCart(), isEmpty);

      // Back to Aisha: her data is still there.
      storage.useAccount(DemoAccounts.aisha.email);
      expect(storage.readWishlist(), {product.id});
      expect(storage.readCart().single.quantity, 2);

      // No active account -> nothing visible.
      storage.useAccount(null);
      expect(storage.readWishlist(), isEmpty);
      expect(storage.readCart(), isEmpty);
    });
  });

  group('CartController', () {
    test('one line per product; old colour/size carts are merged', () async {
      final p = MockData.products().first;
      final old = {
        'product': p.toJson(),
        'color': 'Pink',
        'size': 'M',
        'quantity': 1,
      };
      final old2 = {
        'product': p.toJson(),
        'color': 'Blue',
        'size': null,
        'quantity': 2,
      };
      SharedPreferences.setMockInitialValues({
        'a@b.com:cart': jsonEncode([old, old2]),
      });
      final storage = StorageService(await SharedPreferences.getInstance())
        ..useAccount('a@b.com');
      final cart = CartController(storage);

      expect(cart.items.length, 1);
      expect(cart.items.single.quantity, 3);

      cart.add(p, qty: 2); // same product again -> same line
      expect(cart.items.length, 1);
      expect(cart.items.single.quantity, 5);
    });
  });

  group('ThemeController', () {
    test(
      'defaults to light, persists the choice and resolves system',
      () async {
        SharedPreferences.setMockInitialValues({});
        final storage = StorageService(await SharedPreferences.getInstance());

        final c = ThemeController(storage);
        expect(c.mode, AppThemeMode.light);
        expect(c.resolveDark(Brightness.dark), isFalse);

        c.setMode(AppThemeMode.dark);
        expect(c.resolveDark(Brightness.light), isTrue);

        c.setMode(AppThemeMode.system);
        expect(c.resolveDark(Brightness.dark), isTrue);
        expect(c.resolveDark(Brightness.light), isFalse);

        // A new controller (app restart) restores the saved mode.
        expect(ThemeController(storage).mode, AppThemeMode.system);
      },
    );
  });

  group('ProductQuery', () {
    final all = MockData.products();

    test('search narrows results', () {
      final r = const ProductQuery(search: 'watch').apply(all);
      expect(r, isNotEmpty);
      expect(r.length, lessThan(all.length));
    });

    test('price sort ascending', () {
      final r = const ProductQuery(sort: SortOption.priceLowHigh).apply(all);
      for (var i = 1; i < r.length; i++) {
        expect(r[i].price, greaterThanOrEqualTo(r[i - 1].price));
      }
    });

    test('max price filter', () {
      final r = const ProductQuery(maxPrice: 50).apply(all);
      expect(r.every((p) => p.price <= 50), isTrue);
    });
  });

  group('Infinite scroll pagination', () {
    test('loads first page then appends on loadMore', () async {
      final c = PagedProductsController(
        _FakeRepo(),
        pageSize: 10,
        loadMoreDelay: Duration.zero,
      );
      await c.load();
      expect(c.status, LoadStatus.ready);
      expect(c.items.length, 10);
      expect(c.hasMore, isTrue);

      await c.loadMore();
      expect(c.items.length, 20);

      while (c.hasMore) {
        await c.loadMore();
      }
      expect(c.items.length, c.totalMatches);
      expect(c.hasMore, isFalse);
    });
  });
}
