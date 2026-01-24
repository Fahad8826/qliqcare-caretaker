import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/appbar.dart';
import 'package:qlickcare/Utils/loading.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import '../controller/payslip_controller.dart';

class PayslipListView extends StatelessWidget {
  PayslipListView({super.key});

  final PayslipController controller = Get.put(PayslipController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: "Payment Details",
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: isPortrait ? size.width * 0.055 : size.height * 0.065,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: Loading());
        }

        if (controller.payslips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: isPortrait ? size.width * 0.2 : size.height * 0.25,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  "No payslips available",
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.045,
            vertical: size.height * 0.02,
          ),
          itemCount: controller.payslips.length,
          itemBuilder: (_, index) {
            final payslip = controller.payslips[index];

            return Container(
              margin: EdgeInsets.only(bottom: size.height * 0.015),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.018,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Payslip title using monthName
                    Expanded(
                      child: Text(
                        "${payslip.monthName} - Pay slip",
                        style: AppTextStyles.body.copyWith(
                          fontSize: isPortrait ? size.width * 0.04 : size.height * 0.048,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    SizedBox(width: size.width * 0.03),

                    // Right side - Download button
                    ElevatedButton(
                      onPressed: () => controller.downloadPayslip(payslip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.045,
                          vertical: size.height * 0.012,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(
                          size.width * 0.24,
                          size.height * 0.04,
                        ),
                      ),
                      child: Text(
                        "Download",
                        style: AppTextStyles.body.copyWith(
                          fontSize: isPortrait ? size.width * 0.035 : size.height * 0.042,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}