import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/chat/service/callpermisson.dart';

class AllPermissionPage extends StatefulWidget {
  const AllPermissionPage({super.key});

  @override
  State<AllPermissionPage> createState() => _AllPermissionPageState();
}

class _AllPermissionPageState extends State<AllPermissionPage> {
  bool camera = false;
  bool mic = false;
  bool location = false;
  bool notification = false;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    camera = await Permission.camera.isGranted;
    mic = await Permission.microphone.isGranted;
    location = await Permission.locationAlways.isGranted ||
        await Permission.locationWhenInUse.isGranted;
    notification = await Permission.notification.isGranted;

    setState(() {});
  }

  bool get allGranted => camera && mic && location && notification;

  // ===============================
  // PERMISSION ALERT DIALOG
  // ===============================
  Future<void> _showPermissionDialog({
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: AppTextStyles.heading2),
        content: Text(message, style: AppTextStyles.body),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(actionText, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionToggle({
    required Permission permission,
    required String permissionName,
    required String enableMessage,
    required String disableMessage,
  }) async {
    final isGranted = await permission.isGranted;

    if (!isGranted) {
      // Turn ON
      await _showPermissionDialog(
        title: "$permissionName Permission",
        message: enableMessage,
        actionText: "Allow",
        onConfirm: () async {
          final status = await permission.request();
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          _loadStatuses();
        },
      );
    } else {
      // Turn OFF (Open Settings)
      await _showPermissionDialog(
        title: "Disable $permissionName?",
        message: disableMessage,
        actionText: "Open Settings",
        onConfirm: () async {
          await openAppSettings();
          _loadStatuses();
        },
      );
    }
  }

  Future<void> _requestAll() async {
    final granted = await AppPermissions.requestAll();

    if (granted) {
      Get.offAllNamed('/MainHome');
    } else {
      _loadStatuses();
      Get.snackbar(
        "Permissions required",
        "Please allow all permissions to continue",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Permissions",
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enable permissions to continue",
              style: AppTextStyles.heading2.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              "We require these permissions for business support, ticketing, and communication features.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            _PermissionCard(
              title: "Camera",
              subtitle: "Required for video calls",
              icon: Icons.videocam_rounded,
              granted: camera,
              onToggle: () => _handlePermissionToggle(
                permission: Permission.camera,
                permissionName: "Camera",
                enableMessage:
                    "We use the camera for video calls and to help users share visual information during support and ticketing.",
                disableMessage:
                    "If you disable camera access, video calling will not work properly.",
              ),
            ),

            const SizedBox(height: 14),

            _PermissionCard(
              title: "Microphone",
              subtitle: "Required for voice calls",
              icon: Icons.mic_rounded,
              granted: mic,
              onToggle: () => _handlePermissionToggle(
                permission: Permission.microphone,
                permissionName: "Microphone",
                enableMessage:
                    "We use the microphone for voice calls and business communication between users.",
                disableMessage:
                    "If you disable microphone access, voice calling will not work properly.",
              ),
            ),

            const SizedBox(height: 14),

            _PermissionCard(
              title: "Location",
              subtitle: "Required for better service support",
              icon: Icons.location_on_rounded,
              granted: location,
              onToggle: () => _handlePermissionToggle(
                permission: Permission.locationWhenInUse,
                permissionName: "Location",
                enableMessage:
                    "We use location to improve support service availability and request handling.",
                disableMessage:
                    "If you disable location access, some location-based services may not work properly.",
              ),
            ),

            const SizedBox(height: 14),

            _PermissionCard(
              title: "Notifications",
              subtitle: "Required for ticket updates & alerts",
              icon: Icons.notifications_active_rounded,
              granted: notification,
              onToggle: () => _handlePermissionToggle(
                permission: Permission.notification,
                permissionName: "Notifications",
                enableMessage:
                    "We use notifications to keep you updated about support messages, ticket updates, and incoming calls.",
                disableMessage:
                    "If you disable notifications, you may miss ticket updates, calls, or important alerts.",
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      allGranted ? AppColors.primary : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _requestAll,
                child: Text(
                  "Continue",
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// PERMISSION CARD WIDGET
// ===============================
class _PermissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool granted;
  final VoidCallback onToggle;

  const _PermissionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.granted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: granted,
            activeColor: AppColors.primary,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
