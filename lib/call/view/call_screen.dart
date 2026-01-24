import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:qlickcare/call/controller/call_controller.dart';
import 'package:qlickcare/call/view/call_controls.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallController controller = Get.find<CallController>();

  @override
  void initState() {
    super.initState();

    /// ✅ listen once for call end
    ever(controller.callState, (state) {
      if (state == CallState.ended) {
        _goBackAfterDelay();
      }
    });
  }

  void _goBackAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted && Get.isOverlaysOpen == false) {
      Get.back(); // ✅ go to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        /// ================= ENDED UI =================
        if (controller.callState.value == CallState.ended) {
          return const Center(
            child: Text(
              "Call Ended",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return Stack(
          children: [
            /// ================= REMOTE VIDEO =================
            if (controller.callType == 'video')
              Positioned.fill(
                child: RTCVideoView(
                  controller.remoteRenderer,
                  objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

            /// ================= AUDIO UI =================
            if (controller.callType == 'audio')
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              ),

            /// ================= LOCAL PIP =================
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

            /// ================= CONTROLS =================
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
