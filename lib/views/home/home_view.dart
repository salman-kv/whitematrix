import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/paged_products_controller.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../core/routes.dart';
import '../../models/category.dart';
import '../../services/product_query.dart';
import '../../services/product_repository.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/paged_product_grid.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_box.dart';
import '../../widgets/tappable.dart';
import 'home_banner.dart';
import 'notifications_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          PagedProductsController(ctx.read<ProductRepository>(), pageSize: 10)
            ..load(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(bottom: false, child: _HomeBody()),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.pagePadding(MediaQuery.sizeOf(context).width);
    final catalog = context.watch<CatalogController>();

    Widget padded(Widget child, {double top = 0, double bottom = 0}) =>
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, top, pad, bottom),
            child: child,
          ),
        );

    return PagedProductGrid(
      heroPrefix: 'home-trending',
      headerSlivers: [
        padded(_TopBar(), top: 8),
        padded(_Greeting(), top: 14),
        padded(_SearchRow(), top: 14, bottom: 16),
        if (catalog.isOffline) padded(_OfflineNote(), bottom: 12),
        SliverToBoxAdapter(
          child: catalog.status == LoadStatus.loading
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: ShimmerBox(height: 158, radius: 20),
                )
              : HomeBanner(),
        ),
        padded(_CategoryRow(), top: 18),
        padded(
          SectionHeader(
            title: 'Best Deals',
            onSeeAll: () => Navigator.pushNamed(context, Routes.bestSellers),
          ),
          top: 18,
          bottom: 10,
        ),
        SliverToBoxAdapter(child: _BestDeals(pad: pad)),
        padded(
          SectionHeader(
            title: 'Trending Products',
            onSeeAll: () => Navigator.pushNamed(context, Routes.bestSellers),
          ),
          top: 20,
          bottom: 10,
        ),
        SliverToBoxAdapter(child: _SortChips()),
        SliverToBoxAdapter(child: SizedBox(height: 14)),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppLogo(size: 28),
        Spacer(),
        CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => showNotificationsSheet(context),
        ),
      ],
    );
  }
}

/// Search pill (opens the search page) + filter button for the trending feed.
class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final paged = context.watch<PagedProductsController>();
    final active = paged.query.hasActiveFilters;

    return Row(
      children: [
        Expanded(
          child: Tappable(
            pressedScale: 0.98,
            onTap: () => Navigator.pushNamed(context, Routes.search),
            child: Container(
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 21,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search for products, brands and more...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Tappable(
          onTap: () async {
            final q = await showFilterSheet(context, paged.query);
            if (q != null) paged.updateQuery(q);
          },
          child: Badge(
            isLabelVisible: active,
            smallSize: 10,
            backgroundColor: AppColors.heart,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.warningText),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — showing demo products',
              style: TextStyle(fontSize: 12, color: AppColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final c in ShopCategory.homeShortcuts)
          Expanded(
            child: Tappable(
              onTap: () =>
                  Navigator.pushNamed(context, Routes.category, arguments: c),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(c.icon, color: c.accent, size: 25),
                  ),
                  SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BestDeals extends StatelessWidget {
  final double pad;
  const _BestDeals({required this.pad});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final scale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.4).toDouble();
    const w = 150.0;
    final h = w + 82 * scale;

    if (catalog.status == LoadStatus.loading) {
      return SizedBox(
        height: h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: pad),
          itemCount: 3,
          separatorBuilder: (_, _) => SizedBox(width: 14),
          itemBuilder: (_, _) =>
              SizedBox(width: w, child: ProductCardShimmer()),
        ),
      );
    }

    final deals = catalog.bestDeals;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        physics: BouncingScrollPhysics(),
        itemCount: deals.length,
        separatorBuilder: (_, _) => SizedBox(width: 14),
        itemBuilder: (_, i) => SizedBox(
          width: w,
          child: ProductCard(product: deals[i], heroPrefix: 'home-deals'),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthController, String>(
      (a) => (a.user?.name ?? 'there').split(' ').first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name 👋',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 2),
        Text(
          'What are you shopping for today?',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Quick sort chips for the Trending grid (full filters live in the sheet).
class _SortChips extends StatelessWidget {
  const _SortChips();

  static const _options = [
    (SortOption.relevance, 'Popular'),
    (SortOption.rating, 'Top Rated'),
    (SortOption.priceLowHigh, 'Price: Low'),
    (SortOption.priceHighLow, 'Price: High'),
    (SortOption.discount, 'Best Discount'),
  ];

  @override
  Widget build(BuildContext context) {
    final paged = context.watch<PagedProductsController>();
    final pad = Responsive.pagePadding(MediaQuery.sizeOf(context).width);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: _options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (opt, label) = _options[i];
          final selected = paged.query.sort == opt;
          return Tappable(
            onTap: () => paged.updateQuery(paged.query.copyWith(sort: opt)),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
