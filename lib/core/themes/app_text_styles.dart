import 'package:flutter/material.dart';

import 'app_font_weight.dart';

/// AppTextStyles — centralized text styles
/// ─────────────────────────────────────────
/// Naming convention: font[Size][Weight]
/// Sizes: 12, 14, 16, 18, 20, 24
/// Weights: Light, Regular, SemiBold, Bold
///
/// Usage:
///   AppTextStyles.font16Regular
///   AppTextStyles.font18Bold.copyWith(color: AppColors.primary200)

class AppTextStyles {
  const AppTextStyles._();

  // ─────────────────────────────────────────────
  // 12
  // ─────────────────────────────────────────────

  static const TextStyle font12Light = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font12Regular = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font12Medium = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.medium,
  );

  static const TextStyle font12Bold = TextStyle(
    fontSize: 12,
    fontWeight: AppFontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // 14
  // ─────────────────────────────────────────────

  static const TextStyle font14Light = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font14Regular = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font14SemiBold = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.semiBold,
  );

  static const TextStyle font14Bold = TextStyle(
    fontSize: 14,
    fontWeight: AppFontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // 16
  // ─────────────────────────────────────────────

  static const TextStyle font16Light = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font16Regular = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font16SemiBold = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.semiBold,
  );

  static const TextStyle font16Bold = TextStyle(
    fontSize: 16,
    fontWeight: AppFontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // 18
  // ─────────────────────────────────────────────

  static const TextStyle font18Light = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font18Regular = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font18SemiBold = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.semiBold,
  );

  static const TextStyle font18Bold = TextStyle(
    fontSize: 18,
    fontWeight: AppFontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // 20
  // ─────────────────────────────────────────────

  static const TextStyle font20Light = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font20Regular = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font20SemiBold = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.semiBold,
  );

  static const TextStyle font20Bold = TextStyle(
    fontSize: 20,
    fontWeight: AppFontWeight.bold,
  );

  // ─────────────────────────────────────────────
  // 24
  // ─────────────────────────────────────────────

  static const TextStyle font24Light = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.light,
  );

  static const TextStyle font24Regular = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.regular,
  );

  static const TextStyle font24SemiBold = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.semiBold,
  );

  static const TextStyle font24Bold = TextStyle(
    fontSize: 24,
    fontWeight: AppFontWeight.bold,
  );
}
