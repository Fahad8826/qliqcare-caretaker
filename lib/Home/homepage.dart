import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/bookings/controller/bookingcontroller.dart';
import 'package:qlickcare/bookings/view/Details/bookingdetailedview.dart';
import 'package:qlickcare/chat/controller/chat_controller.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/Drawer/drawer.dart';
import 'package:qlickcare/chat/view/chatdetailscreen.dart';
import 'package:qlickcare/notification/views/listnotification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationName = "Loading...";
  Map<int, bool> expandedStates = {};

  final P_Controller profileController = Get.put(P_Controller());
  final ChatController controller = Get.put(ChatController());
  final BookingController ongoingBookingController = Get.put(
    BookingController(),
    tag: 'homepage',
  );

  @override
  void initState() {
    super.initState();
    _fetchLocationName();
    ongoingBookingController.fetchOngoingBookings();
  }

  Future<void> _fetchLocationName() async {
    try {
      final coords = await LocationService.getCurrentCoordinates();
      if (coords != null) {
        final name = await LocationService.getLocationName(
          coords['lat']!,
          coords['lng']!,
        );
        setState(() {
          locationName = name;
        });
      } else {
        setState(() {
          locationName = "Location unavailable";
        });
      }
    } catch (e) {
      print("❌ Error fetching location name: $e");
      setState(() {
        locationName = "Location unavailable";
      });
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      expandedStates[index] = !(expandedStates[index] ?? false);
    });
  }

  String _formatWorkType(String workType) {
    return workType.replaceAll('_', ' ').capitalize ?? workType;
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.day.toString().padLeft(2, '0')} ${_getMonthName(parsedDate.month)} ${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "Home",
        actions: [
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.bell,
              color: AppColors.background,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notification()),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.background, size: 28),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Obx(() {
              final profile = profileController.profile.value;
              final fullName = profile?.fullName ?? "User";
              final profilePicture = profile?.profilePicture;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning,",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fullName,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (profilePicture != null &&
                                profilePicture.trim().isNotEmpty)
                            ? Image.network(
                                profilePicture.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                size: 32,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // My Patients Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                "My Patients",
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Patient Cards
            Obx(() {
              if (ongoingBookingController.isLoading.value) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(40), child: Loading()),
                );
              }

              if (ongoingBookingController.bookings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No Patients Found",
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(
                  ongoingBookingController.bookings.length,
                  (index) {
                    final booking = ongoingBookingController.bookings.elementAt(
                      index,
                    );

                    return _buildPatientCard(
                      context,
                      index: index,
                      name: "${booking.patientName}, ${booking.age}",
                      condition: booking.booking_status,
                      gender: booking.gender,
                      shift: _formatWorkType(booking.workType),
                      location: "${booking.address}, ${booking.pincode}",
                      customerName: booking.customerName,
                      customerPhone: booking.customerPhone,
                      patientDetails: {
                        "ID": booking.id.toString(),
                        "Gender": booking.gender,
                        "Age": booking.age.toString(),
                        "Status": booking.booking_status,
                        "Customer": booking.customerName,
                      },
                      serviceDetails: {
                        "Work Type": _formatWorkType(booking.workType),
                        "Location": "${booking.address}, ${booking.pincode}",
                        "Start Date": _formatDate(booking.startDate),
                        "End Date": _formatDate(booking.endDate),
                      },
                      totalAmount: booking.totalAmount,
                      advanceAmount: booking.advanceAmount,
                      isReassigned: booking.isCurrentlyReassigned,
                      reassignedTo:
                          booking.reassignmentStatus?.reassignedTo ?? "",
                      startDate: booking.reassignmentStatus?.startDate ?? "",
                      endDate: booking.reassignmentStatus?.endDate ?? "",
                      progress:
                          booking.reassignmentStatus?.completionPercentage ?? 0,
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(
    BuildContext context, {
    required int index,
    required String name,
    required String condition,
    required String gender,
    required String shift,
    required String location,
    required String customerName,
    required String customerPhone,
    required Map<String, String> patientDetails,
    required Map<String, String> serviceDetails,
    required String totalAmount,
    required String advanceAmount,
    required bool isReassigned,
    String? reassignedTo,
    String? startDate,
    String? endDate,
    double? progress,
  }) {
    final isExpanded = expandedStates[index] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleExpansion(index),
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Basic Info
          Row(
            children: [
              Icon(
                gender.toLowerCase() == "male" ? Icons.male : Icons.female,
                color: AppColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(gender, style: AppTextStyles.small),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                color: AppColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shift,
                  style: AppTextStyles.small,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.small,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Reassignment Banner
          if (isReassigned) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🔁 Reassigned Booking",
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (reassignedTo != null && reassignedTo.trim().isNotEmpty)
                    Text(
                      "Caretaker: $reassignedTo",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  if (startDate != null && endDate != null)
                    Text(
                      "Duration: $startDate → $endDate",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (progress != null)
                    Text(
                      "Progress: ${progress.toStringAsFixed(0)}%",
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Expanded Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),

                // Patient Details
                Text(
                  "Patient Details",
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ...patientDetails.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${entry.key}:",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                // Service Details
                Text(
                  "Service Details",
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ...serviceDetails.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.key}:",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => BookingDetailsPage(
                          bookingId:
                              ongoingBookingController.bookings[index].id,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Attendance & Tasks",
                      style: AppTextStyles.button.copyWith(fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      final bookingId =
                          ongoingBookingController.bookings[index].id;

                      // ✅ Make sure chat rooms are loaded
                      if (controller.chatRooms.isEmpty) {
                        await controller.fetchChatRooms();
                      }

                      final chatId = controller.getChatIdByBooking(bookingId);

                      if (chatId == null) {
                        Get.snackbar(
                          "Chat Not Available",
                          "No chat room found for this booking",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      // ✅ Important: set selected chat so header name works immediately
                      controller.selectedChat.value = controller.chatRooms
                          .firstWhere((e) => e.id == chatId);

                      Get.to(() => ChatDetailScreen(chatId: chatId));
                    },

                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Chat with Patient",
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
