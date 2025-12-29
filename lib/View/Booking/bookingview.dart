import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/bookingcontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/Booking/bookingdetailedview.dart';

class BookingView extends StatelessWidget {
  // ✅ Use tagged controller to isolate from homepage
  final BookingController controller = Get.put(
    BookingController(),
    tag: 'allbookings', // Unique tag for this page
  );

  @override
  Widget build(BuildContext context) {
    controller.fetchBookings();
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return WillPopScope(
      // ✅ Clean up controller when leaving page
      onWillPop: () async {
        Get.delete<BookingController>(tag: 'allbookings');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: CommonAppBar(
          title: "All Patient Details",
          leading: IconButton(
            icon: Icon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: isPortrait ? size.width * 0.055 : size.height * 0.065,
            ),
            onPressed: () {
              // ✅ Clean up before going back
              Get.delete<BookingController>(tag: 'allbookings');
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            // Filter Chips Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.015,
              ),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: "All",
                        isSelected: controller.selectedFilter.value == "ALL",
                        onTap: () => controller.filterBookings("ALL"),
                      ),
                      SizedBox(width: size.width * 0.02),
                      _buildFilterChip(
                        context,
                        label: "On Duty",
                        isSelected: controller.selectedFilter.value == "ONGOING",
                        onTap: () => controller.filterBookings("ONGOING"),
                      ),
                      SizedBox(width: size.width * 0.02),
                      _buildFilterChip(
                        context,
                        label: "Work Completed",
                        isSelected:
                            controller.selectedFilter.value == "WORK_COMPLETED",
                        onTap: () => controller.filterBookings("WORK_COMPLETED"),
                      ),
                      SizedBox(width: size.width * 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // Booking List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(size.height * 0.05),
                      child: Loading(),
                    ),
                  );
                }

                if (controller.filteredBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: isPortrait
                              ? size.width * 0.2
                              : size.height * 0.25,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          "No Bookings Found",
                          style: AppTextStyles.heading2.copyWith(
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
                  itemCount: controller.filteredBookings.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredBookings[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row with Name and Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.patientName,
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: isPortrait
                                          ? size.width * 0.048
                                          : size.height * 0.055,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(context, item.booking_status),
                              ],
                            ),

                            SizedBox(height: size.height * 0.01),
                            SizedBox(height: size.height * 0.012),

                            // Patient Details Row
                            Row(
                              children: [
                                Icon(
                                  item.gender?.toLowerCase() == "male"
                                      ? Icons.male
                                      : Icons.female,
                                  size: isPortrait
                                      ? size.width * 0.04
                                      : size.height * 0.048,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Text(
                                  item.gender ?? "Male",
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: isPortrait
                                        ? size.width * 0.032
                                        : size.height * 0.038,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Icon(
                                  Icons.access_time,
                                  size: isPortrait
                                      ? size.width * 0.04
                                      : size.height * 0.048,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Text(
                                  item.workType ?? "Day Shift",
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: isPortrait
                                        ? size.width * 0.032
                                        : size.height * 0.038,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.008),

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: isPortrait
                                      ? size.width * 0.04
                                      : size.height * 0.048,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Expanded(
                                  child: Text(
                                    item.address ?? "Location not specified",
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: isPortrait
                                          ? size.width * 0.032
                                          : size.height * 0.038,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.015),

                            // Patient Details Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(
                                    () => BookingDetailsPage(bookingId: item.id),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05,
                                    vertical: size.height * 0.012,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "Patient Details",
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: isPortrait
                                        ? size.width * 0.035
                                        : size.height * 0.042,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: isPortrait ? size.width * 0.035 : size.height * 0.04,
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    Color statusColor;
    String statusText;

    switch (status.toUpperCase()) {
      case "ONGOING":
        statusColor = AppColors.primary;
        statusText = "On Duty";
        break;
      case "WORK_COMPLETED":
        statusColor = Colors.blue;
        statusText = "Completed";
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.006,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.small.copyWith(
          fontSize: isPortrait ? size.width * 0.03 : size.height * 0.036,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}