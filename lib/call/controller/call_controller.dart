// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qlickcare/chat/service/websoket_chat_service.dart';

// enum CallState {
//   idle,
//   ringing,
//   connecting,
//   ongoing,
//   ended,
// }

// class CallController extends GetxController {
//   final WebSocketService ws;

//   CallController(this.ws);

//   // ======================
//   // STATE
//   // ======================
//   final callState = CallState.idle.obs;
//   final isMuted = false.obs;
//   final isVideoEnabled = true.obs;
//   final isSpeakerOn = false.obs;
//   final callDuration = 0.obs;

//   int? callLogId;
//   int? receiverId;
//   String callType = 'audio'; // audio | video

//   Timer? _callTimer;
//   Timer? _ringTimer;

//   // ======================
//   // WEBRTC
//   // ======================
//   RTCPeerConnection? _peer;
//   MediaStream? localStream;
//   MediaStream? remoteStream;

//   final RTCVideoRenderer localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

//   // ======================
//   // INIT
//   // ======================
//   @override
//   void onInit() {
//     super.onInit();
//     _initRenderers();
//     ws.callStream.listen(_handleSignal);
//   }

//   Future<void> _initRenderers() async {
//     await localRenderer.initialize();
//     await remoteRenderer.initialize();
//   }

//   // ======================
//   // PERMISSIONS
//   // ======================
//   Future<void> _ensurePermissions() async {
//     final statuses = await [
//       Permission.camera,
//       Permission.microphone,
//     ].request();

//     if (statuses[Permission.camera] != PermissionStatus.granted ||
//         statuses[Permission.microphone] != PermissionStatus.granted) {
//       throw Exception('Camera or Microphone permission denied');
//     }
//   }

//   // ======================
//   // SIGNAL HANDLER
//   // ======================
//   Future<void> _handleSignal(Map<String, dynamic> data) async {
//     final type = data['type'];
//     print('📞 Call signal received: $type');

//     switch (type) {
//       case 'call_offer':
//         callLogId = data['call_log_id'];
//         receiverId = data['caller_id'];
//         callType = data['call_type'];

//         callState.value = CallState.ringing;
//         _startRingTimeout();

//         await _createPeer(setRemoteOffer: data['offer']);
//         break;

//       case 'call_answer':
//         if (_peer == null) return;

//         await _peer!.setRemoteDescription(
//           RTCSessionDescription(
//             data['answer']['sdp'],
//             data['answer']['type'],
//           ),
//         );

//         callState.value = CallState.ongoing;
//         _startCallTimer();
//         break;

//       case 'ice_candidate':
//         if (_peer == null) return;

//         await _peer!.addCandidate(
//           RTCIceCandidate(
//             data['candidate']['candidate'],
//             data['candidate']['sdpMid'],
//             data['candidate']['sdpMLineIndex'],
//           ),
//         );
//         break;

//       case 'call_end':
//       case 'call_ended':
//       case 'call_decline':
//         endCall(remote: true);
//         break;
//     }
//   }

//   // ======================
//   // OUTGOING CALL
//   // ======================
//   Future<void> startCall({
//     required int receiverId,
//     required String type,
//   }) async {
//     try {
//       print('📞 Starting $type call to user $receiverId');

//       await _ensurePermissions();

//       this.receiverId = receiverId;
//       callType = type;
//       callState.value = CallState.connecting;

//       await _createPeer();

//       final offer = await _peer!.createOffer();
//       await _peer!.setLocalDescription(offer);

//       ws.send({
//         'type': 'call_offer',
//         'receiver_id': receiverId,
//         'call_type': type,
//         'offer': offer.toMap(),
//       });

//       _startRingTimeout();
//     } catch (e) {
//       print('❌ Start call error: $e');
//       _cleanup();
//       callState.value = CallState.idle;
//     }
//   }

//   // ======================
//   // INCOMING CALL ACCEPT
//   // ======================
//   Future<void> acceptCall() async {
//     try {
//       await _ensurePermissions();

//       if (_peer == null) {
//         await _createPeer();
//       }

//       final answer = await _peer!.createAnswer();
//       await _peer!.setLocalDescription(answer);

//       ws.sendCallAnswer(
//         callLogId: callLogId!,
//         answer: answer.toMap(),
//       );

//       callState.value = CallState.ongoing;
//       _startCallTimer();
//     } catch (e) {
//       print('❌ Accept call error: $e');
//       declineCall();
//     }
//   }

//   void declineCall() {
//     if (callLogId != null) {
//       ws.declineCall(callLogId!);
//     }
//     endCall();
//   }

//   // ======================
//   // END CALL
//   // ======================
//   void endCall({bool remote = false}) {
//     if (!remote && callLogId != null) {
//       ws.endCall(callLogId!);
//     }
//     _cleanup();
//     callState.value = CallState.ended;
//   }

//   // ======================
//   // CONTROLS
//   // ======================
//   void toggleMute() {
//     isMuted.toggle();
//     localStream?.getAudioTracks().forEach(
//       (t) => t.enabled = !isMuted.value,
//     );
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

//   // ======================
//   // WEBRTC CORE
//   // ======================
//   Future<void> _createPeer({Map<String, dynamic>? setRemoteOffer}) async {
//     if (_peer != null && localStream != null) return;

//     await _ensurePermissions();

//     localStream ??= await webrtc.navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': callType == 'video',
//     });

//     localRenderer.srcObject = localStream;

//     _peer ??= await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//         {'urls': 'stun:stun1.l.google.com:19302'},
//       ],
//     });

//     for (var track in localStream!.getTracks()) {
//       await _peer!.addTrack(track, localStream!);
//     }

