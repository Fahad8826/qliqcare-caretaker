import 'package:qlickcare/Model/bookings/Details/currentreassaignment_model.dart';

class ReassignmentInfo {
  final bool isOriginalCaretaker;
  final bool isReassignedToMe;
  final bool isActiveToday;
  final bool hasActiveReassignment;
  final CurrentReassignment? currentReassignment;

  ReassignmentInfo({
    required this.isOriginalCaretaker,
    required this.isReassignedToMe,
    required this.isActiveToday,
    required this.hasActiveReassignment,
    this.currentReassignment,
  });

  factory ReassignmentInfo.fromJson(Map<String, dynamic> json) {
    return ReassignmentInfo(
      isOriginalCaretaker: json['is_original_caretaker'] ?? false,
      isReassignedToMe: json['is_reassigned_to_me'] ?? false,
      isActiveToday: json['is_active_today'] ?? false,
      hasActiveReassignment: json['has_active_reassignment'] ?? false,
      currentReassignment: json['current_reassignment'] != null
          ? CurrentReassignment.fromJson(json['current_reassignment'])
          : null,
    );
  }
}
