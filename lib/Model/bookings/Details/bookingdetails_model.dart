

import 'package:qlickcare/Model/attendance/bookingattendance_model.dart';
import 'package:qlickcare/Model/bookings/Details/myreassaignmentperiod.dart';
import 'package:qlickcare/Model/bookings/Details/reassaignmnetinfo_model.dart';



class BookingDetails {
  final int id;
  final String bookingStatus; // NEW
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final int? caretakerId; // NEW
  final String? caretakerName; // NEW
  final String? caretakerPhone; // NEW
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
  final int? daysRemaining; // NEW
  final int? daysElapsed; // NEW
  final String workType;
  final String totalAmount;
  final String advanceAmount;
  final String accountNumber;
  final String ifscCode;
  final String status;
  final List<TodoItem> todos;
  final List<AttendanceItem> attendance;
  final AttendanceSummary? attendanceSummary;
  final TodayAttendance? todayAttendance; // NEW
  final bool? canCheckIn; // NEW
  final bool? canCheckOut; // NEW
  final String createdAt;
  final String updatedAt;
  final ReassignmentInfo? reassignmentInfo;
  final List<MyReassignmentPeriod>? myReassignmentPeriods;


  BookingDetails({
    required this.id,
    required this.bookingStatus,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.caretakerId,
    this.caretakerName,
    this.caretakerPhone,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.patientCondition,
    required this.mobilityLevel,
    this.otherMobilityText,
    required this.address,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.aadharNumber,
    this.aadharImage,
    required this.startDate,
    required this.endDate,
    this.daysRemaining,
    this.daysElapsed,
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
    this.attendanceSummary,
    this.todayAttendance,
    this.canCheckIn,
    this.canCheckOut,
    this.reassignmentInfo,
    this.myReassignmentPeriods,

  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'] ?? 0,
      bookingStatus: json['booking_status'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      caretakerId: json['caretaker_id'],
      caretakerName: json['caretaker_name'],
      caretakerPhone: json['caretaker_phone'],
      patientName: json['patient_name'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      patientCondition: json['patient_condition'] ?? '',
      mobilityLevel: json['mobility_level'] ?? '',
      otherMobilityText: json['other_mobility_text'],
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      aadharNumber: json['aadhar_number'] ?? '',
      aadharImage: json['aadhar_image'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      daysRemaining: json['days_remaining'],
      daysElapsed: json['days_elapsed'],
      workType: json['work_type'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      status: json['status'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      advanceAmount: json['advance_amount'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      todos: (json['todos'] as List? ?? [])
          .map((e) => TodoItem.fromJson(e))
          .toList(),
      attendance: (json['attendance'] as List? ?? [])
          .map((e) => AttendanceItem.fromJson(e))
          .toList(),
      attendanceSummary: json['attendance_summary'] != null
          ? AttendanceSummary.fromJson(json['attendance_summary'])
          : null,
      todayAttendance: json['today_attendance'] != null
          ? TodayAttendance.fromJson(json['today_attendance'])
          : null,
      canCheckIn: json['can_check_in'],
      canCheckOut: json['can_check_out'],
      reassignmentInfo: json['reassignment_info'] != null
    ? ReassignmentInfo.fromJson(json['reassignment_info'])
    : null,
    myReassignmentPeriods: (json['my_reassignment_periods'] as List? ?? [])
    .map((e) => MyReassignmentPeriod.fromJson(e))
    .toList(),

    );
  }
}

// ============================================
// Todo Item Model (NO CHANGES)
// ============================================
class TodoItem {
  final int id;
  final String? text;
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
      text: json['text'],
      time: json['time'],
      isDefault: json['is_default'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

// ============================================
// Attendance Status Enum (NO CHANGES)
// ============================================
enum AttendanceStatus {
  checkedIn,
  checkedOut,
  absent,
  onLeave, // ADDED
  upcoming,
}