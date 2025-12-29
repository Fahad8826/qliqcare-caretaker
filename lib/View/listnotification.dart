import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/notificationlistcontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';

class notification extends StatelessWidget {
  notification({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Responsive sizing
    final iconSize = isPortrait ? screenWidth * 0.06 : screenHeight * 0.06;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final cardPadding = screenWidth * 0.04;
    final cardMargin = screenHeight * 0.015;
    final iconContainerSize = isPortrait ? screenWidth * 0.12 : screenHeight * 0.12;
    final titleFontSize = isPortrait ? screenWidth * 0.042 : screenHeight * 0.042;
    final bodyFontSize = isPortrait ? screenWidth * 0.038 : screenHeight * 0.038;
    final timeFontSize = isPortrait ? screenWidth * 0.032 : screenHeight * 0.032;

    return Scaffold(
      appBar: CommonAppBar(
        title: "Notifications",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: iconSize,
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
          return _buildEmptyState(context, screenWidth, screenHeight, isPortrait);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final n = controller.notifications[index];

              return Container(
                margin: EdgeInsets.only(bottom: cardMargin),
                decoration: BoxDecoration(
                  color: n.isRead
                      ? AppColors.background
                      : AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: n.isRead
                        ? Colors.grey.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Handle notification tap
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Container
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? Colors.grey.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.notifications_rounded,
                                color: n.isRead
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                size: iconContainerSize * 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: titleFontSize,
                                          color: AppColors.textPrimary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: screenWidth * 0.02,
                                        height: screenWidth * 0.02,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.008),
                                Text(
                                  n.body,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: timeFontSize,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      n.timeAgo,
                                      style: TextStyle(
                                        fontSize: timeFontSize,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, double screenWidth, double screenHeight, bool isPortrait) {
    final emptyIconSize = isPortrait ? screenWidth * 0.25 : screenHeight * 0.25;
    final emptyTitleSize = isPortrait ? screenWidth * 0.05 : screenHeight * 0.05;
    final emptyBodySize = isPortrait ? screenWidth * 0.038 : screenHeight * 0.038;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.08),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: emptyIconSize,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "No Notifications",
              style: TextStyle(
                fontSize: emptyTitleSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              "You're all caught up! Check back later for new notifications.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: emptyBodySize,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}