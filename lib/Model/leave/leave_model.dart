class LeaveRequest {
  final int id;
  final String caretakerName;
  final String caretakerPhone;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String reason;
  final String requestedAt;

  LeaveRequest({
    required this.id,
    required this.caretakerName,
    required this.caretakerPhone,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.requestedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      caretakerName: json['caretaker_name'],
      caretakerPhone: json['caretaker_phone'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      totalDays: json['total_days'],
      reason: json['reason'],
      requestedAt: json['requested_at'],
    );
  }
}
