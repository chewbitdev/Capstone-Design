// ============================================================
//  보호자 데모 모드 설정 파일  ← 이 파일만 수정하세요
//
//  1) kGuardianDemoMode를 true/false로 전환
//  2) kGuardianScenario에서 원하는 시나리오 선택
//  3) 저장 후 앱 전체 재실행 (Hot Restart)
// ============================================================

import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';

const bool kGuardianDemoMode = true;

// ── 시나리오 선택 ──────────────────────────────────────────────
const _GScenario kGuardianScenario = _GScenario.multipleIssues;
// const _GScenario kGuardianScenario = _GScenario.normal;
// const _GScenario kGuardianScenario = _GScenario.singleEmergency;
// const _GScenario kGuardianScenario = _GScenario.allOffline;

enum _GScenario { normal, singleEmergency, multipleIssues, allOffline }

// ============================================================

class GuardianDemoData {

  // ── 피보호자 목록 ─────────────────────────────────────────
  static List<Ward> get wards {
    final now = DateTime.now();
    return switch (kGuardianScenario) {

      _GScenario.normal => [
          Ward(
            id: '1', name: '김복순',
            phoneNumber: '010-1234-5678',
            relationship: '어머니', age: 73,
            status: WardStatus.normal,
            lastUpdated: now.subtract(const Duration(minutes: 3)),
            sleepTime: '7시간', activityTime: '1시간 20분', outingTime: '2시간 10분',
          ),
          Ward(
            id: '2', name: '김영식',
            phoneNumber: '010-9876-5432',
            relationship: '아버지', age: 76,
            status: WardStatus.normal,
            lastUpdated: now.subtract(const Duration(minutes: 6)),
            sleepTime: '6시간 30분', activityTime: '45분', outingTime: '1시간',
          ),
        ],

      _GScenario.singleEmergency => [
          Ward(
            id: '1', name: '김복순',
            phoneNumber: '010-1234-5678',
            relationship: '어머니', age: 73,
            status: WardStatus.emergency,
            lastUpdated: now.subtract(const Duration(minutes: 2)),
            sleepTime: '5시간', activityTime: '30분', outingTime: '0분',
          ),
          Ward(
            id: '2', name: '김영식',
            phoneNumber: '010-9876-5432',
            relationship: '아버지', age: 76,
            status: WardStatus.normal,
            lastUpdated: now.subtract(const Duration(minutes: 8)),
            sleepTime: '7시간', activityTime: '1시간', outingTime: '1시간 30분',
          ),
        ],

      _GScenario.multipleIssues => [
          Ward(
            id: '1', name: '김복순',
            phoneNumber: '010-1234-5678',
            relationship: '어머니', age: 73,
            status: WardStatus.emergency,
            lastUpdated: now.subtract(const Duration(minutes: 1)),
            sleepTime: '4시간', activityTime: '20분', outingTime: '0분',
          ),
          Ward(
            id: '2', name: '김영식',
            phoneNumber: '010-9876-5432',
            relationship: '아버지', age: 76,
            status: WardStatus.warning,
            lastUpdated: now.subtract(const Duration(minutes: 5)),
            sleepTime: '5시간 30분', activityTime: '40분', outingTime: '30분',
          ),
          Ward(
            id: '3', name: '이순자',
            phoneNumber: '010-5555-7777',
            relationship: '할머니', age: 81,
            status: WardStatus.outing,
            lastUpdated: now.subtract(const Duration(minutes: 8)),
            sleepTime: '8시간', activityTime: '1시간 10분', outingTime: '2시간 30분',
          ),
          Ward(
            id: '4', name: '박동수',
            phoneNumber: '010-3333-8888',
            relationship: '할아버지', age: 84,
            status: WardStatus.normal,
            lastUpdated: now.subtract(const Duration(minutes: 4)),
            sleepTime: '7시간 30분', activityTime: '1시간', outingTime: '0분',
          ),
        ],

      _GScenario.allOffline => [
          Ward(
            id: '1', name: '김복순',
            phoneNumber: '010-1234-5678',
            relationship: '어머니', age: 73,
            status: WardStatus.offline,
            lastUpdated: now.subtract(const Duration(hours: 3)),
          ),
          Ward(
            id: '2', name: '김영식',
            phoneNumber: '010-9876-5432',
            relationship: '아버지', age: 76,
            status: WardStatus.offline,
            lastUpdated: now.subtract(const Duration(hours: 2)),
          ),
        ],
    };
  }

