import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../core/routes.dart';
import '../models/product.dart';
import 'app_image.dart';
import 'tappable.dart';
import 'wishlist_button.dart';

/// Product tile used in every grid / carousel. The image is a [Hero] so it
/// animates into the product detail page; [heroPrefix] keeps tags unique when
/// the same product appears in several lists.
class ProductCard extends StatelessWidget {
  final Product product;
  final String heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    required this.heroPrefix,
  });

  static String heroTag(String prefix, int id) => '$prefix-$id';

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Tappable(
      onTap: () => Navigator.pushNamed(
        context,
        Routes.product,
        arguments: ProductArgs(p, heroTag(heroPrefix, p.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: heroTag(heroPrefix, p.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      padding: EdgeInsets.all(10),
                      child: AppImage(url: p.thumbnail),
                    ),
                  ),
                ),
                if (p.hasDiscount)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${p.discountRounded}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: WishlistButton(productId: p.id, size: 30),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            p.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 2),
          Text(
            Fmt.money(p.price),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: AppColors.star),
              SizedBox(width: 2),
              Text(
                p.rating.toStringAsFixed(1),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
