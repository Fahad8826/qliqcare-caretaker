import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlickcare/Controllers/logoutcontroller.dart';
import 'package:qlickcare/Controllers/whtasappcontroller.dart';
import 'package:qlickcare/Controllers/profilecontroller.dart';
import 'package:qlickcare/Services/logoutdailoge.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final P_Controller profileController = Get.put(P_Controller());
    final WhatsAppLauncherController waController = Get.put(
      WhatsAppLauncherController(),
    );
    final profile = profileController.profile.value;

    // Responsive sizes
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double padding = w * 0.05;

    return ClipRRect(
      child: Drawer(
        width: w * 0.78,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ------------------ TOP HEADER ------------------
              Container(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  h * 0.10,
                  padding,
                  padding,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    // ---------------- Profile Text ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            profile?.fullName ?? "User",
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            profile?.phoneNumber ?? "",
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------------- Profile Photo ----------------
                    CircleAvatar(
                      radius: w * 0.10,
                      backgroundColor: Colors.grey.shade300,
                      child: CircleAvatar(
                        radius: w * 0.093,
                        backgroundImage:
                            (profile?.profilePicture != null &&
                                profile!.profilePicture!.trim().isNotEmpty)
                            ? NetworkImage(profile!.profilePicture!.trim())
                            : const AssetImage('assets/images/logo.png')
                                  as ImageProvider,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // ---------------- Drawer Items ----------------
              drawerItem(
                icon: FontAwesomeIcons.users,
                title: "All Patients Details",
                onTap: () {
                  Get.toNamed('/bookingView');
                },
              ),

              drawerItem(
                icon: FontAwesomeIcons.creditCard,
                title: "Payment Details",
                onTap: () {
                  Get.toNamed('/payslipList');
                },
              ),

              drawerItem(
                icon: FontAwesomeIcons.commentDots,
                title: "Register Your Complaints",
                onTap: () {
                  Get.toNamed('/complaints');
                },
              ),

              drawerItem(
                icon: FontAwesomeIcons.calendar,
                title: "Attendance",
                onTap: () {
                  Get.toNamed('/leaveAttendance');
                },
              ),
              drawerItem(
                icon: FontAwesomeIcons.fileCircleCheck,
                title: "Leave",
                onTap: () {
                  Get.toNamed('/leave');
                },
              ),
              drawerItem(
                icon: FontAwesomeIcons.fileLines,
                title: "Privacy Policy",
                onTap: () async {
                  const url = 'https://www.freeprivacypolicy.com/live/40d61b74-e512-4397-a315-c8dc3b3197ee';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Error', 'Could not launch Privacy Policy');
                  }
                },
              ),

              drawerItem(
                icon: FontAwesomeIcons.arrowRightFromBracket,
                title: "Logout",
                color: AppColors.error,
                onTap: () => confirmLogout(context),
              ),

              drawerItem(
                icon: FontAwesomeIcons.whatsapp,
                title: "WhatsApp Us",
                color: AppColors.success,
                onTap: () {
                  waController.openWhatsApp(
                    "9061750540", // mobile number with country code
                    message:
                        "Hello!  Iam ${profile?.fullName ?? "User"}, I need assistance.", // default message
                  );
                },
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Drawer Tile Widget ----------------
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 20, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // ---------------- LOGOUT CONFIRMATION ----------------
  
}
