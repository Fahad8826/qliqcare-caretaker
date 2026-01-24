import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/attendance/controller/leave/leavecontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/attendance/view/leave_stats.dart';
import 'package:qlickcare/attendance/view/leavedetails.dart';
import 'package:qlickcare/attendance/view/leavereqest_widget.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  final LeaveController controller = Get.put(LeaveController());
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      controller.fetchLeaveStats(),
      controller.fetchLeaveRequests(),
    ]);
  }

  List<dynamic> get filteredLeaves {
    if (selectedFilter == "all") {
      return controller.leaveRequests;
    }
    return controller.leaveRequests
        .where((leave) => leave.status.toLowerCase() == selectedFilter)
        .toList();
  }

  void _showLeaveRequestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Modal Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  Text("Apply for Leave", style: AppTextStyles.subtitle),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LeaveRequestWidget(
                  onSuccess: () {
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Leave Management",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLeaveRequestModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Apply Leave",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary, // spinner stroke color
        backgroundColor: AppColors.screenBackground, // behind spinner
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: size.width * 0.04,
            right: size.width * 0.04,
            top: size.height * 0.02,
            bottom: size.height * 0.1, // Space for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Leave Requests", style: AppTextStyles.heading2),
                  Obx(() {
                    final total = filteredLeaves.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$total",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              SizedBox(height: size.height * 0.015),

              // Filter Chips
              _buildFilterChips(size),

              SizedBox(height: size.height * 0.02),

              // Leave Requests List
              _buildLeaveRequestsList(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCards(Size size) {
    return Obx(() {
      final stats = controller.leaveStats.value;
      if (stats == null) return const SizedBox();

      return Row(
        children: [
          Expanded(
            child: _quickStatCard(
              size,
              icon: Icons.pending_actions,
              label: "Pending",
              value: stats.pendingleaves.toString(),
              color: Colors.orange,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: _quickStatCard(
              size,
              icon: Icons.check_circle,
              label: "Approved",
              value: stats.approvedleaves.toString(),
              color: AppColors.success,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: _quickStatCard(
              size,
              icon: Icons.calendar_month,
              label: "This Month",
              value: stats.leaveDaysThisMonth.toString(),
              color: AppColors.secondary,
            ),
          ),
        ],
      );
    });
  }

  Widget _quickStatCard(
    Size size, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(Size size) {
    return Obx(() {
      final stats = controller.leaveStats.value;

      final filters = [
        {
          'label': 'All',
          'value': 'all',
          'count': controller.leaveRequests.length,
        },
        {
          'label': 'Pending',
          'value': 'pending',
          'count': stats?.pendingleaves ?? 0,
          'color': Colors.orange,
        },
        {
          'label': 'Approved',
          'value': 'approved',
          'count': stats?.approvedleaves ?? 0,
          'color': AppColors.success,
        },
        {
          'label': 'Rejected',
          'value': 'rejected',
          'count': controller.leaveRequests
              .where((l) => l.status.toLowerCase() == 'rejected')
              .length,
          'color': AppColors.error,
        },
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter['value'];
            final chipColor = (filter['color'] as Color?) ?? AppColors.primary;
            final count = filter['count'] as int;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : chipColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$count",
                        style: TextStyle(
                          color: isSelected ? Colors.white : chipColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedFilter = filter['value'] as String);
                },
                backgroundColor: Colors.white,
                selectedColor: chipColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: isSelected ? chipColor : AppColors.border,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildLeaveRequestsList(Size size) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.08),
          child: const Center(child: Loading()),
        );
      }

      final leaves = filteredLeaves;

      if (leaves.isEmpty) {
        return _buildEmptyState(size);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaves.length,
        separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
        itemBuilder: (context, index) {
          final leave = leaves[index];
          return _buildLeaveCard(leave, size);
        },
      );
    });
  }

  Widget _buildLeaveCard(dynamic leave, Size size) {
    final statusColor = _getStatusColor(leave.status);
    final startDate = DateFormat(
      'MMM dd, yyyy',
    ).format(DateTime.parse(leave.startDate));
    final endDate = DateFormat(
      'MMM dd, yyyy',
    ).format(DateTime.parse(leave.endDate));

    return InkWell(
      onTap: () {
        Get.to(
          () => LeaveDetailPage(leaveRequest: leave),
          transition: Transition.rightToLeft,
        )?.then((_) => _loadData());
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(leave.status),
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        leave.statusDisplay,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    leave.leaveTypeDisplay,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.012),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "$startDate → $endDate",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.008),
            Row(
              children: [
                Icon(Icons.timelapse, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  "${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (leave.reason.isNotEmpty) ...[
              SizedBox(height: size.height * 0.008),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.subject, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leave.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: size.height * 0.01),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "View Details →",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    String message = selectedFilter == "all"
        ? "No Leave Requests"
        : "No ${selectedFilter.capitalize} Leave Requests";

    String subtitle = selectedFilter == "all"
        ? "You haven't requested any leave yet"
        : "You don't have any ${selectedFilter} leaves";

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.08),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 60,
                color: AppColors.textSecondary.withOpacity(0.4),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.008),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            if (selectedFilter == "all") ...[
              SizedBox(height: size.height * 0.03),
              ElevatedButton.icon(
                onPressed: _showLeaveRequestModal,
                icon: const Icon(Icons.add),
                label: const Text("Apply for Leave"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
