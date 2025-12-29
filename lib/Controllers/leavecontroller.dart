import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Model/leave/leavestats_model.dart';
import '../Services/tokenservice.dart';
import '../Model/leave/leave_model.dart';

class LeaveController extends GetxController {
  final isLoading = false.obs;
  final leave = Rxn<LeaveRequest>();
  var leaveStats = Rxn<LeaveStats>();

  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/leave/request/";

  Future<void> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    isLoading.value = true;

    try {
      final token = await TokenService.getAccessToken();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "start_date": startDate,
          "end_date": endDate,
          "reason": reason,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        leave.value = LeaveRequest.fromJson(data["leave"]);
        Get.snackbar("Success", data["message"]);
      } else {
        Get.snackbar("Error", data["message"] ?? "Leave request failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeaveStats() async {
    final token = await TokenService.getAccessToken();
    final baseUrl = dotenv.env['BASE_URL']!;

    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("$baseUrl/api/caretaker/leave/stats/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        leaveStats.value = LeaveStats.fromJson(data);
      } else {
        print("❌ Leave stats error: ${response.body}");
      }
    } catch (e) {
      print("❌ Leave stats exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

   @override
  void onInit() {
    fetchLeaveStats();
    super.onInit();
  }

}
