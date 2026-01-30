
// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qlickcare/call/view/incoming_call_screen.dart';
// import 'package:qlickcare/chat/service/websoket_chat_service.dart';

// void logCall(String msg) => print('📞 CALL => $msg');
// void logRTC(String msg) => print('🎥 RTC => $msg');

// enum CallState { idle, ringing, connecting, ongoing, ended }

// class CallController extends GetxController {
//   final WebSocketService ws;

//   CallController(this.ws);

//   final callState = CallState.idle.obs;
//   final isMuted = false.obs;
//   final isVideoEnabled = true.obs;
//   final isSpeakerOn = false.obs;
//   final callDuration = 0.obs;

//   int? callLogId;
//   int? receiverId;
//   String callType = 'audio';

//   Timer? _callTimer;
//   Timer? _ringTimer;

//   RTCPeerConnection? _peer;
//   MediaStream? localStream;
//   MediaStream? remoteStream;

//   final RTCVideoRenderer localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

//   /// ✅ Queue ICE candidates until remoteDescription is ready
//   final List<RTCIceCandidate> _pendingCandidates = [];
//   RTCSessionDescription? _remoteDescription;

//   /// INIT
//   @override
//   void onInit() {
//     super.onInit();

//     logCall('Controller initialized');

//     ever(callState, (s) => logCall('STATE => $s'));

//     _initRenderers();

//     ws.connectionStream.listen((c) => logCall('WS connected => $c'));
//     ws.callStream.listen(_handleSignal);
//   }

//   Future<void> _initRenderers() async {
//     await localRenderer.initialize();
//     await remoteRenderer.initialize();
//   }

//   /// PERMISSIONS
//   Future<void> _ensurePermissions() async {
//     final statuses = await [Permission.camera, Permission.microphone].request();

//     if (statuses.values.any((e) => e != PermissionStatus.granted)) {
//       throw Exception('Permissions denied');
//     }
//   }

//   /// ✅ PUBLIC method to handle signals from FCM or WebSocket
//   Future<void> handleSignal(Map<String, dynamic> data) async {
//     await _handleSignal(data);
//   }

//   /// SIGNAL HANDLER
//   Future<void> _handleSignal(Map<String, dynamic> data) async {
//     final type = data['type'];
//     logCall('Signal => $type');

//     switch (type) {
//       /// ✅ Incoming offer
//       case 'call_offer':
//         callLogId = data['call_log_id'];
//         receiverId = data['caller_id'];
//         callType = data['call_type'];

//         logCall('Incoming call: callLogId=$callLogId, from=$receiverId, type=$callType');

//         callState.value = CallState.ringing;

//         // ✅ Create peer and set remote offer
//         await _createPeer(setRemoteOffer: data['offer']);
//         _startRingTimeout();

//         // ✅ Show UI if not already shown
//         if (!Get.isDialogOpen!) {
//           Get.dialog(
//             IncomingCallDialog(
//               callerName: data['caller_name'] ?? 'Unknown',
//               callType: callType,
//               callController: this,
//             ),
//             barrierDismissible: false,
//           );
//         }
//         break;

//       case 'incoming_call_notification':
//       logCall('📞 Incoming call notification received!');
      
//       // Same handling as call_offer
//       callLogId = data['call_log_id'];
//       receiverId = data['caller_id'];
//       callType = data['call_type'];

//       logCall('Incoming call: callLogId=$callLogId, from=$receiverId, type=$callType');

//       callState.value = CallState.ringing;

//       // ✅ Create peer and set remote offer
//       await _createPeer(setRemoteOffer: data['offer']);
//       _startRingTimeout();

//       // ✅ Show UI if not already shown
//       if (!Get.isDialogOpen!) {
//         Get.dialog(
//           IncomingCallDialog(
//             callerName: data['caller_name'] ?? 'Unknown',
//             callType: callType,
//             callController: this,
//           ),
//           barrierDismissible: false,
//         );
//       }
//       break;

//       /// ✅ Answer received for outgoing call
//       case 'call_answer':
//         callLogId = int.tryParse(data['call_log_id'].toString());

//         logCall('Answer received callLogId=$callLogId');

//         final answer = RTCSessionDescription(
//           data['answer']['sdp'],
//           data['answer']['type'],
//         );
//         await _peer?.setRemoteDescription(answer);
//         _remoteDescription = answer;

//         /// ✅ After remote description is set -> add queued ICE candidates
//         await _flushPendingIceCandidates();

//         callState.value = CallState.ongoing;
//         _startCallTimer();
//         break;

//       /// ✅ ICE candidate
//       case 'ice_candidate':
//         logRTC('ICE received');

//         final candidate = RTCIceCandidate(
//           data['candidate']['candidate'],
//           data['candidate']['sdpMid'],
//           data['candidate']['sdpMLineIndex'],
//         );

