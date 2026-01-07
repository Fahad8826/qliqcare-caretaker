import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Model/bookingdetails_model.dart';
import 'package:qlickcare/Services/tokenexpireservice.dart';
import 'package:qlickcare/Utils/appcolors.dart';

class BookingDetailsController extends GetxController {
  final isLoading = false.obs;
  final booking = Rxn<BookingDetails>();

  String get baseUrl => "${dotenv.env['BASE_URL']}/api/caretaker/bookings";

  /// Fetch booking details by ID
  // Future<void> fetchBookingDetails(int bookingId) async {
  //   isLoading.value = true;

  //   try {
  //     final token = await TokenService.getAccessToken();

  //     if (token == null || token.isEmpty) {
  //       Get.snackbar(
  //         "Error",
  //         "Authentication token not found. Please login again.",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //       return;
  //     }

  //     final url = "$baseUrl/$bookingId/";
  //     debugPrint("📡 Fetching booking details from: $url");

  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     debugPrint("📥 Response status: ${response.statusCode}");

  //     if (response.statusCode == 200) {
  //       try {
  //         final data = jsonDecode(response.body);
  //         debugPrint("✅ JSON decoded successfully");
  //         debugPrint("📊 Booking ID: ${data['id']}");
          
  //         booking.value = BookingDetails.fromJson(data);
  //         debugPrint("✅ Booking details loaded successfully");
  //       } catch (parseError, stackTrace) {
  //         debugPrint("❌ Parse Error: $parseError");
  //         debugPrint("❌ Stack trace: $stackTrace");
  //         debugPrint("📄 Response body: ${response.body}");
          
  //         Get.snackbar(
  //           "Parse Error",
  //           "Failed to parse booking data: $parseError",
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: AppColors.error,
  //           colorText: AppColors.background,
  //           duration: const Duration(seconds: 5),
  //         );
  //       }
  //     } else if (response.statusCode == 404) {
  //       Get.snackbar(
  //         "Not Found",
  //         "Booking not found",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //     } else if (response.statusCode == 401) {
  //       Get.snackbar(
  //         "Unauthorized",
  //         "Session expired. Please login again.",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //     } else {
  //       Get.snackbar(
  //         "Error",
  //         "Failed to load booking details (${response.statusCode})",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint("❌ Exception: $e");
  //     debugPrint("❌ Stack trace: $stackTrace");
      
