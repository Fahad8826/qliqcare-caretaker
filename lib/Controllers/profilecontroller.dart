// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../Model/profile_model.dart';
// import '../Services/tokenservice.dart';

// class P_Controller extends GetxController {
//   var profile = Profile(specializationIds: [], workTypes: []).obs;

//   var isLoading = false.obs;
//   var isUpdating = false.obs;
//   var isUpdatingDosDonts = false.obs;
//   var selectedImage = Rx<String?>(null);
//   var scrollOffset = 0.0.obs;

//   var workTypesList = <String>[].obs;
//   var specializationList = <Map<String, dynamic>>[].obs;
//   var locationsList = <Map<String, dynamic>>[].obs;

//   // ✅ NEW: Store references to TextControllers from the view
//   TextEditingController? dosTextController;
//   TextEditingController? dontsTextController;

//   late final String baseUrl;
//   final Duration _timeout = const Duration(seconds: 20);

//   @override
//   void onInit() {
//     super.onInit();
//     baseUrl = dotenv.env['BASE_URL']?.trim() ?? "";
//     fetchAll();
//   }

//   @override
//   void dispose() {
//     selectedImage.value = null;
//     scrollOffset.value = 0.0;
//     workTypesList.clear();
//     specializationList.clear();
//     locationsList.clear();
//     profile.value = Profile(specializationIds: [], workTypes: []);
    
//     // Clear controller references
//     dosTextController = null;
//     dontsTextController = null;
    
//     super.dispose();
//   }

//   // -------------------------
//   // AUTH HEADERS
//   // -------------------------
//   Future<Map<String, String>> _headers({bool withAuth = false}) async {
//     final h = {"Accept": "application/json"};
//     if (!withAuth) return h;
//     final token = await TokenService.getAccessToken();
//     h["Authorization"] = "Bearer $token";
//     return h;
//   }

//   // -------------------------
//   // FETCH EVERYTHING
//   // -------------------------
//   Future<void> fetchAll() async {
//     isLoading(true);
//     await Future.wait([
//       fetchProfile(),
//       fetchWorkTypes(),
//       fetchSpecializations(),
//       fetchLocations(),
//     ]);
//     isLoading(false);
//   }

//   // -------------------------
//   // GET PROFILE
//   // -------------------------
//   Future<void> fetchProfile() async {
//     try {
//       final url = Uri.parse("$baseUrl/api/caretaker/profile/");
//       final resp = await http
//           .get(url, headers: await _headers(withAuth: true))
//           .timeout(_timeout);

//       if (resp.statusCode == 200) {
//         profile.value = Profile.fromJson(jsonDecode(resp.body));
//         debugPrint("✅ Profile loaded successfully");
//       } else {
//         Get.snackbar("Error", "Failed to load profile");
//       }
//     } catch (e) {
//       debugPrint("❌ Profile fetch error: $e");
//       Get.snackbar("Error", "Profile fetch error: $e");
//     }
//   }

//   // -------------------------
//   // FETCH WORK TYPES
//   // -------------------------
//   Future<void> fetchWorkTypes() async {
//     try {
//       final url = Uri.parse("$baseUrl/api/caretaker/work-types/");
//       final resp = await http.get(url).timeout(_timeout);
//       if (resp.statusCode == 200) {
//         final body = jsonDecode(resp.body);
//         workTypesList.value = List<String>.from(
//           body["work_types"].map((e) => e["value"]),
//         );
//         debugPrint("✅ Work types loaded: ${workTypesList.length}");
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to load work types: $e");
//       Get.snackbar("Error", "Failed to load work types");
//     }
//   }

//   // -------------------------
//   // FETCH SPECIALIZATIONS
//   // -------------------------
//   Future<void> fetchSpecializations() async {
//     try {
//       final url = Uri.parse("$baseUrl/api/caretaker/service-categories/");
//       final resp = await http.get(url).timeout(_timeout);
//       if (resp.statusCode == 200) {
//         specializationList.value = List<Map<String, dynamic>>.from(
//           jsonDecode(resp.body),
//         );
//         debugPrint("✅ Specializations loaded: ${specializationList.length}");
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to load specializations: $e");
//       Get.snackbar("Error", "Failed to load specializations");
//     }
//   }

//   // -------------------------
//   // FETCH LOCATIONS
//   // -------------------------
//   Future<void> fetchLocations() async {
//     try {
//       final url = Uri.parse("$baseUrl/api/caretaker/locations/");
//       final resp = await http.get(url).timeout(_timeout);
//       if (resp.statusCode == 200) {
//         locationsList.value = List<Map<String, dynamic>>.from(
//           jsonDecode(resp.body),
//         );
//         debugPrint("✅ Locations loaded: ${locationsList.length}");
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to load locations: $e");
//       Get.snackbar("Error", "Failed to load locations");
//     }
//   }

//   // -------------------------
//   // UPDATE PROFILE (MAIN METHOD)
//   // -------------------------
//   Future<bool> updateProfile() async {
//     isUpdating(true);
//     try {
//       // ✅ Get values from text controllers if available (most accurate)
//       String dosToSave;
//       String dontsToSave;
      
//       if (dosTextController != null && dontsTextController != null) {
//         dosToSave = dosTextController!.text.trim();
//         dontsToSave = dontsTextController!.text.trim();
//         debugPrint("📝 Using TextController values");
//       } else {
//         dosToSave = profile.value.dos?.trim() ?? "";
//         dontsToSave = profile.value.donts?.trim() ?? "";
//         debugPrint("📝 Using Profile model values (fallback)");
//       }
      
