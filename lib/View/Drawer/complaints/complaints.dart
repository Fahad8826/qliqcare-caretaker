import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';

import '../../../Controllers/complaintscontroller.dart';
import 'complaintview.dart';
import '../../../Utils/appcolors.dart';

class ComplaintsPage extends StatefulWidget {
  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final ComplaintController controller = Get.put(ComplaintController());

  final subjectCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final priorities = ["low", "medium", "high", "urgent"];
  final selectedPriority = "".obs;

  @override
  void initState() {
    super.initState();
    controller.fetchMyComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "My Complaints",
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
        if (controller.isLoading.value) {
          return Center(child: Loading());
        }

        if (controller.complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: isPortrait ? size.width * 0.2 : size.height * 0.25,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  "No complaints found",
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  "Tap + button to submit a complaint",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.015,
          ),
          itemCount: controller.complaints.length,
          itemBuilder: (context, i) {
            final c = controller.complaints[i];

            return Container(
              margin: EdgeInsets.only(bottom: size.height * 0.012),
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
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.008,
                ),
                title: Text(
                  c.subject,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.006),
                  child: Text(
                    c.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.025,
                    vertical: size.height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(c.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.priority.toUpperCase(),
                        style: AppTextStyles.small.copyWith(
                          color: _getPriorityColor(c.priority),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.015,
                          vertical: size.height * 0.002,
                        ),
                        decoration: BoxDecoration(
                          color: c.status.toLowerCase() == "pending"
                              ? Colors.orange.withOpacity(0.2)
                              : AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c.status,
                          style: AppTextStyles.small.copyWith(
                            fontSize: 10,
                            color: c.status.toLowerCase() == "pending"
                                ? Colors.orange.shade700
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.to(() => ComplaintDetailPage(id: c.id));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: isPortrait ? size.width * 0.07 : size.height * 0.08,
        ),
        onPressed: () {
          openSubmitModal(context);
        },
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

  void openSubmitModal(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    subjectCtrl.clear();
    descriptionCtrl.clear();
    selectedPriority.value = "";

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(size.width * 0.045),
        height: isPortrait ? size.height * 0.55 : size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Submit Complaint", style: AppTextStyles.heading2),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.025),

              // Subject Field
              Text(
                "Subject",
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: size.height * 0.008),
              TextField(
                controller: subjectCtrl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: "Enter subject",
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
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.015,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Description Field
              Text(
                "Description",
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: size.height * 0.008),
              TextField(
                controller: descriptionCtrl,
                maxLines: 4,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: "Describe your complaint in detail",
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
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.015,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Priority Dropdown
              Text(
                "Priority",
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: size.height * 0.008),
              Obx(
                () => DropdownButtonFormField<String>(
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
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
                  hint: Text(
                    "Select priority level",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                  value: selectedPriority.value == ""
                      ? null
                      : selectedPriority.value,
                  items: priorities.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(p),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(p.toUpperCase(), style: AppTextStyles.body),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      selectedPriority.value = value.toString(),
                ),
              ),

              SizedBox(height: size.height * 0.03),

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
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.6,
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (subjectCtrl.text.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter a subject",
                                backgroundColor: AppColors.error.withOpacity(
                                  0.1,
                                ),
                                colorText: AppColors.error,
                              );
                              return;
                            }
                            if (descriptionCtrl.text.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter a description",
                                backgroundColor: AppColors.error.withOpacity(
                                  0.1,
                                ),
                                colorText: AppColors.error,
                              );
                              return;
                            }
                            if (selectedPriority.value.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please select a priority",
                                backgroundColor: AppColors.error.withOpacity(
                                  0.1,
                                ),
                                colorText: AppColors.error,
                              );
                              return;
                            }

                            await controller.submitComplaint(
                              subject: subjectCtrl.text,
                              description: descriptionCtrl.text,
                              priority: selectedPriority.value,
                            );

                            Get.back();
                          },
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: size.height * 0.025,
                            width: size.height * 0.025,
                            child:Loading()
                          )
                        : Text("Submit Complaint", style: AppTextStyles.button),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }
}
