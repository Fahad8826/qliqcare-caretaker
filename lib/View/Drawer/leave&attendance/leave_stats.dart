import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/leavecontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';

class LeaveStatsSection extends StatelessWidget {
  LeaveStatsSection({super.key});

  final LeaveController controller = Get.put(LeaveController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
            child: const Loading(),
          ),
        );
      }

      if (controller.leaveStats.value == null) {
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
          child: Center(
            child: Text(
              "No leave data available",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      final stats = controller.leaveStats.value!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Leave Summary",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // Leave Stats Card
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
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_available,
                        color: AppColors.secondary,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      "Leave Statistics",
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),

                // Stats rows
                _statRow(
                  context,
                  icon: Icons.list_alt,
                  label: "Total Leaves",
                  value: stats.totalLeaves.toString(),
                ),
                _statRow(
                  context,
                  icon: Icons.upcoming,
                  label: "Upcoming Leaves",
                  value: stats.upcomingLeaves.toString(),
                  valueColor: stats.upcomingLeaves > 0
                      ? Colors.orange
                      : AppColors.textPrimary,
                ),
                _statRow(
                  context,
                  icon: Icons.play_circle_outline,
                  label: "Ongoing Leaves",
                  value: stats.ongoingLeaves.toString(),
                  valueColor: stats.ongoingLeaves > 0
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
                _statRow(
                  context,
                  icon: Icons.history,
                  label: "Past Leaves",
                  value: stats.pastLeaves.toString(),
                ),
                _statRow(
                  context,
                  icon: Icons.event_busy,
                  label: "Total Days on Leave",
                  value: stats.totalDaysOnLeave.toString(),
                ),
                _statRow(
                  context,
                  icon: Icons.calendar_month,
                  label: "Leave Days This Month",
                  value: stats.leaveDaysThisMonth.toString(),
                  valueColor: stats.leaveDaysThisMonth > 0
                      ? AppColors.secondary
                      : AppColors.textPrimary,
                  isLast: true,
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),
        ],
      );
    });
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