import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/attendance/model/attendance_model.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';

class AttendanceController extends GetxController {
  // -------------------- STATE --------------------
  final RxBool isLoading = false.obs;
  final Rx<Attendance?> todayAttendance = Rx<Attendance?>(null);

  // -------------------- BASE URL --------------------
  String get baseUrl => "${dotenv.env['BASE_URL']}/api/caretaker/bookings";

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
      debugPrint("111111111CHECK IN lat: $latitude, lng: $longitude 111111111");

      final response = await ApiService.request(
        (token) => http.post(
          Uri.parse("$baseUrl/$bookingId/attendance/check-in/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "latitude": latitude.toStringAsFixed(6),
            "longitude": longitude.toStringAsFixed(6),
          }),
        ),
      );
      debugPrint("📡 CHECK-IN status: ${response.statusCode}");
      debugPrint("📦 CHECK-IN response: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["attendance"] != null) {
        todayAttendance.value = Attendance.fromJson(data["attendance"]);

        showSnackbarSafe("Success", _extractMessage(data));
      } else {
        showSnackbarSafe("Info", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ CHECK-IN error: $e");
      debugPrintStack(stackTrace: s);

      showSnackbarSafe("Error", "Network or server error");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= CHECK OUT =================
  Future<void> checkOut({
    required int bookingId,
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;

    try {
      final response = await ApiService.request(
        (token) => http.post(
          Uri.parse("$baseUrl/$bookingId/attendance/check-out/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
  "latitude": latitude.toStringAsFixed(6),
  "longitude": longitude.toStringAsFixed(6),
}),
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["attendance"] != null) {
        todayAttendance.value = Attendance.fromJson(data["attendance"]);

        showSnackbarSafe("Success", _extractMessage(data));
      } else {
        showSnackbarSafe("Info", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ CHECK-OUT error: $e");
      debugPrintStack(stackTrace: s);

      showSnackbarSafe("Error", "Network or server error");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOCATION HANDLERS =================

  Future<void> handleCheckIn(int bookingId) async {
    debugPrint("📍 Fetching location for CHECK-IN");

    final location = await LocationService.getCurrentCoordinates();

    if (location == null) {
      showSnackbarSafe("Location Error", "Unable to fetch location");

      return;
    }

    await checkIn(
      bookingId: bookingId,
      latitude: location["lat"]!,
      longitude: location["lng"]!,
    );
  }

  Future<void> handleCheckOut(int bookingId) async {
  debugPrint("🚪 CHECK-OUT initiated | Booking ID: $bookingId");

  try {
    debugPrint("📍 Requesting current location for CHECK-OUT...");

    final location = await LocationService.getCurrentCoordinates();

    debugPrint("📡 LocationService response: $location");

    if (location == null) {
      debugPrint("❌ Location fetch failed (null response)");

      showSnackbarSafe(
        "Location Error",
        "Unable to fetch location",
      );
      return;
    }

    final lat = location["lat"];
    final lng = location["lng"];

    debugPrint("📍 Parsed coordinates → lat: $lat | lng: $lng");

    if (lat == null || lng == null) {
      debugPrint("❌ Invalid coordinates (lat/lng is null)");

      showSnackbarSafe(
        "Location Error",
        "Invalid location data",
      );
      return;
    }

    debugPrint(
      "🚀 Sending CHECK-OUT request | "
      "Booking ID: $bookingId | "
      "lat: ${lat.toStringAsFixed(6)} | "
      "lng: ${lng.toStringAsFixed(6)}",
    );

    await checkOut(
      bookingId: bookingId,
      latitude: lat,
      longitude: lng,
    );

    debugPrint("✅ CHECK-OUT request completed successfully");

  } catch (e, s) {
    debugPrint("❌ CHECK-OUT exception: $e");
    debugPrintStack(stackTrace: s);
  
    showSnackbarSafe(
      "Error",
      "Something went wrong during check-out",
    );
  }
}


  // -------------------- CLEANUP --------------------
  @override
  void onClose() {
    debugPrint("🧹 AttendanceController disposed");

    todayAttendance.value = null;

    super.onClose();
  }
}
