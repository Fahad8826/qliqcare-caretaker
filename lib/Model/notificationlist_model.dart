class AppNotification {
  final int id;
  final String title;
  final String body;
  final String notificationType;
  final String notificationTypeDisplay;
  final bool isRead;
  final String timeAgo;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.notificationTypeDisplay,
    required this.isRead,
    required this.timeAgo,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      notificationType: json['notification_type'] ?? '',
      notificationTypeDisplay:
          json['notification_type_display'] ?? '',
      isRead: json['is_read'] ?? false,
      timeAgo: json['time_ago'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
