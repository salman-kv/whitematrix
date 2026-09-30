import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'shimmer_box.dart';

/// Network image with caching, a shimmer while loading and a graceful fallback.
class AppImage extends StatelessWidget {
  final String url;

  const AppImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _Fallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: Duration(milliseconds: 250),
      placeholder: (_, _) => ShimmerBox(radius: 0),
      errorWidget: (_, _, _) => _Fallback(),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) => Center(
    child: Icon(
      Icons.shopping_bag_outlined,
      size: 34,
      color: AppColors.textHint,
    ),
  );
}
