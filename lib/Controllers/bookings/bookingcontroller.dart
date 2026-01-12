import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/Model/bookings/booking_model.dart';
import 'package:qlickcare/Services/tokenexpireservice.dart';

class BookingController extends GetxController {
  /// Loader
  var isLoading = false.obs;

  /// All bookings from API
  var bookings = <BookingItem>[].obs;

  /// Filtered bookings for UI
  var filteredBookings = <BookingItem>[].obs;

  /// Selected filter chip
  var selectedFilter = "ALL".obs;

  @override
  void onInit() {
    super.onInit();
    fetchOngoingBookings();

    /// Automatically re-apply filter whenever bookings change
    ever(bookings, (_) => _applyFilter());
  }

  /// ==============================
  /// FETCH ALL BOOKINGS
  /// ==============================
  Future<void> fetchBookings() async {
    final String baseUrl = dotenv.env['BASE_URL']!;
    // String? token = await TokenService.getAccessToken();

    isLoading.value = true;

    try {
      // var headers = {'Authorization': 'Bearer $token'};
      var url = Uri.parse("$baseUrl/api/caretaker/bookings/");
      // var response = await http.get(url, headers: headers);
      final response = await ApiService.request((token) {
        return http.get(url, headers: {'Authorization': 'Bearer $token'});
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List results = data["results"] ?? [];

        bookings.value = results.map((e) => BookingItem.fromJson(e)).toList();
      } else {
        print("Error fetching bookings: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    isLoading.value = false;
  }

  Future<void> fetchOngoingBookings() async {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final url = Uri.parse("$baseUrl/api/caretaker/bookings/ongoing/");

  isLoading.value = true;

  try {
    final response = await ApiService.request((token) {
      return http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];

      bookings.value = results
          .where(
            (e) =>
                (e["booking_status"] ?? "")
                    .toString()
                    .toUpperCase() ==
                "ONGOING",
          )
          .map((e) => BookingItem.fromJson(e))
          .toList();
    } else {
      debugPrint("Error fetching ongoing bookings: ${response.body}");
    }
  } catch (e) {
    debugPrint("Exception: $e");
  } finally {
    isLoading.value = false;
  }
}


  /// ==============================
  /// FILTER BOOKINGS (Called from UI)
  /// ==============================
  void filterBookings(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  /// ==============================
  /// APPLY FILTER LOGIC
  /// ==============================
  void _applyFilter() {
    if (selectedFilter.value == "ALL") {
      filteredBookings.value = bookings;
    } else {
      filteredBookings.value = bookings
          .where(
            (booking) =>
                booking.booking_status.toUpperCase() ==
                selectedFilter.value.toUpperCase(),
          )
          .toList();
    }
  }
}
