import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/attendance/controller/attendancecontroller.dart';
import 'package:qlickcare/bookings/controller/bookingcontroller.dart';
import 'package:qlickcare/bookings/controller/bookingdetailscontroller.dart';
import 'package:qlickcare/bookings/service/attendaceservice.dart';
import 'package:qlickcare/bookings/service/locationguard.dart';
import 'package:qlickcare/bookings/service/slidingservice.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Drawer/drawer.dart';
import 'package:qlickcare/notification/views/listnotification.dart';
import 'package:qlickcare/bookings/model/bookingdetails_model.dart';
import 'package:qlickcare/bookings/view/Details/taskstatus_widget.dart';

class todo extends StatefulWidget {
  const todo({super.key});

  @override
  State<todo> createState() => _todoState();
}

class _todoState extends State<todo> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final bookingController = Get.find<BookingController>();
  final detailsController = Get.find<BookingDetailsController>();
  final attendanceController = Get.find<AttendanceController>();

  final RxInt selectedBookingId = 0.obs;
  final RxBool isExpanded = false.obs;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    
    print("📋 Todo Page initState");
    
    // ✅ Initialize immediately if bookings already exist
    if (bookingController.bookings.isNotEmpty) {
      _initializeFirstBooking();
    } else {
      // ✅ Wait for bookings to load, then initialize
      ever(bookingController.bookings, (bookings) {
        if (bookings.isNotEmpty && !_hasInitialized) {
          _initializeFirstBooking();
        }
      });
      
      // ✅ Fetch if empty
      if (!bookingController.isLoading.value) {
        bookingController.fetchOngoingBookings();
      }
    }
  }

  // ✅ Separate initialization method
  void _initializeFirstBooking() {
    if (_hasInitialized) return;
    
    _hasInitialized = true;
    final firstBooking = bookingController.bookings.first;
    
    print("✅ Auto-selecting first booking: ${firstBooking.id}");
    
    selectedBookingId.value = firstBooking.id;
    
    // ✅ Add small delay to ensure UI is ready
    Future.delayed(Duration.zero, () {
      detailsController.fetchBookingDetails(firstBooking.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      appBar: CommonAppBar(
        title: "My Tasks",
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(FontAwesomeIcons.bars, color: AppColors.background, size: 22),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.bell, color: AppColors.background, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => notification()),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // ✅ Show skeleton while bookings are loading
        if (bookingController.isLoading.value) {
          return _buildSkeletonUI();
        }

        if (bookingController.bookings.isEmpty) {
          return _buildEmptyState();
        }

        return _buildMainContent();
      }),
    );
  }

  // ✅ FIXED: Skeleton UI without overflow
  Widget _buildSkeletonUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Card Skeleton
          Container(
            height: 140,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tasks Skeleton
          Container(
            height: 60,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            height: 200,
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
          ),
          
          const SizedBox(height: 24),
          
          // Calendar Skeleton
          Container(
            height: 300,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No Patients Assigned",
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Selection Card
          _buildPatientSelectionCard(),

          const SizedBox(height: 24),

          // Booking Details
          Obx(() => _buildBookingDetails()),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    // ✅ Show loading skeleton while details are fetching
    if (detailsController.isLoading.value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
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
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
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
          ),
        ],
      );
    }

    if (detailsController.booking.value == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            "Select a patient to view tasks",
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final booking = detailsController.booking.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Tasks Header
        Text(
          "Today's Tasks",
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        buildCaretakerStatusMessage(booking),

        // Task List
        _buildTaskList(
          booking.todos,
          detailsController.isOnLeaveToday,
          booking.endDate,
          detailsController,
        ),

        const SizedBox(height: 24),

        // Monthly Attendance Card
        AttendanceCalendar(
          startDate: DateTime.parse(booking.startDate),
          endDate: DateTime.parse(booking.endDate),
          attendanceData: _attendanceDataFromApi(booking),
          reassignmentPeriods: booking.myReassignmentPeriods,
        ),

        const SizedBox(height: 24),

        _buildAttendanceSection(booking),

        const SizedBox(height: 16),
      ],
    );
  }

  Map<int, AttendanceDayStatus> _attendanceDataFromApi(BookingDetails booking) {
    final Map<int, AttendanceDayStatus> data = {};

    for (final attendance in booking.attendance) {
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

  Widget _buildAttendanceSection(BookingDetails booking) {
    if (detailsController.isCheckedOutToday) {
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

    if (detailsController.isOnLeaveToday) {
      return Center(
        child: Text(
          "You are on leave today",
          style: AppTextStyles.small.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (booking.endDate.isNotEmpty && _isBookingCompleted(booking.endDate)) {
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

    double? bookingLat;
    double? bookingLng;

    try {
      if (booking.latitude.isNotEmpty && booking.longitude.isNotEmpty) {
        bookingLat = double.parse(booking.latitude);
        bookingLng = double.parse(booking.longitude);
      }
    } catch (e) {
      debugPrint("❌ Location parse error: $e");
    }

    if (bookingLat == null || bookingLng == null) {
      return Center(
        child: Text(
          "Location not available for this booking",
          style: AppTextStyles.small.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return LocationGuard(
      targetLatitude: bookingLat,
      targetLongitude: bookingLng,
      radiusInMeters: 500.0,
      showDistance: true,
      autoRefresh: false,
      refreshIntervalSeconds: 30,
      onLocationStatusChanged: (isWithinRange, distance) {
        debugPrint("📍 Todo Page → withinRange: $isWithinRange | distance: $distance");
      },
      child: AttendanceSlideButton(
        isCheckedIn: detailsController.isCheckedInToday,
        onCheckIn: () async {
          await attendanceController.handleCheckIn(booking.id);
          await detailsController.fetchBookingDetails(selectedBookingId.value);
        },
        onCheckOut: () async {
          await attendanceController.handleCheckOut(booking.id);
          await detailsController.fetchBookingDetails(selectedBookingId.value);
        },
      ),
    );
  }

  bool _isBookingCompleted(String endDateStr) {
    try {
      final endDate = DateTime.parse(endDateStr);
      final today = DateTime.now();

      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final now = DateTime(today.year, today.month, today.day);

      return end.isBefore(now);
    } catch (e) {
      debugPrint("Date parse error: $e");
      return false;
    }
  }

  Widget _buildPatientSelectionCard() {
    return Obx(() {
      final selectedBooking = bookingController.bookings.firstWhereOrNull(
        (b) => b.id == selectedBookingId.value,
      );

      if (selectedBooking == null) {
        // ✅ Fallback: Select first booking if none selected
        if (bookingController.bookings.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            selectedBookingId.value = bookingController.bookings.first.id;
          });
        }
        return SizedBox.shrink();
      }

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
              onTap: () => isExpanded.value = !isExpanded.value,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Obx(
                          () => Icon(
                            isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip(
                          selectedBooking.customerName ?? "N/A",
                          AppColors.error.withOpacity(0.1),
                          AppColors.error,
                        ),
                        _infoChip(
                          selectedBooking.workType ?? "Day Shift",
                          AppColors.success.withOpacity(0.1),
                          AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          selectedBooking.gender?.toLowerCase() == "male" ? Icons.male : Icons.female,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedBooking.gender ?? "N/A",
                          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          FontAwesomeIcons.locationDot,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedBooking.address ?? "Location not specified",
                            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
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
              return _buildPatientList();
            }),
          ],
        ),
      );
    });
  }

  Widget _buildPatientList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: bookingController.bookings.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border),
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
              color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${booking.patientName}, ${booking.age ?? 'N/A'}",
                          style: AppTextStyles.body.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.workType ?? "N/A",
                          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    List<TodoItem> todos,
    bool isOnLeaveToday,
    String endDate,
    detailsController,
  ) {
    final booking = detailsController.booking.value;

    final bool disableActions = isOnLeaveToday ||
        _isBookingCompleted(endDate) ||
        detailsController.isCheckedOutToday ||
        (booking?.bookingStatus.toUpperCase() == "CANCELED") ||
        (booking?.bookingStatus.toUpperCase() == "PENDING") ||
        (booking?.bookingStatus.toUpperCase() == "WORK_COMPLETED");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (disableActions)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Task actions are disabled.",
              style: AppTextStyles.small.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        Container(
          padding: const EdgeInsets.all(16),
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
          child: todos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "No tasks for today",
                      style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEAEAEA)),
                  itemBuilder: (context, index) {
                    final task = todos[index];
                    final bool isCompleted = task.isCompleted;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.text ?? "No Task",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
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
                                    : () {
                                        detailsController.updateTodoStatus(
                                          task.id,
                                          !task.isCompleted,
                                        );
                                      },
                                child: Opacity(
                                  opacity: disableActions ? 0.4 : 1.0,
                                  child: Icon(
                                    isCompleted ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circle,
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
        ),
      ],
    );
  }
}