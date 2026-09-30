import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

void showNotificationsSheet(BuildContext context) {
  const items = [
    (
      Icons.local_offer_rounded,
      'Flash sale is live',
      'Up to 50% off on fashion — today only.',
    ),
    (
      Icons.local_shipping_rounded,
      'Free shipping',
      'Orders above \$50 ship free.',
    ),
    (
      Icons.favorite_rounded,
      'Wishlist reminder',
      'Items you saved are still available.',
    ),
  ];

  showModalBottomSheet<void>(
    context: context,
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 14),
          for (final (icon, title, body) in items)
            Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primary),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
