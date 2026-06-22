class EventDetailModel {
  final int userId;
  final String name;
  final int eventId;
  final String eventType;
  final String description;
  final DateTime occurredAt;

  const EventDetailModel({
    required this.userId,
    required this.name,
    required this.eventId,
    required this.eventType,
    required this.description,
    required this.occurredAt,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      eventId: (json['eventId'] as num).toInt(),
      eventType: json['eventType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      occurredAt: _parseDate(json['occurredAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
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
