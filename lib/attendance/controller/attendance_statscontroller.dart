import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/attendance/model/attendencestatus_model.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';

class AttendanceStatsController extends GetxController {
  final isLoading = false.obs;
  final stats = Rxn<AttendanceStats>();

  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/attendance/stats/";

  Future<void> fetchStats() async {
    isLoading.value = true;

    try {
      final token = await TokenService.getAccessToken();

      // final response = await http.get(
      //   Uri.parse(baseUrl),
      //   headers: {
      //     "Authorization": "Bearer $token",
      //   },
      // );
      final response = await ApiService.request(
        (token) => http.get(
          Uri.parse(baseUrl),
          headers: {
            "Content-Type": 'application/json',
            "Authorization":"Bearer $token"
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stats.value = AttendanceStats.fromJson(data);
      } else {
        showSnackbarSafe("Error", "Failed to load stats");
      }
    } catch (e) {
      showSnackbarSafe("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }
}
