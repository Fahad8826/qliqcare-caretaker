// ============================================
// AttendanceSession Model
// ============================================
class AttendanceSession {
  final int sessionNumber;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final String status;
  final String? notes;

  AttendanceSession({
    required this.sessionNumber,
    this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.status,
    this.notes,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      sessionNumber: json['session_number'] ?? 0,
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_number': sessionNumber,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'total_hours': totalHours,
      'status': status,
      'notes': notes,
    };
  }

  // Helper getters
  bool get isCheckedIn => status == 'CHECKED_IN';
  bool get isCheckedOut => status == 'CHECKED_OUT';
  bool get isActive => isCheckedIn;
  bool get isCompleted => isCheckedOut;

  // Duration helper
  Duration? get duration {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  // Format check-in time
  String get formattedCheckIn {
    if (checkInTime == null) return 'N/A';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  // Format check-out time
  String get formattedCheckOut {
    if (checkOutTime == null) return 'N/A';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  // Format total hours
  String get formattedTotalHours {
    if (totalHours == 0) return '0h 0m';
    final hours = totalHours.floor();
    final minutes = ((totalHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  // Copy with method for updates
  AttendanceSession copyWith({
    int? sessionNumber,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? totalHours,
    String? status,
    String? notes,
  }) {
    return AttendanceSession(
      sessionNumber: sessionNumber ?? this.sessionNumber,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'AttendanceSession(sessionNumber: $sessionNumber, status: $status, totalHours: $totalHours)';
  }
}

