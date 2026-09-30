import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/catalog_controller.dart';
import 'controllers/nav_controller.dart';
import 'controllers/recent_search_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'core/routes.dart';
import 'services/product_repository.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = await StorageService.create();
  runApp(ShopEaseApp(storage: storage));
}

class ShopEaseApp extends StatefulWidget {
  final StorageService storage;
  final ProductRepository? repository; // injectable for tests

  const ShopEaseApp({super.key, required this.storage, this.repository});

  @override
  State<ShopEaseApp> createState() => _ShopEaseAppState();
}

class _ShopEaseAppState extends State<ShopEaseApp> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();
  late final ThemeController _theme = ThemeController(widget.storage);
  late final ProductRepository _repo = widget.repository ?? ProductRepository();
  late final AuthController _auth = AuthController(widget.storage);
  late final CatalogController _catalog = CatalogController(_repo);
  late final CartController _cart = CartController(widget.storage);
  late final WishlistController _wishlist = WishlistController(widget.storage);
  late final RecentSearchController _recent = RecentSearchController(
    widget.storage,
  );
  final NavController _nav = NavController();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_syncAccountData);
    WidgetsBinding.instance.addObserver(this);
    _theme.addListener(_applyTheme);
    AppColors.dark = _resolveDark();
    _setSystemBars();
  }

  bool _resolveDark() => _theme.resolveDark(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  @override
  void didChangePlatformBrightness() => _applyTheme();

  /// Applies a theme change everywhere, instantly and without losing state:
  /// the palette flag is flipped, the MaterialApp gets a new ThemeData, and
  /// every mounted widget is marked dirty so colours read from [AppColors]
  /// are re-evaluated (scroll positions, routes and form input are kept).
  void _applyTheme() {
    final dark = _resolveDark();
    if (dark == AppColors.dark) return;
    AppColors.dark = dark;
    _setSystemBars();
    setState(() {});
    void markDirty(Element e) {
      e.markNeedsBuild();
      e.visitChildren(markDirty);
    }

    (_navKey.currentContext as Element?)?.visitChildren(markDirty);
  }

  void _setSystemBars() {
    final icons = AppColors.dark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: icons,
      ),
    );
  }

  /// Whenever the session changes (login / logout) every per-account
  /// controller re-reads its data for the now-active account.
  void _syncAccountData() {
    _cart.reload();
    _wishlist.reload();
    _recent.reload();
  }

  @override
  void dispose() {
    _auth.removeListener(_syncAccountData);
    _theme.removeListener(_applyTheme);
    WidgetsBinding.instance.removeObserver(this);
    for (final c in [
      _auth,
      _catalog,
      _cart,
      _wishlist,
      _recent,
      _nav,
      _theme,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: _repo),
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _catalog),
        ChangeNotifierProvider.value(value: _cart),
        ChangeNotifierProvider.value(value: _wishlist),
        ChangeNotifierProvider.value(value: _recent),
        ChangeNotifierProvider.value(value: _nav),
        ChangeNotifierProvider.value(value: _theme),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navKey,
        theme: AppTheme.build(),
        themeAnimationDuration: Duration.zero,
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.generate,
      ),
    );
  }
}
