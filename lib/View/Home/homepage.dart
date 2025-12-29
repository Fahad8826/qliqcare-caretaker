import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:qlickcare/Controllers/bookingcontroller.dart';
import 'package:qlickcare/Controllers/profilecontroller.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/Drawer/drawer.dart';
import 'package:qlickcare/View/Drawer/Booking/bookingdetailedview.dart';
import 'package:qlickcare/View/chat/chatdetailscreen.dart';
import 'package:qlickcare/View/listnotification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationName = "Loading...";

  // Track which patient cards are expanded
  Map<int, bool> expandedStates = {};

  // GetX Controllers
  final P_Controller profileController = Get.put(P_Controller());

  final BookingController ongoingBookingController = Get.put(
  BookingController(),
  tag: 'homepage', // ✅ Add this tag
);

  @override
  void initState() {
    super.initState();
    _fetchLocationName();
    
    ongoingBookingController.fetchOngoingBookings();
  }

  

Future<void> _fetchLocationName() async {
    try {
      // Get current coordinates (service should already be running from main.dart or login)
      final coords = await LocationService.getCurrentCoordinates();

      if (coords != null) {
        // Get location name from coordinates
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

  // Helper function to format work type
  String _formatWorkType(String workType) {
    return workType.replaceAll('_', ' ').capitalize ?? workType;
  }

  // Helper function to format date
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
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "Home",
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.bell,
              color: AppColors.background,
              size: isPortrait ? size.width * 0.055 : size.height * 0.065,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  notification()),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.background,
              size: isPortrait ? size.width * 0.07 : size.height * 0.08,
            ),
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
                margin: EdgeInsets.all(size.width * 0.04),
                padding: EdgeInsets.all(size.width * 0.04),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning,",
                            style: AppTextStyles.body.copyWith(
                              fontSize: isPortrait
                                  ? size.width * 0.038
                                  : size.height * 0.045,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            fullName,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: isPortrait
                                  ? size.width * 0.055
                                  : size.height * 0.065,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.secondary,
                                size: isPortrait
                                    ? size.width * 0.045
                                    : size.height * 0.055,
                              ),
                              SizedBox(width: size.width * 0.01),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: isPortrait
                                        ? size.width * 0.035
                                        : size.height * 0.042,
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
                      width: isPortrait
                          ? size.width * 0.16
                          : size.height * 0.18,
                      height: isPortrait
                          ? size.width * 0.16
                          : size.height * 0.18,
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
                                  return Icon(
                                    Icons.person,
                                    size: isPortrait
                                        ? size.width * 0.08
                                        : size.height * 0.09,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: isPortrait
                                    ? size.width * 0.08
                                    : size.height * 0.09,
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
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Text(
                "My Patients",
                style: AppTextStyles.heading2.copyWith(
                  fontSize: isPortrait ? size.width * 0.05 : size.height * 0.06,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: size.height * 0.015),

            // Patient Cards from Real Data
            Obx(() {
              if (ongoingBookingController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.1),
                    child: Loading(),
                  ),
                );
              }

              if (ongoingBookingController.bookings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.1),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: size.width * 0.15,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          "No Patients Found",
                          style: AppTextStyles.heading2.copyWith(
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
                      condition: booking.booking_status, // ✅ FIXED
                      gender: booking.gender,
                      shift: _formatWorkType(booking.workType),
                      location: "${booking.address}, ${booking.pincode}",
                      customerName: booking.customerName,
                      customerPhone: booking.customerPhone,
                      patientDetails: {
                        "ID": booking.id.toString(),
                        "Gender": booking.gender,
                        "Age": booking.age.toString(),
                        "Status": booking.booking_status, // ✅ FIXED
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
                    );
                  },
                ),
              );
            }),

            SizedBox(height: size.height * 0.02),
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
  }) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final isExpanded = expandedStates[index] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.008,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
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
                        fontSize: isPortrait
                            ? size.width * 0.045
                            : size.height * 0.055,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      condition,
                      style: AppTextStyles.body.copyWith(
                        fontSize: isPortrait
                            ? size.width * 0.037
                            : size.height * 0.044,
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
                  size: isPortrait ? size.width * 0.07 : size.height * 0.08,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          // Basic Info
          Row(
            children: [
              Icon(
                gender.toLowerCase() == "male" ? Icons.male : Icons.female,
                color: AppColors.secondary,
                size: isPortrait ? size.width * 0.04 : size.height * 0.048,
              ),
              SizedBox(width: size.width * 0.015),
              Text(
                gender,
                style: AppTextStyles.small.copyWith(
                  fontSize: isPortrait
                      ? size.width * 0.033
                      : size.height * 0.04,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Icon(
                Icons.access_time,
                color: AppColors.secondary,
                size: isPortrait ? size.width * 0.04 : size.height * 0.048,
              ),
              SizedBox(width: size.width * 0.015),
              Expanded(
                child: Text(
                  shift,
                  style: AppTextStyles.small.copyWith(
                    fontSize: isPortrait
                        ? size.width * 0.033
                        : size.height * 0.04,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.008),

          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.secondary,
                size: isPortrait ? size.width * 0.04 : size.height * 0.048,
              ),
              SizedBox(width: size.width * 0.015),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.small.copyWith(
                    fontSize: isPortrait
                        ? size.width * 0.033
                        : size.height * 0.04,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Expanded Content with Animation
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Divider(color: AppColors.border),
                SizedBox(height: size.height * 0.015),

                // Patient Details
                Text(
                  "Patient Details",
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: isPortrait
                        ? size.width * 0.04
                        : size.height * 0.048,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: size.height * 0.012),

                ...patientDetails.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${entry.key} :",
                          style: AppTextStyles.body.copyWith(
                            fontSize: isPortrait
                                ? size.width * 0.035
                                : size.height * 0.042,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.body.copyWith(
                              fontSize: isPortrait
                                  ? size.width * 0.035
                                  : size.height * 0.042,
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

                SizedBox(height: size.height * 0.02),

                // Service Details
                Text(
                  "Service Details",
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: isPortrait
                        ? size.width * 0.04
                        : size.height * 0.048,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: size.height * 0.012),

                ...serviceDetails.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.key} :",
                          style: AppTextStyles.body.copyWith(
                            fontSize: isPortrait
                                ? size.width * 0.035
                                : size.height * 0.042,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.body.copyWith(
                              fontSize: isPortrait
                                  ? size.width * 0.035
                                  : size.height * 0.042,
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

                SizedBox(height: size.height * 0.02),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.055,
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Attendance & Tasks",
                      style: AppTextStyles.button.copyWith(
                        fontSize: isPortrait
                            ? size.width * 0.038
                            : size.height * 0.045,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.055,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            name: customerName,
                            status: "Online",
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Chat with Patient",
                      style: AppTextStyles.button.copyWith(
                        fontSize: isPortrait
                            ? size.width * 0.038
                            : size.height * 0.045,
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
