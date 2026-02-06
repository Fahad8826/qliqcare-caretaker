import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/meeting/controller/meeting_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/appcolors.dart';

class MeetingDetailPage extends StatelessWidget {
  final int id;

  const MeetingDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeetingsController>();

    // Fetch data on build
    Future.microtask(() => controller.fetchMeetingDetail(id));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Meeting Details",
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value ||
            controller.meetingDetail.value == null) {
          return const Center(child: Loading());
        }

        final meeting = controller.meetingDetail.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting Title Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.045),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            FontAwesomeIcons.video,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting.title,
                                style: AppTextStyles.heading2.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              _StatusChip(
                                status: meeting.statusDisplay,
                                isUpcoming: meeting.isUpcoming,
                                isPast: meeting.isPast,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(size.width * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting Schedule Info
                    _buildSectionHeader("Schedule", FontAwesomeIcons.calendar),
                    SizedBox(height: size.height * 0.01),
                    _ScheduleCard(
                      date: _formatDate(meeting.scheduledDate),
                      time: _formatTime(meeting.scheduledTime),
                      duration: "${meeting.durationMinutes} minutes",
                    ),

                    SizedBox(height: size.height * 0.025),

                    // Description (if available)
                    if (meeting.description != null &&
                        meeting.description!.isNotEmpty) ...[
                      _buildSectionHeader(
                          "Description", FontAwesomeIcons.alignLeft),
                      SizedBox(height: size.height * 0.01),
                      _ContentCard(
                        content: meeting.description!,
                      ),
                      SizedBox(height: size.height * 0.025),
                    ],

                    // Meeting Access
                    _buildSectionHeader("Meeting Access", FontAwesomeIcons.link),
                    SizedBox(height: size.height * 0.01),
                    _MeetingLinkCard(
                      meetLink: meeting.meetLink,
                      calendarLink: meeting.calendarLink,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: meeting.meetLink));
                        Get.snackbar(
                          "Copied",
                          "Meeting link copied to clipboard",
                          backgroundColor: AppColors.success.withOpacity(0.1),
                          colorText: AppColors.success,
                          duration: Duration(seconds: 2),
                          margin: EdgeInsets.all(16),
                        );
                      },
                      onJoin: () => _launchMeetLink(meeting.meetLink),
                      onAddCalendar: meeting.calendarLink != null
                          ? () => _launchMeetLink(meeting.calendarLink!)
                          : null,
                    ),

                    SizedBox(height: size.height * 0.025),

                    // Participants
                    if (meeting.participants != null &&
                        meeting.participants!.isNotEmpty) ...[
                      _buildSectionHeader(
                        "Participants (${meeting.participants!.length})",
                        FontAwesomeIcons.users,
                      ),
                      SizedBox(height: size.height * 0.01),
                      _ParticipantsCard(
                        participants: meeting.participants!,
                      ),
                      SizedBox(height: size.height * 0.025),
                    ],

                    // Meeting Notes (if available)
                    if (meeting.meetingNotes != null &&
                        meeting.meetingNotes!.isNotEmpty) ...[
                      _buildSectionHeader(
                          "Notes", FontAwesomeIcons.noteSticky),
                      SizedBox(height: size.height * 0.01),
                      _NotesCard(
                        notes: meeting.meetingNotes!,
                      ),
                      SizedBox(height: size.height * 0.025),
                    ],

                    // Organizer Info
                    if (meeting.createdByEmail != null) ...[
                      _buildSectionHeader("Organizer", FontAwesomeIcons.userTie),
                      SizedBox(height: size.height * 0.01),
                      _OrganizerCard(
                        email: meeting.createdByEmail!,
                      ),
                      SizedBox(height: size.height * 0.025),
                    ],

                    // Action Buttons
                    if (meeting.status == "SCHEDULED" || meeting.isUpcoming)
                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBackgroundColor:
                                  AppColors.success.withOpacity(0.6),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : () => _showConfirmationDialog(
                                    context, controller, meeting.id),
                            icon: controller.isLoading.value
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Icon(FontAwesomeIcons.circleCheck, size: 18),
                            label: Text(
                              "Mark as Attended",
                              style: AppTextStyles.button.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }),

                    // Past Meeting Notice
                    if (meeting.isPast)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: Text(
                                "This meeting has already passed",
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    MeetingsController controller,
    int meetingId,
  ) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Confirm Attendance",
          style: AppTextStyles.heading2.copyWith(fontSize: 18),
        ),
        content: Text(
          "Mark this meeting as attended?",
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              "Cancel",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Confirm",
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.markAttended(meetingId);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return "${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "$displayHour:$minute $period";
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _launchMeetLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open link",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        margin: EdgeInsets.all(16),
      );
    }
  }

  Color _getParticipantColor(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return Colors.purple;
      case 'CARETAKER':
        return Colors.blue;
      case 'PATIENT':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getParticipantIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return FontAwesomeIcons.userTie;
      case 'CARETAKER':
        return FontAwesomeIcons.userNurse;
      case 'PATIENT':
        return FontAwesomeIcons.userInjured;
      default:
        return FontAwesomeIcons.user;
    }
  }

  Color _getAttendanceColor(String status) {
    switch (status.toUpperCase()) {
      case 'INVITED':
        return Colors.blue;
      case 'ATTENDED':
        return AppColors.success;
      case 'DECLINED':
        return AppColors.error;
      case 'PENDING':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Status Chip Widget
class _StatusChip extends StatelessWidget {
  final String status;
  final bool isUpcoming;
  final bool isPast;

  const _StatusChip({
    required this.status,
    required this.isUpcoming,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    if (isPast) {
      chipColor = Colors.grey;
    } else if (isUpcoming) {
      chipColor = AppColors.success;
    } else {
      chipColor = AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.small.copyWith(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Schedule Card Widget
class _ScheduleCard extends StatelessWidget {
  final String date;
  final String time;
  final String duration;

  const _ScheduleCard({
    required this.date,
    required this.time,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ScheduleRow(
            icon: FontAwesomeIcons.calendar,
            label: "Date",
            value: date,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _ScheduleRow(
            icon: FontAwesomeIcons.clock,
            label: "Time",
            value: time,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _ScheduleRow(
            icon: FontAwesomeIcons.hourglass,
            label: "Duration",
            value: duration,
          ),
        ],
      ),
    );
  }
}

// Schedule Row Widget
class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Content Card Widget
class _ContentCard extends StatelessWidget {
  final String content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        content,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Meeting Link Card Widget
class _MeetingLinkCard extends StatelessWidget {
  final String meetLink;
  final String? calendarLink;
  final VoidCallback onCopy;
  final VoidCallback onJoin;
  final VoidCallback? onAddCalendar;

  const _MeetingLinkCard({
    required this.meetLink,
    this.calendarLink,
    required this.onCopy,
    required this.onJoin,
    this.onAddCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Link Display
          Row(
            children: [
              Expanded(
                child: Text(
                  meetLink,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.copy,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                onPressed: onCopy,
                constraints: BoxConstraints(),
                padding: EdgeInsets.all(8),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.015),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onJoin,
                  icon: Icon(FontAwesomeIcons.video, size: 15),
                  label: Text("Join Meeting"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (onAddCalendar != null) ...[
                SizedBox(width: size.width * 0.02),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: onAddCalendar,
                    icon: Icon(FontAwesomeIcons.calendarPlus, size: 14),
                    label: Text(""),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Participants Card Widget
class _ParticipantsCard extends StatelessWidget {
  final List<dynamic> participants;

  const _ParticipantsCard({required this.participants});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: participants.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final participant = participants[index];
          final participantColor = _getParticipantColor(participant.participantType);
          final attendanceColor = _getAttendanceColor(participant.attendanceStatus);

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.015,
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: participantColor.withOpacity(0.15),
                  child: Icon(
                    _getParticipantIcon(participant.participantType),
                    color: participantColor,
                    size: 18,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.participantName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        participant.participantEmail,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: size.width * 0.02),
                
                // Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: participantColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        participant.participantTypeDisplay,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 10,
                          color: participantColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: attendanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        participant.attendanceStatusDisplay,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 10,
                          color: attendanceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getParticipantColor(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return Colors.purple;
      case 'CARETAKER':
        return Colors.blue;
      case 'PATIENT':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getParticipantIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return FontAwesomeIcons.userTie;
      case 'CARETAKER':
        return FontAwesomeIcons.userNurse;
      case 'PATIENT':
        return FontAwesomeIcons.userInjured;
      default:
        return FontAwesomeIcons.user;
    }
  }

  Color _getAttendanceColor(String status) {
    switch (status.toUpperCase()) {
      case 'INVITED':
        return Colors.blue;
      case 'ATTENDED':
        return AppColors.success;
      case 'DECLINED':
        return AppColors.error;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Notes Card Widget
class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.noteSticky,
            color: Colors.blue.shade700,
            size: 16,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              notes,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Organizer Card Widget
class _OrganizerCard extends StatelessWidget {
  final String email;

  const _OrganizerCard({required this.email});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              FontAwesomeIcons.userTie,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Organized by",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}