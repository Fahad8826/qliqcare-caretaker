import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/attendance/model/bookingattendance_model.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/bookings/model/bookingdetails_model.dart';

class EnhancedAttendanceSummary extends StatelessWidget {
  final BookingDetails booking;

  const EnhancedAttendanceSummary({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final summary = booking.attendanceSummary;
    final todayAttendance = booking.todayAttendance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Attendance Summary",
          style: AppTextStyles.subtitle.copyWith(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        // Today's Status Card
        if (todayAttendance != null && todayAttendance.hasAttendance)
          _buildTodayStatusCard(size, todayAttendance)
        else
          _buildNoTodayDataCard(size),

        SizedBox(height: size.height * 0.02),

        // Booking Progress Card
        if (booking.daysElapsed != null && booking.daysRemaining != null)
          _buildBookingProgressCard(size, booking),

        if (booking.daysElapsed != null && 
            booking.daysRemaining != null && 
            summary != null)
          SizedBox(height: size.height * 0.02),

        // Overall Statistics
        if (summary != null) _buildStatisticsCard(size, summary),
      ],
    );
  }

  Widget _buildTodayStatusCard(Size size, TodayAttendance todayAttendance) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (todayAttendance.status) {
      case 'CHECKED_IN':
        statusColor = AppColors.success;
        statusIcon = FontAwesomeIcons.circleCheck;
        statusText = 'Currently Checked In';
        break;
      case 'CHECKED_OUT':
        statusColor = Colors.blue;
        statusIcon = FontAwesomeIcons.clockRotateLeft;
        statusText = 'Work Completed';
        break;
      case 'ON_LEAVE':
        statusColor = Colors.orange;
        statusIcon = FontAwesomeIcons.umbrellaBeach;
        statusText = 'On Approved Leave';
        break;
      case 'ABSENT':
        statusColor = AppColors.error;
        statusIcon = FontAwesomeIcons.circleXmark;
        statusText = 'Not Checked In';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = FontAwesomeIcons.clock;
        statusText = 'No Data';
    }

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
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
            "Today's Attendance",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTextStyles.body.copyWith(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    if (todayAttendance.activeSession != null)
                      Text(
                        "Session #${todayAttendance.activeSession}",
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (todayAttendance.totalSessions > 0) ...[
            SizedBox(height: size.height * 0.015),
            Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)),
            SizedBox(height: size.height * 0.015),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  size,
                  FontAwesomeIcons.listCheck,
                  "Sessions",
                  todayAttendance.totalSessions.toString(),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                _buildMetricItem(
                  size,
                  FontAwesomeIcons.clock,
                  "Hours Today",
                  todayAttendance.totalHoursToday.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoTodayDataCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
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
            "Today's Attendance",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.calendarDay,
                color: AppColors.textSecondary,
                size: 20,
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Text(
                  "No attendance data for today",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingProgressCard(Size size, BookingDetails booking) {
    final totalDuration = (booking.daysElapsed ?? 0) + (booking.daysRemaining ?? 0);
    final progress = totalDuration > 0 
        ? (booking.daysElapsed ?? 0) / totalDuration 
        : 0.0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
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
            "Booking Progress",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Days Elapsed",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${booking.daysElapsed}",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Days Remaining",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${booking.daysRemaining}",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.045,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.015),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(Size size, AttendanceSummary summary) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
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
            "Overall Statistics",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.calendar,
                  "Total Days",
                  summary.totalDays.toString(),
                  Colors.blue,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.calendarCheck,
                  "Expected",
                  summary.expectedDays.toString(),
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.circleCheck,
                  "Worked",
                  summary.daysWorked.toString(),
                  AppColors.success,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.circleXmark,
                  "Absent",
                  summary.absentDays.toString(),
                  AppColors.error,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          // Third Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.umbrellaBeach,
                  "Leave",
                  summary.leaveDays.toString(),
                  Colors.orange,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.clock,
                  "Total Hours",
                  summary.totalHours.toStringAsFixed(1),
                  Colors.indigo,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          // Fourth Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.listCheck,
                  "Sessions",
                  summary.totalSessions.toString(),
                  Colors.teal,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: _buildStatItem(
                  size,
                  FontAwesomeIcons.checkDouble,
                  "Completed",
                  summary.completedSessions.toString(),
                  Colors.cyan,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.015),
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: size.height * 0.015),

          // Attendance Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Attendance Rate",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.025,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getAttendanceRateColor(summary.attendanceRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${summary.attendanceRate.toStringAsFixed(1)}%",
                  style: AppTextStyles.body.copyWith(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: _getAttendanceRateColor(summary.attendanceRate),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: summary.attendanceRate / 100,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAttendanceRateColor(summary.attendanceRate),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    Size size,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(
                    fontSize: size.width * 0.028,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    Size size,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return Colors.orange;
    return AppColors.error;
  }
}