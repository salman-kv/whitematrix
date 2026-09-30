import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/paged_products_controller.dart';
import '../../services/product_query.dart';
import '../../services/product_repository.dart';
import '../../widgets/paged_product_grid.dart';

/// Every product ranked by customer rating, with infinite scrolling.
class BestSellersView extends StatelessWidget {
  const BestSellersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PagedProductsController(
        ctx.read<ProductRepository>(),
        query: ProductQuery(sort: SortOption.rating),
        pageSize: 8,
      )..load(),
      child: Scaffold(
        appBar: AppBar(title: Text('Best Sellers')),
        body: PagedProductGrid(
          heroPrefix: 'best',
          headerSlivers: [SliverToBoxAdapter(child: SizedBox(height: 8))],
        ),
      ),
    );
  }
}
