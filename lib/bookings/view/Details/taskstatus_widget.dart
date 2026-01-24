import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qlickcare/bookings/controller/bookingdetailscontroller.dart';

import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/bookings/model/bookingdetails_model.dart';

final detailsController = Get.find<BookingDetailsController>();
/// Returns true if the booking end date is before today.
bool isBookingCompleted(String endDate) {
  if (endDate.isEmpty) return false;
  try {
    final bookingEnd = DateTime.parse(endDate);
    final now = DateTime.now();
    return bookingEnd.isBefore(DateTime(now.year, now.month, now.day));
  } catch (e) {
    return false;
  }
}

Widget buildCaretakerStatusMessage(BookingDetails booking) {
  String? message;
  Color color = AppColors.textSecondary;
  IconData icon = Icons.info_outline;

  if (detailsController.isCheckedOutToday) {
    message = "You have completed today’s attendance.";
    color = AppColors.success;
    icon = Icons.check_circle_outline;
  } else if (detailsController.isOnLeaveToday) {
    message = "You are on leave today. Tasks and attendance are disabled.";
    color = AppColors.error;
    icon = Icons.event_busy;
  } else if (booking.endDate.isNotEmpty &&
      isBookingCompleted(booking.endDate)) {
    message = "This booking period has ended. No further actions are required.";
    color = AppColors.error;
    icon = Icons.lock_clock;
  }

  if (message == null) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}


