import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../views/auth/login_view.dart';
import '../views/best_sellers/best_sellers_view.dart';
import '../views/cart/order_success_view.dart';
import '../views/categories/category_products_view.dart';
import '../views/profile/orders_view.dart';
import '../views/profile/settings_view.dart';
import '../views/product/product_detail_view.dart';
import '../views/search/search_view.dart';
import '../views/shell/main_shell.dart';
import '../views/splash/splash_view.dart';

class ProductArgs {
  final Product product;
  final String heroTag;
  const ProductArgs(this.product, this.heroTag);
}

class Routes {
  Routes._();

  static const splash = '/';
  static const login = '/login';
  static const shell = '/shell';
  static const product = '/product';
  static const bestSellers = '/best-sellers';
  static const category = '/category';
  static const search = '/search';
  static const orderSuccess = '/order-success';
  static const orders = '/orders';
  static const settings = '/settings';

  static Route<dynamic> generate(RouteSettings s) {
    switch (s.name) {
      case splash:
        return _fade(const SplashView(), s);
      case login:
        return _fade(const LoginView(), s);
      case shell:
        return _fade(const MainShell(), s);
      case product:
        return MaterialPageRoute(
          settings: s,
          builder: (_) => ProductDetailView(args: s.arguments as ProductArgs),
        );
      case bestSellers:
        return MaterialPageRoute(
          settings: s,
          builder: (_) => const BestSellersView(),
        );
      case category:
        return MaterialPageRoute(
          settings: s,
          builder: (_) =>
              CategoryProductsView(category: s.arguments as ShopCategory),
        );
      case search:
        return _fade(
          const SearchView(),
          s,
          duration: const Duration(milliseconds: 220),
        );
      case orderSuccess:
        return _fade(OrderSuccessView(order: s.arguments as Order), s);
      case settings:
        return MaterialPageRoute(
          settings: s,
          builder: (_) => const SettingsView(),
        );
      case orders:
        return MaterialPageRoute(
          settings: s,
          builder: (_) => const OrdersView(),
        );
    }
    return _fade(const SplashView(), s);
  }

  static PageRouteBuilder<T> _fade<T>(
    Widget page,
    RouteSettings s, {
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      settings: s,
      transitionDuration: duration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}
