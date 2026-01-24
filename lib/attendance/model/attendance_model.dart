

class Attendance {
  final int id;
  final String date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final String workDuration;

  Attendance({
    required this.id,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.workDuration,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      // ✅ SAFE FALLBACKS
      id: json['id'] ?? 0,
      date: json['date'] ?? "",
      status: json['status'] ?? "",

      // ✅ NULLABLE STRINGS
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],

      // ✅ NULL-SAFE BOOLEANS
      isCheckedIn: json['is_checked_in'] ?? false,
      isCheckedOut: json['is_checked_out'] ?? false,

      // ✅ STRING FALLBACK
      workDuration: json['work_duration_display'] ?? "0h 0m",
    );
  }
}
