import 'package:flutter/material.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const Loading()
            : Text(
                text,
                style: const TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class LargeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;       // true = filled, false = outlined
  final Color? color;         // optional custom color
  final EdgeInsetsGeometry? padding;

  const LargeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color btnColor = color ?? (isPrimary ? AppColors.primary : AppColors.error);
    final double w = MediaQuery.of(context).size.width;

    if (isPrimary) {
      /// FILLED BUTTON
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          padding: padding ?? EdgeInsets.symmetric(vertical: w * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );
    } else {
      /// OUTLINED BUTTON
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: btnColor, width: 1.4),
          padding: padding ?? EdgeInsets.symmetric(vertical: w * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: btnColor),
        ),
      );
    }
  }
}