  // ── 생체 데이터 ───────────────────────────────────────────
  static Map<String, BiometricData> get biometrics {
    final now = DateTime.now();
    return switch (kGuardianScenario) {

      _GScenario.normal => {
          '1': BiometricData(wardId: '1', heartRate: 74, respiratoryRate: 16,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 3))),
          '2': BiometricData(wardId: '2', heartRate: 68, respiratoryRate: 15,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 6))),
        },

      _GScenario.singleEmergency => {
          '1': BiometricData(wardId: '1', heartRate: 132, respiratoryRate: 26,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 2))),
          '2': BiometricData(wardId: '2', heartRate: 70, respiratoryRate: 15,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 8))),
        },

      _GScenario.multipleIssues => {
          '1': BiometricData(wardId: '1', heartRate: 128, respiratoryRate: 28,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 1))),
          '2': BiometricData(wardId: '2', heartRate: 107, respiratoryRate: 22,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 5))),
          '3': BiometricData(wardId: '3', heartRate: 0, respiratoryRate: 0,
              isActive: false, recordedAt: now.subtract(const Duration(minutes: 8))),
          '4': BiometricData(wardId: '4', heartRate: 71, respiratoryRate: 15,
              isActive: true, recordedAt: now.subtract(const Duration(minutes: 4))),
        },

      _GScenario.allOffline => {
          '1': BiometricData(wardId: '1', heartRate: 0, respiratoryRate: 0,
              isActive: false, recordedAt: now.subtract(const Duration(hours: 3))),
          '2': BiometricData(wardId: '2', heartRate: 0, respiratoryRate: 0,
              isActive: false, recordedAt: now.subtract(const Duration(hours: 2))),
        },
    };
  }

  // ── 알림 목록 ─────────────────────────────────────────────
  static List<EmergencyAlert> get alerts {
    final now = DateTime.now();
    return switch (kGuardianScenario) {

      _GScenario.normal => [],

      _GScenario.singleEmergency => [
          EmergencyAlert(
            id: 'a1', wardId: '1', wardName: '김복순',
            type: AlertType.fall,
            message: '낙상이 감지되었습니다',
            occurredAt: now.subtract(const Duration(minutes: 2)),
          ),
        ],

      _GScenario.multipleIssues => [
          EmergencyAlert(
            id: 'a0', wardId: 'system', wardName: '이순자',
            type: AlertType.invitation,
            message: '이순자님이 보호자로 초대했습니다.',
            occurredAt: now.subtract(const Duration(minutes: 30)),
          ),
          EmergencyAlert(
            id: 'a1', wardId: '1', wardName: '김복순',
            type: AlertType.fall,
            message: '낙상이 감지되었습니다',
            occurredAt: now.subtract(const Duration(minutes: 1)),
          ),
          EmergencyAlert(
            id: 'a2', wardId: '2', wardName: '김영식',
            type: AlertType.heartRateAbnormal,
            message: '심박수 107bpm — 정상 범위 초과',
            occurredAt: now.subtract(const Duration(minutes: 5)),
          ),
          EmergencyAlert(
            id: 'a3', wardId: '3', wardName: '이순자',
            type: AlertType.outing,
            message: '외출이 감지되었습니다',
            occurredAt: now.subtract(const Duration(minutes: 8)),
          ),
          EmergencyAlert(
            id: 'a4', wardId: '1', wardName: '김복순',
            type: AlertType.inactivity,
            message: '40분 이상 움직임 없음',
            occurredAt: now.subtract(const Duration(hours: 1)),
            isResolved: true,
          ),
          EmergencyAlert(
            id: 'a5', wardId: '3', wardName: '이순자',
            type: AlertType.heartRateAbnormal,
            message: '심박수 88bpm — 주의 수준',
            occurredAt: now.subtract(const Duration(hours: 2)),
            isResolved: true,
          ),
        ],

      _GScenario.allOffline => [],
    };
  }
}
