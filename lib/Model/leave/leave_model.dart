// class LeaveRequest {
//   final int id;
//   final String caretakerName;
//   final String caretakerPhone;
//   final String startDate;
//   final String endDate;
//   final int totalDays;
//   final String reason;
//   final String status;
//   final String statusDisplay;
//   final String leaveType;
//   final String leaveTypeDisplay;

//   // nullable fields
//   final String? adminRemarks;
//   final String requestedAt;
//   final String? processedAt;
//   final String? updatedAt;

//   LeaveRequest({
//     required this.id,
//     required this.caretakerName,
//     required this.caretakerPhone,
//     required this.startDate,
//     required this.endDate,
//     required this.totalDays,
//     required this.reason,
//     required this.status,
//     required this.statusDisplay,
//     required this.leaveType,
//     required this.leaveTypeDisplay,
//     this.adminRemarks,
//     required this.requestedAt,
//     this.processedAt,
//     this.updatedAt,
//   });

//   factory LeaveRequest.fromJson(Map<String, dynamic> json) {
//     return LeaveRequest(
//       id: json['id'],
//       caretakerName: json['caretaker_name'] ?? '',
//       caretakerPhone: json['caretaker_phone'] ?? '',
//       startDate: json['start_date'],
//       endDate: json['end_date'],
//       totalDays: json['total_days'],
//       reason: json['reason'] ?? '',
//       status: json['status'],
//       statusDisplay: json['status_display'],
//       leaveType: json['leave_type'],
//       leaveTypeDisplay: json['leave_type_display'] ?? '',
//       adminRemarks: json['admin_remarks'],
//       requestedAt: json['requested_at'],
//       processedAt: json['processed_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
// }
class LeaveRequest {
  final int id;
  final int caretakerId;
  final String caretakerName;
  final String caretakerPhone;
  final String leaveType;
  final String leaveTypeDisplay;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String reason;
  final String status;
  final String statusDisplay;
  final String adminRemarks;
  final String requestedAt;
  final String? processedAt;
  final String? updatedAt;

  LeaveRequest({
    required this.id,
    required this.caretakerId,
    required this.caretakerName,
    required this.caretakerPhone,
    required this.leaveType,
    required this.leaveTypeDisplay,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.statusDisplay,
    required this.adminRemarks,
    required this.requestedAt,
    this.processedAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json["id"] ?? 0,
      caretakerId: json["caretaker_id"] ?? 0,
      caretakerName: json["caretaker_name"] ?? "",
      caretakerPhone: json["caretaker_phone"] ?? "",
      leaveType: json["leave_type"] ?? "",
      leaveTypeDisplay: json["leave_type_display"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      totalDays: json["total_days"] ?? 0,
      reason: json["reason"] ?? "",
      status: json["status"] ?? "",
      statusDisplay: json["status_display"] ?? "",
      adminRemarks: json["admin_remarks"] ?? "",
      requestedAt: json["requested_at"] ?? "",
      processedAt: json["processed_at"], // nullable
      updatedAt: json["updated_at"],     // nullable
    );
  }
}
