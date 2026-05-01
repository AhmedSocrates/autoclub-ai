import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  // --- Headings (black on white) ---
  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.57,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    height: 1.65,
  );

  // --- Body Text (dark on light) ---
  static const TextStyle bodyLg = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    height: 1.83,
  );

  static const TextStyle bodyMd = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.76,
  );

  static const TextStyle bodySm = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.68,
  );

  // --- Labels & Captions ---
  static const TextStyle label = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    height: 1.57,
    letterSpacing: 0.5,
  );

  // --- Inverted: white text on dark/black surfaces ---
  static const TextStyle h1Inverted = TextStyle(
    color: AppColors.textOnDark,
    fontSize: 24,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyMdInverted = TextStyle(
    color: AppColors.textOnDark,
    fontSize: 14,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.76,
  );

  static const TextStyle bodySmInverted = TextStyle(
    color: AppColors.textOnDark,
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.68,
  );
}
