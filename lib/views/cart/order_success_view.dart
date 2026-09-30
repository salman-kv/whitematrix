import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/nav_controller.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/routes.dart';
import '../../models/order.dart';
import '../../widgets/app_button.dart';

class OrderSuccessView extends StatefulWidget {
  final Order order;
  const OrderSuccessView({super.key, required this.order});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _goHome({bool toOrders = false}) {
    context.read<NavController>().select(NavController.home);
    Navigator.pushNamedAndRemoveUntil(context, Routes.shell, (r) => false);
    if (toOrders) Navigator.pushNamed(context, Routes.orders);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final pop = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
      parent: _anim,
      curve: Interval(0.4, 1, curve: Curves.easeOut),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              children: [
                Spacer(),
                ScaleTransition(
                  scale: pop,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                FadeTransition(
                  opacity: fade,
                  child: Column(
                    children: [
                      Text(
                        'Order Placed!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Thank you for shopping with ShopEase.\nYour order is on its way.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _line('Order ID', '#${o.id}'),
                            SizedBox(height: 8),
                            _line('Items', '${o.items.length}'),
                            SizedBox(height: 8),
                            _line('Total paid', Fmt.money(o.total), bold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                AppButton(label: 'Continue Shopping', onPressed: _goHome),
                SizedBox(height: 12),
                AppButton(
                  label: 'View Orders',
                  outlined: true,
                  onPressed: () => _goHome(toOrders: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(String l, String v, {bool bold = false}) => Row(
    children: [
      Text(l, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Spacer(),
      Text(
        v,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}
