import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';

import '../model/complain_model.dart';
class ComplaintController extends GetxController {
  var isLoading = false.obs;
  var complaints = <ComplaintItem>[].obs;
  var complaintDetail = Rxn<ComplaintDetail>();


Future<void> submitComplaint({
  required String subject,
  required String description,
  required String priority,
}) async {
  try {
    isLoading.value = true;

    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse("$baseUrl/api/caretaker/complaints/");

    final response = await ApiService.request((token) {
      return http.post(
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
    });

    if (response.statusCode == 201) {
      showSnackbarSafe("Success", "Complaint submitted");
      fetchMyComplaints();
    } else {
      debugPrint("Submit Error: ${response.body}");
      showSnackbarSafe("Error", "Failed to submit complaint");
    }
  } finally {
    isLoading.value = false;
  }
}

  Future<void> fetchMyComplaints() async {
  try {
    isLoading.value = true;

    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse("$baseUrl/api/caretaker/complaints/");

    final response = await ApiService.request((token) {
      return http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    });

    debugPrint("LIST RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List items = decoded["complaints"] ?? [];

      complaints.value =
          items.map((e) => ComplaintItem.fromJson(e)).toList();
    } else {
      debugPrint("List Error: ${response.body}");
    }
  } finally {
    isLoading.value = false;
  }
}



  Future<void> fetchComplaintDetail(int id) async {
  try {
    isLoading.value = true;

    final baseUrl = dotenv.env['BASE_URL']!;
    final url =
        Uri.parse("$baseUrl/api/caretaker/complaints/$id/");

    final response = await ApiService.request((token) {
      return http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    });

    debugPrint("DETAIL RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      complaintDetail.value = ComplaintDetail.fromJson(decoded);
    } else {
      debugPrint("Detail Error: ${response.body}");
    }
  } finally {
    isLoading.value = false;
  }
}

}
