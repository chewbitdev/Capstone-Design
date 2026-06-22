class EmergencyEventModel {
  final int id;
  final String eventType;
  final String status;
  final DateTime createdAt;

  const EmergencyEventModel({
    required this.id,
    required this.eventType,
    required this.status,
    required this.createdAt,
  });

  factory EmergencyEventModel.fromJson(Map<String, dynamic> json) =>
      EmergencyEventModel(
        id: json['id'] as int,
        eventType: json['eventType'] as String,
        status: json['status'] as String,
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is List && value.length >= 3) {
      return DateTime(
        value[0] as int,
        value[1] as int,
        value[2] as int,
        value.length > 3 ? value[3] as int : 0,
        value.length > 4 ? value[4] as int : 0,
      );
    }
    return DateTime.now();
  }
}
