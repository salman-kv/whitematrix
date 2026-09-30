import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/catalog_controller.dart';
import '../../core/app_colors.dart';
import '../../core/routes.dart';
import '../../models/category.dart';
import '../../widgets/app_image.dart';
import '../../widgets/tappable.dart';

class _BannerData {
  final String kicker;
  final String title;
  final ShopCategory target;
  final List<Color> colors;
  const _BannerData(this.kicker, this.title, this.target, this.colors);
}

const _banners = [
  _BannerData('Up to 50% OFF', 'Big Fashion Sale', ShopCategory.women, [
    Color(0xFF2F6BFF),
    Color(0xFF1B4FD8),
  ]),
  _BannerData(
    'New Arrivals',
    'Latest Gadgets & Tech',
    ShopCategory.electronics,
    [Color(0xFF6A5CFF), Color(0xFF3B3FD8)],
  ),
  _BannerData('Glow Up', 'Beauty Essentials', ShopCategory.beauty, [
    Color(0xFFFF7A9C),
    Color(0xFFE2457A),
  ]),
];

/// Auto-advancing promotional carousel with page dots.
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final _page = PageController(viewportFraction: 0.93);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 4), (_) {
      if (!_page.hasClients) return;
      _page.animateToPage(
        (_index + 1) % _banners.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: _page,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: _BannerCard(data: b, image: catalog.coverFor(b.target)),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _banners.length; i++)
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  final String? image;
  const _BannerCard({required this.data, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.colors.last.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 6,
            top: 14,
            width: 130,
            child: image == null ? SizedBox.shrink() : AppImage(url: image!),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.kicker,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                SizedBox(
                  width: 150,
                  child: Text(
                    data.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Tappable(
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.category,
                    arguments: data.target,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Shop Now',
                      style: TextStyle(
                        color: data.colors.last,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
