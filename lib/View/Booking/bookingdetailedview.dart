import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/attendancecontroller.dart';
import 'package:qlickcare/Controllers/bookingdetailscontroller.dart';
import 'package:qlickcare/Controllers/Model/bookingdetails_model.dart';
import 'package:qlickcare/Services/attendaceservice.dart';
import 'package:qlickcare/Services/slidingservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/listnotification.dart';

import 'package:slide_to_act/slide_to_act.dart';

class BookingDetailsPage extends StatefulWidget {
  final int bookingId;
  BookingDetailsPage({required this.bookingId});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final BookingDetailsController controller = Get.put(
    BookingDetailsController(),
  );

  final AttendanceController attendanceController = Get.put(
    AttendanceController(),
  );

  @override
  void initState() {
    super.initState();
    // 👇 Call fetchBookingDetails ONCE when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBookingDetails(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 👇 REMOVE this line - don't call it in build!
    // controller.fetchBookingDetails(bookingId);

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

              _buildPatientInfoCard(size, b),

              SizedBox(height: size.height * 0.03),

              Text(
                "Today's Tasks",
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: size.height * 0.015),

              _buildTaskList(size, b.todos),

              SizedBox(height: size.height * 0.03),

              AttendanceCalendar(
                startDate: DateTime.parse(b.startDate),
                endDate: DateTime.parse(b.endDate),
                attendanceData: attendanceDataFromApi(b),
              ),

              SizedBox(height: size.height * 0.03),

              Obx(() {
                final bool isCheckedIn = controller.isCheckedInToday;
                final bool isCheckedOut = controller.isCheckedOutToday;

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

                return AttendanceSlideButton(
                  isCheckedIn: controller.isCheckedInToday,
                  onCheckIn: () async {
                    await attendanceController.handleCheckIn();
                    await controller.fetchBookingDetails(widget.bookingId);
                  },
                  onCheckOut: () async {
                    await attendanceController.handleCheckOut();
                    await controller.fetchBookingDetails(widget.bookingId);
                  },
                );
              }),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        );
      }),
    );
  }

  

  Widget _buildPatientInfoCard(Size size, BookingDetails b) {
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
                "${b.patientName}, ${b.age}",
                style: AppTextStyles.heading2.copyWith(
                  fontSize: size.width * 0.045,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.005),

          Wrap(
            spacing: size.width * 0.02,
            runSpacing: size.height * 0.01,
            children: [
              _infoChip(
                size,
                b.patientCondition,
                AppColors.background,
                AppColors.error,
              ),
              _infoChip(
                size,
                b.workType,
                AppColors.background,
                AppColors.success,
              ),
            ],
          ),

          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.venusMars,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: size.width * 0.01),
              Text(
                b.gender,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              const Icon(
                FontAwesomeIcons.locationDot,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: size.width * 0.01),
              Text(
                b.address,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(Size size, String text, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: 4,
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
                        controller.updateTodoStatus(
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
