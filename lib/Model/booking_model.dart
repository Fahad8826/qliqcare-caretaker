class BookingItem {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String patientName;
  final String gender;
  final int age;
  final String startDate;
  final String endDate;
  final String workType;
  final String status;
  final String booking_status;
  final String totalAmount;
  final String advanceAmount;
  final String createdAt;
  final String address;
  final String pincode;

  BookingItem({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.startDate,
    required this.endDate,
    required this.workType,
    required this.status,
    required this.booking_status,
    required this.totalAmount,
    required this.advanceAmount,
    required this.createdAt,
    required this.address,
    required this.pincode,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'],
      customerName: json['customer_name'] ?? "",
      customerEmail: json['customer_email'] ?? "",
      customerPhone: json['customer_phone'] ?? "",
      patientName: json['patient_name'] ?? "",
      gender: json['gender'] ?? "",
      age: json['age'] ?? 0,
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      workType: json['work_type'] ?? "",
      status: json['status'] ?? "",
      booking_status: json['booking_status'] ?? "",
      totalAmount: json['total_amount'] ?? "",
      advanceAmount: json['advance_amount'] ?? "",
      createdAt: json['created_at'] ?? "",
      address: json['address'] ?? "",
      pincode: json['pincode'] ?? "",
    );
  }
}
