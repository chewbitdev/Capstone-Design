class VitalModel {
  final int? heartRate;
  final int? breathRate;
  final String? status;

  const VitalModel({this.heartRate, this.breathRate, this.status});

  factory VitalModel.fromJson(Map<String, dynamic> json) => VitalModel(
        heartRate: json['heartRate'] as int?,
        breathRate: json['breathRate'] as int?,
        status: json['status'] as String?,
      );
}
