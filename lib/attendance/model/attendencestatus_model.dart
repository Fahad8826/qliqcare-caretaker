

import 'package:qlickcare/attendance/model/bookingattendance_model.dart';

/// ---------------- ATTENDANCE ENUM & PARSER ----------------



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

