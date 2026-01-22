import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/call_controller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/View/chat/call/call_screen.dart';

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final String callType; // 'audio' or 'video'
  final CallController callController;

  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.callType,
    required this.callController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismiss
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.98),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.08),
                  child: Column(
                    children: [
                      Text(
                        'Incoming ${callType == 'video' ? 'Video' : 'Audio'} Call',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      // Caller avatar with glow
                      _buildCallerAvatar(size),
                      SizedBox(height: size.height * 0.03),
                      // Caller name
                      Text(
                        callerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'is calling you...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom buttons
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline button
                      _buildActionButton(
                        icon: Icons.call_end,
                        label: 'Decline',
                        color: Colors.red,
                        onPressed: () {
                          callController.declineCall();
                          Get.back(); // Close dialog
                        },
                      ),
                      // Accept button
                      _buildActionButton(
                        icon: callType == 'video'
                            ? Icons.videocam
                            : Icons.call,
                        label: 'Accept',
                        color: Colors.green,
                        onPressed: () async {
                          Get.back(); // Close dialog
                          await callController.acceptCall();
                          Get.to(() => CallScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallerAvatar(Size size) {
    final initial = callerName.isNotEmpty ? callerName[0].toUpperCase() : '?';

    return Container(
      width: size.width * 0.35,
      height: size.width * 0.35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size.width * 0.15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                icon,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Helper function to show incoming call
void showIncomingCallDialog({
  required BuildContext context,
  required String callerName,
  required String callType,
  required CallController callController,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => IncomingCallDialog(
      callerName: callerName,
      callType: callType,
      callController: callController,
    ),
  );
}