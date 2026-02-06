import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';
import '../controller/complaintscontroller.dart';
import '../../Utils/appcolors.dart';

class ComplaintDetailPage extends StatelessWidget {
  final int id;

  const ComplaintDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComplaintController>();
    
    // Fetch data on build
    Future.microtask(() => controller.fetchComplaintDetail(id));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Complaint #$id",
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(closeOverlays: true),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.complaintDetail.value == null) {
          return const Center(child: Loading());
        }

        final complaint = controller.complaintDetail.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Priority Badges
              Row(
                children: [
                  Expanded(
                    child: _StatusBadge(status: complaint.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriorityBadge(priority: complaint.priority),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subject Section
              _SectionLabel(label: "Subject"),
              const SizedBox(height: 8),
              _InfoCard(
                icon: Icons.subject,
                content: complaint.subject,
              ),

              const SizedBox(height: 20),

              // Description Section
              _SectionLabel(label: "Description"),
              const SizedBox(height: 8),
              _InfoCard(
                icon: Icons.description_outlined,
                content: complaint.description,
                maxLines: null,
              ),

              const SizedBox(height: 20),

              // Admin Response Section
              _SectionLabel(label: "Admin Response"),
              const SizedBox(height: 8),
              _AdminResponseCard(
                response: complaint.adminResponse,
                hasResponse: complaint.adminResponse != null,
              ),

              const SizedBox(height: 20),

              // Metadata
              _MetadataCard(
                createdAt: complaint.createdAt,
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}

/// Section Label
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.subtitle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status.toLowerCase() == "pending";
    final color = isPending ? Colors.orange : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            "STATUS",
            style: AppTextStyles.small.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Priority Badge
class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

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

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            "PRIORITY",
            style: AppTextStyles.small.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            priority.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Card
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String content;
  final int? maxLines;

  const _InfoCard({
    required this.icon,
    required this.content,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
                fontSize: 14,
              ),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin Response Card
class _AdminResponseCard extends StatelessWidget {
  final String? response;
  final bool hasResponse;

  const _AdminResponseCard({
    required this.response,
    required this.hasResponse,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasResponse ? AppColors.success : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasResponse ? Icons.check_circle : Icons.pending_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                hasResponse ? "Response Received" : "Pending Review",
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response ?? "No response yet. Your complaint is under review by our admin team.",
            style: AppTextStyles.body.copyWith(
              color: hasResponse ? AppColors.textPrimary : AppColors.textSecondary,
              fontStyle: hasResponse ? FontStyle.normal : FontStyle.italic,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadata Card
class _MetadataCard extends StatelessWidget {
  final String createdAt;

  const _MetadataCard({required this.createdAt});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            "Created: ",
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(createdAt),
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}