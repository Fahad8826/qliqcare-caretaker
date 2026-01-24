// import 'package:permission_handler/permission_handler.dart';

// class CallPermissions {
//   static Future<void> ensureGranted() async {
//     final statuses = await [
//       Permission.camera,
//       Permission.microphone,
//     ].request();

//     if (statuses[Permission.camera] != PermissionStatus.granted ||
//         statuses[Permission.microphone] != PermissionStatus.granted) {
//       throw Exception('Camera or Microphone permission denied');
//     }
//   }
// }


import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  /// 🔥 Ask ALL required permissions at once
  static Future<bool> requestAll() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  /// 🔹 Call only permissions
  static Future<void> ensureCallPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses.values.any((s) => !s.isGranted)) {
      throw Exception('Camera/Microphone permission denied');
    }
  }

  /// 🔹 Location only
  static Future<bool> ensureLocation() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }
}

