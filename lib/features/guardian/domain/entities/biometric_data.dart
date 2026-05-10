class BiometricData {
  const BiometricData({
    required this.wardId,
    required this.heartRate,
    required this.respiratoryRate,
    required this.isActive,
    required this.recordedAt,
  });

  final String wardId;
  final int heartRate;
  final int respiratoryRate;
  final bool isActive;
  final DateTime recordedAt;

  bool get isHeartRateAbnormal => heartRate < 50 || heartRate > 100;
  bool get isRespiratoryAbnormal => respiratoryRate < 12 || respiratoryRate > 20;
  bool get hasAnyAbnormality => isHeartRateAbnormal || isRespiratoryAbnormal;
}
