import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/attendance/model/leave/leave_model.dart';
import 'package:qlickcare/attendance/model/leave/leavestats_model.dart';
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';

class LeaveController extends GetxController {
  // -------------------- STATE --------------------
  final RxBool isLoading = false.obs;
  final RxBool isStatsLoading = false.obs;
  
  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;
  final Rx<LeaveStats?> leaveStats = Rx<LeaveStats?>(null);

  // -------------------- BASE URL --------------------
  String get baseUrl => "${dotenv.env['BASE_URL']}/api/caretaker";

  // -------------------- MESSAGE HANDLER --------------------
  String _extractMessage(Map<String, dynamic> data) {
    if (data["message"] != null) return data["message"];
    if (data["detail"] != null) {
      if (data["detail"] is List) {
        return (data["detail"] as List).join("\n");
      }
      return data["detail"].toString();
    }
    return "Something went wrong";
  }

  // ================= FETCH LEAVE REQUESTS =================
  Future<void> fetchLeaveRequests() async {
    isLoading.value = true;

    debugPrint("🚀 FETCH LEAVE REQUESTS started");

    try {
      final response = await ApiService.request((token) {
        return http.get(
          Uri.parse("$baseUrl/leave/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      });

      debugPrint("📡 fetchLeaveRequests: ${response.statusCode}");
      debugPrint("📦 FETCH response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        if (data is List) {
          // Direct array response
          leaveRequests.value = data
              .map((item) => LeaveRequest.fromJson(item))
              .toList();
        } else if (data is Map<String, dynamic>) {
          // Paginated response - check for 'leaves' key first, then 'results'
          if (data["leaves"] != null) {
            leaveRequests.value = (data["leaves"] as List)
                .map((item) => LeaveRequest.fromJson(item))
                .toList();
          } else if (data["results"] != null) {
            leaveRequests.value = (data["results"] as List)
                .map((item) => LeaveRequest.fromJson(item))
                .toList();
          } else {
            leaveRequests.value = [];
          }
        } else {
          leaveRequests.value = [];
        }
        
        debugPrint("✅ Fetched ${leaveRequests.length} leave requests");
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ FETCH error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to fetch leave requests");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= FETCH LEAVE STATS =================
  Future<void> fetchLeaveStats() async {
    isStatsLoading.value = true;

    debugPrint("🚀 FETCH LEAVE STATS started");

    try {
      final response = await ApiService.request((token) {
        return http.get(
          Uri.parse("$baseUrl/leave/stats/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      });

      debugPrint("📡 STATS status: ${response.statusCode}");
      debugPrint("📦 STATS response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        leaveStats.value = LeaveStats.fromJson(data);
        debugPrint("✅ Leave stats fetched successfully");
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", _extractMessage(data));
      }
    } catch (e, s) {
      debugPrint("❌ STATS error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to fetch leave stats");
    } finally {
      isStatsLoading.value = false;
    }
  }

  // ================= REQUEST LEAVE =================
  Future<bool> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    required String leaveType,
  }) async {
    isLoading.value = true;

    debugPrint("🚀 REQUEST LEAVE started");
    debugPrint("📤 Data: $startDate → $endDate, Type: $leaveType");

    try {
      final response = await ApiService.request((token) {
        return http.post(
          Uri.parse("$baseUrl/leave/request/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "start_date": startDate,
            "end_date": endDate,
            "reason": reason,
            "leave_type": leaveType,
          }),
        );
      });

      debugPrint("📡 REQUEST status: ${response.statusCode}");
      debugPrint("📦 REQUEST response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          data["message"] ?? "Leave request submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh data
        await fetchLeaveRequests();
        await fetchLeaveStats();
        
        debugPrint("✅ Leave request submitted");
        return true;
      } else {
        Get.snackbar("Error", _extractMessage(data));
        return false;
      }
    } catch (e, s) {
      debugPrint("❌ REQUEST error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to submit leave request");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE LEAVE =================
  Future<bool> updateLeave({
    required int leaveId,
    required String startDate,
    required String endDate,
    required String reason,
    required String leaveType,
  }) async {
    isLoading.value = true;

    debugPrint("🚀 UPDATE LEAVE started | ID: $leaveId");
    debugPrint("📤 Data: $startDate → $endDate, Type: $leaveType");

    try {
      final response = await ApiService.request((token) {
        return http.put(
          Uri.parse("$baseUrl/leave/$leaveId/update/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "start_date": startDate,
            "end_date": endDate,
            "reason": reason,
            "leave_type": leaveType,
          }),
        );
      });

      debugPrint("📡 UPDATE status: ${response.statusCode}");
      debugPrint("📦 UPDATE response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          data["message"] ?? "Leave request updated successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh data
        await fetchLeaveRequests();
        await fetchLeaveStats();
        
        debugPrint("✅ Leave request updated");
        return true;
      } else {
        Get.snackbar("Error", _extractMessage(data));
        return false;
      }
    } catch (e, s) {
      debugPrint("❌ UPDATE error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to update leave request");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE LEAVE =================
  Future<bool> deleteLeaveRequest(int leaveId) async {
    isLoading.value = true;

    debugPrint("🚀 DELETE LEAVE started | ID: $leaveId");

    try {
      final response = await ApiService.request((token) {
        return http.delete(
          Uri.parse("$baseUrl/leave/$leaveId/cancel/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      });

      debugPrint("📡 DELETE status: ${response.statusCode}");
      debugPrint("📦 DELETE response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          "Success",
          "Leave request deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh data
        await fetchLeaveRequests();
        await fetchLeaveStats();
        
        debugPrint("✅ Leave request deleted");
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", _extractMessage(data));
        return false;
      }
    } catch (e, s) {
      debugPrint("❌ DELETE error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Failed to delete leave request");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- CLEANUP --------------------
  @override
  void onClose() {
    debugPrint("🧹 LeaveController disposed");
    leaveRequests.clear();
    leaveStats.value = null;
    super.onClose();
  }
}
