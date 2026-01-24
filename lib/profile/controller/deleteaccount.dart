import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/profile/model/deleteaccount_model.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import 'package:qlickcare/authentication/view/login.dart';

class AccountController extends GetxController {
  var isDeleting = false.obs;

  Future<void> deleteAccount() async {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final url = Uri.parse('$baseUrl/api/caretaker/account/delete/');

  final body = jsonEncode(
    DeleteAccountRequest(confirmation: "DELETE").toJson(),
  );

  try {
    isDeleting.value = true;

    final response = await ApiService.request((token) {
      return http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      Get.snackbar(
        "Success",
        data["message"] ?? "Account deleted",
      );

      // 👉 Explicit logout after delete
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAll(() => LoginView());
      });
    } else {
      Get.snackbar("Error", response.body);
    }
  } catch (e) {
    Get.snackbar("Exception", e.toString());
  } finally {
    isDeleting.value = false;
  }
}

}
