import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Model/attendance/attendencestatus_model.dart';
import '../Services/tokenservice.dart';

class AttendanceStatsController extends GetxController {
  final isLoading = false.obs;
  final stats = Rxn<AttendanceStats>();

  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/attendance/stats/";

  Future<void> fetchStats() async {
    isLoading.value = true;

    try {
      final token = await TokenService.getAccessToken();

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stats.value = AttendanceStats.fromJson(data);
      } else {
        Get.snackbar("Error", "Failed to load stats");
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }
}
