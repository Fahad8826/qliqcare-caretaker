import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Model/complain_model.dart';
import '../Services/tokenservice.dart';

class ComplaintController extends GetxController {
  var isLoading = false.obs;
  var complaints = <ComplaintItem>[].obs;
  var complaintDetail = Rxn<ComplaintDetail>();

  // ---------------------------
  // SUBMIT COMPLAINT
  // ---------------------------
  Future<void> submitComplaint({
    required String subject,
    required String description,
    required String priority,
  }) async {
    try {
      isLoading.value = true;

      final token = await TokenService.getAccessToken();
      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse("$baseUrl/api/caretaker/complaints/");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "subject": subject,
          "description": description,
          "priority": priority,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar("Success", "Complaint submitted");
        fetchMyComplaints();
      } else {
        print("Submit Error: ${response.body}");
        Get.snackbar("Error", "Failed to submit complaint");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // GET COMPLAINT LIST
  // ---------------------------
  Future<void> fetchMyComplaints() async {
    try {
      isLoading.value = true;

      final token = await TokenService.getAccessToken();
      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse("$baseUrl/api/caretaker/complaints/");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("LIST RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Extract list from "complaints"
        final List items = decoded["complaints"] ?? [];

        complaints.value = items.map((e) => ComplaintItem.fromJson(e)).toList();
      } else {
        print("List Error: ${response.body}");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // GET COMPLAINT DETAIL
  // ---------------------------
  Future<void> fetchComplaintDetail(int id) async {
    try {
      isLoading.value = true;

      final token = await TokenService.getAccessToken();
      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse("$baseUrl/api/caretaker/complaints/$id/");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("DETAIL RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        complaintDetail.value = ComplaintDetail.fromJson(decoded);
      } else {
        print("Detail Error: ${response.body}");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
