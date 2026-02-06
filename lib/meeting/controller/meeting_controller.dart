import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import '../model/meeting_model.dart';

class MeetingsController extends GetxController {
  var isLoading = false.obs;
  var meetings = <MeetingItem>[].obs;
  var meetingDetail = Rxn<MeetingDetail>();
  var selectedFilter = "SCHEDULED".obs; // Default filter

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
  }

  // Fetch meetings list with optional filter
  Future<void> fetchMeetings({String? status}) async {
    try {
      isLoading.value = true;

      final baseUrl = dotenv.env['BASE_URL']!;
      final filterParam = status ?? selectedFilter.value;
      final url = Uri.parse("$baseUrl/api/caretaker/meetings/?status=$filterParam");

      final response = await ApiService.request((token) {
        return http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
          },
        );
      });

      debugPrint("MEETINGS LIST RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List items = decoded["meetings"] ?? [];

        meetings.value = items.map((e) => MeetingItem.fromJson(e)).toList();
      } else {
        debugPrint("Meetings List Error: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to fetch meetings",
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      debugPrint("Meetings List Exception: $e");
      Get.snackbar(
        "Error",
        "An error occurred while fetching meetings",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch meeting detail
  // Future<void> fetchMeetingDetail(int id) async {
  //   try {
  //     isLoading.value = true;

  //     final baseUrl = dotenv.env['BASE_URL']!;
  //     final url = Uri.parse("$baseUrl/api/caretaker/meetings/$id/");

  //     final response = await ApiService.request((token) {
  //       return http.get(
  //         url,
  //         headers: {
  //           "Authorization": "Bearer $token",
  //         },
  //       );
  //     });

  //     debugPrint("MEETING DETAIL RESPONSE: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       meetingDetail.value = MeetingDetail.fromJson(decoded);
  //     } else {
  //       debugPrint("Meeting Detail Error: ${response.body}");
  //       Get.snackbar(
  //         "Error",
  //         "Failed to fetch meeting details",
  //         backgroundColor: AppColors.error.withOpacity(0.1),
  //         colorText: AppColors.error,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("Meeting Detail Exception: $e");
  //     Get.snackbar(
  //       "Error",
  //       "An error occurred while fetching meeting details",
  //       backgroundColor: AppColors.error.withOpacity(0.1),
  //       colorText: AppColors.error,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> fetchMeetingDetail(int id) async {
  try {
    isLoading.value = true;

    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse("$baseUrl/api/caretaker/meetings/$id/");

    final response = await ApiService.request((token) {
      return http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    });

    debugPrint("MEETING DETAIL RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Extract the 'meeting' object from the response
      final meetingData = decoded['meeting'];
      meetingDetail.value = MeetingDetail.fromJson(meetingData);
    } else {
      debugPrint("Meeting Detail Error: ${response.body}");
      Get.snackbar(
        "Error",
        "Failed to fetch meeting details",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  } catch (e) {
    debugPrint("Meeting Detail Exception: $e");
    Get.snackbar(
      "Error",
      "An error occurred while fetching meeting details",
      backgroundColor: AppColors.error.withOpacity(0.1),
      colorText: AppColors.error,
    );
  } finally {
    isLoading.value = false;
  }
}

  // Mark meeting as attended
  Future<void> markAttended(int meetingId) async {
    try {
      isLoading.value = true;

      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse("$baseUrl/api/caretaker/meetings/$meetingId/mark-attended/");

      final response = await ApiService.request((token) {
        return http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      debugPrint("MARK ATTENDED RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Meeting marked as attended",
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
        
        // Refresh the meeting detail
        fetchMeetingDetail(meetingId);
        
        // Refresh the meetings list
        fetchMeetings();
      } else {
        debugPrint("Mark Attended Error: ${response.body}");
        final decoded = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          decoded["error"] ?? "Failed to mark meeting as attended",
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      debugPrint("Mark Attended Exception: $e");
      Get.snackbar(
        "Error",
        "An error occurred while marking attendance",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update filter
  void updateFilter(String filter) {
    selectedFilter.value = filter;
    fetchMeetings(status: filter);
  }
}