import 'package:permission_handler/permission_handler.dart';

class CallPermissions {
  static Future<void> ensureGranted() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      throw Exception('Camera or Microphone permission denied');
    }
  }
}
