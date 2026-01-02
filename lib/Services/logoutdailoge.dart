import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qlickcare/Controllers/logoutcontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';


void confirmLogout(BuildContext context) {
  final logoutController = Get.put(LogoutController());
  final size = MediaQuery.of(context).size;

  Get.dialog(
    Obx(() => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(size.width * 0.05),
      
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: size.width * 0.08,
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Title
          Text(
            logoutController.isLoading.value ? "Logging Out..." : "Logout",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          // Message or Loading
          logoutController.isLoading.value
              ? Column(
                  children: [

                    Text(
                      "Please wait...",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

          SizedBox(height: size.height * 0.025),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: logoutController.isLoading.value
                      ? null
                      : () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: AppTextStyles.body.copyWith(
                      color: logoutController.isLoading.value
                          ? AppColors.textSecondary.withOpacity(0.5)
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.03),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.012),
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.error.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: logoutController.isLoading.value
                      ? null
                      : () {
                          logoutController.logout();
                        },
                  child: logoutController.isLoading.value
                      ? SizedBox(
                          height: size.height * 0.02,
                          width: size.height * 0.02,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Logout",
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    )),
    barrierDismissible: false,
  );
}