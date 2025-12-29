import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/Controllers/attendance_statscontroller.dart';
import 'package:qlickcare/Controllers/leavecontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import '../Utils/appcolors.dart';
import '../Utils/loading.dart';

class Leaveandattendace extends StatefulWidget {
  const Leaveandattendace({super.key});

  @override
  State<Leaveandattendace> createState() => _LeaveandattendaceState();
}

class _LeaveandattendaceState extends State<Leaveandattendace> {
  final LeaveController leaveController = Get.put(LeaveController());
  final AttendanceStatsController statsController = Get.put(
    AttendanceStatsController(),
  );

  final TextEditingController reasonController = TextEditingController();

  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    statsController.fetchStats();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Select Leave Dates",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Leave & Attendance",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =======================
            /// ATTENDANCE STATS
            /// =======================
            Obx(() {
              if (statsController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                    child: const Loading(),
                  ),
                );
              }

              final stats = statsController.stats.value;
              if (stats == null) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Summary",
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  // Overall Stats Card
                  _statsCard(
                    context,
                    title: "Overall Statistics",
                    icon: Icons.analytics_outlined,
                    iconColor: AppColors.primary,
                    children: [
                      _statRow(
                        context,
                        icon: Icons.event_note,
                        label: "Total Booking Sessions",
                        value: stats.overall.totalSessions.toString(),
                      ),
                      _statRow(
                        context,
                        icon: Icons.calendar_today,
                        label: "Days Worked",
                        value: stats.overall.uniqueDaysWorked.toString(),
                      ),
                      _statRow(
                        context,
                        icon: Icons.access_time,
                        label: "Total Hours",
                        value: "${stats.overall.totalHoursWorked}h",
                      ),
                      _statRow(
                        context,
                        icon: Icons.av_timer,
                        label: "Avg Hours/Day",
                        value: "${stats.overall.avgHoursPerDay}h",
                      ),
                      _statRow(
                        context,
                        icon: Icons.timelapse,
                        label: "Avg Hours/Session",
                        value: "${stats.overall.avgHoursPerSession}h",
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.015),

                  // Today Stats Card
                  _statsCard(
                    context,
                    title: "Today's Activity",
                    icon: Icons.today,
                    iconColor: Colors.orange,
                    children: [
                      _statRow(
                        context,
                        icon: Icons.work_outline,
                        label: "Active Booking Sessions",
                        value: stats.today.activeSessions.toString(),
                      ),
                      _statRow(
                        context,
                        icon: Icons.check_circle_outline,
                        label: "Has Active Booking Session",
                        value: stats.today.hasActiveSession ? "Yes" : "No",
                        valueColor: stats.today.hasActiveSession
                            ? AppColors.success
                            : AppColors.textSecondary,
                        isLast: true,
                      ),
                    ],
                  ),
                ],
              );
            }),

            SizedBox(height: size.height * 0.03),

            /// =======================
            /// APPLY LEAVE SECTION
            /// =======================
            Text(
              "Apply for Leave",
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.015),

            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selection
                  Text(
                    "Leave Duration",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.screenBackground,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: AppColors.primary,
                            size: size.width * 0.055,
                          ),
                          SizedBox(width: size.width * 0.03),
                          Expanded(
                            child: Text(
                              selectedRange == null
                                  ? "Select leave dates"
                                  : "${_formatDate(selectedRange!.start)} → ${_formatDate(selectedRange!.end)}",
                              style: AppTextStyles.body.copyWith(
                                color: selectedRange == null
                                    ? AppColors.textSecondary.withOpacity(0.6)
                                    : AppColors.textPrimary,
                                fontWeight: selectedRange == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: size.width * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Reason Field
                  Text(
                    "Reason for Leave",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextField(
                    controller: reasonController,
                    maxLines: 4,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText:
                          "Please provide a reason for your leave request",
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: AppColors.screenBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // Submit Button
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: AppColors.primary
                              .withOpacity(0.6),
                        ),
                        onPressed:
                            leaveController.isLoading.value ||
                                selectedRange == null
                            ? null
                            : () {
                                if (reasonController.text.trim().isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please provide a reason for leave",
                                    backgroundColor: AppColors.error
                                        .withOpacity(0.1),
                                    colorText: AppColors.error,
                                  );
                                  return;
                                }

                                leaveController.requestLeave(
                                  startDate: _formatDateApi(
                                    selectedRange!.start,
                                  ),
                                  endDate: _formatDateApi(selectedRange!.end),
                                  reason: reasonController.text.trim(),
                                );
                              },
                        child: leaveController.isLoading.value
                            ? SizedBox(
                                height: size.height * 0.025,
                                width: size.height * 0.025,
                                child: const Loading(),
                              )
                            : Text(
                                "Submit Leave Request",
                                style: AppTextStyles.button,
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// UI HELPERS
  /// =======================
  Widget _statsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: size.width * 0.055),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          ...children,
        ],
      ),
    );
  }

  Widget _statRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isLast = false,
  }) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
          child: Row(
            children: [
              Icon(
                icon,
                size: size.width * 0.045,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
              SizedBox(width: size.width * 0.025),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}
