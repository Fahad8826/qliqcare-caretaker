import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qlickcare/Model/bookings/Details/bookingdetails_model.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/Controllers/bookings/bookingdetailscontroller.dart';

/// Reusable Card Container
class BookingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const BookingCard({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section Header
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading2.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Card Title
class CardTitle extends StatelessWidget {
  final String title;

  const CardTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.subtitle.copyWith(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Info Row Widget
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Chip Widget
class InfoChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const InfoChip({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Patient Information Card
class PatientInfoCard extends StatelessWidget {
  final BookingDetails booking;
  final VoidCallback onOpenMaps;

  const PatientInfoCard({
    Key? key,
    required this.booking,
    required this.onOpenMaps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: "Patient Information"),
          const SizedBox(height: 12),
          
          Text(
            "${booking.patientName}, ${booking.age}, BOOKING ID${booking.id}",
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (booking.patientCondition.isNotEmpty)
                InfoChip(
                  text: booking.patientCondition,
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  textColor: AppColors.error,
                ),
              if (booking.workType.isNotEmpty)
                InfoChip(
                  text: booking.workType,
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  textColor: AppColors.success,
                ),
              if (booking.mobilityLevel.isNotEmpty)
                InfoChip(
                  text: booking.mobilityLevel,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  textColor: Colors.blue,
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (booking.gender.isNotEmpty)
            InfoRow(
              icon: FontAwesomeIcons.venusMars,
              label: "Gender",
              value: booking.gender,
            ),
          
          if (booking.address.isNotEmpty)
            _AddressRow(
              address: booking.address,
              hasLocation: booking.latitude.isNotEmpty && booking.longitude.isNotEmpty,
              onOpenMaps: onOpenMaps,
            ),
          
          if (booking.pincode.isNotEmpty)
            InfoRow(
              icon: FontAwesomeIcons.mapPin,
              label: "Pincode",
              value: booking.pincode,
            ),
          
          if (booking.aadharNumber.isNotEmpty)
            InfoRow(
              icon: FontAwesomeIcons.idCard,
              label: "Aadhar",
              value: booking.aadharNumber,
            ),
          
          if (booking.aadharImage != null && booking.aadharImage!.isNotEmpty)
            AadharImageSection(imageUrl: booking.aadharImage!),
        ],
      ),
    );
  }
}

/// Address Row with Maps Button
class _AddressRow extends StatelessWidget {
  final String address;
  final bool hasLocation;
  final VoidCallback onOpenMaps;

  const _AddressRow({
    required this.address,
    required this.hasLocation,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.locationDot,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            "Address: ",
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              address,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasLocation)
            InkWell(
              onTap: onOpenMaps,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.mapLocationDot,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Aadhar Image Section
class AadharImageSection extends StatelessWidget {
  final String imageUrl;

  const AadharImageSection({Key? key, required this.imageUrl}) : super(key: key);

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Failed to load image",
                          style: AppTextStyles.body.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)),
        const SizedBox(height: 12),
        
        Text(
          "Aadhar Document",
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        GestureDetector(
          onTap: () => _showFullScreenImage(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: Loading());
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 40, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text(
                        "Failed to load image",
                        style: AppTextStyles.small.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Tap to view full image",
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Customer Contact Card
class CustomerContactCard extends StatelessWidget {
  final BookingDetails booking;

  const CustomerContactCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasCustomerData = booking.customerName.isNotEmpty ||
        booking.customerPhone.isNotEmpty ||
        booking.customerEmail.isNotEmpty;

    if (!hasCustomerData) return const SizedBox.shrink();

    return BookingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: "Customer Contact"),
          const SizedBox(height: 12),
          
          if (booking.customerName.isNotEmpty)
            InfoRow(
              icon: FontAwesomeIcons.user,
              label: "Name",
              value: booking.customerName,
            ),
          
          if (booking.customerPhone.isNotEmpty)
            InfoRow(
              icon: FontAwesomeIcons.phone,
              label: "Phone",
              value: booking.customerPhone,
            ),
          
          
        ],
      ),
    );
  }
}



/// Task List Widget
class TaskList extends StatelessWidget {
  final List<TodoItem> todos;
  final bool isOnLeaveToday;
  final String endDate;
  final BookingDetailsController controller;

  const TaskList({
    Key? key,
    required this.todos,
    required this.isOnLeaveToday,
    required this.endDate,
    required this.controller,
  }) : super(key: key);

  bool _isBookingCompleted(String endDateStr) {
    try {
      final endDate = DateTime.parse(endDateStr);
      final today = DateTime.now();
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final now = DateTime(today.year, today.month, today.day);
      return end.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disableActions = isOnLeaveToday || _isBookingCompleted(endDate);

    return BookingCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todos.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFEAEAEA)),
        itemBuilder: (context, index) {
          final task = todos[index];
          final bool isCompleted = task.isCompleted;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.text ?? "No Task",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      task.time ?? "N/A",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: disableActions
                          ? null
                          : () => controller.updateTodoStatus(
                                task.id,
                                !task.isCompleted,
                              ),
                      child: Opacity(
                        opacity: disableActions ? 0.4 : 1.0,
                        child: Icon(
                          isCompleted
                              ? FontAwesomeIcons.solidCircleCheck
                              : FontAwesomeIcons.circle,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.textSecondary.withOpacity(0.5),
                          size: 22,
                        ),
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

/// Helper Functions
class BookingDetailsHelper {
  static Future<void> openGoogleMaps(String? latitude, String? longitude) async {
    if (latitude == null ||
        longitude == null ||
        latitude.isEmpty ||
        longitude.isEmpty) {
      Get.snackbar(
        "Location Error",
        "Location coordinates are not available",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.background,
      );
      return;
    }

    try {
      final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          "Error",
          "Could not open Google Maps",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.background,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open location: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.background,
      );
    }
  }
}