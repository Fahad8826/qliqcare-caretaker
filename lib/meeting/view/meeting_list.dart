import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/meeting/controller/meeting_controller.dart';
import 'package:qlickcare/meeting/view/meeting_details.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/appcolors.dart';

class MeetingsPage extends StatefulWidget {
  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  final MeetingsController controller = Get.put(MeetingsController());

  final List<Map<String, String>> filters = [
    {"label": "Scheduled", "value": "SCHEDULED"},
    {"label": "Today", "value": "today"},
    {"label": "All", "value": ""},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "My Meetings",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.012,
            ),
            color: Colors.white,
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) {
                    final isSelected =
                        controller.selectedFilter.value == filter["value"];
                    return Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                      child: FilterChip(
                        label: Text(filter["label"]!),
                        selected: isSelected,
                        onSelected: (_) {
                          controller.updateFilter(filter["value"]!);
                        },
                        labelStyle: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.035,
                          vertical: size.height * 0.006,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),

          // Meetings List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: Loading());
              }

              if (controller.meetings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.calendarXmark,
                        size: isPortrait ? size.width * 0.18 : size.height * 0.22,
                        color: AppColors.textSecondary.withOpacity(0.4),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "No meetings found",
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.008),
                      Text(
                        "Check back later for upcoming meetings",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMeetings(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.all(size.width * 0.04),
                  itemCount: controller.meetings.length,
                  itemBuilder: (context, i) {
                    final meeting = controller.meetings[i];

                    return Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Status Badge
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    meeting.title,
                                    style: AppTextStyles.subtitle.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                _StatusBadge(
                                  status: meeting.statusDisplay,
                                  isUpcoming: meeting.isUpcoming,
                                  isPast: meeting.isPast,
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.012),

                            // Date and Time in one line
                            Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 13,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Text(
                                  _formatDate(meeting.scheduledDate),
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Icon(
                                  FontAwesomeIcons.clock,
                                  size: 13,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Text(
                                  _formatTime(meeting.scheduledTime),
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.015),

                            // Action Buttons
                            Row(
                              children: [
                                // Join Meeting Button
                                if (meeting.isUpcoming)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _launchMeetLink(meeting.meetLink),
                                      icon: Icon(
                                        FontAwesomeIcons.video,
                                        size: 14,
                                      ),
                                      label: Text("Join"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.012,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                if (meeting.isUpcoming)
                                  SizedBox(width: size.width * 0.02),

                                // View Details Button
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Get.to(() =>
                                          MeetingDetailPage(id: meeting.id));
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.circleInfo,
                                      size: 14,
                                    ),
                                    label: Text("Details"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.012,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
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
        "Could not open meeting link",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
}

// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isUpcoming;
  final bool isPast;

  const _StatusBadge({
    required this.status,
    required this.isUpcoming,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (isPast) {
      badgeColor = Colors.grey;
    } else if (isUpcoming) {
      badgeColor = AppColors.success;
    } else {
      badgeColor = AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.small.copyWith(
          fontSize: 9,
          color: badgeColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}