import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/call/controller/call_controller.dart';

class CallControls extends StatelessWidget {
  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 🔇 MUTE
          _circleButton(
            icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
            color: controller.isMuted.value ? Colors.red : Colors.grey,
            onTap: controller.toggleMute,
          ),

          // 🔊 SPEAKER (AUDIO ONLY)
          if (controller.callType == 'audio')
            _circleButton(
              icon: controller.isSpeakerOn.value
                  ? Icons.volume_up
                  : Icons.volume_down,
              color: Colors.grey,
              onTap: controller.toggleSpeaker,
            ),

          // 🎥 VIDEO TOGGLE (VIDEO ONLY)
          if (controller.callType == 'video')
            _circleButton(
              icon: controller.isVideoEnabled.value
                  ? Icons.videocam
                  : Icons.videocam_off,
              color: Colors.grey,
              onTap: controller.toggleVideo,
            ),

          // 🔄 SWITCH CAMERA (VIDEO ONLY)
          if (controller.callType == 'video')
            _circleButton(
              icon: Icons.cameraswitch,
              color: Colors.grey,
              onTap: controller.switchCamera,
            ),

          // ❌ END CALL
          _circleButton(
            icon: Icons.call_end,
            color: Colors.red,
            onTap: controller.endCall,
          ),
        ],
      );
    });
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
