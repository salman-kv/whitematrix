import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_colors.dart';

/// Animated skeleton placeholder.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerBox({super.key, this.width, this.height, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Skeleton that mimics a [ProductCard].
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 1, child: ShimmerBox(radius: 18)),
        SizedBox(height: 10),
        ShimmerBox(width: 110, height: 12, radius: 6),
        SizedBox(height: 8),
        ShimmerBox(width: 70, height: 14, radius: 6),
        SizedBox(height: 8),
        ShimmerBox(width: 40, height: 10, radius: 6),
      ],
    );
  }
}
