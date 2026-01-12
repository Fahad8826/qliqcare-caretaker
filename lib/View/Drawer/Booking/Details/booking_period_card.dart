import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/Model/bookings/Details/myreassaignmentperiod.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Model/bookings/Details/bookingdetails_model.dart';

class BookingPeriodCard extends StatelessWidget {
  final BookingDetails booking;

  const BookingPeriodCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.startDate.isEmpty || booking.endDate.isEmpty) {
      return SizedBox.shrink();
    }

    // Parse normal dates
    final startDate = DateTime.tryParse(booking.startDate);
    final endDate = DateTime.tryParse(booking.endDate);

    if (startDate == null || endDate == null) {
      return SizedBox.shrink();
    }

    final duration = endDate.difference(startDate).inDays + 1;

    // 🔍 Find my active reassignment period (first match)
    MyReassignmentPeriod? myPeriod;
    if (booking.myReassignmentPeriods != null) {
      try {
        myPeriod = booking.myReassignmentPeriods!.firstWhere(
          (p) => p.amIReassignedTo == true,
        );
      } catch (e) {
        myPeriod = null;
      }
    }

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Period",
            style: AppTextStyles.heading2.copyWith(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10),

          /// Normal booking period row
          Row(
            children: [
              Expanded(child: _dateItem("Start Date", startDate)),
              Container(
                height: 40,
                width: 1,
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
              Expanded(child: _dateItem("End Date", endDate)),
            ],
          ),

          SizedBox(height: 10),

          /// Duration Chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Total Duration: $duration days",
              style: AppTextStyles.body.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 16),

          /// 🌟 Highlight reassignment period if applicable
          if (myPeriod != null) ...[
            Divider(height: 24),
            Text(
              "Reassigned Working Period",
              style: AppTextStyles.heading2.copyWith(
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _dateItem(
                    "Start Date",
                    DateTime.parse(myPeriod.startDate),
                    highlight: true,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.orange.withOpacity(0.3),
                ),
                Expanded(
                  child: _dateItem(
                    "End Date",
                    DateTime.parse(myPeriod.endDate),
                    highlight: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "You are assigned for ${myPeriod.totalDays} days",
                style: AppTextStyles.body.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateItem(String title, DateTime date, {bool highlight = false}) {
    final textColor = highlight ? Colors.orange : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.small.copyWith(
            color: highlight ? Colors.orange : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          DateFormat('dd MMM yyyy').format(date),
          style: AppTextStyles.body.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
