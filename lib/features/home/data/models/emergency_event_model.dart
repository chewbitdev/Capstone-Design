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
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
