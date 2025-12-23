import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:qlickcare/Controllers/Model/attendencestatus_model.dart';
import 'package:qlickcare/Controllers/Model/bookingdetails_model.dart';
import 'package:qlickcare/Services/tokenservice.dart';

class BookingDetailsController extends GetxController {
  var isLoading = false.obs;
  var booking = Rxn<BookingDetails>();


  AttendanceItem? get todayAttendance {
    if (booking.value == null) return null;

    final today = DateTime.now();

    return booking.value!.attendance.firstWhereOrNull(
      (a) =>
          a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day,
    );
  }

  bool get isCheckedInToday =>
      todayAttendance?.status == "CHECKED_IN";

  bool get isCheckedOutToday =>
      todayAttendance?.status == "CHECKED_OUT";



  Future<void> fetchBookingDetails(int id) async {
  final token = await TokenService.getAccessToken();
  final baseUrl = dotenv.env['BASE_URL']!;

  var headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
  };

  try {
    isLoading.value = true;

    final url = "$baseUrl/api/caretaker/bookings/$id/";
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // 🔍 ADD THESE DEBUG PRINTS
      print("📡 API Response received for booking ID: ${data['id']}");
      print("📦 Attendance array from API: ${data['attendance']?.length} items");
      
      // Print first 3 attendance items to see the actual data
      if (data['attendance'] != null && (data['attendance'] as List).isNotEmpty) {
        print("📋 First attendance item: ${data['attendance'][0]}");
        if ((data['attendance'] as List).length > 1) {
          print("📋 Second attendance item: ${data['attendance'][1]}");
        }
      }
      
      booking.value = BookingDetails.fromJson(data);
      
      // 🔍 VERIFY AFTER PARSING
      print("✅ Parsed booking attendance count: ${booking.value?.attendance.length}");
      if (booking.value?.attendance.isNotEmpty ?? false) {
        print("📌 First parsed attendance: Date=${booking.value!.attendance[0].date}, Status=${booking.value!.attendance[0].status}");
      }
      
    } else {
      print("❌ Error: ${response.body}");
    }
  } catch (e) {
    print("❌ Exception: $e");
    print("❌ Stack trace: ${StackTrace.current}");
  } finally {
    isLoading.value = false;
  }
}



Future<void> updateTodoStatus(int todoId, bool isCompleted) async {
  final token = await TokenService.getAccessToken();
  final baseUrl = dotenv.env['BASE_URL']!;

  try {
    final response = await http.patch(
      Uri.parse("$baseUrl/api/caretaker/todos/$todoId/update/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "is_completed": isCompleted,
      }),
    );

    if (response.statusCode == 200) {
      final index =
          booking.value!.todos.indexWhere((t) => t.id == todoId);

      if (index != -1) {
        booking.value!.todos[index].isCompleted = isCompleted;
        booking.refresh(); // 🔁 UI update
      }
    }
  } catch (e) {
    print("Todo update error: $e");
  }
}


}
