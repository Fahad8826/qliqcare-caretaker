import 'package:qlickcare/Model/attendance/attendancesession_model.dart';
import 'package:qlickcare/Model/attendance/attendencestatus_model.dart';

// ============================================
// ATTENDANCE ENUMS
// ============================================
enum AttendanceStatus {
  checkedIn,
  checkedOut,
  absent,
  onLeave,
  upcoming,
}

// Helper to parse string status to enum
AttendanceStatus parseAttendanceStatus(String status) {
  switch (status.toUpperCase()) {
    case 'CHECKED_IN':
      return AttendanceStatus.checkedIn;
    case 'CHECKED_OUT':
      return AttendanceStatus.checkedOut;
    case 'ABSENT':
      return AttendanceStatus.absent;
    case 'ON_LEAVE':
      return AttendanceStatus.onLeave;
    default:
      return AttendanceStatus.upcoming;
  }
}


class AttendanceItem {
  final DateTime date;
  final String status;
  final int totalSessions;
  final double totalHours;
  final List<AttendanceSession> sessions;
  final LeaveInfo? leaveInfo;

  AttendanceItem({
    required this.date,
    required this.status,
    required this.totalSessions,
    required this.totalHours,
    required this.sessions,
    this.leaveInfo,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      date: DateTime.parse(json['date']),
      status: json['status'] ?? '',
      totalSessions: json['total_sessions'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => AttendanceSession.fromJson(e))
          .toList(),
      leaveInfo: json['leave_info'] != null
          ? LeaveInfo.fromJson(json['leave_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'status': status,
      'total_sessions': totalSessions,
      'total_hours': totalHours,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'leave_info': leaveInfo?.toJson(),
    };
  }

}


/// ---------------- ATTENDANCE SUMMARY ----------------
class AttendanceSummary {
  final int totalDays;
  final int expectedDays;
  final int daysWorked;
  final int absentDays;
  final int leaveDays;
  final int upcomingDays;
  final double attendanceRate;
  final int totalSessions;
  final int completedSessions;
  final int activeSessions;
  final double totalHours;

  AttendanceSummary({
    required this.totalDays,
    required this.expectedDays,
    required this.daysWorked,
    required this.absentDays,
    required this.leaveDays,
    required this.upcomingDays,
    required this.attendanceRate,
    required this.totalSessions,
    required this.completedSessions,
    required this.activeSessions,
    required this.totalHours,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['total_days'] ?? 0,
      expectedDays: json['expected_days'] ?? 0,
      daysWorked: json['days_worked'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      leaveDays: json['leave_days'] ?? 0,
      upcomingDays: json['upcoming_days'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
      totalSessions: json['total_sessions'] ?? 0,
      completedSessions: json['completed_sessions'] ?? 0,
      activeSessions: json['active_sessions'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'expected_days': expectedDays,
      'days_worked': daysWorked,
      'absent_days': absentDays,
      'leave_days': leaveDays,
      'upcoming_days': upcomingDays,
      'attendance_rate': attendanceRate,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'active_sessions': activeSessions,
      'total_hours': totalHours,
    };
  }
}

// ============================================
// LEAVE INFO MODEL
// ============================================
class LeaveInfo {
  final bool isOnLeave;
  final String message;

  LeaveInfo({
    required this.isOnLeave,
    required this.message,
  });

  factory LeaveInfo.fromJson(Map<String, dynamic> json) {
    return LeaveInfo(
      isOnLeave: json['is_on_leave'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_on_leave': isOnLeave,
      'message': message,
    };
  }
}



// ============================================
// TODAY ATTENDANCE MODEL
// ============================================
class TodayAttendance {
  final bool hasAttendance;
  final String status;
  final int totalSessions;
  final int? activeSession;
  final double totalHoursToday;
  

  TodayAttendance({
    required this.hasAttendance,
    required this.status,
    required this.totalSessions,
    this.activeSession,
    required this.totalHoursToday,
    
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      hasAttendance: json['has_attendance'] ?? false,
      status: json['status'] ?? '',
      totalSessions: json['total_sessions'] ?? 0,
      activeSession: json['active_session'],
      totalHoursToday: (json['total_hours_today'] ?? 0).toDouble(),
         );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_attendance': hasAttendance,
      'status': status,
      'total_sessions': totalSessions,
      'active_session': activeSession,
      'total_hours_today': totalHoursToday,
      };
  }

  // Helper getters
  AttendanceStatus get attendanceStatus => parseAttendanceStatus(status);
  bool get isCheckedIn => status == 'CHECKED_IN';
  bool get isCheckedOut => status == 'CHECKED_OUT';
  bool get isOnLeave => status == 'ON_LEAVE';
  bool get isAbsent => status == 'ABSENT';
}

// ============================================
// ATTENDANCE STATS MODELS (For separate stats API)
// ============================================
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

  Map<String, dynamic> toJson() {
    return {
      'overall': overall.toJson(),
      'current_month': currentMonth.toJson(),
      'today': today.toJson(),
    };
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
      totalSessions: json['total_sessions'] ?? 0,
      uniqueDaysWorked: json['unique_days_worked'] ?? 0,
      totalHoursWorked: (json['total_hours_worked'] ?? 0).toDouble(),
      avgHoursPerDay: (json['average_hours_per_day'] ?? 0).toDouble(),
      avgHoursPerSession: (json['average_hours_per_session'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'unique_days_worked': uniqueDaysWorked,
      'total_hours_worked': totalHoursWorked,
      'average_hours_per_day': avgHoursPerDay,
      'average_hours_per_session': avgHoursPerSession,
    };
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
      totalSessions: json['total_sessions'] ?? 0,
      uniqueDaysWorked: json['unique_days_worked'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'unique_days_worked': uniqueDaysWorked,
      'total_hours': totalHours,
    };
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
      totalSessions: json['total_sessions'] ?? 0,
      activeSessions: json['active_sessions'] ?? 0,
      completedSessions: json['completed_sessions'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      hasActiveSession: json['has_active_session'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'active_sessions': activeSessions,
      'completed_sessions': completedSessions,
      'total_hours': totalHours,
      'has_active_session': hasActiveSession,
    };
  }
}

// ============================================
// ATTENDANCE DAY STATUS ENUM (For Calendar UI)
// ============================================
enum AttendanceDayStatus {
  checkedIn,
  checkedOut,
  absent,
  onLeave,
  upcoming,
}

// Helper function to convert attendance item to day status
AttendanceDayStatus getAttendanceDayStatus(AttendanceItem item) {
  switch (item.status.toUpperCase()) {
    case 'CHECKED_IN':
      return AttendanceDayStatus.checkedIn;
    case 'CHECKED_OUT':
      return AttendanceDayStatus.checkedOut;
    case 'ON_LEAVE':
      return AttendanceDayStatus.onLeave;
    case 'ABSENT':
      return AttendanceDayStatus.absent;
    default:
      return AttendanceDayStatus.upcoming;
  }
}