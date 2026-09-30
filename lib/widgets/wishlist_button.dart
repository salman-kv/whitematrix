import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/wishlist_controller.dart';
import '../core/app_colors.dart';

/// Heart toggle with a small bounce animation.
class WishlistButton extends StatelessWidget {
  final int productId;
  final double size;

  const WishlistButton({super.key, required this.productId, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final liked = context.select<WishlistController, bool>(
      (w) => w.contains(productId),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<WishlistController>().toggle(productId);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1100),
              content: Text(
                liked ? 'Removed from wishlist' : 'Added to wishlist',
              ),
            ),
          );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(
            scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
            child: c,
          ),
          child: Icon(
            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(liked),
            size: size * 0.56,
            color: liked ? AppColors.heart : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
