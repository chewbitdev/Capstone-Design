import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/biometric_history.dart';

// ── 더미 데이터 생성 ──────────────────────────────────────────────────────────

List<BiometricRecord> _generateDaily(String wardId) {
  final rng = Random(wardId.hashCode);
  final now = DateTime.now();
  return List.generate(24, (i) {
    final t = DateTime(now.year, now.month, now.day).add(Duration(hours: i));
    return BiometricRecord(
      time: t,
      heartRate: 65 + rng.nextInt(30),
      respiratoryRate: 14 + rng.nextInt(6),
      spO2: 95.0 + rng.nextDouble() * 4,
    );
  });
}

List<BiometricRecord> _generateWeekly(String wardId) {
  final rng = Random(wardId.hashCode + 1);
  final now = DateTime.now();
  return List.generate(7, (i) {
    final t = now.subtract(Duration(days: 6 - i));
    return BiometricRecord(
      time: DateTime(t.year, t.month, t.day),
      heartRate: 65 + rng.nextInt(25),
      respiratoryRate: 14 + rng.nextInt(6),
      spO2: 95.0 + rng.nextDouble() * 4,
    );
  });
}

List<BiometricRecord> _generateMonthly(String wardId) {
  final rng = Random(wardId.hashCode + 2);
  final now = DateTime.now();
  return List.generate(30, (i) {
    final t = now.subtract(Duration(days: 29 - i));
    return BiometricRecord(
      time: DateTime(t.year, t.month, t.day),
      heartRate: 65 + rng.nextInt(25),
      respiratoryRate: 14 + rng.nextInt(6),
      spO2: 95.0 + rng.nextDouble() * 4,
    );
  });
}

// ── Providers ──────────────────────────────────────────────────────────────

final dailyRecordsProvider =
    Provider.family<List<BiometricRecord>, String>(
  (ref, wardId) => _generateDaily(wardId),
);

final weeklyRecordsProvider =
    Provider.family<List<BiometricRecord>, String>(
  (ref, wardId) => _generateWeekly(wardId),
);

final monthlyRecordsProvider =
    Provider.family<List<BiometricRecord>, String>(
  (ref, wardId) => _generateMonthly(wardId),
);
