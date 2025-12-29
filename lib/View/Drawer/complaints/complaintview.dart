import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';
import '../../../Controllers/complaintscontroller.dart';
import '../../../Utils/appcolors.dart';

class ComplaintDetailPage extends StatefulWidget {
  final int id;
  const ComplaintDetailPage({super.key, required this.id});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final controller = Get.find<ComplaintController>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => controller.fetchComplaintDetail(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Complaint #${widget.id}",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value ||
            controller.complaintDetail.value == null) {
          return Center(child: Loading());
        }

        final c = controller.complaintDetail.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Priority Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "STATUS",
                            style: AppTextStyles.small.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: size.height * 0.006),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.006,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c.status.toUpperCase(),
                              style: AppTextStyles.body.copyWith(
                                color: c.status.toLowerCase() == "pending"
                                    ? Colors.orange.shade700
                                    : AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Priority
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "PRIORITY",
                            style: AppTextStyles.small.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: size.height * 0.006),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.006,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(c.priority),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c.priority.toUpperCase(),
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Subject Card
              _buildInfoCard(
                context,
                icon: Icons.subject,
                title: "Subject",
                content: c.subject,
                size: size,
              ),

              SizedBox(height: size.height * 0.015),

              // Description Card
              _buildInfoCard(
                context,
                icon: Icons.description_outlined,
                title: "Description",
                content: c.description,
                size: size,
                maxLines: null,
              ),

              SizedBox(height: size.height * 0.015),

              // Admin Response Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: c.adminResponse != null
                      ? AppColors.success.withOpacity(0.05)
                      : Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: c.adminResponse != null
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                            color: c.adminResponse != null
                                ? AppColors.success.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            c.adminResponse != null
                                ? Icons.admin_panel_settings
                                : Icons.pending_outlined,
                            color: c.adminResponse != null
                                ? AppColors.success
                                : Colors.orange.shade700,
                            size: isPortrait
                                ? size.width * 0.055
                                : size.height * 0.065,
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Text(
                          "Admin Response",
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      c.adminResponse ??
                          "No response yet. Please wait for admin review.",
                      style: AppTextStyles.body.copyWith(
                        color: c.adminResponse != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontStyle: c.adminResponse != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Created Date Card
              _buildCompactInfoCard(
                context,
                icon: Icons.calendar_today_outlined,
                label: "Created",
                value: _formatDate(c.createdAt),
                size: size,
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Size size,
    int? maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? size.width * 0.05
                      : size.height * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Size size,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: MediaQuery.of(context).orientation == Orientation.portrait
                ? size.width * 0.045
                : size.height * 0.055,
          ),
          SizedBox(width: size.width * 0.03),
          Text(
            "$label: ",
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "urgent":
        return Colors.red;
      case "high":
        return Colors.orange;
      case "medium":
        return Colors.blue;
      case "low":
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
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
      return "${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }
}
