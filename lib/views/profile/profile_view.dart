import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/app_colors.dart';
import '../../core/routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tappable.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Log out?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final nav = context.read<NavController>();
    await context.read<AuthController>().logout();
    nav.select(NavController.home);
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
  }

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name is not part of this demo')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final accent = auth.account?.accent ?? AppColors.primary;
    final nav = context.read<NavController>();

    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.inventory_2_outlined,
        'My Orders',
        () => Navigator.pushNamed(context, Routes.orders),
      ),
      (
        Icons.favorite_border_rounded,
        'Wishlist',
        () => nav.select(NavController.wishlist),
      ),
      (
        Icons.location_on_outlined,
        'Addresses',
        () => _soon(context, 'Addresses'),
      ),
      (
        Icons.credit_card_rounded,
        'Payment Methods',
        () => _soon(context, 'Payment Methods'),
      ),
      (
        Icons.notifications_none_rounded,
        'Notifications',
        () => _soon(context, 'Notifications'),
      ),
      (
        Icons.headset_mic_outlined,
        'Help & Support',
        () => _soon(context, 'Help & Support'),
      ),
      (
        Icons.settings_outlined,
        'Settings',
        () => Navigator.pushNamed(context, Routes.settings),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accent.withValues(alpha: 0.75), accent],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Center(
                  child: Text(
                    user?.name ?? 'Guest',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 2),
                Center(
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 26),
                for (final (icon, label, onTap) in items)
                  Tappable(
                    onTap: onTap,
                    pressedScale: 0.985,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              size: 19,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 14),
                AppButton(
                  label: 'Log out',
                  outlined: true,
                  icon: Icons.logout_rounded,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
