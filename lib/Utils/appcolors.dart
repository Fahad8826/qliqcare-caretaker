import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (From Figma)
  static const Color primary = Color.fromARGB(255, 31, 113, 65); // #0A3D2E
  static const Color secondary = Color.fromARGB(255, 18, 108, 75); // #0E9F6E

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color screenBackground = Color(0xFFF5F5F5);

  // Button Colors
  static const Color button = primary;
  static const Color buttonText = Colors.white;

  // AppBar Colors
  static const Color appBar = primary;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Error / Success
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;

  // Borders
  static const Color border = Color(0xFFE0E0E0);
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle heading1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle small = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );
}
