import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../models/cart_item.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_message.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _placing = false;

  Future<void> _checkout() async {
    setState(() => _placing = true);
    await Future<void>.delayed(Duration(milliseconds: 1100)); // fake payment
    if (!mounted) return;
    final order = context.read<CartController>().placeOrder();
    setState(() => _placing = false);
    Navigator.pushNamed(context, Routes.orderSuccess, arguments: order);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear cart?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) context.read<CartController>().clear();
  }

  void _remove(CartItem item) {
    final cart = context.read<CartController>();
    final index = cart.remove(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Item removed'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Color(0xFF8DB4FF),
            onPressed: () => cart.restore(item, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('My Cart'),
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Clear cart',
              icon: Icon(Icons.delete_outline_rounded),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: cart.isEmpty
          ? StateMessage(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Looks like you have not added anything yet.',
              actionLabel: 'Start Shopping',
              onAction: () =>
                  context.read<NavController>().select(NavController.home),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (_, i) {
                final item = cart.items[i];
                return Dismissible(
                  key: ValueKey(item.key),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _remove(item),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  child: _CartTile(item: item, onRemove: () => _remove(item)),
                );
              },
            ),
      // In the bottom slot so snack-bars (e.g. "Undo") appear above it.
      bottomNavigationBar: cart.isEmpty
          ? null
          : _Summary(cart: cart, placing: _placing, onCheckout: _checkout),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  const _CartTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartController>();
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppImage(url: item.product.thumbnail),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  item.product.brand.isNotEmpty
                      ? item.product.brand
                      : Fmt.titleCase(item.product.category),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  Fmt.money(item.lineTotal),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                QuantityStepper(
                  compact: true,
                  value: item.quantity,
                  onIncrement: () => cart.increment(item),
                  onDecrement: () => cart.decrement(item),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final CartController cart;
  final bool placing;
  final VoidCallback onCheckout;

  const _Summary({
    required this.cart,
    required this.placing,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    Widget row(String l, String v, {bool bold = false, Color? color}) =>
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                l,
                style: TextStyle(
                  fontSize: bold ? 15 : 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                v,
                style: TextStyle(
                  fontSize: bold ? 16 : 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.paddingOf(context).bottom * 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          row('Sub Total', Fmt.money(cart.subtotal)),
          row(
            'Shipping',
            cart.shipping == 0 ? 'Free' : Fmt.money(cart.shipping),
            color: cart.shipping == 0 ? AppColors.success : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: AppColors.border),
          ),
          row('Total', Fmt.money(cart.total), bold: true),
          SizedBox(height: 12),
          AppButton(label: 'Checkout', loading: placing, onPressed: onCheckout),
        ],
      ),
    );
  }
}
