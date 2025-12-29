import 'package:flutter/material.dart';
import 'package:qlickcare/Utils/appcolors.dart';

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

  /// 🔥 STATUS-BASED DATA
  final Map<int, AttendanceDayStatus> attendanceData;

  const AttendanceCalendar({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.attendanceData,
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

          /// Legend
          _buildLegend(),
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
    final int totalDays =
        endDate.difference(startDate).inDays + 1;

    /// Offset for correct weekday alignment
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
        /// Empty cells before start date
        if (index < startWeekday) {
          return const SizedBox.shrink();
        }

        final int dayIndex = index - startWeekday;
        final DateTime currentDate =
            startDate.add(Duration(days: dayIndex));

        final int day = currentDate.day;

        final AttendanceDayStatus? status =
            attendanceData[day];

        final bool isToday =
            _isSameDate(currentDate, DateTime.now());

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: status != null
                ? _getAttendanceColor(status)
                : Colors.transparent,
            border: Border.all(
              color: isToday
                  ? AppColors.primary
                  : Colors.grey.shade300,
              width: isToday ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            "$day",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: status != null
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
          ),
        );
      },
    );
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
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
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
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
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
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