//         /// ✅ If remoteDescription not set yet, queue ICE
//         if (_peer == null || _remoteDescription == null) {
//           logRTC('ICE queued (remoteDescription not set yet)');
//           _pendingCandidates.add(candidate);
//         } else {
//           await _peer!.addCandidate(candidate);
//         }
//         break;

//       case 'call_end':
//       case 'call_ended':
//       case 'call_decline':
//         endCall(remote: true);
//         break;
//     }
//   }

//   /// START CALL (Outgoing)
//   Future<void> startCall({
//     required int receiverId,
//     required String type,
//   }) async {
//     logCall('Starting $type call → $receiverId');

//     await _ensurePermissions();

//     this.receiverId = receiverId;
//     callType = type;
//     callState.value = CallState.connecting;

//     await _createPeer();

//     final offer = await _peer!.createOffer();
//     await _peer!.setLocalDescription(offer);

//     logRTC('Offer created');

//     ws.send({
//       'type': 'call_offer',
//       'receiver_id': receiverId,
//       'call_type': type,
//       'offer': offer.toMap(),
//     });

//     _startRingTimeout();
//   }

//   /// ACCEPT (Incoming)
//   Future<void> acceptCall() async {
//     logCall('Accepting call');

//     await _ensurePermissions();

//     /// ✅ IMPORTANT: must have peer + remote offer already set
//     if (_peer == null || _remoteDescription == null) {
//       logCall("❌ Cannot accept call: remote offer not set yet");
//       return;
//     }

//     final answer = await _peer!.createAnswer();
//     await _peer!.setLocalDescription(answer);

//     ws.sendCallAnswer(callLogId: callLogId!, answer: answer.toMap());

//     /// ✅ flush ICE after local description too
//     await _flushPendingIceCandidates();

//     callState.value = CallState.ongoing;
//     _startCallTimer();
//   }

//   void declineCall() {
//     logCall('Decline call');
//     if (callLogId != null) ws.declineCall(callLogId!);
//     endCall();
//   }

//   void endCall({bool remote = false}) {
//     logCall('End call remote=$remote');

//     if (!remote && callLogId != null) ws.endCall(callLogId!);

//     _cleanup();
//     callState.value = CallState.ended;
//   }

//   /// WEBRTC
//   Future<void> _createPeer({Map<String, dynamic>? setRemoteOffer}) async {
//     logRTC('Creating peer');

//     await _ensurePermissions();

//     /// ✅ If localStream was disposed earlier, recreate it
//     if (localStream == null) {
//       localStream = await webrtc.navigator.mediaDevices.getUserMedia({
//         'audio': true,
//         'video': callType == 'video',
//       });

//       localRenderer.srcObject = localStream;
//       logRTC('Local stream created');
//     }

//     /// ✅ Create peer only once
//     if (_peer == null) {
//       _peer = await createPeerConnection({
//         'iceServers': [
//           {'urls': 'stun:stun.l.google.com:19302'},
//         ],
//       });

//       final tracks = localStream?.getTracks() ?? [];
//       logRTC("Local tracks count: ${tracks.length}");

//       if (tracks.isEmpty) {
//         throw Exception("No tracks found in localStream");
//       }

//       /// ✅ Add all tracks safely
//       for (final track in tracks) {
//         await _peer!.addTrack(track, localStream!);
//       }

//       _peer!.onTrack = (e) {
//         if (e.streams.isNotEmpty) {
//           remoteStream = e.streams.first;
//           remoteRenderer.srcObject = remoteStream;
//           logRTC('Remote stream attached');
//         }
//       };

//       _peer!.onIceCandidate = (c) {
//         if (c.candidate != null && callLogId != null) {
//           logRTC('ICE generated');
//           ws.sendIceCandidate(callLogId: callLogId!, candidate: c.toMap());
//         }
//       };
//     }

//     /// ✅ Incoming call offer -> set remote description
//     if (setRemoteOffer != null) {
//       final offer = RTCSessionDescription(
//         setRemoteOffer['sdp'],
//         setRemoteOffer['type'],
//       );
//       await _peer!.setRemoteDescription(offer);
//       _remoteDescription = offer;
//       logRTC('Remote offer set');

//       /// ✅ After remote offer is set -> flush queued ICE
//       await _flushPendingIceCandidates();
//     }
//   }

//   /// ✅ Flush ICE candidates queued earlier
//   Future<void> _flushPendingIceCandidates() async {
//     if (_peer == null || _remoteDescription == null) return;

//     if (_pendingCandidates.isNotEmpty) {
//       logRTC("Flushing ${_pendingCandidates.length} queued ICE candidates");
//     }

//     for (final c in _pendingCandidates) {
//       await _peer!.addCandidate(c);
//     }

