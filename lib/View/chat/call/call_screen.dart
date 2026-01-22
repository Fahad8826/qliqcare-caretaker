import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/call_controller.dart';
import 'package:qlickcare/View/chat/call/call_controls.dart';

class CallScreen extends StatelessWidget {
  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.callState.value == CallState.ended) {
          return const Center(
            child: Text(
              "Call Ended",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Stack(
          children: [
            // ================= VIDEO CALL =================
            if (controller.callType == 'video')
              Positioned.fill(
                child: RTCVideoView(
                  controller.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

            // ================= AUDIO CALL =================
            if (controller.callType == 'audio')
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Audio Call",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),

            // ================= LOCAL VIDEO (PIP) =================
            if (controller.callType == 'video')
              Positioned(
                top: 50,
                right: 20,
                width: 120,
                height: 160,
                child: RTCVideoView(
                  controller.localRenderer,
                  mirror: true,
                ),
              ),

            // ================= CONTROLS =================
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: CallControls(),
            ),
          ],
        );
      }),
    );
  }
}
