import 'package:flutter/material.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Model/bookings/Details/myreassaignmentperiod.dart';

/// ✅ Attendance Status Enum
enum AttendanceDayStatus {
  checkedIn,
  checkedOut,
  absent,
  upcoming,
  onLeave,
}

class AttendanceCalendar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<int, AttendanceDayStatus> attendanceData;
  
  /// 🔥 NEW: Reassignment periods
  final List<MyReassignmentPeriod>? reassignmentPeriods;

  const AttendanceCalendar({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.attendanceData,
    this.reassignmentPeriods,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Month Title
          Text(
            _getMonthName(startDate.month),
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          /// Week Header
          _buildWeekHeader(),

          const SizedBox(height: 8),

          /// Calendar Grid
          _buildCalendarGrid(),

          const SizedBox(height: 16),

          /// Legend with Reassignment
          _buildLegend(),
          
          /// Show reassignment info if exists
               ],
      ),
    );
  }

  // ---------------- WEEK HEADER ----------------

  Widget _buildWeekHeader() {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------- CALENDAR GRID ----------------

  Widget _buildCalendarGrid() {
    final int totalDays = endDate.difference(startDate).inDays + 1;
    final int startWeekday = startDate.weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalDays + startWeekday,
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox.shrink();
        }

        final int dayIndex = index - startWeekday;
        final DateTime currentDate = startDate.add(Duration(days: dayIndex));
        final int day = currentDate.day;
        final AttendanceDayStatus? status = attendanceData[day];
        final bool isToday = _isSameDate(currentDate, DateTime.now());
        
        /// 🔥 CHECK IF THIS DATE IS IN REASSIGNMENT PERIOD
        final reassignmentInfo = _getReassignmentForDate(currentDate);
        final bool isReassigned = reassignmentInfo != null;

        return _buildCalendarDay(
          day: day,
          status: status,
          isToday: isToday,
          isReassigned: isReassigned,
          reassignmentInfo: reassignmentInfo,
        );
      },
    );
  }

  // ---------------- BUILD CALENDAR DAY ----------------

  Widget _buildCalendarDay({
    required int day,
    required AttendanceDayStatus? status,
    required bool isToday,
    required bool isReassigned,
    MyReassignmentPeriod? reassignmentInfo,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: status != null
            ? _getAttendanceColor(status)
            : Colors.transparent,
        border: Border.all(
          color: isReassigned
              ? Colors.blue.shade700
              : (isToday ? AppColors.primary : Colors.grey.shade300),
          width: isReassigned ? 2.5 : (isToday ? 1.5 : 1),
        ),
        /// 🔥 Add gradient overlay for reassigned dates
        gradient: isReassigned
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (status != null ? _getAttendanceColor(status) : Colors.grey.shade200),
                  (status != null ? _getAttendanceColor(status) : Colors.grey.shade200)
                      .withOpacity(0.7),
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          /// Day Number
          Center(
            child: Text(
              "$day",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: status != null ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          
          /// 🔥 Reassignment Indicator
          if (isReassigned)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- CHECK REASSIGNMENT FOR DATE ----------------

  MyReassignmentPeriod? _getReassignmentForDate(DateTime date) {
    if (reassignmentPeriods == null || reassignmentPeriods!.isEmpty) {
      return null;
    }

    for (var period in reassignmentPeriods!) {
      try {
        final start = DateTime.parse(period.startDate);
        final end = DateTime.parse(period.endDate);
        
        final startDateOnly = DateTime(start.year, start.month, start.day);
        final endDateOnly = DateTime(end.year, end.month, end.day);
        final checkDate = DateTime(date.year, date.month, date.day);

        if ((checkDate.isAtSameMomentAs(startDateOnly) || checkDate.isAfter(startDateOnly)) &&
            (checkDate.isAtSameMomentAs(endDateOnly) || checkDate.isBefore(endDateOnly))) {
          return period;
        }
      } catch (e) {
        debugPrint("Error parsing reassignment dates: $e");
      }
    }
    
    return null;
  }

  // ---------------- LEGEND ----------------

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(Colors.orange, "Checked In"),
        _legendItem(Colors.green, "Checked Out"),
        _legendItem(Colors.red, "Absent"),
        _legendItem(Colors.grey, "Upcoming"),
        _legendItem(Colors.purple, "On Leave"),
        if (reassignmentPeriods != null && reassignmentPeriods!.isNotEmpty)
          _legendItem(Colors.blue.shade700, "Reassigned", showDot: true),
      ],
    );
  }

  Widget _legendItem(Color color, String text, {bool showDot = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showDot)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1),
              ),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  
  // ---------------- STATUS → COLOR ----------------

  Color _getAttendanceColor(AttendanceDayStatus status) {
    switch (status) {
      case AttendanceDayStatus.checkedIn:
        return Colors.orange;
      case AttendanceDayStatus.checkedOut:
        return Colors.green;
      case AttendanceDayStatus.absent:
        return Colors.red;
      case AttendanceDayStatus.onLeave:
        return Colors.purple;
      case AttendanceDayStatus.upcoming:
        return Colors.grey;
    }
  }

  // ---------------- HELPERS ----------------

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December",
    ];
    return months[month - 1];
  }
}