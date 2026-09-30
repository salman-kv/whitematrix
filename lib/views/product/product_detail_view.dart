import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../models/product.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_image.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/wishlist_button.dart';

class ProductDetailView extends StatefulWidget {
  final ProductArgs args;
  const ProductDetailView({super.key, required this.args});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late final Product p = widget.args.product;
  final _pager = PageController();

  int _page = 0;
  int _qty = 1;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    final cart = context.read<CartController>();
    cart.add(p, qty: _qty);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added $_qty × ${p.title} to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Color(0xFF8DB4FF),
            onPressed: () {
              context.read<NavController>().select(NavController.cart);
              Navigator.popUntil(
                context,
                (r) => r.settings.name == Routes.shell,
              );
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final images = p.gallery;
    final top = MediaQuery.paddingOf(context).top;
    final screenH = MediaQuery.sizeOf(context).height;
    final galleryH = (screenH * 0.40).clamp(280.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gallery(images, top, galleryH),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: _details(),
            ),
          ],
        ),
      ),
      // In the bottom slot so snack-bars appear above it, never over the button.
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _gallery(List<String> images, double top, double height) {
    return SizedBox(
      height: height + top,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: widget.args.heroTag,
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(24, top + 50, 24, 36),
                child: images.isEmpty
                    ? AppImage(url: '')
                    : PageView.builder(
                        controller: _pager,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, i) => AppImage(url: images[i]),
                      ),
              ),
            ),
          ),
          Positioned(
            top: top + 8,
            left: 16,
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 40,
              outlined: false,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: top + 8,
            right: 16,
            child: WishlistButton(productId: p.id, size: 40),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.primary
                            : AppColors.textHint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.title,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        if (p.brand.isNotEmpty) ...[
          SizedBox(height: 2),
          Text(
            p.brand,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 18, color: AppColors.star),
            SizedBox(width: 4),
            Text(
              p.rating.toStringAsFixed(1),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 6),
            Text(
              '(${Fmt.compactCount(p.reviewCount)} reviews)',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            Spacer(),
            _stockBadge(),
          ],
        ),
        SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Fmt.money(p.price),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            if (p.hasDiscount) ...[
              SizedBox(width: 10),
              Text(
                Fmt.money(p.originalPrice),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${p.discountRounded}% OFF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 22),
        // Colour: the earlier swatch design, with the single choice selected.
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Color: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: p.colorOption,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textHint.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Size',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        // Sizes the box to its text (Align gives it loose width).
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(minWidth: 46),
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                p.sizeOption,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 22),
        Text(
          'Product Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text(
          p.description,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _stockBadge() {
    final low = p.stock > 0 && p.stock <= 10;
    final out = p.stock <= 0;
    final color = out
        ? AppColors.error
        : (low ? Color(0xFFD97706) : AppColors.success);
    final text = out
        ? 'Out of stock'
        : (low ? 'Only ${p.stock} left' : 'In stock');
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          QuantityStepper(
            value: _qty,
            onIncrement: () => setState(() => _qty++),
            onDecrement: () => setState(() => _qty--),
          ),
          SizedBox(width: 16),
          Expanded(
            child: AppButton(
              label: 'Add to Cart',
              icon: Icons.shopping_bag_outlined,
              onPressed: p.stock > 0 ? _addToCart : null,
            ),
          ),
        ],
      ),
    );
  }
}
