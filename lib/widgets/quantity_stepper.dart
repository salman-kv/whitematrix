import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'tappable.dart';

/// "−  1  +" control used on the product page and in the cart.
class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final box = compact ? 28.0 : 36.0;
    Widget btn(IconData i, VoidCallback f, bool enabled) => Tappable(
      onTap: enabled ? f : null,
      child: Container(
        width: box,
        height: box,
        alignment: Alignment.center,
        child: Icon(
          i,
          size: compact ? 16 : 18,
          color: enabled ? AppColors.textPrimary : AppColors.textHint,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, onDecrement, value > 1),
          SizedBox(
            width: compact ? 26 : 34,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 150),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          btn(Icons.add_rounded, onIncrement, true),
        ],
      ),
    );
  }
}