//     _peer!.onTrack = (event) {
//       if (event.streams.isNotEmpty) {
//         remoteStream = event.streams.first;
//         remoteRenderer.srcObject = remoteStream;
//       }
//     };

//     _peer!.onIceCandidate = (candidate) {
//       if (candidate.candidate != null && callLogId != null) {
//         ws.sendIceCandidate(
//           callLogId: callLogId!,
//           candidate: candidate.toMap(),
//         );
//       }
//     };

//     if (setRemoteOffer != null) {
//       await _peer!.setRemoteDescription(
//         RTCSessionDescription(
//           setRemoteOffer['sdp'],
//           setRemoteOffer['type'],
//         ),
//       );
//     }
//   }

//   // ======================
//   // TIMERS
//   // ======================
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
//     _ringTimer = Timer(const Duration(seconds: 30), () {
//       if (callState.value == CallState.ringing ||
//           callState.value == CallState.connecting) {
//         declineCall();
//       }
//     });
//   }

//   // ======================
//   // CLEANUP
//   // ======================
//   void _cleanup() {
//     _callTimer?.cancel();
//     _ringTimer?.cancel();

//     _peer?.close();
//     _peer = null;

//     localStream?.getTracks().forEach((t) => t.stop());
//     localStream?.dispose();
//     localStream = null;

//     remoteStream?.dispose();
//     remoteStream = null;

//     localRenderer.srcObject = null;
//     remoteRenderer.srcObject = null;

//     callLogId = null;
//     receiverId = null;
//     isMuted.value = false;
//     isVideoEnabled.value = true;
//     callDuration.value = 0;
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

  /// INIT
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

  /// PERMISSIONS
  Future<void> _ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();

    if (statuses.values.any((e) => e != PermissionStatus.granted)) {
      throw Exception('Permissions denied');
    }
  }

  /// SIGNAL HANDLER
  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final type = data['type'];
    logCall('Signal => $type');

    switch (type) {
      case 'call_offer':
        callLogId = data['call_log_id'];
        receiverId = data['caller_id'];
        callType = data['call_type'];

        callState.value = CallState.ringing;

        await _createPeer(setRemoteOffer: data['offer']);
        _startRingTimeout();
        break;

      case 'call_answer':
        callLogId = data['call_log_id']; // ⭐ VERY IMPORTANT

        logCall('Answer received callLogId=$callLogId');

        await _peer?.setRemoteDescription(
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
        );

        callState.value = CallState.ongoing;
        _startCallTimer();
        break;

      case 'ice_candidate':
        logRTC('ICE received');

        await _peer?.addCandidate(
          RTCIceCandidate(
            data['candidate']['candidate'],
            data['candidate']['sdpMid'],
            data['candidate']['sdpMLineIndex'],
          ),
        );
        break;

      case 'call_end':
      case 'call_ended':
      case 'call_decline':
        endCall(remote: true);
        break;
    }
  }

  /// START CALL
  Future<void> startCall({
    required int receiverId,
    required String type,
  }) async {
    logCall('Starting $type call → $receiverId');

    await _ensurePermissions();

    this.receiverId = receiverId;
    callType = type;
    callState.value = CallState.connecting;

    await _createPeer();

    final offer = await _peer!.createOffer();
    await _peer!.setLocalDescription(offer);

    logRTC('Offer created');

    ws.send({
      'type': 'call_offer',
      'receiver_id': receiverId,
      'call_type': type,
      'offer': offer.toMap(),
    });

    _startRingTimeout();
  }

  /// ACCEPT
  Future<void> acceptCall() async {
    logCall('Accepting call');

    await _ensurePermissions();

    final answer = await _peer!.createAnswer();
    await _peer!.setLocalDescription(answer);

    ws.sendCallAnswer(callLogId: callLogId!, answer: answer.toMap());

    callState.value = CallState.ongoing;
    _startCallTimer();
  }

  void declineCall() {
    logCall('Decline call');
    if (callLogId != null) ws.declineCall(callLogId!);
    endCall();
  }

  void endCall({bool remote = false}) {
    logCall('End call remote=$remote');

    if (!remote && callLogId != null) ws.endCall(callLogId!);

    _cleanup();
    callState.value = CallState.ended;
  }

  /// WEBRTC
  Future<void> _createPeer({Map<String, dynamic>? setRemoteOffer}) async {
    if (_peer != null) return;

    logRTC('Creating peer');

    localStream ??= await webrtc.navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': callType == 'video',
    });

    localRenderer.srcObject = localStream;

    _peer = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    for (var track in localStream!.getTracks()) {
      await _peer!.addTrack(track, localStream!);
    }

    _peer!.onTrack = (e) {
      remoteStream = e.streams.first;
      remoteRenderer.srcObject = remoteStream;
      logRTC('Remote stream attached');
    };

    _peer!.onIceCandidate = (c) {
      if (c.candidate != null && callLogId != null) {
        logRTC('ICE generated');
        ws.sendIceCandidate(callLogId: callLogId!, candidate: c.toMap());
      }
    };

    if (setRemoteOffer != null) {
      await _peer!.setRemoteDescription(
        RTCSessionDescription(setRemoteOffer['sdp'], setRemoteOffer['type']),
      );
      logRTC('Remote offer set');
    }
  }

  //   // ======================
  //   // CONTROLS
  //   // ======================
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

  /// TIMER
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
    _ringTimer = Timer(const Duration(seconds: 30), () => declineCall());
  }

  /// CLEANUP
  void _cleanup() {
    logCall('Cleanup');

    _callTimer?.cancel();
    _ringTimer?.cancel();

    _peer?.close();
    _peer = null;

    localStream?.dispose();
    remoteStream?.dispose();

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  @override
  void onClose() {
    _cleanup();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }
}
