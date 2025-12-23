import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Controllers/Model/deleteaccount_model.dart';
import 'package:qlickcare/Services/tokenservice.dart';
import 'package:qlickcare/View/Auth/login.dart';

class AccountController extends GetxController {
  var isDeleting = false.obs;

  Future<void> deleteAccount() async {
    final String baseUrl = dotenv.env['BASE_URL']!;
    String? token = await TokenService.getAccessToken();

    final url = Uri.parse('$baseUrl/api/caretaker/account/delete/');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(
      DeleteAccountRequest(confirmation: "DELETE").toJson(),
    );

    try {
      isDeleting.value = true;

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 Show success
        Get.snackbar("Success", data["message"] ?? "Account deleted");

        // 🔥 CLEAR ALL TOKENS
        await TokenService.clearTokens();

        // 🔥 Now navigate to login screen
        Future.delayed(Duration(milliseconds: 500), () {
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
