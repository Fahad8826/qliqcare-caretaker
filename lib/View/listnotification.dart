import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/notificationlistcontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';

class notification extends StatelessWidget {
  notification({super.key});

  final NotificationController controller =
      Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: CommonAppBar(
        title: "Notifications",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.06 : size.height * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: AppColors.screenBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: Loading());
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final n = controller.notifications[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.isRead
                      ? AppColors.background
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notifications,
                      color: n.isRead
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
