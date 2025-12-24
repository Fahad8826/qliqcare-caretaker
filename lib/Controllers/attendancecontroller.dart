
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Model/attendance_model.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Services/tokenservice.dart';




class AttendanceController extends GetxController {
  // -------------------- STATE --------------------
  final RxBool isLoading = false.obs;
  final Rx<Attendance?> todayAttendance = Rx<Attendance?>(null);

  // -------------------- BASE URL --------------------
  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/attendance";

  // -------------------- HEADERS --------------------
  Future<Map<String, String>> _headers() async {
    final token = await TokenService.getAccessToken();

    debugPrint("🔐 Using access token: ${token?.substring(0, 10)}...");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

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
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;

    debugPrint("🚀 CHECK-IN started");
    debugPrint("📍 Latitude: $latitude, Longitude: $longitude");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-in/"),
        headers: await _headers(),
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      debugPrint("📡 CHECK-IN API status: ${response.statusCode}");
      debugPrint("📦 CHECK-IN API response: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["attendance"] != null) {
        todayAttendance.value =
            Attendance.fromJson(data["attendance"]);

        debugPrint("✅ CHECK-IN success");
        Get.snackbar("Success", _extractMessage(data));
      } else {
        debugPrint("⚠️ CHECK-IN business validation failed");
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

  // ================= CHECK OUT =================
  Future<void> checkOut({
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;

    debugPrint("🚀 CHECK-OUT started");
    debugPrint("📍 Latitude: $latitude, Longitude: $longitude");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-out/"),
        headers: await _headers(),
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      debugPrint("📡 CHECK-OUT API status: ${response.statusCode}");
      debugPrint("📦 CHECK-OUT API response: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["attendance"] != null) {
        todayAttendance.value =
            Attendance.fromJson(data["attendance"]);

        debugPrint("✅ CHECK-OUT success");
        Get.snackbar("Success", _extractMessage(data));
      } else {
        debugPrint("⚠️ CHECK-OUT business validation failed");
        Get.snackbar("Info", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ CHECK-OUT error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Network or server error");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= HANDLERS (LOCATION INSIDE CONTROLLER) =================

  Future<void> handleCheckIn() async {
    debugPrint("📍 Fetching location for CHECK-IN");

    final location = await LocationService.getCurrentCoordinates();

    if (location == null) {
      debugPrint("❌ Location fetch failed for CHECK-IN");
      Get.snackbar("Location Error", "Unable to fetch location");
      return;
    }

    debugPrint(
        "📍 Location fetched → lat=${location["lat"]}, lng=${location["lng"]}");

    await checkIn(
      latitude: location["lat"]!,
      longitude: location["lng"]!,
    );
  }

  Future<void> handleCheckOut() async {
    debugPrint("📍 Fetching location for CHECK-OUT");

    final location = await LocationService.getCurrentCoordinates();

    if (location == null) {
      debugPrint("❌ Location fetch failed for CHECK-OUT");
      Get.snackbar("Location Error", "Unable to fetch location");
      return;
    }

    debugPrint(
        "📍 Location fetched → lat=${location["lat"]}, lng=${location["lng"]}");

    await checkOut(
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
