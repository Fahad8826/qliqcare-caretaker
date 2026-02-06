import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/notification/model/notificationlist_model.dart';

import 'package:qlickcare/authentication/service/tokenexpireservice.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <AppNotification>[].obs;
  final count = 0.obs;

  String get baseUrl =>
      "${dotenv.env['BASE_URL']}/api/caretaker/notifications/";

  @override
  void onReady() {
    fetchNotifications(); // ✅ runs every time page opens
    super.onReady();
  }


  Future<void> fetchNotifications() async {
  try {
    isLoading.value = true;

    final response = await ApiService.request(
      (token) => http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      count.value = data['count'] ?? 0;
      notifications.value = (data['notifications'] as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    }
  } catch (_) {
    showSnackbarSafe("Error", "Session expired");
  } finally {
    isLoading.value = false;
  }
}

}
