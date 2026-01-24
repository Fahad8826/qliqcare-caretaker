import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/bookings/model/bookingdetails_model.dart';
import '../../../Utils/appcolors.dart';

class TaskListWidget extends StatelessWidget {
  final Size size;
  final List<TodoItem> todos;
  final Function(int taskId, bool isCompleted) onToggle;

  const TaskListWidget({
    super.key,
    required this.size,
    required this.todos,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todos.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFEAEAEA)),
        itemBuilder: (context, index) {
          final task = todos[index];
          final bool isCompleted = task.isCompleted;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// TASK TEXT
                Expanded(
                  child: Text(
                    task.text ?? "No Task",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),

                /// TIME + CHECK ICON
                Row(
                  children: [
                    Text(
                      task.time ?? "N/A",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),

                    /// CLICKABLE ICON
                    GestureDetector(
                      onTap: () {
                        onToggle(task.id, !task.isCompleted);
                      },
                      child: Icon(
                        isCompleted
                            ? FontAwesomeIcons.solidCircleCheck
                            : FontAwesomeIcons.circle,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
