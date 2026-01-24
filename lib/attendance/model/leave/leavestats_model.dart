class LeaveStats {
  final int totalLeaves;
  final int upcomingLeaves;
  final int pastLeaves;
  final int ongoingLeaves;
  final int totalDaysOnLeave;
  final int leaveDaysThisMonth;
  final int pendingleaves;
  final int approvedleaves;

  LeaveStats({
    required this.totalLeaves,
    required this.upcomingLeaves,
    required this.pastLeaves,
    required this.ongoingLeaves,
    required this.totalDaysOnLeave,
    required this.leaveDaysThisMonth,
    required this.pendingleaves,
    required this.approvedleaves,
  });

  factory LeaveStats.fromJson(Map<String, dynamic> json) {
    return LeaveStats(
      totalLeaves: json['total_leaves'] ?? 0,
      upcomingLeaves: json['upcoming_leaves'] ?? 0,

      pastLeaves: json['past_leaves'] ?? 0,
      ongoingLeaves: json['ongoing_leaves'] ?? 0,
      totalDaysOnLeave: json['total_days_on_leave'] ?? 0,
      leaveDaysThisMonth: json['leave_days_this_month'] ?? 0,
      pendingleaves: json['pending_leaves'] ?? 0,
      approvedleaves: json['approved_leaves'] ?? 0,
    );
  }
}
