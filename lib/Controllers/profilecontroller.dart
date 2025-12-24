import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Model/profile_model.dart';
import '../Services/tokenservice.dart';

class P_Controller extends GetxController {
  var profile = Profile(specializationIds: [], workTypes: []).obs;

  var isLoading = false.obs;
  var isUpdating = false.obs;

  var selectedImage = Rx<String?>(null); // Holds local picked image path
  var scrollOffset = 0.0.obs; // For scroll animations

  var workTypesList = <String>[].obs;
  var specializationList = <Map<String, dynamic>>[].obs;
  var locationsList = <Map<String, dynamic>>[].obs;

  late final String baseUrl;
  final Duration _timeout = const Duration(seconds: 20);

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BASE_URL']?.trim() ?? "";
    fetchAll();
  }

  void dispose() {
    selectedImage.value = null;
    scrollOffset.value = 0.0;

    workTypesList.clear();
    specializationList.clear();
    locationsList.clear();

    profile.value = Profile(specializationIds: [], workTypes: []);

    super.dispose();
    onInit();
  }

  // -------------------------
  // AUTH HEADERS
  // -------------------------
  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final h = {"Accept": "application/json"};

    if (!withAuth) return h;

    final token = await TokenService.getAccessToken();
    h["Authorization"] = "Bearer $token";

    return h;
  }

  // -------------------------
  // FETCH EVERYTHING
  // -------------------------
  Future<void> fetchAll() async {
    isLoading(true);
    await Future.wait([
      fetchProfile(),
      fetchWorkTypes(),
      fetchSpecializations(),
      fetchLocations(),
    ]);
    isLoading(false);
  }

  // -------------------------
  // GET PROFILE
  // -------------------------
  Future<void> fetchProfile() async {
    try {
      final url = Uri.parse("$baseUrl/api/caretaker/profile/");
      final resp = await http
          .get(url, headers: await _headers(withAuth: true))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        profile.value = Profile.fromJson(jsonDecode(resp.body));
        debugPrint("✅ Profile loaded successfully");
      } else {
        Get.snackbar("Error", "Failed to load profile");
      }
    } catch (e) {
      debugPrint("❌ Profile fetch error: $e");
      Get.snackbar("Error", "Profile fetch error: $e");
    }
  }

  // -------------------------
  // FETCH WORK TYPES
  // -------------------------
  Future<void> fetchWorkTypes() async {
    try {
      final url = Uri.parse("$baseUrl/api/caretaker/work-types/");
      final resp = await http.get(url).timeout(_timeout);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        workTypesList.value = List<String>.from(
          body["work_types"].map((e) => e["value"]),
        );
        debugPrint("✅ Work types loaded: ${workTypesList.length}");
      }
    } catch (e) {
      debugPrint("❌ Failed to load work types: $e");
      Get.snackbar("Error", "Failed to load work types");
    }
  }

  // -------------------------
  // FETCH SPECIALIZATIONS
  // -------------------------
  Future<void> fetchSpecializations() async {
    try {
      final url = Uri.parse("$baseUrl/api/caretaker/service-categories/");
      final resp = await http.get(url).timeout(_timeout);

      if (resp.statusCode == 200) {
        specializationList.value = List<Map<String, dynamic>>.from(
          jsonDecode(resp.body),
        );
        debugPrint("✅ Specializations loaded: ${specializationList.length}");
      }
    } catch (e) {
      debugPrint("❌ Failed to load specializations: $e");
      Get.snackbar("Error", "Failed to load specializations");
    }
  }

  // -------------------------
  // FETCH LOCATIONS
  // -------------------------
  Future<void> fetchLocations() async {
    try {
      final url = Uri.parse("$baseUrl/api/caretaker/locations/");
      final resp = await http.get(url).timeout(_timeout);

      if (resp.statusCode == 200) {
        locationsList.value = List<Map<String, dynamic>>.from(
          jsonDecode(resp.body),
        );
        debugPrint("✅ Locations loaded: ${locationsList.length}");
      }
    } catch (e) {
      debugPrint("❌ Failed to load locations: $e");
      Get.snackbar("Error", "Failed to load locations");
    }
  }

  // -------------------------
  // UPDATE PROFILE (MAIN METHOD)
  // -------------------------
  Future<bool> updateProfile() async {
    isUpdating(true);
    try {
      final url = Uri.parse('$baseUrl/api/caretaker/profile/update/');
      final token = await TokenService.getAccessToken();

      // Check if we have an image to upload
      final hasImage =
          selectedImage.value != null && selectedImage.value!.isNotEmpty;

      if (hasImage) {
        // USE MULTIPART for image upload
        return await _updateProfileWithImage(url, token!);
      } else {
        // USE JSON for regular updates (faster, cleaner)
        return await _updateProfileJson(url, token!);
      }
    } catch (e) {
      debugPrint("❌ ERROR updateProfile: $e");
      Get.snackbar("Error", "Update failed: ${e.toString()}");
      return false;
    } finally {
      isUpdating(false);
    }
  }

  // -------------------------
  // JSON UPDATE (no image)
  // -------------------------
  Future<bool> _updateProfileJson(Uri url, String token) async {
    try {
      final jsonBody = profile.value.toJson();

      debugPrint("📦 JSON BODY TO SEND: ${jsonEncode(jsonBody)}");

      final response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(_timeout);

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📡 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        final errorBody = response.body;
        debugPrint("❌ Update failed: $errorBody");
        Get.snackbar(
          "Update Failed",
          errorBody,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ JSON update error: $e");
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  // -------------------------
  // MULTIPART UPDATE (with image)
  // -------------------------
  Future<bool> _updateProfileWithImage(Uri url, String token) async {
    try {
      final request = http.MultipartRequest("PATCH", url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add JSON data as a single "data" field
      final jsonBody = profile.value.toJson();
      request.fields["data"] = jsonEncode(jsonBody);

      debugPrint("📦 MULTIPART DATA: ${request.fields['data']}");

      // Add image file
      if (selectedImage.value != null) {
        final file = File(selectedImage.value!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_picture',
              selectedImage.value!,
            ),
          );
          debugPrint("📦 IMAGE FILE: ${selectedImage.value}");
        } else {
          debugPrint("❌ Image file does not exist");
        }
      }

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📡 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        selectedImage.value = null; // Clear after successful upload
        await fetchProfile();
        Get.snackbar(
          "Success",
          "Profile and image updated successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        debugPrint("❌ Update failed: ${response.body}");
        Get.snackbar(
          "Update Failed",
          response.body,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ Multipart update error: $e");
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  static Future<bool> updateLocation(double lat, double lng) async {
    final String baseUrl = dotenv.env['BASE_URL']!;
    final token = await TokenService.getAccessToken(); // ⬅️ your stored token

    final url = Uri.parse("$baseUrl/api/caretaker/profile/update/");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"latitude": lat, "longitude": lng}),
      );

      print("🌍 Update Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error updating location: $e");
      return false;
    }
  }
}
