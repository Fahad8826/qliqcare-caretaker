import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:qlickcare/Services/locationpermisson.dart';

import '../authentication/service/tokenservice.dart';

class LocationService {
  static const MethodChannel _channel =
      MethodChannel('com.qliq/location');

  static final StreamController<Map<String, double>> _locationStream =
      StreamController.broadcast();

  static bool _initialized = false;
  static bool _started = false;
  /// -------------------------------
  /// INIT
  /// -------------------------------
 static void initialize() {
  if (_initialized) return;
  debugPrint("📡 LocationService initialized");
  _channel.setMethodCallHandler(_handleMethodCall);
  _initialized = true;
}

static Future<void> _handleMethodCall(MethodCall call) async {
  debugPrint("📥 Native callback: ${call.method}");

  if (call.method != "locationUpdate") return;

  final lat = (call.arguments['latitude'] as num).toDouble();
  final lng = (call.arguments['longitude'] as num).toDouble();

  debugPrint("📍 LOCATION UPDATE → lat=$lat lng=$lng");

  final data = {
    "lat": double.parse(lat.toStringAsFixed(6)),
    "lng": double.parse(lng.toStringAsFixed(6)),
  };

  _locationStream.add(data);

  debugPrint("📡 Sending location to API");
  await updateLocation(data["lat"]!, data["lng"]!);
}

  /// -------------------------------
  /// CURRENT LOCATION
  /// -------------------------------
  static Future<Map<String, double>?> getCurrentCoordinates() async {
    final granted =
        await LocationPermissionHandler.requestForeground();

    if (!granted) return null;

    final location =
        await _channel.invokeMethod<Map>('getLocation');

    if (location == null) return null;

    return {
      "lat": (location["latitude"] as num).toDouble(),
      "lng": (location["longitude"] as num).toDouble(),
    };
  }

  /// -------------------------------
  /// START BACKGROUND
  /// -------------------------------
static Future<bool> startBackground(BuildContext context) async {
  debugPrint("🚀 [LocationService] startBackground() invoked");

  if (_started) {
    debugPrint("♻️ [LocationService] Background service already running");
    return true;
  }

  try {
    debugPrint("⚙️ [LocationService] Initializing MethodChannel");
    initialize();

    // ---------- Foreground Permission ----------
    debugPrint("📍 Requesting FOREGROUND permission...");
    final fg = await LocationPermissionHandler.requestForeground();
    debugPrint("📍 Foreground permission result: $fg");

    if (!fg) {
      debugPrint("❌ Foreground permission denied. Aborting start.");
      return false;
    }

    // ---------- Background Permission ----------
    debugPrint("🌍 Requesting BACKGROUND permission...");
    final bg =
        await LocationPermissionHandler.requestBackground(context);
    debugPrint("🌍 Background permission result: $bg");

    if (!bg) {
      debugPrint("⚠️ Background permission denied. Aborting start.");
      return false;
    }

    // ---------- Auth + Config ----------
    debugPrint("🔐 Fetching auth token...");
    final token = await TokenService.getAccessToken();

    debugPrint("🌐 Reading BASE_URL from env...");
    final baseUrl = dotenv.env['BASE_URL'];

    debugPrint("🔐 Token exists: ${token != null}");
    debugPrint("🌐 Base URL value: $baseUrl");

    if (token == null || baseUrl == null) {
      debugPrint("❌ Missing token or BASE_URL. Cannot start service.");
      return false;
    }

    // ---------- Native Service Start ----------
    debugPrint("📡 Invoking native startLocationService...");

    await _channel.invokeMethod('startLocationService', {
      'token': token,
      'baseUrl': baseUrl,
    });

    debugPrint("✅ Native location service started successfully");

    _started = true;
    return true;

  } catch (e, stack) {
    debugPrint("❌ [LocationService] Failed to start background service");
    debugPrint("❌ Error: $e");
    debugPrint("❌ Stack: $stack");
    return false;
  }
}

  static Future<void> stopBackground() async {
    await _channel.invokeMethod('stopLocationService');
  }

  /// -------------------------------
  /// API UPDATE
  /// -------------------------------
 static Future<void> updateLocation(double lat, double lng) async {
  final token = await TokenService.getAccessToken();
  final baseUrl = dotenv.env['BASE_URL'];

  final url =
      Uri.parse("$baseUrl/api/caretaker/location-update/");

  debugPrint("🌍 POST $url");
  debugPrint("📦 Payload: lat=$lat lng=$lng");

  final res = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "latitude": lat,
      "longitude": lng,
    }),
  );

  debugPrint("📨 API response: ${res.statusCode}");
}

  /// -------------------------------
  /// LOCATION NAME
  /// -------------------------------
  static Future<String> getLocationName(
      double lat, double lng) async {
    final places =
        await placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return "Unknown";
    return "${places.first.locality}, ${places.first.administrativeArea}";
  }

  static Stream<Map<String, double>> get stream =>
      _locationStream.stream;
}