import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class AttendanceSlideButton extends StatefulWidget {
  final bool isCheckedIn;
  final Future<void> Function() onCheckIn;
  final Future<void> Function() onCheckOut;

  const AttendanceSlideButton({
    super.key,
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  State<AttendanceSlideButton> createState() =>
      _AttendanceSlideButtonState();
}

class _AttendanceSlideButtonState extends State<AttendanceSlideButton> {
  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    final double width = size.width * (isTablet ? 0.6 : 0.75);
    final double height = isTablet ? 52 : 48;
    final double iconSize = isTablet ? 22 : 20;
    final double fontSize = isTablet ? 16 : 14;

    return Center(
      child: Directionality(
        textDirection:
            widget.isCheckedIn ? TextDirection.rtl : TextDirection.ltr,
        child: SizedBox(
          width: width,
          child: SlideAction(
            key: _slideKey,
            height: height,
            borderRadius: 20,
            elevation: 0,
            outerColor: widget.isCheckedIn
                ? const Color(0xFFE85C1F)
                : AppColors.primary,
            innerColor: Colors.white,
            sliderButtonIcon: Icon(
              widget.isCheckedIn
                  ? Icons.arrow_back
                  : Icons.arrow_forward,
              size: iconSize,
              color: widget.isCheckedIn
                  ? const Color(0xFFE85C1F)
                  : AppColors.primary,
            ),
            sliderButtonIconPadding: 8,
            text: widget.isCheckedIn
                ? "Slide to Check-Out"
                : "Slide to Check-In",
            textStyle: AppTextStyles.button.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            onSubmit: () async {
              // ✅ Call API
              if (widget.isCheckedIn) {
                await widget.onCheckOut();
              } else {
                await widget.onCheckIn();
              }

              // ✅ IMPORTANT: reset AFTER API & rebuild
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                _slideKey.currentState?.reset();
              }
            },
          ),
        ),
      ),
    );
  }
}
