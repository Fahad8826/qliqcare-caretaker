
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'tokenservice.dart';

class LocationService {
  static const MethodChannel _channel = MethodChannel('com.qliq/location');

  static final StreamController<Map<String, double>> _locationStream =
      StreamController.broadcast();

  static bool _isHandlerRegistered = false;

  /// ----------------------------------------------------------
  /// INITIALIZE METHOD CALL HANDLER (Call once in main.dart)
  /// ----------------------------------------------------------
  static void initialize() {
    if (!_isHandlerRegistered) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _isHandlerRegistered = true;
      debugPrint("✅ Location method call handler registered");
    }
  }

  /// Handle method calls from Kotlin
  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == "locationUpdate") {
      try {
        final lat = (call.arguments['latitude'] as num).toDouble();
        final lng = (call.arguments['longitude'] as num).toDouble();

        debugPrint("📍 Background location received in Flutter: $lat, $lng");

        // Round to 6 decimal places
        final roundedLat = double.parse(lat.toStringAsFixed(6));
        final roundedLng = double.parse(lng.toStringAsFixed(6));

        // Add to stream for UI updates
        _locationStream.add({
          "lat": roundedLat,
          "lng": roundedLng,
        });

        // 🔥 NEW: Call API to update profile
        await updateLocation(roundedLat, roundedLng);

      } catch (e) {
        debugPrint("❌ Error parsing location update: $e");
      }
    }
  }

  /// ----------------------------------------------------------
  /// REQUEST LOCATION PERMISSIONS
  /// ----------------------------------------------------------
  static Future<bool> requestLocationPermission() async {
    debugPrint("🔐 Requesting location permissions...");

    PermissionStatus status = await Permission.location.status;
    debugPrint("📍 Current permission status: $status");

    if (status.isGranted) {
      debugPrint("✅ Location permission already granted");
      return true;
    }

    if (status.isDenied) {
      status = await Permission.location.request();

      if (status.isGranted) {
        debugPrint("✅ Location permission granted");
        return true;
      } else if (status.isPermanentlyDenied) {
        debugPrint("❌ Location permission permanently denied");
        await openAppSettings();
        return false;
      } else {
        debugPrint("❌ Location permission denied");
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      debugPrint("⚠️ Permission permanently denied. Opening settings...");
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// ----------------------------------------------------------
  /// REQUEST BACKGROUND LOCATION PERMISSION (Android 10+)
  /// ----------------------------------------------------------
  static Future<bool> requestBackgroundLocationPermission() async {
    debugPrint("🔐 Requesting background location permission...");

    bool foregroundGranted = await requestLocationPermission();
    if (!foregroundGranted) {
      debugPrint("❌ Foreground permission not granted");
      return false;
    }

    PermissionStatus status = await Permission.locationAlways.status;
    debugPrint("📍 Background permission status: $status");

    if (status.isGranted) {
      debugPrint("✅ Background location permission already granted");
      return true;
    }

    if (status.isDenied) {
      status = await Permission.locationAlways.request();

      if (status.isGranted) {
        debugPrint("✅ Background location permission granted");
        return true;
      } else if (status.isPermanentlyDenied) {
        debugPrint("❌ Background permission permanently denied");
        await openAppSettings();
        return false;
      } else {
        debugPrint("❌ Background location permission denied");
        return false;
      }
    }

    return false;
  }

  /// ----------------------------------------------------------
  /// GET CURRENT COORDINATES (WITH PERMISSION CHECK)
  /// ----------------------------------------------------------
  static Future<Map<String, double>?> getCurrentCoordinates() async {
    try {
      bool hasPermission = await requestLocationPermission();

      if (!hasPermission) {
        debugPrint("❌ Location permission not granted");
        return null;
      }

      debugPrint("📍 Fetching current location...");

      final location = await _channel.invokeMethod<Map>('getLocation');

      if (location == null) {
        debugPrint("❌ Location is null");
        return null;
      }

      final double lat = (location["latitude"] as num).toDouble();
      final double lng = (location["longitude"] as num).toDouble();

      debugPrint("📍 Current coordinates: $lat, $lng");

      final coords = {
        "lat": double.parse(lat.toStringAsFixed(6)),
        "lng": double.parse(lng.toStringAsFixed(6)),
      };
      _locationStream.add(coords);

      return coords;
    } catch (e) {
      debugPrint("❌ Error fetching coordinates: $e");
      return null;
    }
  }

  /// ----------------------------------------------------------
  /// START BACKGROUND LOCATION SERVICE
  /// ----------------------------------------------------------
  static Future<bool> startBackgroundLocation() async {
    try {
      initialize();

      bool hasPermission = await requestBackgroundLocationPermission();

      if (!hasPermission) {
        debugPrint("❌ Background location permission not granted");
        return false;
      }

      final token = await TokenService.getAccessToken();
      final baseUrl = dotenv.env['BASE_URL'];

      if (token == null || baseUrl == null) {
        debugPrint("❌ Token or Base URL missing");
        return false;
      }

      await _channel.invokeMethod('startLocationService', {
        'token': token,
        'baseUrl': baseUrl,
      });

      debugPrint("✅ Background location service started");

      return true;
    } catch (e) {
      debugPrint("❌ Error starting background location: $e");
      return false;
    }
  }

  /// ----------------------------------------------------------
  /// STOP BACKGROUND LOCATION SERVICE
  /// ----------------------------------------------------------
  static Future<void> stopBackgroundLocation() async {
    try {
      await _channel.invokeMethod('stopLocationService');
      debugPrint("🛑 Background location service stopped");
    } catch (e) {
      debugPrint("❌ Error stopping background location: $e");
    }
  }

  /// ----------------------------------------------------------
  /// UPDATE LOCATION TO API
  /// ----------------------------------------------------------
  static Future<void> updateLocation(double lat, double lng) async {
    final token = await TokenService.getAccessToken();
    final baseUrl = dotenv.env['BASE_URL'];
    
    if (token == null || baseUrl == null) {
      debugPrint("❌ Cannot update location: Missing token or baseUrl");
      return;
    }

    final url = Uri.parse("$baseUrl/api/caretaker/location-update/");

    try {
      final roundedLat = double.parse(lat.toStringAsFixed(6));
      final roundedLng = double.parse(lng.toStringAsFixed(6));

      debugPrint("🌍 Sending location to API: $roundedLat, $roundedLng");

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"latitude": roundedLat, "longitude": roundedLng}),
      ).timeout(const Duration(seconds: 10));

      debugPrint("🌍 Update Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("✅ Location updated successfully");
        debugPrint("📦 Response: ${response.body}");
      } else {
        debugPrint("⚠️ Location update failed: ${response.statusCode}");
        debugPrint("📦 Response: ${response.body}");
      }
    } on TimeoutException {
      debugPrint("❌ Location update timed out");
    } catch (e) {
      debugPrint("❌ Error updating location: $e");
    }
  }

  /// ----------------------------------------------------------
  /// CHECK IF PERMISSIONS ARE GRANTED
  /// ----------------------------------------------------------
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> hasBackgroundLocationPermission() async {
    return await Permission.locationAlways.isGranted;
  }

  /// ----------------------------------------------------------
  /// GET LOCATION NAME FROM COORDINATES
  /// ----------------------------------------------------------
  static Future<String> getLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> locationParts = [];

        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationParts.add(place.administrativeArea!);
        }

        String locationName = locationParts.isNotEmpty
            ? locationParts.join(', ')
            : 'Unknown Location';

        debugPrint("📍 Location name: $locationName");
        return locationName;
      }

      return 'Unknown Location';
    } catch (e) {
      debugPrint("❌ Error getting location name: $e");
      return 'Location unavailable';
    }
  }

  /// ----------------------------------------------------------
  /// LOCATION STREAM
  /// ----------------------------------------------------------
  static Stream<Map<String, double>> get locationStream =>
      _locationStream.stream;

  /// ----------------------------------------------------------
  /// DISPOSE (Call when logging out)
  /// ----------------------------------------------------------
  static void dispose() {
    if (!_locationStream.isClosed) {
      _locationStream.close();
    }
  }
}