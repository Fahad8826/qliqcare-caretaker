class MyReassignmentPeriod {
  final int id;
  final String startDate;
  final String endDate;
  final int totalDays;
  final int daysCompleted;
  final String status;
  final double completionPercentage;
  final String reassignedTo;
  final int reassignedToId;
  final String originalCaretaker;
  final int originalCaretakerId;
  final bool amIReassignedTo;
  final bool amIOriginal;

  MyReassignmentPeriod({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.daysCompleted,
    required this.status,
    required this.completionPercentage,
    required this.reassignedTo,
    required this.reassignedToId,
    required this.originalCaretaker,
    required this.originalCaretakerId,
    required this.amIReassignedTo,
    required this.amIOriginal,
  });

  factory MyReassignmentPeriod.fromJson(Map<String, dynamic> json) {
    return MyReassignmentPeriod(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: json['total_days'] ?? 0,
      daysCompleted: json['days_completed'] ?? 0,
      status: json['status'] ?? '',
      completionPercentage:
          (json['completion_percentage'] ?? 0).toDouble(),
      reassignedTo: json['reassigned_to'] ?? '',
      reassignedToId: json['reassigned_to_id'] ?? 0,
      originalCaretaker: json['original_caretaker'] ?? '',
      originalCaretakerId: json['original_caretaker_id'] ?? 0,
      amIReassignedTo: json['am_i_reassigned_to'] ?? false,
      amIOriginal: json['am_i_original'] ?? false,
    );
  }
}
