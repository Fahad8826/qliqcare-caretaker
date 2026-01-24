class PayslipModel {
  final int id;
  final String month;
  final String monthName;
  final String amount;
  final String status;
  final String statusDisplay;
  final String invoiceNumber;
  final String invoiceUrl;
  final DateTime sharedAt;
  final DateTime createdAt;

  PayslipModel({
    required this.id,
    required this.month,
    required this.monthName,
    required this.amount,
    required this.status,
    required this.statusDisplay,
    required this.invoiceNumber,
    required this.invoiceUrl,
    required this.sharedAt,
    required this.createdAt,
  });

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'],
      month: json['month'],
      monthName: json['month_name'],
      amount: json['amount'],
      status: json['status'],
      statusDisplay: json['status_display'],
      invoiceNumber: json['invoice_number'],
      invoiceUrl: json['invoice_url'],
      sharedAt: DateTime.parse(json['shared_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
