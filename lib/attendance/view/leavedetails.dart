import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/attendance/controller/leave/leavecontroller.dart';
import 'package:qlickcare/attendance/model/leave/leave_model.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/attendance/view/leavereqest_widget.dart';

class LeaveDetailPage extends StatefulWidget {
  final LeaveRequest leaveRequest;

  const LeaveDetailPage({
    super.key,
    required this.leaveRequest,
  });

  @override
  State<LeaveDetailPage> createState() => _LeaveDetailPageState();
}

class _LeaveDetailPageState extends State<LeaveDetailPage> {
  final LeaveController controller = Get.find<LeaveController>();
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Leave Details",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(closeOverlays: true),
        ),
        actions: [
          if (!isEditMode && _canEdit())
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => isEditMode = true),
            ),
          if (_canDelete())
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: isEditMode ? _buildEditMode(size) : _buildViewMode(size),
    );
  }

  Widget _buildViewMode(Size size) {
    final leave = widget.leaveRequest;
    final statusColor = _getStatusColor(leave.status);
    final startDate = DateFormat('MMM dd, yyyy').format(DateTime.parse(leave.startDate));
    final endDate = DateFormat('MMM dd, yyyy').format(DateTime.parse(leave.endDate));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Badge
          Container(
            width: double.infinity,
            color: statusColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getStatusIcon(leave.status), color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  leave.statusDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave Type
                _buildSimpleRow(
                  "Leave Type",
                  leave.leaveTypeDisplay,
                  Icons.category_outlined,
                ),
                const Divider(height: 24),

                // Date Range
                _buildSimpleRow(
                  "Start Date",
                  startDate,
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                _buildSimpleRow(
                  "End Date",
                  endDate,
                  Icons.event_outlined,
                ),
                const SizedBox(height: 16),
                _buildSimpleRow(
                  "Duration",
                  "${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}",
                  Icons.timelapse_outlined,
                ),
                const Divider(height: 24),

                // Reason
                if (leave.reason.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.description_outlined, 
                        size: 20, 
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Reason",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      leave.reason,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // Admin Remarks
                if (leave.adminRemarks != null && leave.adminRemarks!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Admin Remarks",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      leave.adminRemarks!,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // Timestamps
                Text(
                  "Timeline",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimestamp(
                  "Requested",
                  DateFormat('MMM dd, yyyy hh:mm a')
                      .format(DateTime.parse(leave.requestedAt)),
                ),
                if (leave.processedAt != null)
                  _buildTimestamp(
                    "Processed",
                    DateFormat('MMM dd, yyyy hh:mm a')
                        .format(DateTime.parse(leave.processedAt!)),
                  ),
                if (leave.updatedAt != null)
                  _buildTimestamp(
                    "Last Updated",
                    DateFormat('MMM dd, yyyy hh:mm a')
                        .format(DateTime.parse(leave.updatedAt!)),
                  ),

                SizedBox(height: size.height * 0.03),

                // Action Buttons
                if (_canEdit() || _canDelete())
                  Row(
                    children: [
                      if (_canEdit())
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => isEditMode = true),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text("Edit"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (_canEdit() && _canDelete()) 
                        SizedBox(width: size.width * 0.03),
                      if (_canDelete())
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showDeleteDialog,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text("Cancel"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(Size size) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          LeaveRequestWidget(
            isEdit: true,
            leaveId: widget.leaveRequest.id,
            initialReason: widget.leaveRequest.reason,
            initialLeaveType: widget.leaveRequest.leaveType,
            initialRange: DateTimeRange(
              start: DateTime.parse(widget.leaveRequest.startDate),
              end: DateTime.parse(widget.leaveRequest.endDate),
            ),
            onSuccess: () {
              setState(() => isEditMode = false);
              Get.back(closeOverlays: true);
            },
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => isEditMode = false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Cancel Leave Request"),
        content: const Text(
          "Are you sure you want to cancel this leave request? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: Text(
              "No, Keep It",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back(closeOverlays: true);
              final success = await controller.deleteLeaveRequest(widget.leaveRequest.id);
              if (success) {
                Get.back(closeOverlays: true);
              }
            },
            child: Text(
              "Yes, Cancel",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  bool _canEdit() {
    final status = widget.leaveRequest.status.toLowerCase();
    final startDate = DateTime.parse(widget.leaveRequest.startDate);
    return status == 'pending' && startDate.isAfter(DateTime.now());
  }

  bool _canDelete() {
    final status = widget.leaveRequest.status.toLowerCase();
    final startDate = DateTime.parse(widget.leaveRequest.startDate);
    return (status == 'pending' || status == 'approved') && 
           startDate.isAfter(DateTime.now());
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info;
    }
  }
}