import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/attendancecontroller.dart';
import 'package:qlickcare/Controllers/bookingdetailscontroller.dart';
import 'package:qlickcare/Model/bookingdetails_model.dart';
import 'package:qlickcare/Services/attendaceservice.dart';
import 'package:qlickcare/Services/locationguard.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Services/slidingservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/Drawer/Booking/bookingattendaces.dart';
import 'package:qlickcare/View/Drawer/Booking/taskstatus_widget.dart';
import 'package:qlickcare/View/listnotification.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsPage extends StatelessWidget {
  final int bookingId;
  
  BookingDetailsPage({required this.bookingId}) {
    // Initialize controllers
    final controller = Get.put(BookingDetailsController());
    final attendanceController = Get.put(AttendanceController());
    
    // Fetch data when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchBookingDetails(bookingId);
      await _fetchCaretakerLocation();
    });
  }

  // Store caretaker location as observable
  final caretakerLocation = Rxn<Map<String, double>>();
  final isLoadingLocation = false.obs;

  // Fetch caretaker location from profile
  Future<void> _fetchCaretakerLocation() async {
    isLoadingLocation.value = true;

    try {
      caretakerLocation.value = await LocationService.getCurrentCoordinates();
      debugPrint("📍 Caretaker location loaded: ${caretakerLocation.value}");
    } catch (e) {
      debugPrint("❌ Error loading caretaker location: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Open Google Maps with latitude and longitude
  Future<void> _openGoogleMaps(String? latitude, String? longitude) async {
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
      // Google Maps URL with coordinates
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingDetailsController>();
    final attendanceController = Get.find<AttendanceController>();
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: CommonAppBar(
        title: "Booking Details",
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
                MaterialPageRoute(builder: (context) => notification()),
              );
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.background,
            size: isPortrait ? size.width * 0.07 : size.height * 0.08,
          ),
        ),
      ),
      backgroundColor: AppColors.screenBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: Loading());
        }

        if (controller.booking.value == null) {
          return const Center(child: Text("No Booking Data"));
        }

        final BookingDetails b = controller.booking.value!;

        Map<int, AttendanceDayStatus> attendanceDataFromApi(BookingDetails b) {
          final Map<int, AttendanceDayStatus> data = {};

          for (final attendance in b.attendance) {
            final day = attendance.date.day;

            switch (attendance.status) {
              case "CHECKED_IN":
                data[day] = AttendanceDayStatus.checkedIn;
                break;

              case "CHECKED_OUT":
                data[day] = AttendanceDayStatus.checkedOut;
                break;

              case "ABSENT":
                data[day] = AttendanceDayStatus.absent;
                break;
              case "ON_LEAVE":
                data[day] = AttendanceDayStatus.onLeave;
                break;

              default:
                data[day] = AttendanceDayStatus.upcoming;
            }
          }

          return data;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              // Patient Information Card
              _buildPatientInfoCard(size, b, context),

              SizedBox(height: size.height * 0.02),

              // Customer Contact Card
              _buildCustomerContactCard(size, b),

              SizedBox(height: size.height * 0.02),

              // Booking Period Card
              _buildBookingPeriodCard(size, b),

              SizedBox(height: size.height * 0.02),

              // Attendance Summary Card
              if (b.attendanceSummary != null)
                EnhancedAttendanceSummary(booking: b),
              SizedBox(height: size.height * 0.03),

              // Today's Tasks
              Text(
                "Today's Tasks",
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: size.height * 0.015),
              buildCaretakerStatusMessage(b),
              _buildTaskList(size, b.todos, controller.isOnLeaveToday, b.endDate, controller),

              SizedBox(height: size.height * 0.03),

              // Attendance Calendar
              Text(
                "Attendance Calendar",
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: size.height * 0.015),

              AttendanceCalendar(
                startDate: DateTime.parse(b.startDate),
                endDate: DateTime.parse(b.endDate),
                attendanceData: attendanceDataFromApi(b),
              ),

              SizedBox(height: size.height * 0.03),

              // Check-in/Check-out Slider with Location Check
              _buildAttendanceSlider(size, b, controller, attendanceController),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAttendanceSlider(
    Size size,
    BookingDetails b,
    BookingDetailsController controller,
    AttendanceController attendanceController,
  ) {
    return Obx(() {
      final bool isCheckedOut = controller.isCheckedOutToday;
      final bool isleaveToday = controller.isOnLeaveToday;

      if (isCheckedOut) {
        return Center(
          child: Text(
            "Attendance completed for today",
            style: AppTextStyles.small.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      if (isleaveToday) {
        return Center(
          child: Text(
            "You are on leave today",
            style: AppTextStyles.small.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      if (b.endDate.isNotEmpty && isBookingCompleted(b.endDate)) {
        return Center(
          child: Text(
            "Booking period is completed",
            style: AppTextStyles.small.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      // Parse booking coordinates
      double? bookingLat;
      double? bookingLng;

      try {
        if (b.latitude.isNotEmpty && b.longitude.isNotEmpty) {
          bookingLat = double.parse(b.latitude);
          bookingLng = double.parse(b.longitude);
        }
      } catch (e) {
        debugPrint("❌ Error parsing booking coordinates: $e");
      }

      // Check if booking coordinates are available
      if (bookingLat == null || bookingLng == null) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off, color: AppColors.error, size: 32),
                SizedBox(height: 8),
                Text(
                  "Location not available for this booking",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Wrap AttendanceSlideButton with LocationGuard
      return LocationGuard(
        targetLatitude: bookingLat,
        targetLongitude: bookingLng,
        radiusInMeters: 1000000.0, // Adjust as needed
        showDistance: true,
        autoRefresh: false, // Set to true if you want periodic location updates
        refreshIntervalSeconds: 30,
        onLocationStatusChanged: (isWithinRange, distance) {
          debugPrint("Location status: $isWithinRange, Distance: $distance");
        },
        child: AttendanceSlideButton(
          isCheckedIn: controller.isCheckedInToday,
          onCheckIn: () async {
            await attendanceController.handleCheckIn(bookingId);
            await controller.fetchBookingDetails(bookingId);
          },
          onCheckOut: () async {
            await attendanceController.handleCheckOut(bookingId);
            await controller.fetchBookingDetails(bookingId);
          },
        ),
      );
    });
  }

  // Patient Information Card
  Widget _buildPatientInfoCard(Size size, BookingDetails b, BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Patient Information",
                style: AppTextStyles.heading2.copyWith(
                  fontSize: size.width * 0.04,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),

          Text(
            "${b.patientName}, ${b.age}, BOOKING ID${b.id}",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.05,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          Wrap(
            spacing: size.width * 0.02,
            runSpacing: size.height * 0.01,
            children: [
              if (b.patientCondition.isNotEmpty)
                _infoChip(
                  size,
                  b.patientCondition,
                  AppColors.error.withOpacity(0.1),
                  AppColors.error,
                ),
              if (b.workType.isNotEmpty)
                _infoChip(
                  size,
                  b.workType,
                  AppColors.success.withOpacity(0.1),
                  AppColors.success,
                ),
              if (b.mobilityLevel.isNotEmpty)
                _infoChip(
                  size,
                  b.mobilityLevel,
                  Colors.blue.withOpacity(0.1),
                  Colors.blue,
                ),
            ],
          ),

          SizedBox(height: size.height * 0.015),

          if (b.gender.isNotEmpty)
            _buildInfoRow(size, FontAwesomeIcons.venusMars, "Gender", b.gender),

          // Address with Google Maps button
          if (b.address.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.locationDot,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    "Address: ",
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b.address,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Google Maps button
                  if (b.latitude.isNotEmpty && b.longitude.isNotEmpty)
                    InkWell(
                      onTap: () => _openGoogleMaps(b.latitude, b.longitude),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.mapLocationDot,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          if (b.pincode.isNotEmpty)
            _buildInfoRow(size, FontAwesomeIcons.mapPin, "Pincode", b.pincode),
          if (b.aadharNumber.isNotEmpty)
            _buildInfoRow(
              size,
              FontAwesomeIcons.idCard,
              "Aadhar",
              b.aadharNumber,
            ),

          // Aadhar Image Section
          if (b.aadharImage != null && b.aadharImage!.isNotEmpty) ...[
            SizedBox(height: size.height * 0.015),
            Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)),
            SizedBox(height: size.height * 0.015),

            Text(
              "Aadhar Document",
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height * 0.01),

            GestureDetector(
              onTap: () {
                // Show full screen image
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        Center(
                          child: InteractiveViewer(
                            child: Image.network(
                              b.aadharImage!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: AppColors.error,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Failed to load image",
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
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
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: size.height * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    b.aadharImage!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: Loading());
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 40,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Failed to load image",
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              "Tap to view full image",
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                fontSize: size.width * 0.03,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Customer Contact Card
  Widget _buildCustomerContactCard(Size size, BookingDetails b) {
    // Check if any customer data exists
    final hasCustomerData =
        b.customerName.isNotEmpty ||
        b.customerPhone.isNotEmpty ||
        b.customerEmail.isNotEmpty;

    if (!hasCustomerData) return SizedBox.shrink();

    return Container(
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
          Text(
            "Customer Contact",
            style: AppTextStyles.heading2.copyWith(
              fontSize: size.width * 0.04,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          if (b.customerName.isNotEmpty)
            _buildInfoRow(size, FontAwesomeIcons.user, "Name", b.customerName),
          if (b.customerPhone.isNotEmpty)
            _buildInfoRow(
              size,
              FontAwesomeIcons.phone,
              "Phone",
              b.customerPhone,
            ),
          if (b.customerEmail.isNotEmpty)
            _buildInfoRow(
              size,
              FontAwesomeIcons.envelope,
              "Email",
              b.customerEmail,
            ),
        ],
      ),
    );
  }

  // Booking Period Card
  Widget _buildBookingPeriodCard(Size size, BookingDetails b) {
    if (b.startDate.isEmpty || b.endDate.isEmpty) {
      return SizedBox.shrink();
    }

    try {
      final startDate = DateTime.parse(b.startDate);
      final endDate = DateTime.parse(b.endDate);
      final duration = endDate.difference(startDate).inDays + 1;

      return Container(
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
            Text(
              "Booking Period",
              style: AppTextStyles.heading2.copyWith(
                fontSize: size.width * 0.04,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: size.height * 0.015),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start Date",
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(startDate),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "End Date",
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(endDate),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.01),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Duration: $duration days",
                style: AppTextStyles.body.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error parsing dates: $e");
      return SizedBox.shrink();
    }
  }

  bool isBookingCompleted(String endDateStr) {
    try {
      final endDate = DateTime.parse(endDateStr);
      final today = DateTime.now();

      // Compare only date (remove time)
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final now = DateTime(today.year, today.month, today.day);

      return end.isBefore(now);
    } catch (e) {
      debugPrint("Date parse error: $e");
      return false;
    }
  }

  Widget _buildInfoRow(Size size, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          SizedBox(width: size.width * 0.02),
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

  Widget _infoChip(Size size, String text, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
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

  
Widget _buildTaskList(
    Size size,
    List<TodoItem> todos,
    bool isOnLeaveToday,
    String endDate,
    BookingDetailsController controller,
  ) {
    // Disable actions if on leave or booking is completed
    final bool disableActions = isOnLeaveToday || isBookingCompleted(endDate);

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
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFEAEAEA)),
        itemBuilder: (context, index) {
          final task = todos[index];
          final bool isCompleted = task.isCompleted;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      onTap: disableActions
                          ? null
                          : () {
                              controller.updateTodoStatus(
                                task.id,
                                !task.isCompleted,
                              );
                            },
                      child: Opacity(
                        opacity: disableActions ? 0.4 : 1.0,
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
