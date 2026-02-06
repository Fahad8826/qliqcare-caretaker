class MeetingItem {
  final int id;
  final String title;
  final String scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final String meetLink;
  final String status;
  final String statusDisplay;
  final int? bookingId;
  final int participantCount;
  final bool isUpcoming;
  final bool isPast;

  MeetingItem({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.meetLink,
    required this.status,
    required this.statusDisplay,
    this.bookingId,
    required this.participantCount,
    required this.isUpcoming,
    required this.isPast,
  });

  factory MeetingItem.fromJson(Map<String, dynamic> json) {
    return MeetingItem(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      scheduledDate: json["scheduled_date"] ?? "",
      scheduledTime: json["scheduled_time"] ?? "",
      durationMinutes: json["duration_minutes"] ?? 0,
      meetLink: json["meet_link"] ?? "",
      status: json["status"] ?? "",
      statusDisplay: json["status_display"] ?? "",
      bookingId: json["booking_id"],
      participantCount: json["participant_count"] ?? 0,
      isUpcoming: json["is_upcoming"] ?? false,
      isPast: json["is_past"] ?? false,
    );
  }
}

class MeetingDetail {
  final int id;
  final String title;
  final String? description;
  final String scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final String? googleEventId;
  final String meetLink;
  final String? calendarLink;
  final String status;
  final String statusDisplay;
  final int? createdBy;
  final String? createdByEmail;
  final String? meetingNotes;
  final List<Participant>? participants;
  final bool isUpcoming;
  final bool isPast;

  MeetingDetail({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    this.googleEventId,
    required this.meetLink,
    this.calendarLink,
    required this.status,
    required this.statusDisplay,
    this.createdBy,
    this.createdByEmail,
    this.meetingNotes,
    this.participants,
    required this.isUpcoming,
    required this.isPast,
  });

  factory MeetingDetail.fromJson(Map<String, dynamic> json) {
    return MeetingDetail(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      description: json["description"],
      scheduledDate: json["scheduled_date"] ?? "",
      scheduledTime: json["scheduled_time"] ?? "",
      durationMinutes: json["duration_minutes"] ?? 0,
      googleEventId: json["google_event_id"],
      meetLink: json["meet_link"] ?? "",
      calendarLink: json["calendar_link"],
      status: json["status"] ?? "",
      statusDisplay: json["status_display"] ?? "",
      createdBy: json["created_by"],
      createdByEmail: json["created_by_email"],
      meetingNotes: json["meeting_notes"],
      participants: json["participants"] != null
          ? (json["participants"] as List)
              .map((p) => Participant.fromJson(p))
              .toList()
          : null,
      // Calculate isUpcoming and isPast from the date/time
      isUpcoming: _isUpcoming(json["scheduled_date"], json["scheduled_time"]),
      isPast: _isPast(json["scheduled_date"], json["scheduled_time"]),
    );
  }

  static bool _isUpcoming(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return false;
    try {
      final meetingDateTime = DateTime.parse("$dateStr $timeStr");
      final now = DateTime.now();
      return meetingDateTime.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  static bool _isPast(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return false;
    try {
      final meetingDateTime = DateTime.parse("$dateStr $timeStr");
      final now = DateTime.now();
      return meetingDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  // Helper getter for participant count
  int get participantCount => participants?.length ?? 0;
}

class Participant {
  final int id;
  final String participantType;
  final String participantTypeDisplay;
  final String participantName;
  final String participantEmail;
  final String? participantPhone;
  final String attendanceStatus;
  final String attendanceStatusDisplay;
  final bool invitationSent;
  final String? invitationSentAt;
  final String? joinedAt;

  Participant({
    required this.id,
    required this.participantType,
    required this.participantTypeDisplay,
    required this.participantName,
    required this.participantEmail,
    this.participantPhone,
    required this.attendanceStatus,
    required this.attendanceStatusDisplay,
    required this.invitationSent,
    this.invitationSentAt,
    this.joinedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json["id"] ?? 0,
      participantType: json["participant_type"] ?? "",
      participantTypeDisplay: json["participant_type_display"] ?? "",
      participantName: json["participant_name"] ?? "",
      participantEmail: json["participant_email"] ?? "",
      participantPhone: json["participant_phone"],
      attendanceStatus: json["attendance_status"] ?? "",
      attendanceStatusDisplay: json["attendance_status_display"] ?? "",
      invitationSent: json["invitation_sent"] ?? false,
      invitationSentAt: json["invitation_sent_at"],
      joinedAt: json["joined_at"],
    );
  }
}