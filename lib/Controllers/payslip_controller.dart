// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

// import '../Model/payslip_model.dart';
// import '../Services/tokenservice.dart';

// class PayslipController extends GetxController {
//   // ---------------------------
//   // Reactive variables
//   // ---------------------------
//   var isLoading = false.obs;
//   var payslips = <PayslipModel>[].obs;

//   // ---------------------------
//   // FETCH PAYSLIP LIST
//   // ---------------------------
//   Future<void> fetchPayslips() async {
//     try {
//       isLoading.value = true;

//       final token = await TokenService.getAccessToken();
//       final baseUrl = dotenv.env['BASE_URL']!;
//       final url = Uri.parse("$baseUrl/api/caretaker/payslips/");

//       final response = await http.get(
//         url,
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         final List list = decoded["results"] ?? [];

//         payslips.value =
//             list.map((e) => PayslipModel.fromJson(e)).toList();
//       } else {
//         Get.snackbar("Error", "Failed to load payslips");
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ---------------------------
//   // DOWNLOAD PAYSLIP PDF
//   // ---------------------------
//   Future<void> downloadPayslip(PayslipModel payslip) async {
//     try {
//       isLoading.value = true;

//       final token = await TokenService.getAccessToken();
//       final baseUrl = dotenv.env['BASE_URL']!;
//       final url = Uri.parse(
//         "$baseUrl/api/caretaker/payslips/${payslip.id}/download/",
//       );

//       final response = await http.get(
//         url,
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         // Save PDF and get file path
//         final filePath = await _savePdf(
//           bytes: response.bodyBytes,
//           fileName: "${payslip.invoiceNumber}.pdf",
//         );

//         // Snackbar with OPEN button
//         Get.snackbar(
//           "Payslip Downloaded",
//           "Tap to open the PDF",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           mainButton: TextButton(
//             onPressed: () {
//               OpenFilex.open(filePath);
//             },
//             child: const Text(
//               "OPEN",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         );
//       } else {
//         Get.snackbar("Error", "Failed to download payslip");
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ---------------------------
//   // SAVE PDF FILE
//   // ---------------------------
//   Future<String> _savePdf({
//     required List<int> bytes,
//     required String fileName,
//   }) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes);
//     return file.path; // ✅ return file path
//   }

//   // ---------------------------
//   // INIT
//   // ---------------------------
//   @override
//   void onInit() {
//     fetchPayslips();
//     super.onInit();
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:qlickcare/Services/tokenexpireservice.dart';

import '../Model/payslip_model.dart';

class PayslipController extends GetxController {
  // ---------------------------
  // Reactive variables
  // ---------------------------
  final isLoading = false.obs;
  final payslips = <PayslipModel>[].obs;

  // ---------------------------
  // FETCH PAYSLIP LIST
  // ---------------------------
  Future<void> fetchPayslips() async {
    try {
      isLoading.value = true;

      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse("$baseUrl/api/caretaker/payslips/");

      final response = await ApiService.request(
        (token) => http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded["results"] ?? [];

        payslips.value =
            list.map((e) => PayslipModel.fromJson(e)).toList();
      } else {
        Get.snackbar("Error", "Failed to load payslips");
      }
    } catch (e) {
      Get.snackbar("Error", "Session expired. Please login again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // DOWNLOAD PAYSLIP PDF
  // ---------------------------
  Future<void> downloadPayslip(PayslipModel payslip) async {
    try {
      isLoading.value = true;

      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse(
        "$baseUrl/api/caretaker/payslips/${payslip.id}/download/",
      );

      final response = await ApiService.request(
        (token) => http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final filePath = await _savePdf(
          bytes: response.bodyBytes,
          fileName: "${payslip.invoiceNumber}.pdf",
        );

        Get.snackbar(
          "Payslip Downloaded",
          "Tap to open the PDF",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          mainButton: TextButton(
            onPressed: () => OpenFilex.open(filePath),
            child: const Text(
              "OPEN",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        Get.snackbar("Error", "Failed to download payslip");
      }
    } catch (e) {
      Get.snackbar("Error", "Session expired. Please login again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------
  // SAVE PDF FILE
  // ---------------------------
  Future<String> _savePdf({
    required List<int> bytes,
    required String fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // ---------------------------
  // INIT
  // ---------------------------
  @override
  void onInit() {
    fetchPayslips();
    super.onInit();
  }
}
