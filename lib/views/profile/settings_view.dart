import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/theme_controller.dart';
import '../../core/app_colors.dart';
import '../../widgets/tappable.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Choose how ShopEase looks. The whole app updates instantly.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                mode: AppThemeMode.light,
                selected: theme.mode == AppThemeMode.light,
                onTap: () => theme.setMode(AppThemeMode.light),
              ),
              SizedBox(width: 12),
              _ThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                mode: AppThemeMode.dark,
                selected: theme.mode == AppThemeMode.dark,
                onTap: () => theme.setMode(AppThemeMode.dark),
              ),
              SizedBox(width: 12),
              _ThemeOption(
                label: 'System',
                icon: Icons.brightness_auto_rounded,
                mode: AppThemeMode.system,
                selected: theme.mode == AppThemeMode.system,
                onTap: () => theme.setMode(AppThemeMode.system),
              ),
            ],
          ),
          SizedBox(height: 28),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
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
                    Icons.info_outline_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ShopEase',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Version 1.0.0 • Shop Smarter, Live Better',
                        style: TextStyle(
                          fontSize: 12,
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
    );
  }
}

/// A selectable card with a mini preview of the theme it applies.
class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tappable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              _Preview(mode: mode),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny mock screen showing what the theme looks like.
class _Preview extends StatelessWidget {
  final AppThemeMode mode;
  const _Preview({required this.mode});

  @override
  Widget build(BuildContext context) {
    Widget half(bool dark) {
      final bg = dark ? Color(0xFF0E131F) : Colors.white;
      final tile = dark ? Color(0xFF1F2738) : Color(0xFFF4F6FA);
      return Container(
        color: bg,
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              width: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: tile,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: 4,
              width: 20,
              decoration: BoxDecoration(
                color: dark ? Color(0xFF6E7B93) : Color(0xFFB9C2D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 78,
        child: switch (mode) {
          AppThemeMode.light => half(false),
          AppThemeMode.dark => half(true),
          AppThemeMode.system => Row(
            children: [
              Expanded(child: half(false)),
              Expanded(child: half(true)),
            ],
          ),
        },
      ),
    );
  }
}
