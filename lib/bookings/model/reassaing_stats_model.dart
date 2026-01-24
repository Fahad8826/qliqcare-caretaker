class ReassignmentStatus {
  final bool isReassigned;
  final int reassignmentId;
  final String reassignedTo;
  final int reassignedToId;
  final String originalCaretaker;
  final String startDate;
  final String endDate;
  final String status;
  final int daysCompleted;
  final int totalDays;
  final double completionPercentage;

  ReassignmentStatus({
    required this.isReassigned,
    required this.reassignmentId,
    required this.reassignedTo,
    required this.reassignedToId,
    required this.originalCaretaker,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.daysCompleted,
    required this.totalDays,
    required this.completionPercentage,
  });

  factory ReassignmentStatus.fromJson(Map<String, dynamic> json) {
    return ReassignmentStatus(
      isReassigned: json['is_reassigned'] ?? false,
      reassignmentId: json['reassignment_id'] ?? 0,
      reassignedTo: json['reassigned_to'] ?? "",
      reassignedToId: json['reassigned_to_id'] ?? 0,
      originalCaretaker: json['original_caretaker'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      status: json['status'] ?? "",
      daysCompleted: json['days_completed'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      completionPercentage:
          (json['completion_percentage'] ?? 0).toDouble(),
    );
  }
}
