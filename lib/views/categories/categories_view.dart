import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/catalog_controller.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../core/routes.dart';
import '../../models/category.dart';
import '../../widgets/app_image.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/shimmer_box.dart';
import '../../widgets/state_message.dart';
import '../../widgets/tappable.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  String _group = 'All';

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<ShopCategory> get _visible {
    final q = _search.text.trim().toLowerCase();
    return ShopCategory.all
        .where((c) => _group == 'All' || c.group == _group)
        .where((c) => q.isEmpty || c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final width = MediaQuery.sizeOf(context).width;
    final pad = Responsive.pagePadding(width);
    final cols = (width / 180).floor().clamp(2, 4);
    final cats = _visible;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.pushNamed(context, Routes.search),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 12),
                child: TextField(
                  controller: _search,
                  focusNode: _focus,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 21,
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(_search.clear),
                          ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  itemCount: ShopCategory.groups.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final g = ShopCategory.groups[i];
                    return _GroupChip(
                      label: g,
                      selected: g == _group,
                      onTap: () => setState(() => _group = g),
                    );
                  },
                ),
              ),
            ),
            if (cats.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StateMessage(
                  icon: Icons.category_outlined,
                  title: 'No categories found',
                  message: 'Try a different keyword or filter.',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CategoryCard(
                      category: cats[i],
                      cover: catalog.coverFor(cats[i]),
                      count: catalog.countFor(cats[i]),
                      loading: catalog.status == LoadStatus.loading,
                    ),
                    childCount: cats.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18),
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
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ShopCategory category;
  final String? cover;
  final int count;
  final bool loading;

  const _CategoryCard({
    required this.category,
    required this.cover,
    required this.count,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () =>
          Navigator.pushNamed(context, Routes.category, arguments: category),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.all(8),
                child: loading
                    ? ShimmerBox(radius: 10)
                    : (cover == null
                          ? Icon(
                              category.icon,
                              size: 40,
                              color: category.accent,
                            )
                          : AppImage(url: cover!)),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4, 1, 4, 4),
              child: Text(
                '$count+ Items',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
