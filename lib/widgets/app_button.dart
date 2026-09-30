import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'tappable.dart';

/// Primary filled button (also supports an outlined variant and loading state).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = outlined ? AppColors.primary : Colors.white;

    return Tappable(
      onTap: enabled ? onPressed : null,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined
              ? AppColors.card
              : (onPressed == null ? AppColors.textHint : AppColors.primary),
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppColors.primary, width: 1.4)
              : null,
          boxShadow: outlined || onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
