import 'package:flutter/material.dart';

/// Layout helpers so the same screens adapt from small phones to tablets.
class Responsive {
  Responsive._();

  /// Number of product-grid columns for the available width.
  static int gridColumns(double width) => (width / 185).floor().clamp(2, 5);

  /// Horizontal page padding that grows on wide screens.
  static double pagePadding(double width) => width > 700 ? 28 : 16;

  /// Text-scale aware height of a product card for a given cell width.
  static double productCardExtent(BuildContext context, double cellWidth) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);
    return cellWidth + 82 * scale;
  }
}
