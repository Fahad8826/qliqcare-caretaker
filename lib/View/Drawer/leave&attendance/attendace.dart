import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/attendance_statscontroller.dart';
import 'package:qlickcare/Controllers/leave/leavecontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/View/Drawer/leave&attendance/leave_stats.dart';
import 'package:qlickcare/View/Drawer/leave&attendance/leavereqest_widget.dart';
import '../../../Utils/appcolors.dart';
import '../../../Utils/loading.dart';

class Leaveandattendace extends StatefulWidget {
  const Leaveandattendace({super.key});

  @override
  State<Leaveandattendace> createState() => _LeaveandattendaceState();
}

class _LeaveandattendaceState extends State<Leaveandattendace> {
  /// Controllers (put only ONCE here)
  final LeaveController leaveController = Get.put(LeaveController());
  final AttendanceStatsController statsController =
      Get.put(AttendanceStatsController());

  @override
  void initState() {
    super.initState();
    statsController.fetchStats();
    leaveController.fetchLeaveStats();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

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
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                  child: const Center(child: Loading()),
                );
              }

              final stats = statsController.stats.value;
              if (stats == null) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Summary",
                    style: AppTextStyles.heading2,
                  ),
                  SizedBox(height: size.height * 0.015),

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

                  SizedBox(height: size.height * 0.02),

                  _statsCard(
                    context,
                    title: "Today's Activity",
                    icon: Icons.today,
                    iconColor: Colors.orange,
                    children: [
                      _statRow(
                        context,
                        icon: Icons.work_outline,
                        label: "Active Sessions",
                        value: stats.today.activeSessions.toString(),
                      ),
                      _statRow(
                        context,
                        icon: Icons.check_circle_outline,
                        label: "Has Active Session",
                        value:
                            stats.today.hasActiveSession ? "Yes" : "No",
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
            /// LEAVE STATS
            /// =======================
             LeaveStatsSection(),

            SizedBox(height: size.height * 0.03),

           
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
                child: Icon(icon, color: iconColor),
              ),
              SizedBox(width: size.width * 0.03),
              Text(title, style: AppTextStyles.subtitle),
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
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(),
      ],
    );
  }
}
