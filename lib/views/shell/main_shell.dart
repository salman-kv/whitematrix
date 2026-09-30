import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/app_colors.dart';
import '../cart/cart_view.dart';
import '../categories/categories_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import '../wishlist/wishlist_view.dart';

/// Hosts the five tabs. IndexedStack keeps each tab alive, so scroll position
/// and loaded pages survive switching tabs.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabs = [
    HomeView(),
    CategoriesView(),
    CartView(),
    WishlistView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();

    return PopScope(
      canPop: nav.index == NavController.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) nav.select(NavController.home);
      },
      child: Scaffold(
        body: IndexedStack(index: nav.index, children: _tabs),
        bottomNavigationBar: _BottomBar(),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavController>();
    final cartCount = context.select<CartController, int>(
      (c) => c.totalQuantity,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(
                context,
                nav,
                NavController.home,
                Icons.home_outlined,
                Icons.home_rounded,
                'Home',
              ),
              _item(
                context,
                nav,
                NavController.categories,
                Icons.grid_view_outlined,
                Icons.grid_view_rounded,
                'Categories',
              ),
              _item(
                context,
                nav,
                NavController.cart,
                Icons.shopping_cart_outlined,
                Icons.shopping_cart_rounded,
                'Cart',
                badge: cartCount,
              ),
              _item(
                context,
                nav,
                NavController.wishlist,
                Icons.favorite_border_rounded,
                Icons.favorite_rounded,
                'Wishlist',
              ),
              _item(
                context,
                nav,
                NavController.profile,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    NavController nav,
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    int badge = 0,
  }) {
    final selected = nav.index == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => nav.select(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge', style: TextStyle(fontSize: 9)),
              backgroundColor: AppColors.heart,
              offset: Offset(6, -4),
              child: AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 24,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
