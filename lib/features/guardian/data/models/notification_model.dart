class NotificationModel {
  final int notificationId;
  final String userName;
  final String eventType;
  final String message;
  final String status;
  final DateTime sentAt;
  final bool isRead;

  const NotificationModel({
    required this.notificationId,
    required this.userName,
    required this.eventType,
    required this.message,
    required this.status,
    required this.sentAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: (json['notificationId'] as num).toInt(),
      userName: json['userName'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      sentAt: _parseDate(json['sentAt']),
      isRead: (json['readYN'] as String?) == 'Y',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is List && value.length >= 3) {
      return DateTime(
        value[0] as int, value[1] as int, value[2] as int,
        value.length > 3 ? value[3] as int : 0,
        value.length > 4 ? value[4] as int : 0,
      );
    }
    return DateTime.now();
  }
}
