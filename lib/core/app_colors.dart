import 'package:flutter/material.dart';

/// Central colour palette, sampled from the ShopEase design board.
///
/// Brand / status colours are constants. Surface and text colours are getters
/// that switch between the light and dark palette according to [dark], which
/// the app updates whenever the theme changes (see `_ShopEaseAppState`).
class AppColors {
  AppColors._();

  /// True while the dark palette is active.
  static bool dark = false;

  // --- Brand & status (same in both themes) ---
  static const primary = Color(0xFF1F64F2);
  static const star = Color(0xFFFFB020);
  static const heart = Color(0xFFEF4444);
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);

  // --- Theme dependent ---
  /// Page background.
  static Color get bg => dark ? const Color(0xFF0E131F) : Colors.white;

  /// Cards, sheets, chips, bars sitting on [bg].
  static Color get card => dark ? const Color(0xFF171E2E) : Colors.white;

  /// Soft fill: input fields, image tiles, toggles.
  static Color get surface =>
      dark ? const Color(0xFF1F2738) : const Color(0xFFF4F6FA);

  static Color get border =>
      dark ? const Color(0xFF2B3550) : const Color(0xFFE5E9F0);

  static Color get textPrimary =>
      dark ? const Color(0xFFEAEFF8) : const Color(0xFF0F172A);

  static Color get textSecondary =>
      dark ? const Color(0xFF9AA7BF) : const Color(0xFF64748B);

  static Color get textHint =>
      dark ? const Color(0xFF6E7B93) : const Color(0xFF9AA4B5);

  /// Light tint of the brand colour (selected rows, info boxes).
  static Color get primaryLight =>
      dark ? const Color(0xFF1A2B52) : const Color(0xFFE8F0FE);

  static Color get successLight =>
      dark ? const Color(0xFF12351F) : const Color(0xFFDCFCE7);

  static Color get errorLight =>
      dark ? const Color(0xFF3A1A1E) : const Color(0xFFFEECEC);

  static Color get errorBorder =>
      dark ? const Color(0xFF6B2A31) : const Color(0xFFF9C4C4);

  static Color get warningLight =>
      dark ? const Color(0xFF3A2E12) : const Color(0xFFFFF4DB);

  static Color get warningText =>
      dark ? const Color(0xFFF0C56A) : const Color(0xFF8A5A10);

  /// End colour of the splash gradient.
  static Color get splashEnd =>
      dark ? const Color(0xFF131B2E) : const Color(0xFFF1F6FF);

  /// Snack-bar background.
  static Color get snack =>
      dark ? const Color(0xFF2A3450) : const Color(0xFF0F172A);

  static Color get shimmerBase =>
      dark ? const Color(0xFF1F2738) : const Color(0xFFEEF1F6);

  static Color get shimmerHighlight =>
      dark ? const Color(0xFF2B3550) : const Color(0xFFF9FAFC);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1248C4)],
  );
}
