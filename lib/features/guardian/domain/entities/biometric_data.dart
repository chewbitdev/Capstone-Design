class BiometricData {
  const BiometricData({
    required this.wardId,
    required this.heartRate,
    required this.respiratoryRate,
    required this.spO2,
    required this.isActive,
    required this.recordedAt,
  });

  final String wardId;
  final int heartRate;         // bpm
  final int respiratoryRate;   // breaths/min
  final double spO2;           // %
  final bool isActive;
  final DateTime recordedAt;

  bool get isHeartRateAbnormal => heartRate < 50 || heartRate > 100;
  bool get isSpO2Abnormal => spO2 < 95.0;
  bool get isRespiratoryAbnormal => respiratoryRate < 12 || respiratoryRate > 20;
  bool get hasAnyAbnormality =>
      isHeartRateAbnormal || isSpO2Abnormal || isRespiratoryAbnormal;
}
