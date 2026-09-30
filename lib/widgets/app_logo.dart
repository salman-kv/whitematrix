import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Brand mark: a gradient shopping bag with the "ShopEase" wordmark.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool vertical;

  const AppLogo({
    super.key,
    this.size = 32,
    this.showTagline = false,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final mark = ShaderMask(
      shaderCallback: (r) => AppColors.brandGradient.createShader(r),
      blendMode: BlendMode.srcIn,
      child: Icon(Icons.shopping_bag_rounded, size: size, color: Colors.white),
    );

    final text = Column(
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ShopEase',
          style: TextStyle(
            fontSize: size * 0.72,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.1,
          ),
        ),
        if (showTagline)
          Text(
            'Shop Smarter, Live Better',
            style: TextStyle(
              fontSize: size * 0.3,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
      ],
    );

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mark,
              SizedBox(height: size * 0.2),
              text,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              mark,
              SizedBox(width: size * 0.25),
              text,
            ],
          );
  }
}
