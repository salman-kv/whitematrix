import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'tappable.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool outlined;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.outlined = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: outlined ? Border.all(color: AppColors.border) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Icon(icon, size: size * 0.5, color: AppColors.textPrimary),
      ),
    );
  }
}
