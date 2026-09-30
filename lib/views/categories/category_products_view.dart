import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/paged_products_controller.dart';
import '../../core/app_colors.dart';
import '../../core/routes.dart';
import '../../models/category.dart';
import '../../services/product_query.dart';
import '../../services/product_repository.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/paged_product_grid.dart';

class CategoryProductsView extends StatelessWidget {
  final ShopCategory category;
  const CategoryProductsView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PagedProductsController(
        ctx.read<ProductRepository>(),
        query: ProductQuery(slugs: category.slugs.toSet()),
      )..load(),
      child: Builder(
        builder: (context) {
          final paged = context.watch<PagedProductsController>();
          return Scaffold(
            appBar: AppBar(
              title: Text(category.name),
              actions: [
                IconButton(
                  icon: Icon(Icons.search_rounded),
                  onPressed: () => Navigator.pushNamed(context, Routes.search),
                ),
                IconButton(
                  icon: Badge(
                    isLabelVisible: paged.query.hasActiveFilters,
                    smallSize: 9,
                    backgroundColor: AppColors.heart,
                    child: Icon(Icons.tune_rounded),
                  ),
                  onPressed: () async {
                    final q = await showFilterSheet(context, paged.query);
                    if (q != null) paged.updateQuery(q);
                  },
                ),
              ],
            ),
            body: PagedProductGrid(
              heroPrefix: 'cat-${category.id}',
              headerSlivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      paged.status == LoadStatus.ready
                          ? '${paged.totalMatches} products'
                          : ' ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
