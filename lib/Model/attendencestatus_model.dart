
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
