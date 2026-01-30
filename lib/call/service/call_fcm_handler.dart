import 'dart:convert' show jsonDecode;

import 'package:get/get.dart';
import 'package:qlickcare/call/controller/call_controller.dart';
import 'package:qlickcare/call/view/incoming_call_screen.dart';
import 'package:qlickcare/chat/service/websoket_chat_service.dart';

/// ✅ Handles incoming call notifications from FCM
/// This works independently of chat rooms
Future<void> handleIncomingCallFCM(Map<String, dynamic> data) async {
  print('🔵 ========================================');
  print('🔵 CALL FCM HANDLER START');
  print('🔵 ========================================');
  print('🔵 RAW DATA => $data');

  try {
    // ✅ Extract call data
    final callLogId = int.tryParse(data['call_log_id']?.toString() ?? '');
    final callerId = int.tryParse(data['caller_id']?.toString() ?? '');
    final roomId = int.tryParse(data['room_id']?.toString() ?? '');
    final callerName = data['caller_name'] ?? 'Unknown';
    final callType = data['call_type'] ?? 'audio';
    final offerData = data['offer']; // SDP offer from backend

    print('🔵 Parsed Data:');
    print('   - callLogId: $callLogId');
    print('   - callerId: $callerId');
    print('   - roomId: $roomId');
    print('   - callerName: $callerName');
    print('   - callType: $callType');
    print('   - hasOffer: ${offerData != null}');

    // ✅ Validate required data
    if (callLogId == null || callerId == null || roomId == null) {
      print('❌ Missing required call data');
      return;
    }

    // ✅ Get or create WebSocketService
    WebSocketService ws;
    if (Get.isRegistered<WebSocketService>()) {
      ws = Get.find<WebSocketService>();
      print('🔵 Using existing WebSocketService');
    } else {
      ws = Get.put(WebSocketService(), permanent: true);
      print('🔵 Created new WebSocketService');
    }

    // ✅ Connect WebSocket if not connected
    if (!ws.isConnected) {
      print('🔵 Connecting WebSocket to room $roomId...');
      await ws.connect(roomId);
      
      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!ws.isConnected) {
        print('❌ WebSocket connection failed');
        return;
      }
      print('✅ WebSocket connected');
    } else {
      print('🔵 WebSocket already connected');
    }

    // ✅ Get or create CallController
    CallController callController;
    if (Get.isRegistered<CallController>()) {
      callController = Get.find<CallController>();
      print('🔵 Using existing CallController');
    } else {
      callController = Get.put(CallController(ws), permanent: true);
      print('🔵 Created new CallController');
    }

    // ✅ Set call data on controller
    callController.callLogId = callLogId;
    callController.receiverId = callerId;
    callController.callType = callType;

    
if (offerData != null) {
  print('🔵 Processing offer from FCM...');
  
  // ✅ Parse if it's a JSON string
  Map<String, dynamic> parsedOffer = offerData is String 
      ? jsonDecode(offerData) 
      : offerData;
  
  final signal = {
    'type': 'call_offer',
    'call_log_id': callLogId,
    'caller_id': callerId,
    'caller_name': callerName,
    'call_type': callType,
    'offer': parsedOffer,  // ✅ Use parsed offer
  };
  
  ws.injectCallSignal(signal);
}
    else {
      print('⚠️ No offer in FCM data, waiting for WebSocket signal...');
      // The offer will come through WebSocket
      callController.callState.value = CallState.ringing;
    }

    // ✅ Show incoming call dialog
    if (!Get.isDialogOpen!) {
      print('🔵 Showing incoming call dialog...');
      
      Get.dialog(
        IncomingCallDialog(
          callerName: callerName,
          callType: callType,
          callController: callController,
        ),
        barrierDismissible: false,
      );
      
      print('✅ Dialog shown');
    } else {
      print('⚠️ Dialog already open, skipping');
    }

    print('🔵 ========================================');
    print('🔵 CALL FCM HANDLER COMPLETE');
    print('🔵 ========================================');
  } catch (e, stack) {
    print('❌ Error in handleIncomingCallFCM: $e');
    print('❌ Stack trace: $stack');
  }
}