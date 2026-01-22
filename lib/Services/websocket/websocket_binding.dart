// import 'package:get/get.dart';
// import 'package:qlickcare/Services/websocket/websoket_chat_service.dart';

// import 'package:qlickcare/controllers/chat_controller.dart';
// import 'package:qlickcare/Controllers/call_controller.dart';

// class AppBinding extends Bindings {
//   @override
//   void dependencies() {
//     // 🔹 ONE WebSocketService for whole app
//     Get.put<WebSocketService>(
//       WebSocketService(),
//       permanent: true,
//     );

//     // 🔹 Chat controller
//     Get.put<ChatController>(
//       ChatController(),
//       permanent: true,
//     );

//     // 🔹 Call controller (uses SAME websocket)
//     Get.put<CallController>(
//       CallController(Get.find<WebSocketService>()),
//       permanent: true,
//     );
//   }
// }