//     _pendingCandidates.clear();
//   }

//   // ======================
//   // CONTROLS
//   // ======================
//   void toggleMute() {
//     isMuted.toggle();
//     localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted.value);
//   }

//   void toggleVideo() {
//     isVideoEnabled.toggle();
//     localStream?.getVideoTracks().forEach(
//       (t) => t.enabled = isVideoEnabled.value,
//     );
//   }

//   void toggleSpeaker() {
//     isSpeakerOn.toggle();
//     webrtc.Helper.setSpeakerphoneOn(isSpeakerOn.value);
//   }

//   void switchCamera() {
//     final tracks = localStream?.getVideoTracks();
//     if (tracks != null && tracks.isNotEmpty) {
//       webrtc.Helper.switchCamera(tracks.first);
//     }
//   }

//   /// TIMER
//   void _startCallTimer() {
//     _callTimer?.cancel();
//     callDuration.value = 0;
//     _callTimer = Timer.periodic(
//       const Duration(seconds: 1),
//       (_) => callDuration.value++,
//     );
//   }

//   void _startRingTimeout() {
//     _ringTimer?.cancel();
//     _ringTimer = Timer(const Duration(seconds: 30), () => declineCall());
//   }

//   /// CLEANUP
//   void _cleanup() {
//     logCall('Cleanup');

//     _callTimer?.cancel();
//     _ringTimer?.cancel();

//     _peer?.close();
//     _peer = null;

//     localStream?.dispose();
//     remoteStream?.dispose();

//     /// ✅ IMPORTANT FIX
//     localStream = null;
//     remoteStream = null;

//     localRenderer.srcObject = null;
//     remoteRenderer.srcObject = null;

//     _pendingCandidates.clear();
//     _remoteDescription = null;
//   }

//   @override
//   void onClose() {
//     _cleanup();
//     localRenderer.dispose();
//     remoteRenderer.dispose();
//     super.onClose();
//   }
// }


import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:permission_handler/permission_handler.dart';
import 'package:qlickcare/call/view/incoming_call_screen.dart';
import 'package:qlickcare/chat/service/websoket_chat_service.dart';

void logCall(String msg) => print('📞 CALL => $msg');
void logRTC(String msg) => print('🎥 RTC => $msg');

enum CallState { idle, ringing, connecting, ongoing, ended }

class CallController extends GetxController {
  final WebSocketService ws;

  CallController(this.ws);

  final callState = CallState.idle.obs;
  final isMuted = false.obs;
  final isVideoEnabled = true.obs;
  final isSpeakerOn = false.obs;
  final callDuration = 0.obs;

  int? callLogId;
  int? receiverId;
  String callType = 'audio';

  Timer? _callTimer;
  Timer? _ringTimer;

  RTCPeerConnection? _peer;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  final List<RTCIceCandidate> _pendingCandidates = [];
  RTCSessionDescription? _remoteDescription;

