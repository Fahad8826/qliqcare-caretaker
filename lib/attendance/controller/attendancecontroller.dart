
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/attendance/model/attendance_model.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
class AttendanceController extends GetxController {
  // -------------------- STATE --------------------
  final RxBool isLoading = false.obs;
  final Rx<Attendance?> todayAttendance = Rx<Attendance?>(null);

  // -------------------- BASE URL --------------------
  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/bookings";


// old method for headers
  // -------------------- HEADERS --------------------
  // Future<Map<String, String>> _headers() async {
  //   // final token = await TokenService.getAccessToken();

  //   debugPrint("🔐 Using access token: ${token?.substring(0, 10)}...");

  //   return {
  //     "Content-Type": "application/json",
  //     "Authorization": "Bearer $token",
  //   };
  // }

  // -------------------- MESSAGE HANDLER --------------------
  String _extractMessage(Map<String, dynamic> data) {
    if (data["message"] != null) return data["message"];

    if (data["detail"] != null) {
      if (data["detail"] is List) {
        return (data["detail"] as List).join("\n");
      }
      return data["detail"].toString();
    }

    return "Something went wrong";
  }

  // ================= CHECK IN =================
  Future<void> checkIn({
    required int bookingId,
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;

    debugPrint("🚀 CHECK-IN started | Booking ID: $bookingId");

    try {
      // final response = await http.post(
      //   Uri.parse("$baseUrl/$bookingId/attendance/check-in/"),
      //   headers: await _headers(),
      //   body: jsonEncode({
      //     "latitude": latitude,
      //     "longitude": longitude,
      //   }),
      // );
      final response = await ApiService.request(
        (token) => http.post(
          Uri.parse("$baseUrl/$bookingId/attendance/check-in/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization":"Bearer $token"
          },
          body: jsonEncode({
            "latitude": latitude,
            "longitude": longitude,
          }),
        ),
      );


      debugPrint("📡 CHECK-IN status: ${response.statusCode}");
      debugPrint("📦 CHECK-IN response: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["attendance"] != null) {
        todayAttendance.value =
            Attendance.fromJson(data["attendance"]);

        debugPrint("✅ CHECK-IN success");
        Get.snackbar("Success", _extractMessage(data));
      } else {
        debugPrint("⚠️ CHECK-IN validation failed");
        Get.snackbar("Info", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ CHECK-IN error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Network or server error");
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> checkOut({
  required int bookingId,
  required double latitude,
  required double longitude,
}) async {
  isLoading.value = true;

  try {
    final response = await ApiService.request((token) {
      return http.post(
        Uri.parse("$baseUrl/$bookingId/attendance/check-out/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["attendance"] != null) {
      todayAttendance.value = Attendance.fromJson(data["attendance"]);
      Get.snackbar("Success", _extractMessage(data));
    } else {
      Get.snackbar("Info", _extractMessage(data));
    }
  }  finally {
    isLoading.value = false;
  }
}


  // ================= LOCATION HANDLERS =================

  Future<void> handleCheckIn(int bookingId) async {
    debugPrint("📍 Fetching location for CHECK-IN");

    final location = await LocationService.getCurrentCoordinates();

    if (location == null) {
      debugPrint("❌ Location fetch failed");
      Get.snackbar("Location Error", "Unable to fetch location");
      return;
    }

    await checkIn(
      bookingId: bookingId,
      latitude: location["lat"]!,
      longitude: location["lng"]!,
    );
  }

  Future<void> handleCheckOut(int bookingId) async {
    debugPrint("📍 Fetching location for CHECK-OUT");

    final location = await LocationService.getCurrentCoordinates();

    if (location == null) {
      debugPrint("❌ Location fetch failed");
      Get.snackbar("Location Error", "Unable to fetch location");
      return;
    }

    await checkOut(
      bookingId: bookingId,
      latitude: location["lat"]!,
      longitude: location["lng"]!,
    );
  }

  // -------------------- CLEANUP --------------------
  @override
  void onClose() {
    debugPrint("🧹 AttendanceController disposed");
    todayAttendance.value = null;
    super.onClose();
  }
}
