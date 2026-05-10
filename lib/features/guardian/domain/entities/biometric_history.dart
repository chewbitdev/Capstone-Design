class BiometricRecord {
  const BiometricRecord({
    required this.time,
    required this.heartRate,
    required this.respiratoryRate,
  });

  final DateTime time;
  final int heartRate;
  final int respiratoryRate;
}
