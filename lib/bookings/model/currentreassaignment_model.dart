class CurrentReassignment {
  final int id;
  final String reassignedTo;
  final String startDate;
  final String endDate;
  final int daysRemaining;
  final String status;

  CurrentReassignment({
    required this.id,
    required this.reassignedTo,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.status,
  });

  factory CurrentReassignment.fromJson(Map<String, dynamic> json) {
    return CurrentReassignment(
      id: json['id'] ?? 0,
      reassignedTo: json['reassigned_to'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
