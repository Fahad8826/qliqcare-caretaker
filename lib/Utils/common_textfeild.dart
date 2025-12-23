import 'package:flutter/material.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 18 : 14,
        ),

        // Normal Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border, // 🔥 using border color
            width: 1,
          ),
        ),

        // Focused Border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary, // 🔥 primary brand color
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
