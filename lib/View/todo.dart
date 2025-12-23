import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/attendancecontroller.dart';
import 'package:qlickcare/Controllers/bookingcontroller.dart';
import 'package:qlickcare/Controllers/bookingdetailscontroller.dart';
import 'package:qlickcare/Controllers/Model/bookingdetails_model.dart';
import 'package:qlickcare/Services/attendaceservice.dart';
import 'package:qlickcare/Services/slidingservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';

import 'package:qlickcare/View/Drawer/drawer.dart';
import 'package:qlickcare/View/listnotification.dart';
import 'package:slide_to_act/slide_to_act.dart';

// Controller to handle slide action state

class todo extends StatefulWidget {
  const todo({super.key});

  @override
  State<todo> createState() => _todoState();
}

class _todoState extends State<todo> {
  final BookingController bookingController = Get.put(BookingController());
  final BookingDetailsController detailsController = Get.put(
    BookingDetailsController(),
  );
  final AttendanceController attendanceController = Get.put(
    AttendanceController(),
  );

  final RxInt selectedBookingId = 0.obs;
  final RxBool isExpanded = false.obs;

  // Dummy attendance data - replace with real data from API
  final Map<int, bool> attendanceData = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: false,
    8: true,
  };

  @override
  void initState() {
    super.initState();
    bookingController.fetchBookings();

    // Auto-select first booking when data loads
    ever(bookingController.bookings, (bookings) {
      if (bookings.isNotEmpty && selectedBookingId.value == 0) {
        selectedBookingId.value = bookings.first.id;
        detailsController.fetchBookingDetails(bookings.first.id);
      }
    });
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
        title: "Tasks",
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                FontAwesomeIcons.bars,
                color: Colors.white,
                size: isPortrait ? size.width * 0.055 : size.height * 0.065,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.bell,
              color: Colors.white,
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
      ),
      body: Obx(() {
        if (bookingController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        }

        if (bookingController.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: isPortrait ? size.width * 0.2 : size.height * 0.25,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  "No Patients Assigned",
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

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

              // Patient Selection Dropdown Card
              _buildPatientSelectionCard(size, isPortrait),

              SizedBox(height: size.height * 0.03),

              // Show selected patient's details
              Obx(() {
                if (detailsController.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(size.height * 0.05),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (detailsController.booking.value == null) {
                  return SizedBox.shrink();
                }

                final booking = detailsController.booking.value!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Tasks Header
                    Text(
                      "Today's Tasks",
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: isPortrait
                            ? size.width * 0.045
                            : size.height * 0.055,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: size.height * 0.015),

                    // Task List
                    _buildTaskList(size, booking.todos),

                    SizedBox(height: size.height * 0.03),

                    // Monthly Attendance Card
                    AttendanceCalendar(
                      startDate: DateTime.parse(booking.startDate),
                      endDate: DateTime.parse(booking.endDate),
                      attendanceData: attendanceDataFromApi(booking),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Slide to Check-In/Out
                    AttendanceSlideButton(
                      isCheckedIn: detailsController.isCheckedInToday,
                      onCheckIn: () async {
                        await attendanceController.handleCheckIn();
                        await detailsController.fetchBookingDetails(
                          selectedBookingId.value,
                        );
                      },
                      onCheckOut: () async {
                        await attendanceController.handleCheckOut();
                        await detailsController.fetchBookingDetails(
                          selectedBookingId.value,
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPatientSelectionCard(Size size, bool isPortrait) {
    return Obx(() {
      final selectedBooking = bookingController.bookings.firstWhereOrNull(
        (b) => b.id == selectedBookingId.value,
      );

      if (selectedBooking == null) return SizedBox.shrink();

      return Container(
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
          children: [
            // Selected Patient Display
            InkWell(
              onTap: () {
                isExpanded.value = !isExpanded.value;
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${selectedBooking.patientName}, ${selectedBooking.age ?? 'N/A'}",
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: isPortrait
                                  ? size.width * 0.045
                                  : size.height * 0.055,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Obx(
                          () => Icon(
                            isExpanded.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    Wrap(
                      spacing: size.width * 0.02,
                      runSpacing: size.height * 0.008,
                      children: [
                        _infoChip(
                          size,
                          isPortrait,
                          selectedBooking.customerName ?? "N/A",
                          AppColors.error.withOpacity(0.1),
                          AppColors.error,
                        ),
                        _infoChip(
                          size,
                          isPortrait,
                          selectedBooking.workType ?? "Day Shift",
                          AppColors.success.withOpacity(0.1),
                          AppColors.success,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      children: [
                        Icon(
                          selectedBooking.gender?.toLowerCase() == "male"
                              ? Icons.male
                              : Icons.female,
                          size: isPortrait
                              ? size.width * 0.04
                              : size.height * 0.048,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          selectedBooking.gender ?? "N/A",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Icon(
                          FontAwesomeIcons.locationDot,
                          size: isPortrait
                              ? size.width * 0.035
                              : size.height * 0.042,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Expanded(
                          child: Text(
                            selectedBooking.address ?? "Location not specified",
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Patient List (when expanded)
            Obx(() {
              if (!isExpanded.value) return SizedBox.shrink();

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: bookingController.bookings.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final booking = bookingController.bookings[index];
                    final isSelected = booking.id == selectedBookingId.value;

                    return InkWell(
                      onTap: () {
                        selectedBookingId.value = booking.id;
                        detailsController.fetchBookingDetails(booking.id);
                        isExpanded.value = false;
                      },
                      child: Container(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.015,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${booking.patientName}, ${booking.age ?? 'N/A'}",
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.004),
                                  Text(
                                    booking.workType ?? "N/A",
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: isPortrait
                                    ? size.width * 0.05
                                    : size.height * 0.06,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _infoChip(
    Size size,
    bool isPortrait,
    String text,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.height * 0.006,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          fontSize: isPortrait ? size.width * 0.03 : size.height * 0.036,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _buildTaskList(Size size, List<TodoItem> todos) {
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
                      onTap: () {
                        detailsController.updateTodoStatus(
                          task.id,
                          !task.isCompleted, // 👈 toggle
                        );
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
