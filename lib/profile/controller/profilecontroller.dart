import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  // ✅ NEW: Cache keys
  static const String _cacheKeyProfile = 'cached_profile';
  static const String _cacheKeyWorkTypes = 'cached_work_types';
  static const String _cacheKeySpecializations = 'cached_specializations';
  static const String _cacheKeyLocations = 'cached_locations';
  static const String _cacheKeyTimestamp = 'cache_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 30);

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BASE_URL']?.trim() ?? "";
    
    // ✅ NEW: Load cached data first for instant display
    _loadCachedData();
    
    // Then fetch fresh data
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
    dosTextController?.dispose();
    dontsTextController?.dispose();
    super.dispose();
  }

  // ✅ NEW: Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final timestamp = prefs.getInt(_cacheKeyTimestamp) ?? 0;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      if (cacheAge < _cacheDuration.inMilliseconds) {
        final cachedProfile = prefs.getString(_cacheKeyProfile);
        if (cachedProfile != null) {
          profile.value = Profile.fromJson(jsonDecode(cachedProfile));
        }

        final cachedWorkTypes = prefs.getString(_cacheKeyWorkTypes);
        if (cachedWorkTypes != null) {
          workTypesList.value = List<String>.from(jsonDecode(cachedWorkTypes));
        }

        final cachedSpecs = prefs.getString(_cacheKeySpecializations);
        if (cachedSpecs != null) {
          final decoded = jsonDecode(cachedSpecs) as List;
          specializationList.value = decoded
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }

        final cachedLocs = prefs.getString(_cacheKeyLocations);
        if (cachedLocs != null) {
          final decoded = jsonDecode(cachedLocs) as List;
          locationsList.value = decoded
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      }
    } catch (e) {
      print("Error loading cached data: $e");
    }
  }

  // ✅ NEW: Save to cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_cacheKeyProfile, jsonEncode(profile.value.toJson()));
      await prefs.setString(_cacheKeyWorkTypes, jsonEncode(workTypesList));
      await prefs.setString(_cacheKeySpecializations, jsonEncode(specializationList));
      await prefs.setString(_cacheKeyLocations, jsonEncode(locationsList));
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print("Error saving to cache: $e");
    }
  }

  // ✅ NEW: Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyProfile);
      await prefs.remove(_cacheKeyWorkTypes);
      await prefs.remove(_cacheKeySpecializations);
      await prefs.remove(_cacheKeyLocations);
      await prefs.remove(_cacheKeyTimestamp);
    } catch (e) {
      print("Error clearing cache: $e");
    }
  }

  // -------------------------
  // FETCH EVERYTHING (UPDATED)
  // -------------------------
  Future<void> fetchAll() async {
    // ✅ UPDATED: Only show loading if no cached data
    if (profile.value.fullName == null) {
      isLoading(true);
    }
    
    await Future.wait([
      fetchProfile(),
      fetchWorkTypes(),
      fetchSpecializations(),
      fetchLocations(),
    ]);
    
    // ✅ NEW: Save to cache after successful fetch
    await _saveToCache();
    
    isLoading(false);
  }

  // ✅ NEW: Refresh method for pull-to-refresh
  Future<void> refreshProfile() async {
    await fetchAll();
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
  // PUBLIC DATA (NO AUTH) - UPDATED WITH TYPE SAFETY
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
    } catch (e) {
      print("Failed to load work types: $e");
    }
  }

  Future<void> fetchSpecializations() async {
    try {
      final resp = await http
          .get(Uri.parse("$baseUrl/api/caretaker/service-categories/"))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        // ✅ FIXED: Type-safe casting
        final decoded = jsonDecode(resp.body) as List;
        specializationList.value = decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (e) {
      print("Failed to load specializations: $e");
    }
  }

  Future<void> fetchLocations() async {
    try {
      final resp = await http
          .get(Uri.parse("$baseUrl/api/caretaker/locations/"))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        // ✅ FIXED: Type-safe casting
        final decoded = jsonDecode(resp.body) as List;
        locationsList.value = decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (e) {
      print("Failed to load locations: $e");
    }
  }

  // -------------------------
  // UPDATE PROFILE (UPDATED)
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
        
        // ✅ NEW: Clear cache after update
        await clearCache();
        
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
    } catch (e) {
      print("Error updating profile: $e");
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
    } catch (e) {
      print("Error updating profile with image: $e");
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
    } catch (e) {
      print("Error updating dos/donts: $e");
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
    } catch (e) {
      print("Error updating location: $e");
      return false;
    }
  }
}