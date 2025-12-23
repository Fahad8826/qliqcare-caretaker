// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:qlickcare/Services/locationservice.dart';

// class LocationController extends GetxController {
//   Timer? _timer;

//   /// Start background polling
//   void startLocationUpdates({int seconds = 10}) {
//     print("🔄 Auto location update started (every $seconds seconds)");

//     _timer?.cancel(); // Avoid multiple timers

//     _timer = Timer.periodic(Duration(seconds: seconds), (timer) async {
//       print("⏰ Timer tick → fetching location...");
//       await LocationService.updateCurrentLocationToDB();
//     });
//   }

//   /// Stop background polling
//   void stopLocationUpdates() {
//     print("🛑 Auto location update stopped");
//     _timer?.cancel();
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }
// }
import 'package:get/get.dart';
import 'package:qlickcare/Services/locationservice.dart';

class LocationController extends GetxController {

  void startTracking() {
    LocationService.startBackgroundLocation();
  }

  void stopTracking() {
    LocationService.stopBackgroundLocation();
  }
}
