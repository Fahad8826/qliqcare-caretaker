// import 'package:flutter/material.dart';
// import 'package:slide_to_act/slide_to_act.dart';
// import 'package:qlickcare/Utils/appcolors.dart';

// class AttendanceSlideButton extends StatefulWidget {
//   final bool isCheckedIn;
//   final Future<void> Function() onCheckIn;
//   final Future<void> Function() onCheckOut;

//   const AttendanceSlideButton({
//     super.key,
//     required this.isCheckedIn,
//     required this.onCheckIn,
//     required this.onCheckOut,
//   });

//   @override
//   State<AttendanceSlideButton> createState() => _AttendanceSlideButtonState();
// }

// class _AttendanceSlideButtonState extends State<AttendanceSlideButton> {
//   final GlobalKey<SlideActionState> _slideKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final bool isTablet = size.width >= 600;

//     final double width = size.width * (isTablet ? 0.6 : 0.75);
//     final double height = isTablet ? 52 : 48;
//     final double iconSize = isTablet ? 22 : 20;
//     final double fontSize = isTablet ? 16 : 14;

//     return Center(
//       child: Directionality(
//         textDirection: widget.isCheckedIn
//             ? TextDirection.rtl
//             : TextDirection.ltr,
//         child: SizedBox(
//           width: width,
//           child: SlideAction(
//             key: _slideKey,
//             height: height,
//             borderRadius: 20,
//             elevation: 0,
//             outerColor: widget.isCheckedIn
//                 ? const Color(0xFFE85C1F)
//                 : AppColors.primary,
//             innerColor: Colors.white,
//             sliderButtonIcon: Icon(
//               widget.isCheckedIn ? Icons.arrow_back : Icons.arrow_forward,
//               size: iconSize,
//               color: widget.isCheckedIn
//                   ? const Color(0xFFE85C1F)
//                   : AppColors.primary,
//             ),
//             sliderButtonIconPadding: 8,
//             text: widget.isCheckedIn
//                 ? "Slide to Check-Out"
//                 : "Slide to Check-In",
//             textStyle: AppTextStyles.button.copyWith(
//               fontSize: fontSize,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//             // onSubmit: () async {
//             //   // ✅ Call API
//             //   if (widget.isCheckedIn) {
//             //     await widget.onCheckOut();
//             //   } else {
//             //     await widget.onCheckIn();
//             //   }

//             //   // ✅ IMPORTANT: reset AFTER API & rebuild
//             //   await Future.delayed(const Duration(milliseconds: 300));
//             //   if (mounted) {
//             //     _slideKey.currentState?.reset();
//             //   }
//             // },
//             onSubmit: () async {
//               try {
//                 if (widget.isCheckedIn) {
//                   await widget.onCheckOut();
//                 } else {
//                   await widget.onCheckIn();
//                 }
//               } catch (e) {
//                 debugPrint("SlideAction error: $e");
//               } finally {
//                 // ✅ SAFEST reset
//                 final slideState = _slideKey.currentState;
//                 if (slideState != null && mounted) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     slideState.reset();
//                   });
//                 }
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'dart:math' show cos, sqrt, asin;

class AttendanceSlideButton extends StatefulWidget {
  final bool isCheckedIn;
  final Future Function() onCheckIn;
  final Future Function() onCheckOut;
  final double caretakerLatitude;
  final double caretakerLongitude;
  final double bookingLatitude;
  final double bookingLongitude;
  final double radiusInMeters; // Maximum distance allowed

  const AttendanceSlideButton({
    super.key,
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.caretakerLatitude,
    required this.caretakerLongitude,
    required this.bookingLatitude,
    required this.bookingLongitude,
    this.radiusInMeters = 100.0, // Default 100 meters
  });

  @override
  State<AttendanceSlideButton> createState() => _AttendanceSlideButtonState();
}

class _AttendanceSlideButtonState extends State<AttendanceSlideButton> {
  final GlobalKey<SlideActionState> _slideKey = GlobalKey<SlideActionState>();
  bool _isWithinRange = false;
  double _currentDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  @override
  void didUpdateWidget(AttendanceSlideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate if coordinates change
    if (oldWidget.caretakerLatitude != widget.caretakerLatitude ||
        oldWidget.caretakerLongitude != widget.caretakerLongitude) {
      _calculateDistance();
    }
  }

  // Calculate distance using Haversine formula
  void _calculateDistance() {
    _currentDistance = _haversineDistance(
      widget.caretakerLatitude,
      widget.caretakerLongitude,
      widget.bookingLatitude,
      widget.bookingLongitude,
    );

    setState(() {
      _isWithinRange = _currentDistance <= widget.radiusInMeters;
    });

    debugPrint(
      "📍 Distance: ${_currentDistance.toStringAsFixed(0)}m | Within range: $_isWithinRange",
    );
  }

  // Haversine formula to calculate distance between two coordinates
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  double sin(double value) {
    return _sin(value);
  }

  double cos(double value) {
    return _cos(value);
  }

  // Taylor series approximation for sin
  double _sin(double x) {
    double sum = 0;
    double term = x;
    for (int n = 1; n <= 10; n++) {
      sum += term;
      term *= -x * x / ((2 * n) * (2 * n + 1));
    }
    return sum;
  }

  // Taylor series approximation for cos
  double _cos(double x) {
    double sum = 1;
    double term = 1;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      sum += term;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;
    final double width = size.width * (isTablet ? 0.6 : 0.75);
    final double height = isTablet ? 52 : 48;
    final double iconSize = isTablet ? 22 : 20;
    final double fontSize = isTablet ? 16 : 14;

    return Center(
      child: Column(
        children: [
          // Location status message
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isWithinRange ? Icons.check_circle : Icons.location_off,
                  size: 16,
                  color: _isWithinRange ? AppColors.success : AppColors.error,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isWithinRange
                        ? "You are at the location (${_currentDistance.toStringAsFixed(0)}m away)"
                        : "You are too far from the location (${_currentDistance.toStringAsFixed(0)}m away). Required: within ${widget.radiusInMeters.toStringAsFixed(0)}m",
                    style: AppTextStyles.small.copyWith(
                      color: _isWithinRange
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: fontSize - 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Show button only if within range
          if (_isWithinRange)
            Directionality(
              textDirection: widget.isCheckedIn
                  ? TextDirection.rtl
                  : TextDirection.ltr,
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
                    widget.isCheckedIn ? Icons.arrow_back : Icons.arrow_forward,
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
                    try {
                      if (widget.isCheckedIn) {
                        await widget.onCheckOut();
                      } else {
                        await widget.onCheckIn();
                      }
                    } catch (e) {
                      debugPrint("SlideAction error: $e");
                    } finally {
                      // ✅ SAFEST reset
                      final slideState = _slideKey.currentState;
                      if (slideState != null && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          slideState.reset();
                        });
                      }
                    }
                  },
                ),
              ),
            )
          else
            Container(
              width: width,
              padding: EdgeInsets.symmetric(
                vertical: height * 0.3,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "Move closer to the location to ${widget.isCheckedIn ? 'check out' : 'check in'}",
                style: AppTextStyles.body.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
