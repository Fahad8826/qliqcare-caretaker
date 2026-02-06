import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import '../main.dart';

void showSnackbarSafe(
  String title,
  String message, {
  Duration duration = const Duration(seconds: 2),
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  Color? backgroundColor,
  Color? colorText,
  TextButton? mainButton,
}) {
  final messenger = rootScaffoldMessengerKey.currentState;

  if (messenger == null) return;

  messenger.clearSnackBars();

  // Decide margin based on position
  EdgeInsets margin;

  if (snackPosition == SnackPosition.TOP) {
    margin = const EdgeInsets.fromLTRB(16, 60, 16, 0);
  } else {
    margin = const EdgeInsets.fromLTRB(16, 0, 16, 16);
  }

  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: margin,

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorText,
            ),
          ),
          Text(
            message,
            style: TextStyle(color: colorText),
          ),
        ],
      ),

      action: mainButton != null
          ? SnackBarAction(
              label: mainButton.child is Text
                  ? (mainButton.child as Text).data ?? "Action"
                  : "Action",
              onPressed: mainButton.onPressed ?? () {},
            )
          : null,
    ),
  );
}