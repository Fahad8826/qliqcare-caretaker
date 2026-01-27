import 'package:get/get.dart';
import 'package:qlickcare/call/controller/call_controller.dart';
import 'package:qlickcare/call/view/incoming_call_screen.dart';
import 'package:qlickcare/chat/service/websoket_chat_service.dart';

Future<void> handleIncomingCallFCM(
  
  Map<String, dynamic> data,
) async {
   print('🔵 CALL FCM HANDLER START');
  print('🔵 DATA => $data');
  final roomId = int.parse(data['room_id']);
  print('🔵 Parsed roomId = $roomId');
  final callerName = data['caller_name'] ?? 'Unknown';
  final callType = data['call_type'] ?? 'audio';

  /// 1️⃣ Ensure WebSocketService exists
  final ws = Get.put(WebSocketService(), permanent: true);
print('🔵 WS connected before? ${ws.isConnected}');
  /// 2️⃣ Connect WebSocket (if not connected)
  if (!ws.isConnected) {
    await ws.connect(roomId);
  }

  /// 3️⃣ Ensure CallController exists
  final callController = Get.put(
    CallController(ws),
    permanent: true,
  );

  /// 4️⃣ Show incoming call UI
  Get.dialog(
    IncomingCallDialog(
      callerName: callerName,
      callType: callType,
      callController: callController,
    ),
    barrierDismissible: false,
  );
}
