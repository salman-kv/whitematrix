import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/paged_products_controller.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'product_card.dart';
import 'shimmer_box.dart';
import 'state_message.dart';

/// Responsive product grid as a sliver. Column count adapts to the width.
Widget productGridSliver(
  BuildContext context, {
  required int count,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return SliverLayoutBuilder(
    builder: (ctx, constraints) {
      const gap = 14.0;
      final width = constraints.crossAxisExtent;
      final pad = Responsive.pagePadding(width);
      final cols = Responsive.gridColumns(width - pad * 2);
      final cell = (width - pad * 2 - gap * (cols - 1)) / cols;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (c, i) => itemBuilder(c, i),
            childCount: count,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: gap,
            mainAxisSpacing: 16,
            mainAxisExtent: Responsive.productCardExtent(ctx, cell),
          ),
        ),
      );
    },
  );
}

/// Scrollable page = optional header slivers + an infinitely-scrolling product
/// grid powered by [PagedProductsController] (found via Provider).
///
/// How the infinite scroll works:
///  1. A [ScrollController] listener checks how close we are to the bottom.
///  2. Within [_threshold] px of the end it calls `controller.loadMore()`.
///  3. The controller appends the next page and notifies; the grid grows.
///  4. A footer shows a loader while loading, or an "end" note when done.
class PagedProductGrid extends StatefulWidget {
  final List<Widget> headerSlivers;
  final String heroPrefix;
  final Widget? emptyState;

  const PagedProductGrid({
    super.key,
    required this.heroPrefix,
    this.headerSlivers = const [],
    this.emptyState,
  });

  @override
  State<PagedProductGrid> createState() => _PagedProductGridState();
}

class _PagedProductGridState extends State<PagedProductGrid> {
  static const _threshold = 500.0;

  final _scroll = ScrollController();
  int _generation = -1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - _threshold) {
      context.read<PagedProductsController>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PagedProductsController>();

    // After each rebuild: scroll to top if the list was rebuilt (new filter),
    // and top up the list if the first page doesn't fill the screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (c.generation != _generation) {
        if (_generation != -1 && _scroll.offset > 0) _scroll.jumpTo(0);
        _generation = c.generation;
      }
      _maybeLoadMore();
    });

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => c.load(force: true),
      child: CustomScrollView(
        controller: _scroll,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.headerSlivers,
          ..._body(context, c),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context, PagedProductsController c) {
    switch (c.status) {
      case LoadStatus.loading:
        return [
          productGridSliver(
            context,
            count: 6,
            itemBuilder: (_, _) => ProductCardShimmer(),
          ),
        ];
      case LoadStatus.error:
        return [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: StateMessage(
                icon: Icons.wifi_off_rounded,
                title: 'Something went wrong',
                message: 'We could not load products. Check your connection.',
                actionLabel: 'Try again',
                onAction: () => c.load(force: true),
              ),
            ),
          ),
        ];
      case LoadStatus.ready:
        if (c.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 380,
                child:
                    widget.emptyState ??
                    StateMessage(
                      icon: Icons.search_off_rounded,
                      title: 'No products found',
                      message: 'Try a different search or adjust your filters.',
                    ),
              ),
            ),
          ];
        }
        final items = c.items;
        return [
          productGridSliver(
            context,
            count: items.length,
            itemBuilder: (_, i) => _FadeIn(
              key: ValueKey(items[i].id),
              child: ProductCard(
                product: items[i],
                heroPrefix: widget.heroPrefix,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _Footer(controller: c)),
        ];
    }
  }
}

class _Footer extends StatelessWidget {
  final PagedProductsController controller;
  const _Footer({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(height: 8),
            Text(
              'Loading more products...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    if (!controller.hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Text(
            "You've seen it all!",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return SizedBox(height: 60);
  }
}

/// Fade + slight rise when a card first appears.
class _FadeIn extends StatelessWidget {
  final Widget child;
  const _FadeIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
