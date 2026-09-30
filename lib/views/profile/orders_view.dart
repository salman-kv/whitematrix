import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../models/order.dart';
import '../../widgets/app_image.dart';
import '../../widgets/state_message.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<CartController>().orders;

    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: orders.isEmpty
          ? StateMessage(
              icon: Icons.inventory_2_outlined,
              title: 'No orders yet',
              message: 'Orders you place will show up here.',
            )
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final d = order.placedAt;
    final date =
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Processing',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            date,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: order.items.length,
              separatorBuilder: (_, _) => SizedBox(width: 8),
              itemBuilder: (_, i) => Container(
                width: 56,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppImage(url: order.items[i].product.thumbnail),
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${order.items.length} item(s)',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                Fmt.money(order.total),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
