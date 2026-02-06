import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHandler {
  static bool _isRequesting = false;
static bool? _cachedResult;
  /// -------------------------------
  /// FOREGROUND PERMISSION
  /// -------------------------------
static Future<bool> requestForeground() async {
  // If already resolved once, reuse
  if (_cachedResult != null) {
    debugPrint("♻️ Using cached foreground permission: $_cachedResult");
    return _cachedResult!;
  }

  // If another request is running, WAIT instead of returning false
  if (_isRequesting) {
    debugPrint("⏳ Foreground permission request in progress — waiting...");
    while (_isRequesting) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    debugPrint("⏱️ Foreground request finished, result: $_cachedResult");
    return _cachedResult ?? false;
  }

  _isRequesting = true;

  try {
    debugPrint("📍 Requesting FOREGROUND location permission");

    if (Platform.isIOS) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      debugPrint("🍎 iOS location services enabled: $enabled");

      if (!enabled) {
        debugPrint("❌ iOS location services OFF");
        _cachedResult = false;
        return false;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();
      debugPrint("🍎 iOS permission status: $permission");

      if (permission == LocationPermission.denied) {
        debugPrint("🔄 Requesting iOS permission...");
        permission = await Geolocator.requestPermission();
        debugPrint("🍎 iOS permission after request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("❌ iOS permission denied forever — opening settings");
        await Geolocator.openAppSettings();
        _cachedResult = false;
        return false;
      }

      final granted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      debugPrint("✅ Foreground granted (iOS): $granted");
      _cachedResult = granted;
      return granted;
    }

    // ================= ANDROID =================
    var status = await Permission.location.status;
    debugPrint("🤖 Android foreground status: $status");

    if (!status.isGranted) {
      debugPrint("🔄 Requesting Android location permission...");
      status = await Permission.location.request();
      debugPrint("🤖 Android status after request: $status");
    }

    if (status.isPermanentlyDenied) {
      debugPrint("❌ Android permission permanently denied — opening settings");
      await openAppSettings();
      _cachedResult = false;
      return false;
    }

    debugPrint("✅ Foreground granted (Android): ${status.isGranted}");
    _cachedResult = status.isGranted;
    return status.isGranted;
  } finally {
    _isRequesting = false;
  }
}

  /// -------------------------------
  /// BACKGROUND PERMISSION
  /// -------------------------------
  static Future<bool> requestBackground(BuildContext context) async {
  debugPrint("📍 Requesting BACKGROUND location permission");

  if (Platform.isIOS) {
    final permission = await Geolocator.checkPermission();
    debugPrint("🍎 iOS background status: $permission");

    if (permission == LocationPermission.always) {
      debugPrint("✅ iOS background granted");
      return true;
    }

    debugPrint("⚠️ iOS background NOT granted – showing dialog");
    await _showIOSBackgroundDialog(context);
    return false;
  }

  var status = await Permission.locationAlways.status;
  debugPrint("🤖 Android background status: $status");

  if (!status.isGranted) {
    status = await Permission.locationAlways.request();
    debugPrint("🤖 Android background after request: $status");
  }

  if (status.isPermanentlyDenied) {
    debugPrint("❌ Android background permanently denied");
    await openAppSettings();
    return false;
  }

  debugPrint("✅ Background granted: ${status.isGranted}");
  return status.isGranted;
}
  static Future<void> _showIOSBackgroundDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enable Background Location"),
        content: const Text(
          "To allow background tracking, go to Settings → Location → "
          "set permission to 'Always'.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}