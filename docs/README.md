# Heart View 앱 문서

> 노인 건강 모니터링 및 응급 대응 Flutter 앱

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [아키텍처](#2-아키텍처)
3. [디렉토리 구조](#3-디렉토리-구조)
4. [핵심 도메인 모델](#4-핵심-도메인-모델)
5. [화면 구성](#5-화면-구성)
   - [공통 — 인증](#51-공통--인증)
   - [피보호자 화면](#52-피보호자-화면)
   - [보호자 화면](#53-보호자-화면)
6. [상태 관리 (Riverpod)](#6-상태-관리-riverpod)
7. [네트워크 / API](#7-네트워크--api)
8. [색상 시스템](#8-색상-시스템)
9. [데모 모드](#9-데모-모드)
10. [주요 의존성](#10-주요-의존성)

---

## 1. 프로젝트 개요

**Heart View**는 노인(피보호자)의 생체 데이터를 실시간으로 수집하고, 보호자가 어디서든 건강 상태를 모니터링할 수 있도록 돕는 응급 대응 앱입니다.

| 항목 | 내용 |
|------|------|
| 앱 이름 | Heart View |
| 패키지 이름 | `ikong` |
| 플랫폼 | iOS / Android |
| 프레임워크 | Flutter 3.x (Dart 3.11+) |
| 상태 관리 | Riverpod 2.x |
| 인증 방식 | 카카오 OAuth2 + JWT |
| 생체 데이터 수신 | SSE (Server-Sent Events) 스트리밍 |

### 두 가지 사용자 역할

```
┌────────────────┐        ┌────────────────┐
│   피보호자      │◄──────►│    보호자       │
│  (노인 본인)    │  초대   │  (가족/간병인)  │
└────────────────┘        └────────────────┘
```

- **피보호자**: 라즈베리파이 웨어러블 기기 착용, 심박/호흡 데이터 자동 전송, SOS 버튼
- **보호자**: 피보호자 실시간 상태 모니터링, 긴급 알림 수신, 생체 이력 조회

---

## 2. 아키텍처

Clean Architecture + Feature-first 구조를 채택합니다.

```
Presentation (Pages, Widgets, Providers)
      │
      ▼
Domain (Entities, Use Cases)
      │
      ▼
Data (Repositories, Models, Demo Data)
      │
      ▼
Core (Network, Auth, Config)
```

### 레이어별 역할

| 레이어 | 역할 |
|--------|------|
| `presentation` | Flutter 위젯, Riverpod Provider, UI 로직 |
| `domain` | 순수 Dart 엔티티 & 비즈니스 규칙 |
| `data` | API 모델, Repository 구현체, 데모 데이터 |
| `core` | Dio 클라이언트, JWT 저장소, 환경 설정 |
| `shared` | 테마(색상), 공통 위젯 |

---

## 3. 디렉토리 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── auth/
│   │   └── auth_storage.dart          # JWT 저장 (flutter_secure_storage)
│   ├── config/
│   │   └── app_config.dart            # 환경변수 (.env) 래퍼
│   └── network/
│       └── api_client.dart            # Dio 인스턴스 + 인터셉터
├── shared/
│   ├── theme/
│   │   ├── app_colors.dart            # 앱 전역 색상 상수
│   │   └── app_theme.dart
│   └── widgets/
│       └── status_dot.dart
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── pages/login_page.dart
    │       └── widgets/kakao_login_button.dart
    ├── home/                          # 피보호자 Feature
    │   ├── data/
    │   │   ├── demo/dependent_demo_data.dart
    │   │   ├── models/                # API 응답 모델
    │   │   └── repositories/dependent_repository.dart
    │   └── presentation/
    │       ├── pages/dependent_home_page.dart
    │       └── providers/dependent_home_provider.dart
    ├── guardian/                      # 보호자 Feature
    │   ├── domain/entities/
    │   │   ├── ward.dart
    │   │   ├── biometric_data.dart
    │   │   ├── biometric_history.dart
    │   │   └── emergency_alert.dart
    │   ├── data/demo/guardian_demo_data.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── caregiver_home_page.dart
    │       │   ├── ward_detail_page.dart
    │       │   ├── biometric_history_page.dart
    │       │   ├── alert_history_page.dart
    │       │   ├── emergency_alert_page.dart
    │       │   ├── add_ward_page.dart
    │       │   └── guardian_register_page.dart
    │       ├── providers/
    │       │   ├── guardian_provider.dart
    │       │   └── biometric_history_provider.dart
    │       └── widgets/
    │           └── ward_status_card.dart
    └── notification/
        └── presentation/pages/notification_center_page.dart
```

---

## 4. 핵심 도메인 모델

### 4.1 Ward (피보호자)

> `lib/features/guardian/domain/entities/ward.dart`

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | `String` | 고유 식별자 |
| `name` | `String` | 이름 |
| `phoneNumber` | `String` | 전화번호 |
| `relationship` | `String` | 관계 (어머니, 아버지 등) |
| `status` | `WardStatus` | 현재 상태 |
| `lastUpdated` | `DateTime` | 마지막 데이터 수신 시각 |
| `age` | `int?` | 나이 |
| `sleepTime` | `String?` | 오늘 수면 시간 |
| `activityTime` | `String?` | 오늘 활동 시간 |
| `outingTime` | `String?` | 오늘 외출 시간 |

#### WardStatus 열거형

| 값 | 설명 | 색상 |
|----|------|------|
| `normal` | 정상 | 초록 |
| `warning` | 주의 | 주황 |
| `emergency` | 긴급 | 빨강 |
| `outing` | 외출 중 | 파랑 |
| `offline` | 오프라인 | 회색 |

### 4.2 BiometricData (생체 데이터)

> `lib/features/guardian/domain/entities/biometric_data.dart`

| 필드 | 타입 | 설명 |
|------|------|------|
| `wardId` | `String` | 피보호자 ID |
| `heartRate` | `int` | 심박수 (bpm) |
| `respiratoryRate` | `int` | 호흡수 (회/분) |
| `isActive` | `bool` | 기기 활성 여부 |
| `recordedAt` | `DateTime` | 측정 시각 |

#### 이상 감지 기준

| 지표 | 정상 범위 |
|------|-----------|
| 심박수 | 50 ~ 100 bpm |
| 호흡수 | 12 ~ 20 회/분 |

### 4.3 EmergencyAlert (긴급 알림)

> `lib/features/guardian/domain/entities/emergency_alert.dart`

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | `String` | 알림 고유 ID |
| `wardId` | `String` | 피보호자 ID |
| `wardName` | `String` | 피보호자 이름 |
| `type` | `AlertType` | 알림 유형 |
| `message` | `String` | 알림 메시지 |
| `occurredAt` | `DateTime` | 발생 시각 |
| `isResolved` | `bool` | 해결 여부 (기본값: `false`) |

#### AlertType 열거형

| 값 | 한글 레이블 | 심각도 |
|----|-------------|--------|
| `fall` | 낙상 감지 | 심각 |
| `sos` | SOS 신호 | 심각 |
| `heartRateAbnormal` | 심박수 이상 | 주의 |
| `inactivity` | 장시간 미활동 | 주의 |
| `outing` | 외출 감지 | 정보 |
| `invitation` | 보호자 초대 | 정보 |

### 4.4 VitalModel (실시간 생체 스트림)

> `lib/features/home/data/models/vital_model.dart`

서버 SSE 스트림에서 수신하는 JSON 모델입니다.

```json
{
  "heartRate": 74,
  "breathRate": 16,
  "status": "NORMAL"
}
```

---

## 5. 화면 구성

### 5.1 공통 — 인증

#### LoginPage

> `lib/features/auth/presentation/pages/login_page.dart`

- 상단: "Heart View" 텍스트 로고
- 역할 토글 (피보호자 / 보호자) 에 따라 설명 문구 전환 (`AnimatedSwitcher`)
- 카카오 로그인 버튼 → OAuth2 인증 → JWT 저장 → 역할별 홈 이동

```
피보호자 선택 → "건강 상태를 모니터링하고 보호자와 연결하세요"
보호자 선택   → "소중한 가족의 건강을 실시간으로 확인하세요"
```

---

### 5.2 피보호자 화면

#### DependentHomePage

> `lib/features/home/presentation/pages/dependent_home_page.dart`

실시간 생체 데이터를 서버에서 스트리밍으로 수신하여 표시합니다.

| 구역 | 내용 |
|------|------|
| 프로필 카드 | 이름, 상태 배지 |
| 생체 데이터 카드 | 심박수 / 호흡수 실시간 표시, 이상 시 경고 색상 |
| 긴급 이벤트 배너 | 최근 긴급 이벤트 메시지 표시 |
| 보호자 목록 | 연결된 보호자 이름/관계 |
| 알림 버튼 (AppBar) | 알림 센터 이동 |

#### NotificationCenterPage (피보호자)

> `lib/features/notification/presentation/pages/notification_center_page.dart`

| 알림 레벨 | 색상 | 아이콘 | 예시 |
|-----------|------|--------|------|
| 심각 (`danger`) | 빨강 | `warning_rounded` | 낙상 감지, SOS |
| 주의 (`warning`) | 주황 | `info_outline` | 심박수 이상 |
| 정보 (`info`) | 회색 | `sensors_off_outlined` | 기기 연결 해제 |

- 심각/주의 알림에는 "보호자에게 자동으로 알림을 전송했습니다." 문구 자동 포함
- 읽음 / 읽지 않음 섹션 구분

---

### 5.3 보호자 화면

#### CaregiverHomePage

> `lib/features/guardian/presentation/pages/caregiver_home_page.dart`

| 구역 | 내용 |
|------|------|
| AppBar | `N명 모니터링 중` (초록 점 + 텍스트) |
| 요약 카드 3종 | 긴급(빨강) / 주의(주황) / 외출(파랑) 인원 수 |
| 피보호자 카드 목록 | `WardStatusCard` 반복 표시 |

#### WardStatusCard

> `lib/features/guardian/presentation/widgets/ward_status_card.dart`

상태별 카드 스타일:

| 상태 | 테두리 색 | 생체 데이터 색 |
|------|-----------|---------------|
| 긴급 | 빨강 | 빨강 |
| 주의 | 주황 | 주황 |
| 정상 | 없음 | 초록 |
| 외출 | 없음 | — (데이터 수신 불가 표시) |
| 오프라인 | 없음 | 회색 |

#### WardDetailPage

> `lib/features/guardian/presentation/pages/ward_detail_page.dart`

피보호자 1명의 상세 정보 페이지:

- 프로필 카드 (이름, 관계, 나이, 상태)
- 활동 요약: 수면 / 활동 / 외출 시간
- 실시간 생체 데이터 (상태 색상 반영)
- 미해결 알림 목록 (알림 유형별 색상/아이콘)

#### BiometricHistoryPage

> `lib/features/guardian/presentation/pages/biometric_history_page.dart`

4개 탭 구성:

| 탭 | 내용 |
|----|------|
| 오늘 | 현재 심박/호흡 카드 + 시간대별 차트 |
| 이번 주 | 주간 평균 트렌드 차트 |
| 이번 달 | 월간 평균 트렌드 차트 |
| 알림 이력 | 해당 피보호자의 전체 알림 목록 (미해결/해결됨) |

차트 특징:
- 심박수: 빨간색 라인 + 그라데이션 채우기
- 호흡수: 파란색 라인 + 그라데이션 채우기
- 이상치 데이터 행은 경고 아이콘과 색상으로 강조

#### AlertHistoryPage

> `lib/features/guardian/presentation/pages/alert_history_page.dart`

모든 피보호자의 알림 이력을 통합 표시:

| 섹션 | 내용 |
|------|------|
| 미해결 | 수락/해결/보기 액션 가능 |
| 해결됨 | 취소선 스타일, 액션 없음 |

**보호자 초대 카드** (`invitation` 타입):
- 수락 버튼 → `resolveWithMessage()` 로 알림 해결 처리
- 거절 버튼 → `dismiss()` 로 알림 목록에서 제거

#### EmergencyAlertPage

> `lib/features/guardian/presentation/pages/emergency_alert_page.dart`

긴급 알림 상세 페이지 (지도/위치, 전화 걸기 등).

---

## 6. 상태 관리 (Riverpod)

### 보호자 Providers

> `lib/features/guardian/presentation/providers/guardian_provider.dart`

| Provider | 타입 | 설명 |
|----------|------|------|
| `wardsProvider` | `StateNotifierProvider<WardsNotifier, List<Ward>>` | 피보호자 목록 |
| `alertsProvider` | `StateNotifierProvider<AlertsNotifier, List<EmergencyAlert>>` | 전체 알림 목록 |
| `activeAlertsProvider` | `Provider<List<EmergencyAlert>>` | 미해결 알림만 필터 |
| `alertsByWardProvider(wardId)` | `Provider.family` | 특정 피보호자의 미해결 알림 |
| `allAlertsByWardProvider(wardId)` | `Provider.family` | 특정 피보호자의 전체 알림 (날짜 역순) |
| `biometricProvider(wardId)` | `Provider.family` | 특정 피보호자 생체 데이터 |

#### AlertsNotifier 주요 메서드

| 메서드 | 설명 |
|--------|------|
| `resolve(alertId)` | 알림을 해결됨으로 마킹 |
| `resolveWithMessage(alertId, message)` | 메시지 교체 후 해결됨으로 마킹 |
| `dismiss(alertId)` | 알림 목록에서 완전 삭제 |

### 피보호자 Providers

> `lib/features/home/presentation/providers/dependent_home_provider.dart`

| Provider | 설명 |
|----------|------|
| `userProfileProvider` | 사용자 프로필 (이름, 상태) |
| `vitalStreamProvider` | 실시간 생체 데이터 SSE 스트림 |
| `emergencyEventProvider` | 최근 긴급 이벤트 |
| `guardiansProvider` | 연결된 보호자 목록 |

---

## 7. 네트워크 / API

### 기본 설정

> `lib/core/network/api_client.dart`

- Base URL: `.env` 파일의 `BASE_URL`
- 타임아웃: 연결 10초 / 수신 10초
- 인증: 모든 요청에 `Authorization: Bearer {accessToken}` 헤더 자동 주입

### 주요 API 엔드포인트

| Method | URL | 설명 |
|--------|-----|------|
| `GET` | `/api/users/{userId}/main` | 사용자 프로필 조회 |
| `GET` | `/api/emergency_event/{userId}/emergency` | 최근 긴급 이벤트 조회 |
| `GET` | `/guardians?userId={userId}` | 보호자 목록 조회 |
| `POST` | `/guardians/invite` | 보호자 초대 |
| `GET` | `/api/vitals/stream/{userId}` | 생체 데이터 SSE 스트림 |

### SSE 스트림 데이터 형식

```
data: {"heartRate": 74, "breathRate": 16, "status": "NORMAL"}

data: {"heartRate": 112, "breathRate": 24, "status": "EMERGENCY"}
```

### 인증 흐름

```
카카오 로그인
    │
    ▼
카카오 액세스 토큰 획득
    │
    ▼
서버 /auth/kakao 로 전달 → JWT 발급
    │
    ▼
flutter_secure_storage 에 저장
    │
    ▼
이후 모든 API 요청에 Bearer 토큰 자동 첨부
```

---

## 8. 색상 시스템

> `lib/shared/theme/app_colors.dart`

| 이름 | 색상값 | 용도 |
|------|--------|------|
| `primary` | `#2E7D32` | 주요 액션, 버튼 |
| `primarySurface` | `#E8F5E9` | 주요 배경 |
| `danger` | `#D32F2F` | 긴급, 낙상, SOS |
| `dangerSurface` | `#FFEBEE` | 긴급 배경 |
| `warning` | `#F57C00` | 주의, 심박 이상 |
| `warningSurface` | `#FFF3E0` | 주의 배경 |
| `outing` | `#1976D2` | 외출 상태 |
| `outingSurface` | `#E3F2FD` | 외출 배경 |
| `statusOffline` | `#9E9E9E` | 오프라인 |
| `textPrimary` | `#212121` | 본문 텍스트 |
| `textSecondary` | `#757575` | 보조 텍스트 |
| `textHint` | `#BDBDBD` | 힌트 텍스트 |
| `border` | `#E0E0E0` | 카드 테두리 |
| `surface` | `#F5F5F5` | 페이지 배경 |

---

## 9. 데모 모드

실제 서버 없이 앱을 시연하기 위한 데모 데이터 시스템이 구현되어 있습니다.

### 보호자 데모 모드

> `lib/features/guardian/data/demo/guardian_demo_data.dart`

```dart
const bool kGuardianDemoMode = true;  // true: 데모 / false: 실제 API
const _GScenario kGuardianScenario = _GScenario.multipleIssues;
```

| 시나리오 | 설명 |
|----------|------|
| `normal` | 피보호자 2명 모두 정상 |
| `singleEmergency` | 피보호자 1명 낙상 긴급 상황 |
| `multipleIssues` | 4명: 긴급/주의/외출/정상 혼합 + 초대 알림 포함 |
| `allOffline` | 모두 오프라인 |

### 피보호자 데모 모드

> `lib/features/home/data/demo/dependent_demo_data.dart`

```dart
const bool kDemoMode = true;
const _Scenario kScenario = _Scenario.heartIssue;
```

| 시나리오 | 설명 |
|----------|------|
| `normal` | 정상 심박/호흡 |
| `heartIssue` | 심박수 이상 (107bpm) |
| `offline` | 기기 오프라인 |

---

## 10. 주요 의존성

| 패키지 | 용도 |
|--------|------|
| `flutter_riverpod` | 상태 관리 |
| `go_router` | 라우팅 |
| `dio` | HTTP 클라이언트 |
| `web_socket_channel` | WebSocket (향후 확장용) |
| `flutter_secure_storage` | JWT 토큰 보안 저장 |
| `shared_preferences` | 일반 설정 저장 |
| `kakao_flutter_sdk_user` | 카카오 OAuth2 로그인 |
| `fl_chart` | 생체 데이터 차트 |
| `flutter_local_notifications` | 로컬 푸시 알림 |
| `geolocator` + `geocoding` | 위치 서비스 |
| `flutter_dotenv` | 환경변수 관리 |
| `permission_handler` | 런타임 권한 요청 |
| `url_launcher` | 전화 걸기 등 외부 앱 연동 |
| `google_fonts` | 폰트 |
| `intl` | 날짜/숫자 포매팅 |