//       debugPrint("🔍 Values to save:");
//       debugPrint("   dos: '$dosToSave'");
//       debugPrint("   donts: '$dontsToSave'");

//       final url = Uri.parse('$baseUrl/api/caretaker/profile/update/');
//       final token = await TokenService.getAccessToken();

//       final hasImage =
//           selectedImage.value != null && selectedImage.value!.isNotEmpty;

//       bool profileUpdateSuccess = false;
      
//       if (hasImage) {
//         profileUpdateSuccess = await _updateProfileWithImage(url, token!);
//       } else {
//         profileUpdateSuccess = await _updateProfileJson(url, token!);
//       }

//       // Update dos/donts after main profile
//       bool doseDontsSuccess = true;
//       if (profileUpdateSuccess) {
//         doseDontsSuccess = await updateDosDonts(
//           dos: dosToSave, 
//           donts: dontsToSave,
//         );
//       }

//       if (profileUpdateSuccess) {
//         if (doseDontsSuccess) {
//           Get.snackbar(
//             "Success",
//             "Profile updated successfully",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//         } else {
//           Get.snackbar(
//             "Partial Success",
//             "Profile updated but Do's & Don'ts failed",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//         }
//       }

//       return profileUpdateSuccess;
      
//     } catch (e) {
//       debugPrint("❌ ERROR updateProfile: $e");
//       Get.snackbar("Error", "Update failed: ${e.toString()}");
//       return false;
//     } finally {
//       isUpdating(false);
//     }
//   }

//   // -------------------------
//   // JSON UPDATE
//   // -------------------------
//   Future<bool> _updateProfileJson(Uri url, String token) async {
//     try {
//       final jsonBody = profile.value.toJson();
//       debugPrint("📦 JSON BODY TO SEND: ${jsonEncode(jsonBody)}");

//       final response = await http
//           .patch(
//             url,
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//               'Accept': 'application/json',
//             },
//             body: jsonEncode(jsonBody),
//           )
//           .timeout(_timeout);

//       debugPrint("📡 STATUS: ${response.statusCode}");
//       debugPrint("📡 RESPONSE BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         await fetchProfile();
//         return true;
//       } else {
//         debugPrint("❌ Update failed: ${response.body}");
//         Get.snackbar("Update Failed", response.body,
//             snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❌ JSON update error: $e");
//       Get.snackbar("Error", e.toString());
//       return false;
//     }
//   }

//   // -------------------------
//   // MULTIPART UPDATE
//   // -------------------------
//   Future<bool> _updateProfileWithImage(Uri url, String token) async {
//     try {
//       final request = http.MultipartRequest("PATCH", url);
//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Accept'] = 'application/json';

//       final jsonBody = profile.value.toJson();
//       request.fields["data"] = jsonEncode(jsonBody);
//       debugPrint("📦 MULTIPART DATA: ${request.fields['data']}");

//       if (selectedImage.value != null) {
//         final file = File(selectedImage.value!);
//         if (await file.exists()) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'profile_picture',
//               selectedImage.value!,
//             ),
//           );
//           debugPrint("📦 IMAGE FILE: ${selectedImage.value}");
//         }
//       }

//       final streamed = await request.send().timeout(_timeout);
//       final response = await http.Response.fromStream(streamed);

//       debugPrint("📡 STATUS: ${response.statusCode}");
//       debugPrint("📡 RESPONSE BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         selectedImage.value = null;
//         await fetchProfile();
//         return true;
//       } else {
//         debugPrint("❌ Update failed: ${response.body}");
//         Get.snackbar("Update Failed", response.body,
//             snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❌ Multipart update error: $e");
//       Get.snackbar("Error", e.toString());
//       return false;
//     }
//   }

//   // -------------------------
//   // UPDATE DOS/DONTS
//   // -------------------------
//   Future<bool> updateDosDonts({
//     required String dos,
//     required String donts,
//   }) async {
//     try {
//       final token = await TokenService.getAccessToken();
//       final url = Uri.parse("$baseUrl/api/caretaker/profile/dos-donts/");

//       debugPrint("📦 Updating Dos/Donts: dos='$dos', donts='$donts'");

//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode({"dos": dos, "donts": donts}),
//       ).timeout(_timeout);

//       debugPrint("📡 Dos/Donts Status: ${response.statusCode}");
//       debugPrint("📡 Dos/Donts Response: ${response.body}");

//       if (response.statusCode == 200) {
//         profile.update((p) {
//           p!.dos = dos;
//           p.donts = donts;
//         });
//         debugPrint("✅ Do's & Don'ts updated successfully");
//         return true;
//       } else {
//         debugPrint("❌ Do's & Don'ts update failed: ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❌ Do's & Don'ts error: $e");
//       return false;
//     }
//   }

//   // Keep your existing updateLocation method
//   static Future<bool> updateLocation(double lat, double lng) async {
//     final String baseUrl = dotenv.env['BASE_URL']!;
//     final token = await TokenService.getAccessToken();
//     final url = Uri.parse("$baseUrl/api/caretaker/profile/update/");

//     try {
//       final response = await http.patch(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode({"latitude": lat, "longitude": lng}),
//       );

//       print("🌍 Update Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");
//       return response.statusCode == 200;
//     } catch (e) {
//       print("❌ Error updating location: $e");
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Services/tokenexpireservice.dart';

import '../Model/profile_model.dart';

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
      Get.snackbar("Error", "Session expired. Please login again.");
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
      Get.snackbar("Error", "Failed to load work types");
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
      Get.snackbar("Error", "Failed to load specializations");
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
      Get.snackbar("Error", "Failed to load locations");
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
