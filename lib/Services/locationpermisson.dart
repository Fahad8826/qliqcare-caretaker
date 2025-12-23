import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHelper {
  static bool _requestInProgress = false;

  static Future<bool> requestForeground() async {
    if (_requestInProgress) {
      print("⏳ Permission request already running");
      return false;
    }

    _requestInProgress = true;

    final status = await Permission.locationWhenInUse.request();

    _requestInProgress = false;

    print("📍 Foreground permission status: $status");
    return status.isGranted;
  }
}
