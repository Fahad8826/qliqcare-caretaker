import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  final double size;
  final Color? bgColor;

  const Loading({
    super.key,
    this.size = 200,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor ?? Colors.transparent,
      alignment: Alignment.center,
      child: Lottie.asset(
        'assets/lottie/loading.json', // <- your lottie file path
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
