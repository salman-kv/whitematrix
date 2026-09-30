import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/product.dart';
import '../../widgets/paged_product_grid.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_message.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistController>();
    final catalog = context.watch<CatalogController>();
    final products = [
      for (final id in wishlist.ids)
        if (catalog.byId(id) != null) catalog.byId(id)!,
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text('Wishlist'), automaticallyImplyLeading: false),
      body: products.isEmpty
          ? StateMessage(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is empty',
              message: 'Tap the heart on any product to save it here.',
              actionLabel: 'Explore Products',
              onAction: () =>
                  context.read<NavController>().select(NavController.home),
            )
          : _Grid(products: products),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<Product> products;
  const _Grid({required this.products});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        productGridSliver(
          context,
          count: products.length,
          itemBuilder: (_, i) =>
              ProductCard(product: products[i], heroPrefix: 'wish'),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
