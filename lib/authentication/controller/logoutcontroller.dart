
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/notification/service/notification_services.dart';

import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/authentication/view/login.dart';

// class LogoutController extends GetxController {
//   final String baseUrl = dotenv.env['BASE_URL'] ?? '';
//   late final String apiUrl = "$baseUrl/api/caretaker/logout/";
//   RxBool isLoading = false.obs;

//   Future<void> logout() async {
//     isLoading.value = true;

//     try {
//       String? accessToken = await TokenService.getAccessToken();
//       String? refreshToken = await TokenService.getRefreshToken();

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $accessToken",
//         },
//         body: jsonEncode({"refresh": refreshToken, "access": accessToken}),
//       );

//       if (response.statusCode == 200 || response.statusCode == 205) {
//         // 🔥 DELETE FCM TOKEN
//         await NotificationService().deleteToken();

//         await TokenService.clearTokens();
//         Get.offAll(() => LoginView());
//       } else {
//         Get.snackbar("Error", "Logout failed");
//       }
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
class LogoutController extends GetxController {
  late final String baseUrl = dotenv.env['BASE_URL']!;
  late final String apiUrl = "$baseUrl/api/caretaker/logout/";
  final isLoading = false.obs;

  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final accessToken = await TokenService.getAccessToken();
      final refreshToken = await TokenService.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode({
            "refresh": refreshToken,
            "access": accessToken,
          }),
        );
      }
    } catch (_) {
      // ❌ Ignore API failure
    } finally {
      // 🔥 ALWAYS DO THESE
      await NotificationService().deleteToken();
      await TokenService.clearTokens();
      Get.offAll(() => LoginView());
      isLoading.value = false;
    }
  }
}


