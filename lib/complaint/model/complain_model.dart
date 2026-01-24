class ComplaintItem {
  final int id;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final String admin_response;
  final String createdAt;

  ComplaintItem({
    required this.id,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.admin_response,
    required this.createdAt,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) {
    return ComplaintItem(
      id: json["id"],
      subject: json["subject"] ?? "",
      description: json["description"] ?? "",
      priority: json["priority"] ?? "",
      status: json["status"] ?? "",
      admin_response: json["admin_response"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }
}

class ComplaintDetail {
  final int id;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final String? adminResponse;
  final String customerEmail;
  final String createdAt;

  ComplaintDetail({
    required this.id,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.adminResponse,
    required this.customerEmail,
    required this.createdAt,
  });

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) {
    return ComplaintDetail(
      id: json['id'],
      subject: json['subject'] ?? "",
      description: json['description'] ?? "",
      priority: json['priority'] ?? "",
      status: json['status'] ?? "",
      adminResponse: json['admin_response'],
      customerEmail: json['customer_email'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}



