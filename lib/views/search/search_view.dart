import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/paged_products_controller.dart';
import '../../controllers/recent_search_controller.dart';
import '../../core/app_colors.dart';
import '../../models/category.dart';
import '../../services/product_repository.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/paged_product_grid.dart';
import '../../widgets/tappable.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          PagedProductsController(ctx.read<ProductRepository>())..load(),
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  // Label + categories each chip maps to (empty = all).
  static final _audiences = <(String, ShopCategory?)>[
    ('All', null),
    ('Men', ShopCategory.men),
    ('Women', ShopCategory.women),
    ('Electronics', ShopCategory.electronics),
    ('Home', ShopCategory.home),
    ('Beauty', ShopCategory.beauty),
    ('Sports', ShopCategory.sports),
  ];

  static const _popular = [
    'Sneakers',
    'Watch',
    'Dress',
    'Laptop',
    'Perfume',
    'Sunglasses',
    'Bag',
  ];

  late final _text = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  int _audience = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  PagedProductsController get _paged => context.read<PagedProductsController>();

  /// Pushes the current text + chip into the controller.
  void _apply() {
    final cat = _audiences[_audience].$2;
    _paged.updateQuery(
      _paged.query.copyWith(
        search: _text.text,
        slugs: cat?.slugs.toSet() ?? <String>{},
      ),
    );
  }

  void _onChanged(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 350), _apply);
  }

  void _submit(String v) {
    _debounce?.cancel();
    context.read<RecentSearchController>().add(v);
    _apply();
  }

  void _useTerm(String term) {
    _text.text = term;
    _text.selection = TextSelection.collapsed(offset: term.length);
    _submit(term);
    setState(() {});
    _focus.unfocus();
  }

  void _clear() {
    _text.clear();
    _debounce?.cancel();
    _apply();
    setState(() {});
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final paged = context.watch<PagedProductsController>();
    final showSuggestions =
        _text.text.trim().isEmpty &&
        _audience == 0 &&
        !paged.query.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _searchBar(),
            _audienceChips(),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 220),
                child: showSuggestions
                    ? _suggestions(context)
                    : PagedProductGrid(
                        key: ValueKey('results'),
                        heroPrefix: 'search',
                        headerSlivers: [_resultsHeader(paged)],
                        emptyState: _NoResults(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _text,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _submit,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search for products, brands...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                  suffixIcon: _text.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close_rounded, size: 18),
                          onPressed: _clear,
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _audienceChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _audiences.length,
        separatorBuilder: (_, _) => SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _audience;
          return Tappable(
            onTap: () {
              setState(() => _audience = i);
              _apply();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _audiences[i].$1,
                style: TextStyle(
                  fontSize: 12.5,
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

  Widget _resultsHeader(PagedProductsController paged) {
    final ready = paged.status == LoadStatus.ready;
    final active = paged.query.hasActiveFilters;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ready ? '${paged.totalMatches} results' : 'Searching...',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            Tappable(
              onTap: () async {
                final q = await showFilterSheet(context, paged.query);
                if (q != null) paged.updateQuery(q);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryLight : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestions(BuildContext context) {
    final recent = context.watch<RecentSearchController>();

    return ListView(
      key: ValueKey('suggestions'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.all(16),
      children: [
        if (recent.items.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: recent.clear,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          for (final term in recent.items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.history_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              title: Text(term, style: TextStyle(fontSize: 13.5)),
              trailing: IconButton(
                icon: Icon(Icons.close_rounded, size: 18),
                onPressed: () => recent.remove(term),
              ),
              onTap: () => _useTerm(term),
            ),
          SizedBox(height: 16),
        ],
        Text(
          'Popular searches',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _popular)
              ActionChip(
                label: Text(t, style: TextStyle(fontSize: 12.5)),
                avatar: Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => _useTerm(t),
              ),
          ],
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: AppColors.textHint),
            SizedBox(height: 14),
            Text(
              'No products found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Try a different keyword, category or price range.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