  //     Get.snackbar(
  //       "Error",
  //       "Network error: ${e.toString()}",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: AppColors.error,
  //       colorText: AppColors.background,
  //       duration: const Duration(seconds: 5),
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> fetchBookingDetails(int bookingId) async {
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
      try {
        final data = jsonDecode(response.body);
        booking.value = BookingDetails.fromJson(data);
        debugPrint("✅ Booking details loaded successfully");
      } catch (parseError, stackTrace) {
        debugPrint("❌ Parse Error: $parseError");
        debugPrint("❌ Stack trace: $stackTrace");

        Get.snackbar(
          "Parse Error",
          "Failed to parse booking data",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.background,
        );
      }
    } else if (response.statusCode == 404) {
      Get.snackbar(
        "Not Found",
        "Booking not found",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.background,
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to load booking details (${response.statusCode})",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.background,
      );
    }
  } catch (e, stackTrace) {
    debugPrint("❌ Exception: $e");
    debugPrint("❌ Stack trace: $stackTrace");

    Get.snackbar(
      "Error",
      "Network error: ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.background,
    );
  } finally {
    isLoading.value = false;
  }
}


  /// Update todo item completion status
  // Future<void> updateTodoStatus(int todoId, bool isCompleted) async {
  //   try {
  //     final token = await TokenService.getAccessToken();

  //     if (token == null || token.isEmpty) {
  //       Get.snackbar(
  //         "Error",
  //         "Authentication required",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //       return;
  //     }

  //     final response = await http.patch(
  //       Uri.parse("${dotenv.env['BASE_URL']}/api/caretaker/todos/$todoId/"),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "is_completed": isCompleted,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       // Update local state
  //       if (booking.value != null) {
  //         final todoIndex = booking.value!.todos.indexWhere((t) => t.id == todoId);
  //         if (todoIndex != -1) {
  //           booking.value!.todos[todoIndex].isCompleted = isCompleted;
  //           booking.refresh();
  //         }
  //       }

  //       Get.snackbar(
  //         "Success",
  //         isCompleted ? "Task completed" : "Task marked incomplete",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.success,
  //         colorText: AppColors.background,
  //       );
  //     } else {
  //       Get.snackbar(
  //         "Error",
  //         "Failed to update task",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppColors.error,
  //         colorText: AppColors.background,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error updating todo: $e");
  //     Get.snackbar(
  //       "Error",
  //       "Failed to update task: ${e.toString()}",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: AppColors.error,
  //       colorText: AppColors.background,
  //     );
  //   }
  // }
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

    if (response.statusCode == 200) {
      if (booking.value != null) {
        final index =
            booking.value!.todos.indexWhere((t) => t.id == todoId);
        if (index != -1) {
          booking.value!.todos[index].isCompleted = isCompleted;
          booking.refresh();
        }
      }

      Get.snackbar(
        "Success",
        isCompleted ? "Task completed" : "Task marked incomplete",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.background,
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to update task",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.background,
      );
    }
  } catch (e) {
    debugPrint("❌ Error updating todo: $e");
    Get.snackbar(
      "Error",
      "Failed to update task",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.background,
    );
  }
}


  /// Getters for convenient access to booking data
  bool get isCheckedInToday {
    if (booking.value?.todayAttendance == null) return false;
    return booking.value!.todayAttendance!.status == 'CHECKED_IN';
  }

  bool get isCheckedOutToday {
    if (booking.value?.todayAttendance == null) return false;
    return booking.value!.todayAttendance!.status == 'CHECKED_OUT';
  }

  bool get isOnLeaveToday {
    if (booking.value?.todayAttendance == null) return false;
    return booking.value!.todayAttendance!.status == 'ON_LEAVE';
  }

  bool get canCheckIn {
    return booking.value?.canCheckIn ?? false;
  }

  bool get canCheckOut {
    return booking.value?.canCheckOut ?? false;
  }

  String get bookingStatus {
    return booking.value?.bookingStatus ?? '';
  }

  int? get activeSessionNumber {
    return booking.value?.todayAttendance?.activeSession;
  }

  double get todayHoursWorked {
    return booking.value?.todayAttendance?.totalHoursToday ?? 0.0;
  }

  int get todayTotalSessions {
    return booking.value?.todayAttendance?.totalSessions ?? 0;
  }

  // Attendance summary getters
  double get attendanceRate {
    return booking.value?.attendanceSummary?.attendanceRate ?? 0.0;
  }

  int get totalDaysWorked {
    return booking.value?.attendanceSummary?.daysWorked ?? 0;
  }

  int get totalAbsentDays {
    return booking.value?.attendanceSummary?.absentDays ?? 0;
  }

  int get totalLeaveDays {
    return booking.value?.attendanceSummary?.leaveDays ?? 0;
  }

  double get totalHoursWorked {
    return booking.value?.attendanceSummary?.totalHours ?? 0.0;
  }

  int get completedSessions {
    return booking.value?.attendanceSummary?.completedSessions ?? 0;
  }

  int get activeSessions {
    return booking.value?.attendanceSummary?.activeSessions ?? 0;
  }

  // Booking progress getters
  int get daysRemaining {
    return booking.value?.daysRemaining ?? 0;
  }

  int get daysElapsed {
    return booking.value?.daysElapsed ?? 0;
  }

  // Patient info getters
  String get patientName {
    return booking.value?.patientName ?? '';
  }

  String get patientCondition {
    return booking.value?.patientCondition ?? '';
  }

  String get mobilityLevel {
    return booking.value?.mobilityLevel ?? '';
  }

  // Caretaker info getters
  String? get caretakerName {
    return booking.value?.caretakerName;
  }

  String? get caretakerPhone {
    return booking.value?.caretakerPhone;
  }

  /// Refresh booking data
  Future<void> refresh() async {
    if (booking.value != null) {
      await fetchBookingDetails(booking.value!.id);
    }
  }

  /// Clear controller data
  void clearData() {
    booking.value = null;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}