import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qlickcare/attendance/controller/leave/leavecontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';

class LeaveRequestWidget extends StatefulWidget {
  final bool isEdit;
  final int? leaveId;
  final String? initialReason;
  final String? initialLeaveType;
  final DateTimeRange? initialRange;
  final VoidCallback? onSuccess;

  const LeaveRequestWidget({
    super.key,
    this.isEdit = false,
    this.leaveId,
    this.initialReason,
    this.initialLeaveType,
    this.initialRange,
    this.onSuccess,
  });

  @override
  State<LeaveRequestWidget> createState() => _LeaveRequestWidgetState();
}

class _LeaveRequestWidgetState extends State<LeaveRequestWidget> {
  final LeaveController controller = Get.find<LeaveController>();

  late TextEditingController reasonController;
  DateTimeRange? selectedRange;
  String leaveType = "casual";

  final List<String> leaveTypes = [
    "casual",
    "sick",
    "emergency",
    "personal",
    "other",
  ];

  @override
  void initState() {
    super.initState();

    reasonController = TextEditingController(text: widget.initialReason ?? "");

    selectedRange = widget.initialRange;
    leaveType = widget.initialLeaveType ?? "casual";
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: widget.isEdit
          ? DateTime.now().subtract(const Duration(days: 365))
          : DateTime.now(),
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
      setState(() => selectedRange = picked);
    }
  }

  String _formatApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _submit() async {
  if (selectedRange == null) {
    Get.snackbar("Error", "Please select leave dates");
    return;
  }

  if (reasonController.text.trim().isEmpty) {
    Get.snackbar("Error", "Please enter leave reason");
    return;
  }

  if (widget.isEdit && widget.leaveId == null) {
    Get.snackbar("Error", "Invalid leave record");
    return;
  }

  bool success = false; // Initialize as false

  if (widget.isEdit) {
    success = await controller.updateLeave(
      leaveId: widget.leaveId!,
      startDate: _formatApi(selectedRange!.start),
      endDate: _formatApi(selectedRange!.end),
      reason: reasonController.text.trim(),
      leaveType: leaveType,
    );
  } else {
    success = await controller.requestLeave(
      startDate: _formatApi(selectedRange!.start),
      endDate: _formatApi(selectedRange!.end),
      reason: reasonController.text.trim(),
      leaveType: leaveType,
    );
  }

  if (success) {
    // Clear the form after successful submission
    setState(() {
      selectedRange = null;
      reasonController.clear();
      leaveType = "casual";
    });
    
    widget.onSuccess?.call();
  }
}

  @override
  Widget build(BuildContext context) {
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

          Text("Leave Duration", style: AppTextStyles.body),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDateRange,
            child: _inputBox(
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedRange == null
                          ? "Select leave dates"
                          : "${DateFormat('MMM dd').format(selectedRange!.start)} → "
                                "${DateFormat('MMM dd').format(selectedRange!.end)}",
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          /// LEAVE TYPE
          Text("Leave Type", style: AppTextStyles.body),
          const SizedBox(height: 8),
          _inputBox(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: leaveType,
                isExpanded: true,
                items: leaveTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => leaveType = v);
                  }
                },
              ),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          /// REASON
          Text("Reason", style: AppTextStyles.body),
          const SizedBox(height: 8),
          TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: _textFieldDecoration(),
          ),

          SizedBox(height: size.height * 0.03),

          /// SUBMIT BUTTON
          Obx(() {
            return SizedBox(
              width: double.infinity,
              height: size.height * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.isLoading.value ? null : _submit,
                child: controller.isLoading.value
                    ? const Loading()
                    : Text(
                        widget.isEdit ? "Update Leave" : "Submit Leave Request",
                        style: AppTextStyles.button,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  InputDecoration _textFieldDecoration() {
    return InputDecoration(
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
    );
  }
}