  // =====================
  // INIT
  // =====================
  @override
  void onInit() {
    super.onInit();

    logCall('Controller initialized');
    ever(callState, (s) => logCall('STATE => $s'));

    _initRenderers();

    ws.connectionStream.listen((c) => logCall('WS connected => $c'));
    ws.callStream.listen(_handleSignal);
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  // =====================
  // PERMISSIONS
  // =====================
  Future<void> _ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses.values.any((e) => e != PermissionStatus.granted)) {
      throw Exception('Permissions denied');
    }
  }

  // =====================
  // SIGNAL HANDLER
  // =====================
  Future<void> handleSignal(Map<String, dynamic> data) async {
    await _handleSignal(data);
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final type = data['type'];
    final senderId = data['sender_id'];

    // ✅ Ignore signals after call already ended
    if (callState.value == CallState.ended) {
      logCall('Ignoring $type (call already ended)');
      return;
    }

    // ✅ Ignore self-sent signals
    if (senderId != null && senderId == receiverId) {
      logCall('Ignoring self signal: $type');
      return;
    }

    logCall('Signal => $type');

    switch (type) {
      case 'call_offer':
      case 'incoming_call_notification':
        callLogId = data['call_log_id'];
        receiverId = data['caller_id'];
        callType = data['call_type'];

        callState.value = CallState.ringing;

        await _createPeer(setRemoteOffer: data['offer']);
        _startRingTimeout();

        if (!Get.isDialogOpen!) {
          Get.dialog(
            IncomingCallDialog(
              callerName: data['caller_name'] ?? 'Unknown',
              callType: callType,
              callController: this,
            ),
            barrierDismissible: false,
          );
        }
        break;

      case 'call_answer':
        callLogId = int.tryParse(data['call_log_id'].toString());

        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        await _peer?.setRemoteDescription(answer);
        _remoteDescription = answer;
        await _flushPendingIceCandidates();

        callState.value = CallState.ongoing;
        _startCallTimer();
        break;

      case 'ice_candidate':
        final candidate = RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        );

        if (_peer == null || _remoteDescription == null) {
          _pendingCandidates.add(candidate);
        } else {
          await _peer!.addCandidate(candidate);
        }
        break;

      case 'call_decline':
        if (callState.value == CallState.ringing) {
          endCall(remote: true);
        }
        break;

      case 'call_end':
      case 'call_ended':
        if (callState.value == CallState.ongoing) {
          endCall(remote: true);
        }
        break;
    }
  }

  // =====================
  // START CALL
  // =====================
  Future<void> startCall({
    required int receiverId,
    required String type,
  }) async {
    await _ensurePermissions();

    this.receiverId = receiverId;
    callType = type;
    callState.value = CallState.connecting;

    await _createPeer();

    final offer = await _peer!.createOffer();
    await _peer!.setLocalDescription(offer);

    ws.send({
      'type': 'call_offer',
      'receiver_id': receiverId,
      'call_type': type,
      'offer': offer.toMap(),
    });

    _startRingTimeout();
  }

  // =====================
  // ACCEPT CALL
  // =====================
  Future<void> acceptCall() async {
    await _ensurePermissions();

    if (_peer == null || _remoteDescription == null) return;

    final answer = await _peer!.createAnswer();
    await _peer!.setLocalDescription(answer);

    ws.sendCallAnswer(callLogId: callLogId!, answer: answer.toMap());
    await _flushPendingIceCandidates();

    callState.value = CallState.ongoing;
    _startCallTimer();
  }

  // =====================
  // DECLINE / END
  // =====================
  void declineCall() {
    if (callLogId != null) ws.declineCall(callLogId!);
    _cleanup();
    callState.value = CallState.ended;
  }

  void endCall({bool remote = false}) {
    if (callState.value == CallState.ended) return;

    if (!remote && callLogId != null) {
      ws.endCall(callLogId!);
    }

    _cleanup();
    callState.value = CallState.ended;
  }

  // =====================
  // WEBRTC
  // =====================
  Future<void> _createPeer({Map<String, dynamic>? setRemoteOffer}) async {
    await _ensurePermissions();

    if (localStream == null) {
      localStream = await webrtc.navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': callType == 'video',
      });
      localRenderer.srcObject = localStream;
    }

    if (_peer == null) {
      _peer = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });

      for (final track in localStream!.getTracks()) {
        await _peer!.addTrack(track, localStream!);
      }

      _peer!.onTrack = (e) {
        if (e.streams.isNotEmpty) {
          remoteStream = e.streams.first;
          remoteRenderer.srcObject = remoteStream;
        }
      };

      _peer!.onIceCandidate = (c) {
        if (c.candidate != null && callLogId != null) {
          ws.sendIceCandidate(callLogId: callLogId!, candidate: c.toMap());
        }
      };
    }

    if (setRemoteOffer != null) {
      final offer = RTCSessionDescription(
        setRemoteOffer['sdp'],
        setRemoteOffer['type'],
      );
      await _peer!.setRemoteDescription(offer);
      _remoteDescription = offer;
      await _flushPendingIceCandidates();
    }
  }

  Future<void> _flushPendingIceCandidates() async {
    if (_peer == null || _remoteDescription == null) return;
    for (final c in _pendingCandidates) {
      await _peer!.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  // =====================
  // TIMERS
  // =====================
  void _startCallTimer() {
    _callTimer?.cancel();
    callDuration.value = 0;
    _callTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => callDuration.value++,
    );
  }

  void _startRingTimeout() {
    _ringTimer?.cancel();
    _ringTimer = Timer(const Duration(seconds: 30), () {
      if (callState.value == CallState.ringing) declineCall();
    });
  }


  void toggleMute() {
    isMuted.toggle();
    localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted.value);
  }


    void toggleVideo() {
    isVideoEnabled.toggle();
    localStream?.getVideoTracks().forEach(
      (t) => t.enabled = isVideoEnabled.value,
    );
  }

  void toggleSpeaker() {
    isSpeakerOn.toggle();
    webrtc.Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  void switchCamera() {
    final tracks = localStream?.getVideoTracks();
    if (tracks != null && tracks.isNotEmpty) {
      webrtc.Helper.switchCamera(tracks.first);
    }
  }

  // =====================
  // CLEANUP
  // =====================
  void _cleanup() {
    _callTimer?.cancel();
    _ringTimer?.cancel();

    _peer?.close();
    _peer = null;

    localStream?.dispose();
    remoteStream?.dispose();

    localStream = null;
    remoteStream = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    _pendingCandidates.clear();
    _remoteDescription = null;
  }

  @override
  void onClose() {
    _cleanup();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }
}
