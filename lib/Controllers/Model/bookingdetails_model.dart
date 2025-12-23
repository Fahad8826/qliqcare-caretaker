
import 'package:qlickcare/Controllers/Model/attendencestatus_model.dart';

class BookingDetails {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String patientName;
  final String gender;
  final int age;
  final String patientCondition;
  final String mobilityLevel;
  final String? otherMobilityText;
  final String address;
  final String pincode;
  final String latitude;
  final String longitude;
  final String aadharNumber;
  final String? aadharImage;
  final String startDate;
  final String endDate;
  final String workType;
  final String accountNumber;
  final String ifscCode;
  final String status;
  final String totalAmount;
  final String advanceAmount;
  final String createdAt;
  final String updatedAt;
  final List<TodoItem> todos;
  final List<AttendanceItem> attendance;
  final AttendanceSummary? attendanceSummary;

  BookingDetails({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.patientCondition,
    required this.mobilityLevel,
    required this.otherMobilityText,
    required this.address,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.aadharNumber,
    required this.aadharImage,
    required this.startDate,
    required this.endDate,
    required this.workType,
    required this.accountNumber,
    required this.ifscCode,
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.todos,
    required this.attendance,
    required this.attendanceSummary,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'],
      customerName: json['customer_name'] ?? "",
      customerEmail: json['customer_email'] ?? "",
      customerPhone: json['customer_phone'] ?? "",
      patientName: json['patient_name'] ?? "",
      gender: json['gender'] ?? "",
      age: json['age'] ?? 0,
      patientCondition: json['patient_condition'] ?? "",
      mobilityLevel: json['mobility_level'] ?? "",
      otherMobilityText: json['other_mobility_text'],
      address: json['address'] ?? "",
      pincode: json['pincode'] ?? "",
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
      aadharNumber: json['aadhar_number'] ?? "",
      aadharImage: json['aadhar_image'],
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      workType: json['work_type'] ?? "",
      accountNumber: json['account_number'] ?? "",
      ifscCode: json['ifsc_code'] ?? "",
      status: json['status'] ?? "",
      totalAmount: json['total_amount'] ?? "",
      advanceAmount: json['advance_amount'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      todos: (json['todos'] as List).map((e) => TodoItem.fromJson(e)).toList(),
      attendance: (json['attendance'] as List? ?? [])
          .map((e) => AttendanceItem.fromJson(e))
          .toList(),

      attendanceSummary: json['attendance_summary'] != null
          ? AttendanceSummary.fromJson(json['attendance_summary'])
          : null,
    );
  }
}

// class TodoItem {
//   final int id;
//   final String text;
//   final String? time;
//   final bool isDefault;
//   bool isCompleted; // 👈 mutable for UI update

//   TodoItem({
//     required this.id,
//     required this.text,
//     required this.time,
//     required this.isDefault,
//     required this.isCompleted,
//   });

//   factory TodoItem.fromJson(Map<String, dynamic> json) {
//     return TodoItem(
//       id: json['id'],
//       text: json['text'],
//       time: json['time'],
//       isDefault: json['is_default'],
//       isCompleted: json['is_completed'] ?? false, // 👈 ADD THIS
//     );
//   }
// }

class TodoItem {
  final int id;
  final String? text; // ✅ nullable
  final String? time;
  final bool isDefault;
  bool isCompleted;

  TodoItem({
    required this.id,
    this.text,
    this.time,
    required this.isDefault,
    required this.isCompleted,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] ?? 0,
      text: json['text'], // ✅ null-safe
      time: json['time'],
      isDefault: json['is_default'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

