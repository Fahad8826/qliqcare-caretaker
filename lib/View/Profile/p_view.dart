import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/deleteaccount.dart';
import 'package:qlickcare/Controllers/logoutcontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/View/Drawer/drawer.dart';
import 'package:qlickcare/View/Profile/p_update.dart';
import 'package:qlickcare/View/listnotification.dart';
import '../../Controllers/profilecontroller.dart';

class PView extends StatelessWidget {
  final P_Controller controller = Get.put(P_Controller());

  final LogoutController logoutController = Get.put(LogoutController());
  final AccountController accountController = Get.put(AccountController());

  PView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              FontAwesomeIcons.bars,
              color: AppColors.background,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.bell,
              color: AppColors.background,
              size: 22,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  notification()),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: Loading());
        }

        final profile = controller.profile.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              /// ================== GREEN HEADER WITH PROFILE ==================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Green curved background
                  Container(
                    height: screenHeight * 0.18,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  // Profile avatar positioned to overlap
                  Positioned(
                    top: screenHeight * 0.06,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: isSmallScreen
                                ? 55
                                : (isMediumScreen ? 60 : 65),
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                (profile.profilePicture?.trim().isNotEmpty ??
                                    false)
                                ? NetworkImage(profile.profilePicture!.trim())
                                : null,
                            child:
                                (profile.profilePicture?.trim().isNotEmpty ??
                                    false)
                                ? null
                                : Icon(
                                    Icons.person,
                                    size: isSmallScreen ? 50 : 60,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.09),

              /// ================== NAME & INFO ==================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    Text(
                      profile.fullName ?? 'User',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile.availabilityStatus ?? "N/A",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isSmallScreen ? 10 : 16,
                      runSpacing: 4,
                      children: [
                        Text(
                          profile.qualification ?? 'N/A',
                          style: AppTextStyles.body.copyWith(
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),

                        Text(
                          profile.locationName ?? 'N/A',
                          style: AppTextStyles.body.copyWith(
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// ================== STATS CARDS ==================
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            "${profile.experienceYears ?? 0} Years",
                            "Experience",
                            Icons.access_time,
                            isSmallScreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            "${profile.age ?? 0} Yrs",
                            "Age",
                            Icons.access_time,
                            isSmallScreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            "${profile.availabilityStatus ?? "N/A"}",
                            "Availability",
                            Icons.check_circle,
                            isSmallScreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ================== ABOUT ME ==================
                    _sectionCard(
                      icon: Icons.person,
                      title: "About Me",
                      isSmallScreen: isSmallScreen,
                      child: Text(
                        profile.bio ??
                            "I am a trained caretaker with experience in assisting those in need.",
                        style: AppTextStyles.body.copyWith(
                          height: 1.6,
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// ================== SPECIALTIES ==================
                    _sectionCard(
                      icon: Icons.medical_services,
                      title: "Specialties",
                      isSmallScreen: isSmallScreen,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: profile.specializationIds.isEmpty
                            ? [
                                _greenBorderTag(
                                  "No specializations added",
                                  isSmallScreen,
                                ),
                              ]
                            : profile.specializationIds.map((id) {
                                final spec = controller.specializationList
                                    .firstWhere(
                                      (s) => s['id'] == id,
                                      orElse: () => {'name': 'Unknown'},
                                    );
                                return _greenBorderTag(
                                  spec['name'] as String,
                                  isSmallScreen,
                                );
                              }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// ================== SERVICE DETAILS ==================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service Details",
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _detailRow(
                            "Work Type:",
                            profile.workTypes.isNotEmpty
                                ? profile.workTypes
                                      .map(
                                        (type) => type
                                            .replaceAll("_", " ")
                                            .toLowerCase(),
                                      )
                                      .join(", ")
                                : "N/A",
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// ================== DOCUMENTS UPLOADED ==================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Documents Uploaded",
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ---- CONDITIONAL WIDGETS ----
                          if (profile.isVerified == false) ...[
                            Text(
                              "Your documents are under review. Verification may take up to 48 hours.",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ] else ...[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _documentTag("ID Proof", isSmallScreen),
                                _documentTag(
                                  "Experience Certificate",
                                  isSmallScreen,
                                ),
                                _documentTag(
                                  "Educational Certificate",
                                  isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// ================== BUTTONS ==================
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isSmallScreen ? 35 : 40,
                            child: OutlinedButton(
                              onPressed: () => _showLogoutDialog(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: isSmallScreen ? 35 : 40,
                            child: ElevatedButton(
                              onPressed: () => Get.to(() => EProfile()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextButton(
                      onPressed: () {
                        showDeleteAccountDialog(context, () {
                          accountController
                              .deleteAccount(); // <-- your delete function
                        });
                      },
                      child: Text(
                        "Delete My Account",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------------------------------
  // LOGOUT DIALOG
  // -------------------------------------------------------------------------------------
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                Text(
                  'Logout',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                // Message
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          logoutController.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------------------
  // HELPER WIDGETS
  // -------------------------------------------------------------------------------------

  Widget _statCard(
    String value,
    String label,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 12 : 14,
        horizontal: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 20 : 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: isSmallScreen ? 10 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: isSmallScreen ? 18 : 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 100 : 130,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _greenBorderTag(String text, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 14,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F0),
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: isSmallScreen ? 11 : 12,
        ),
      ),
    );
  }

  Widget _documentTag(String text, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: isSmallScreen ? 14 : 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context, Function onConfirm) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 36,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Delete Account',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'This action is permanent and cannot be undone.\nType DELETE to confirm.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Text Field
              TextField(
                controller: textController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(letterSpacing: 1.2),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.trim() == 'DELETE') {
                          Navigator.pop(context);
                          onConfirm();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please type DELETE exactly',
                            backgroundColor: Colors.red.shade50,
                            colorText: Colors.red,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
