class WardDetailModel {
  final int userId;
  final String name;
  final String relationship;
  final String overallStatus;
  final int heartRate;
  final int breathRate;
  final DateTime updatedAt;
  final bool activityStatus;

  const WardDetailModel({
    required this.userId,
    required this.name,
    required this.relationship,
    required this.overallStatus,
    required this.heartRate,
    required this.breathRate,
    required this.updatedAt,
    required this.activityStatus,
  });

  factory WardDetailModel.fromJson(Map<String, dynamic> json) {
    return WardDetailModel(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      relationship: json['relation'] as String? ?? json['relationship'] as String? ?? '',
      overallStatus: json['status'] as String? ?? json['overallStatus'] as String? ?? 'NORMAL',
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      breathRate: (json['breathRate'] as num?)?.toInt() ?? 0,
      updatedAt: _parseDate(json['updatedAt'] ?? json['createdAt']),
      activityStatus: (json['status'] as String?) != 'OFFLINE',
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
