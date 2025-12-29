
/// ---------------- ATTENDANCE ENUM & PARSER ----------------
enum AttendanceStatus {
  checkedIn,
  checkedOut,
  absent,
  upcoming,
}



class AttendanceItem {
  final DateTime date;
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String totalHours;
  final String workDuration;

  AttendanceItem({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.workDuration,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      date: DateTime.parse(json['date']),
      status: json['status'],
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      totalHours: json['total_hours'] ?? "0",
      workDuration: json['work_duration'] ?? "",
    );
  }
}


/// ---------------- ATTENDANCE SUMMARY ----------------
class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;

  AttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
    );
  }
}

class AttendanceStats {
  final OverallStats overall;
  final MonthlyStats currentMonth;
  final TodayStats today;

  AttendanceStats({
    required this.overall,
    required this.currentMonth,
    required this.today,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      overall: OverallStats.fromJson(json['overall']),
      currentMonth: MonthlyStats.fromJson(json['current_month']),
      today: TodayStats.fromJson(json['today']),
    );
  }
}

class OverallStats {
  final int totalSessions;
  final int uniqueDaysWorked;
  final double totalHoursWorked;
  final double avgHoursPerDay;
  final double avgHoursPerSession;

  OverallStats({
    required this.totalSessions,
    required this.uniqueDaysWorked,
    required this.totalHoursWorked,
    required this.avgHoursPerDay,
    required this.avgHoursPerSession,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalSessions: json['total_sessions'],
      uniqueDaysWorked: json['unique_days_worked'],
      totalHoursWorked: json['total_hours_worked'].toDouble(),
      avgHoursPerDay: json['average_hours_per_day'].toDouble(),
      avgHoursPerSession: json['average_hours_per_session'].toDouble(),
    );
  }
}

class MonthlyStats {
  final int totalSessions;
  final int uniqueDaysWorked;
  final double totalHours;

  MonthlyStats({
    required this.totalSessions,
    required this.uniqueDaysWorked,
    required this.totalHours,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      totalSessions: json['total_sessions'],
      uniqueDaysWorked: json['unique_days_worked'],
      totalHours: json['total_hours'].toDouble(),
    );
  }
}

class TodayStats {
  final int totalSessions;
  final int activeSessions;
  final int completedSessions;
  final double totalHours;
  final bool hasActiveSession;

  TodayStats({
    required this.totalSessions,
    required this.activeSessions,
    required this.completedSessions,
    required this.totalHours,
    required this.hasActiveSession,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      totalSessions: json['total_sessions'],
      activeSessions: json['active_sessions'],
      completedSessions: json['completed_sessions'],
      totalHours: json['total_hours'].toDouble(),
      hasActiveSession: json['has_active_session'],
    );
  }
}
