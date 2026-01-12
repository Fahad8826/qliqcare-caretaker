import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/bookingcontroller.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/Drawer/Booking/bookingdetailedview.dart';

class BookingView extends StatelessWidget {
  BookingView({Key? key}) : super(key: key);

  // ✅ Use tagged controller to isolate from homepage
  final BookingController controller = Get.put(
    BookingController(),
    tag: 'allbookings',
  );
  

  @override
  Widget build(BuildContext context) {
    controller.fetchBookings();

    return WillPopScope(
      onWillPop: () async {
        Get.delete<BookingController>(tag: 'allbookings');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: CommonAppBar(
          title: "All Patient Details",
          leading: IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Get.delete<BookingController>(tag: 'allbookings');
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            // Filter Tabs Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  children: [
                    _FilterTab(
                      label: "All",
                      isSelected: controller.selectedFilter.value == "ALL",
                      onTap: () => controller.filterBookings("ALL"),
                    ),
                    _FilterTab(
                      label: "On Duty",
                      isSelected: controller.selectedFilter.value == "ONGOING",
                      onTap: () => controller.filterBookings("ONGOING"),
                    ),
                    _FilterTab(
                      label: "Completed",
                      isSelected: controller.selectedFilter.value == "WORK_COMPLETED",
                      onTap: () => controller.filterBookings("WORK_COMPLETED"),
                    ),
                      _FilterTab(
                      label: "Canceled",
                      isSelected: controller.selectedFilter.value == "CANCELED",
                      onTap: () => controller.filterBookings("CANCELED"),
                    ),
                    
                  ],
                ),
              ),
            ),

            // Booking List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
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
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredBookings.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredBookings[index];
                    return _BookingCard(booking: item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter Tab Widget (Material Design Style)
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Booking Card Widget
class _BookingCard extends StatelessWidget {
  final dynamic booking;

  const _BookingCard({required this.booking});

  

  @override
  Widget build(BuildContext context) {
    final showButton =
    booking.booking_status.toUpperCase() == "ONGOING" ||
    booking.booking_status.toUpperCase() == "WORK_COMPLETED";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    booking.patientName,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: booking.booking_status),
              ],
            ),

            const SizedBox(height: 12),

            // Patient Details Row
            Row(
              children: [
                Icon(
                  booking.gender?.toLowerCase() == "male"
                      ? Icons.male
                      : Icons.female,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  booking.gender ?? "Male",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  booking.workType ?? "Day Shift",
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.address ?? "Location not specified",
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Patient Details Button
            if (showButton)
  Align(
    alignment: Alignment.centerRight,
    child: ElevatedButton(
      onPressed: () {
        Get.to(() => BookingDetailsPage(bookingId: booking.id));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        "Patient Details",
        style: AppTextStyles.body.copyWith(
          fontSize: 13,
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
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.small.copyWith(
          fontSize: 11,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}