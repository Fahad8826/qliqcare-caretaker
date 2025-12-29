// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:qlickcare/Model/bookingdetails_model.dart';
// import 'package:qlickcare/Services/tokenservice.dart';

// class Ongoingbookingdetailscontroller extends GetxController {
//   var isLoading = false.obs;
//   var booking = Rxn<BookingDetails>();

//   Future<void> fetchBookingDetails(int id) async {
//     final token = await TokenService.getAccessToken();
//     final baseUrl = dotenv.env['BASE_URL']!;

//     var headers = {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json'
//     };

//     try {
//       isLoading.value = true;

//       final url = "$baseUrl/api/caretaker/bookings/$id/";
//       final response = await http.get(Uri.parse(url), headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         booking.value = BookingDetails.fromJson(data);
//       } else {
//         print("❌ Error: ${response.body}");
//       }
//     } catch (e) {
//       print("❌ Exception: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
