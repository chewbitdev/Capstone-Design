class BiometricRecord {
  const BiometricRecord({
    required this.time,
    required this.heartRate,
    required this.respiratoryRate,
    required this.spO2,
  });

  final DateTime time;
  final int heartRate;
  final int respiratoryRate;
  final double spO2;
}
