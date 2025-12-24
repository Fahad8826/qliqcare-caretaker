
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'tokenservice.dart';

class ProfileService {
  static Future<Map<String, double>?> getCaretakerLocation() async {
    try {
      final token = await TokenService.getAccessToken();
      final baseUrl = dotenv.env['BASE_URL'];

      if (token == null || baseUrl == null) {
        debugPrint("❌ Token or Base URL missing");
        return null;
      }

      final url = Uri.parse("$baseUrl/api/caretaker/profile/");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract latitude and longitude from profile
        final double? lat = data['latitude'] != null 
            ? double.tryParse(data['latitude'].toString()) 
            : null;
        final double? lng = data['longitude'] != null 
            ? double.tryParse(data['longitude'].toString()) 
            : null;

        if (lat != null && lng != null) {
          debugPrint("✅ Caretaker location: $lat, $lng");
          return {'lat': lat, 'lng': lng};
        } else {
          debugPrint("⚠️ Location not available in profile");
          return null;
        }
      } else {
        debugPrint("❌ Failed to fetch profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching caretaker location: $e");
      return null;
    }
  }
}