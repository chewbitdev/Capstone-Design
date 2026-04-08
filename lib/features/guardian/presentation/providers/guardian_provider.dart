import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

final _mockWards = [
  Ward(
    id: '1',
    name: '김영희',
    age: 72,
    phoneNumber: '010-1234-5678',
    address: '서울시 강남구 테헤란로 123',
    status: WardStatus.emergency,
    lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  Ward(
    id: '2',
    name: '이철수',
    age: 68,
    phoneNumber: '010-9876-5432',
    address: '서울시 서초구 반포대로 45',
    status: WardStatus.normal,
    lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Ward(
    id: '3',
    name: '박순자',
    age: 75,
    phoneNumber: '010-5555-7777',
    address: '서울시 송파구 올림픽로 200',
    status: WardStatus.warning,
    lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
  ),
  Ward(
    id: '4',
    name: '최민호',
    age: 80,
    phoneNumber: '010-3333-8888',
    address: '서울시 마포구 합정동 99',
    status: WardStatus.offline,
    lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

final _mockBiometrics = {
  '1': BiometricData(
    wardId: '1',
    heartRate: 112,
    respiratoryRate: 24,
    spO2: 91.5,
    isActive: true,
    recordedAt: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  '2': BiometricData(
    wardId: '2',
    heartRate: 72,
    respiratoryRate: 16,
    spO2: 98.0,
    isActive: true,
    recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  '3': BiometricData(
    wardId: '3',
    heartRate: 95,
    respiratoryRate: 19,
    spO2: 96.2,
    isActive: true,
    recordedAt: DateTime.now().subtract(const Duration(minutes: 1)),
  ),
  '4': BiometricData(
    wardId: '4',
    heartRate: 0,
    respiratoryRate: 0,
    spO2: 0,
    isActive: false,
    recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
};

final _mockAlerts = [
  EmergencyAlert(
    id: 'a1',
    wardId: '1',
    wardName: '김영희',
    type: AlertType.fall,
    message: '낙상이 감지되었습니다',
    occurredAt: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  EmergencyAlert(
    id: 'a2',
    wardId: '1',
    wardName: '김영희',
    type: AlertType.spO2Low,
    message: '산소포화도 91.5%',
    occurredAt: DateTime.now().subtract(const Duration(minutes: 3)),
  ),
];

// ── Providers ──────────────────────────────────────────────────────────────

final wardsProvider = Provider<List<Ward>>((ref) => _mockWards);

final biometricProvider = Provider.family<BiometricData?, String>(
  (ref, wardId) => _mockBiometrics[wardId],
);

final activeAlertsProvider = Provider<List<EmergencyAlert>>(
  (ref) => _mockAlerts.where((a) => !a.isResolved).toList(),
);

final alertsByWardProvider = Provider.family<List<EmergencyAlert>, String>(
  (ref, wardId) =>
      _mockAlerts.where((a) => a.wardId == wardId && !a.isResolved).toList(),
);

final selectedWardProvider = StateProvider<Ward?>((ref) => null);
