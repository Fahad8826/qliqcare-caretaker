import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import 'package:qlickcare/bookings/model/bookingdetails_model.dart';

class BookingDetailsController extends GetxController {
  final isLoading = false.obs;
  final booking = Rxn<BookingDetails>();

  /// 🔒 Internal fetch lock (prevents parallel API calls)
  bool _isFetching = false;

  /// 📦 Cache to avoid refetching same booking
  final Map<int, BookingDetails> _cache = {};

  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/bookings";

  // =====================================================
  // FETCH BOOKING DETAILS (SAFE, SINGLE-FLIGHT)
  // =====================================================
  Future<void> fetchBookingDetails(
    int bookingId, {
    bool forceRefresh = false,
  }) async {
    // 🔒 Block parallel calls
    if (_isFetching) {
      debugPrint("⏭️ Skipping booking fetch (already in progress)");
      return;
    }

    // 📦 Serve cached data if available
    if (!forceRefresh && _cache.containsKey(bookingId)) {
      booking.value = _cache[bookingId];
      debugPrint("📦 Booking loaded from cache: $bookingId");
      return;
    }

    _isFetching = true;
    isLoading.value = true;

    try {
      final url = "$baseUrl/$bookingId/";
      debugPrint("📡 Fetching booking details from: $url");

      final response = await ApiService.request((token) {
        return http.get(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      debugPrint("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsed = BookingDetails.fromJson(data);

        booking.value = parsed;
        _cache[bookingId] = parsed;

        debugPrint("✅ Booking details loaded successfully");
      } else if (response.statusCode == 404) {
        showSnackbarSafe("Not Found", "Booking not found");
      } else {
        showSnackbarSafe(
          "Error",
          "Failed to load booking details (${response.statusCode})",
        );
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Booking fetch error: $e");
      debugPrint("❌ Stack trace: $stackTrace");

      showSnackbarSafe(
        "Network Error",
        "Unable to load booking details",
      );
    } finally {
      _isFetching = false;
      isLoading.value = false;
    }
  }

  // =====================================================
  // UPDATE TODO STATUS (NO REFETCH)
  // =====================================================
  Future<void> updateTodoStatus(int todoId, bool isCompleted) async {
    try {
      final response = await ApiService.request((token) {
        return http.patch(
          Uri.parse(
            "${dotenv.env['BASE_URL']}/api/caretaker/todos/$todoId/",
          ),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "is_completed": isCompleted,
          }),
        );
      });

      if (response.statusCode == 200 && booking.value != null) {
        final index =
            booking.value!.todos.indexWhere((t) => t.id == todoId);

        if (index != -1) {
          booking.value!.todos[index].isCompleted = isCompleted;
          booking.refresh();
        }

        showSnackbarSafe(
          "Success",
          isCompleted ? "Task completed" : "Task marked incomplete",
        );
      } else {
        showSnackbarSafe("Error", "Failed to update task");
      }
    } catch (e) {
      debugPrint("❌ Error updating todo: $e");
      showSnackbarSafe("Error", "Failed to update task");
    }
  }

  // =====================================================
  // SAFE REFRESH (MANUAL ONLY)
  // =====================================================
  Future<void> refreshBooking() async {
    if (booking.value != null) {
      await fetchBookingDetails(
        booking.value!.id,
        forceRefresh: true,
      );
    }
  }

  // =====================================================
  // CLEANUP
  // =====================================================
  void clearData() {
    booking.value = null;
    _cache.clear();
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }

  // =====================================================
  // GETTERS (UNCHANGED LOGIC)
  // =====================================================
  bool get isCheckedInToday =>
      booking.value?.todayAttendance?.status == 'CHECKED_IN';

  bool get isCheckedOutToday =>
      booking.value?.todayAttendance?.status == 'CHECKED_OUT';

  bool get isOnLeaveToday =>
      booking.value?.todayAttendance?.status == 'ON_LEAVE';

  bool get canCheckIn => booking.value?.canCheckIn ?? false;
  bool get canCheckOut => booking.value?.canCheckOut ?? false;

  String get bookingStatus => booking.value?.bookingStatus ?? '';

  int? get activeSessionNumber =>
      booking.value?.todayAttendance?.activeSession;

  double get todayHoursWorked =>
      booking.value?.todayAttendance?.totalHoursToday ?? 0.0;

  int get todayTotalSessions =>
      booking.value?.todayAttendance?.totalSessions ?? 0;

  double get attendanceRate =>
      booking.value?.attendanceSummary?.attendanceRate ?? 0.0;

  int get totalDaysWorked =>
      booking.value?.attendanceSummary?.daysWorked ?? 0;

  int get totalAbsentDays =>
      booking.value?.attendanceSummary?.absentDays ?? 0;

  int get totalLeaveDays =>
      booking.value?.attendanceSummary?.leaveDays ?? 0;

  double get totalHoursWorked =>
      booking.value?.attendanceSummary?.totalHours ?? 0.0;

  int get completedSessions =>
      booking.value?.attendanceSummary?.completedSessions ?? 0;

  int get activeSessions =>
      booking.value?.attendanceSummary?.activeSessions ?? 0;

  int get daysRemaining => booking.value?.daysRemaining ?? 0;
  int get daysElapsed => booking.value?.daysElapsed ?? 0;

  String get patientName => booking.value?.patientName ?? '';
  String get patientCondition => booking.value?.patientCondition ?? '';
  String get mobilityLevel => booking.value?.mobilityLevel ?? '';

  String? get caretakerName => booking.value?.caretakerName;
  String? get caretakerPhone => booking.value?.caretakerPhone;
}
