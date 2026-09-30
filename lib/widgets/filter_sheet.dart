import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../services/product_query.dart';
import 'app_button.dart';

const double kMaxPriceSlider = 500;

/// Bottom sheet with sort options + price range (design screen 7).
/// Returns the updated query, or null if dismissed.
Future<ProductQuery?> showFilterSheet(
  BuildContext context,
  ProductQuery current,
) {
  return showModalBottomSheet<ProductQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  final ProductQuery initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _sortChoices = [
    SortOption.relevance,
    SortOption.priceLowHigh,
    SortOption.priceHighLow,
    SortOption.rating,
  ];

  late SortOption _sort = widget.initial.sort;
  late RangeValues _range = RangeValues(
    widget.initial.minPrice,
    widget.initial.maxPrice ?? kMaxPriceSlider,
  );

  void _apply() {
    Navigator.pop(
      context,
      widget.initial.copyWith(
        sort: _sort,
        minPrice: _range.start,
        maxPrice: _range.end >= kMaxPriceSlider ? null : _range.end,
      ),
    );
  }

  void _clear() => setState(() {
    _sort = SortOption.relevance;
    _range = const RangeValues(0, kMaxPriceSlider);
  });

  String _label(double v) =>
      v >= kMaxPriceSlider ? '\$${v.toInt()}+' : '\$${v.toInt()}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 18),
          Text(
            'Sort by',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          for (final o in _sortChoices) _sortRow(o),
          SizedBox(height: 20),
          Text(
            'Price Range',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primaryLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: _range,
              min: 0,
              max: kMaxPriceSlider,
              divisions: 50,
              onChanged: (v) => setState(() => _range = v),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _label(_range.start),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _label(_range.end),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Clear',
                  outlined: true,
                  onPressed: _clear,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppButton(label: 'Apply', onPressed: _apply),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortRow(SortOption o) {
    final selected = _sort == o;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _sort = o),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textHint,
                  width: selected ? 6 : 1.6,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              o.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
