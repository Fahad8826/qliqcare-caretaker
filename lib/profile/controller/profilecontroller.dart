

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';

import '../model/profile_model.dart';

class P_Controller extends GetxController {
  var profile = Profile(specializationIds: [], workTypes: []).obs;

  var isLoading = false.obs;
  var isUpdating = false.obs;
  var isUpdatingDosDonts = false.obs;
  var selectedImage = Rx<String?>(null);
  var scrollOffset = 0.0.obs;

  var workTypesList = <String>[].obs;
  var specializationList = <Map<String, dynamic>>[].obs;
  var locationsList = <Map<String, dynamic>>[].obs;

  TextEditingController? dosTextController;
  TextEditingController? dontsTextController;

  late final String baseUrl;
  final Duration _timeout = const Duration(seconds: 20);

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BASE_URL']?.trim() ?? "";
    fetchAll();
  }

  @override
  void dispose() {
    selectedImage.value = null;
    scrollOffset.value = 0.0;
    workTypesList.clear();
    specializationList.clear();
    locationsList.clear();
    profile.value = Profile(specializationIds: [], workTypes: []);
    dosTextController = null;
    dontsTextController = null;
    super.dispose();
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
  // GET PROFILE (AUTH)
  // -------------------------
  Future<void> fetchProfile() async {
    try {
      final url = Uri.parse("$baseUrl/api/caretaker/profile/");

      final resp = await ApiService.request(
        (token) => http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      ).timeout(_timeout);

      if (resp.statusCode == 200) {
        profile.value = Profile.fromJson(jsonDecode(resp.body));
      } else {
        Get.snackbar("Error", "Failed to load profile");
      }
    } catch (e) {
        print("Session expired. Please login again.");
    }
  }

  // -------------------------
  // PUBLIC DATA (NO AUTH)
  // -------------------------
  Future<void> fetchWorkTypes() async {
    try {
      final resp = await http
          .get(Uri.parse("$baseUrl/api/caretaker/work-types/"))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        workTypesList.value =
            List<String>.from(body["work_types"].map((e) => e["value"]));
      }
    } catch (_) {
      print("Failed to load work types");
    }
  }

  Future<void> fetchSpecializations() async {
    try {
      final resp = await http
          .get(Uri.parse("$baseUrl/api/caretaker/service-categories/"))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        specializationList.value =
            List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      }
    } catch (_) {
      print("Failed to load specializations");
    }
  }

  Future<void> fetchLocations() async {
    try {
      final resp = await http
          .get(Uri.parse("$baseUrl/api/caretaker/locations/"))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        locationsList.value =
            List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      }
    } catch (_) {
      print("Failed to load locations");
    }
  }

  // -------------------------
  // UPDATE PROFILE
  // -------------------------
  Future<bool> updateProfile() async {
    isUpdating(true);
    try {
      final dos = dosTextController?.text.trim() ?? profile.value.dos ?? "";
      final donts =
          dontsTextController?.text.trim() ?? profile.value.donts ?? "";

      final url = Uri.parse('$baseUrl/api/caretaker/profile/update/');
      final hasImage =
          selectedImage.value != null && selectedImage.value!.isNotEmpty;

      bool success = hasImage
          ? await _updateProfileWithImage(url)
          : await _updateProfileJson(url);

      if (success) {
        await updateDosDonts(dos: dos, donts: donts);
        Get.snackbar("Success", "Profile updated successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      return success;
    } finally {
      isUpdating(false);
    }
  }

  // -------------------------
  // JSON UPDATE
  // -------------------------
  Future<bool> _updateProfileJson(Uri url) async {
    try {
      final response = await ApiService.request(
        (token) => http.patch(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(profile.value.toJson()),
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // -------------------------
  // MULTIPART UPDATE
  // -------------------------
  Future<bool> _updateProfileWithImage(Uri url) async {
    try {
      final response = await ApiService.multipartRequest(
        (token) async {
          final request = http.MultipartRequest("PATCH", url);
          request.headers['Authorization'] = 'Bearer $token';
          request.fields["data"] = jsonEncode(profile.value.toJson());

          if (selectedImage.value != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'profile_picture',
              selectedImage.value!,
            ));
          }

          return request.send();
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        selectedImage.value = null;
        await fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // -------------------------
  // UPDATE DOS / DONTS
  // -------------------------
  Future<bool> updateDosDonts({
    required String dos,
    required String donts,
  }) async {
    try {
      final response = await ApiService.request(
        (token) => http.post(
          Uri.parse("$baseUrl/api/caretaker/profile/dos-donts/"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"dos": dos, "donts": donts}),
        ),
      );

      if (response.statusCode == 200) {
        profile.update((p) {
          p!.dos = dos;
          p.donts = donts;
        });
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // -------------------------
  // STATIC LOCATION UPDATE
  // -------------------------
  static Future<bool> updateLocation(double lat, double lng) async {
    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse("$baseUrl/api/caretaker/profile/update/");

    try {
      final response = await ApiService.request(
        (token) => http.patch(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"latitude": lat, "longitude": lng}),
        ),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
