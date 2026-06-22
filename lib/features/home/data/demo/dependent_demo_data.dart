// ============================================================
//  데모 모드 설정 파일  ← 이 파일만 수정하세요
//
//  1) kDemoMode를 true/false로 전환
//  2) kScenario에서 원하는 시나리오 선택
//  3) 저장 후 앱 전체 재실행 (Hot Restart)
// ============================================================

import '../models/guardian_model.dart';

const bool kDemoMode = false;

// ── 시나리오 선택 (아래 중 하나만 활성화) ──────────────────────
// const _Scenario kScenario = _Scenario.normal;
// const _Scenario kScenario = _Scenario.heartIssue;
// const _Scenario kScenario = _Scenario.breathIssue;
const _Scenario kScenario = _Scenario.fall;
// const _Scenario kScenario = _Scenario.offline;

enum _Scenario { normal, heartIssue, breathIssue, fall, offline }

// ============================================================

class DependentDemoData {
  static String get name => switch (kScenario) {
        _Scenario.normal      => '김복순',
        _Scenario.heartIssue  => '김복순',
        _Scenario.breathIssue => '김복순',
        _Scenario.fall        => '김복순',
        _Scenario.offline     => '김복순',
      };

  // ── 응급 상태 ─────────────────────────────────────────────
  static bool get isEmergency => switch (kScenario) {
        _Scenario.normal  => false,
        _Scenario.offline => false,
        _             => true,
      };

  // FALL / HEART_ISSUE / BREATH_ISSUE / INACTIVITY / SOS
  static String get emergencyType => switch (kScenario) {
        _Scenario.heartIssue  => 'HEART_ISSUE',
        _Scenario.breathIssue => 'BREATH_ISSUE',
        _Scenario.fall        => 'FALL',
        _                     => 'FALL',
      };

  // ── 생체 데이터 ───────────────────────────────────────────
  static int get heartRate => switch (kScenario) {
        _Scenario.heartIssue => 128,   // 빠른 심박
        _Scenario.offline    => 0,
        _                    => 74,
      };

  static int get breathRate => switch (kScenario) {
        _Scenario.breathIssue => 28,   // 빠른 호흡
        _Scenario.offline     => 0,
        _                     => 16,
      };

  // ── 센서 연결 상태 ────────────────────────────────────────
  static bool get raspberryConnected => kScenario != _Scenario.offline;
  static bool get heartSensorConnected => kScenario != _Scenario.offline;
  static bool get fallSensorConnected => kScenario != _Scenario.offline;

  // ── 오늘의 활동 (시간 단위) ───────────────────────────────
  static String get sleep => switch (kScenario) {
        _Scenario.normal      => '7시간',
        _Scenario.heartIssue  => '5시간',
        _Scenario.breathIssue => '4시간',
        _Scenario.fall        => '6시간',
        _Scenario.offline     => '--',
      };

  static String get activity => switch (kScenario) {
        _Scenario.normal      => '1시간 20분',
        _Scenario.heartIssue  => '45분',
        _Scenario.breathIssue => '30분',
        _Scenario.fall        => '0분',
        _Scenario.offline     => '--',
      };

  static String get outing => switch (kScenario) {
        _Scenario.normal      => '2시간 10분',
        _Scenario.heartIssue  => '1시간',
        _Scenario.breathIssue => '30분',
        _Scenario.fall        => '0분',
        _Scenario.offline     => '--',
      };

  // ── 등록된 보호자 ─────────────────────────────────────────
  static List<GuardianModel> get guardians => switch (kScenario) {
        _Scenario.offline => [
            const GuardianModel(
              id: 1,
              name: '김철수',
              phone: '010-1234-5678',
              isPrimary: true,
              relation: '아들',
            ),
          ],
        _ => [
            const GuardianModel(
              id: 1,
              name: '김철수',
              phone: '010-1234-5678',
              isPrimary: true,
              relation: '아들',
            ),
            const GuardianModel(
              id: 2,
              name: '이영희',
              phone: '010-9876-5432',
              isPrimary: false,
              relation: '딸',
            ),
          ],
      };
}
