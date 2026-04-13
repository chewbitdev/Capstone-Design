# iKong

[![Flutter](https://img.shields.io/badge/Flutter-3.41.5-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.3-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.x-6DB33F?style=flat-square&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-007396?style=flat-square&logo=openjdk&logoColor=white)](https://adoptium.net)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?style=flat-square)](https://github.com/chewbitdev/Capstone-Design)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE.md)

<p align="center">
  <img src="assets/images/icon.png" alt="iKong Logo" width="96"/>
</p>

<p align="center">
  노인을 위한 실시간 건강 모니터링 및 응급 대응 앱
</p>

<p align="center">
  <a href="README.md">English</a>
</p>

---

**iKong**은 독거노인 및 고령자의 안전을 위한 스마트 헬스케어 앱입니다.
웨어러블 기기로부터 실시간 생체 데이터를 수신하고, 낙상 및 응급 상황 발생 시 보호자와 119에 자동으로 알림을 전송합니다.

## 주요 기능

- **실시간 생체 모니터링** — 심박수 / 호흡수 실시간 측정 및 이상 수치 즉시 알림
- **건강 기록** — 일 / 주 / 월 단위 통계 그래프 및 수면 중 생체 데이터 기록
- **낙상 감지** — 낙상 자동 감지 후 무움직임 지속 시 자동 신고
- **긴급 호출** — 119 바로 신고 버튼 및 보호자 즉시 호출
- **자동 알림** — 보호자에게 현재 위치 + 생체 데이터 자동 전송
- **보호자 기능** — 부모님 상태 실시간 확인 및 건강 데이터 조회
- **생활 모니터링** — 활동량 분석, 하루 활동 패턴, 장시간 침대 감지
- **건강 리포트** — 주간 건강 분석 자동 생성 및 AI 기반 이상 패턴 감지
- **멀티 보호자** — 보호자 최대 N명 등록 및 권한 설정

## 시스템 아키텍처

```
        APP                                        SERVER
┌─────────────────┐          REST API        ┌─────────────────┐
│   Flutter App   │ ◄──────────────────────► │  Spring Boot    │
│  (Android/iOS)  │                          │                 │
│                 │        WebSocket         │  · REST API     │
│  · UI / State   │ ◄──────────────────────► │  · WebSocket    │
│  · Biometric    │    (실시간 생체 데이터)      │  · FCM 발송     │
│  · Emergency    │                          │                 │
└─────────────────┘          FCM             └────────┬────────┘
         ▲                                            │
         └────────────────────────────────────────────┘
                         Push Notification
```

### 앱 내부 구조 (Clean Architecture)

```
Presentation  →  Domain  ←  Data
(UI/Riverpod)    (UseCase)   (API/Local)
                              ↕
                       Spring Boot API
```

## 기술 스택

### 앱 (Flutter)

| 분류 | 기술 |
|---|---|
| 프레임워크 | Flutter 3.41.5 / Dart 3.11.3 |
| 아키텍처 | Clean Architecture + Feature-first |
| 상태관리 | Riverpod |
| 라우팅 | go_router |
| 네트워크 | Dio, WebSocket |
| 로컬저장소 | SharedPreferences, Hive, SecureStorage |
| 위치 | Geolocator |
| 알림 | FCM, flutter_local_notifications |
| 차트 | fl_chart |
| 코드생성 | build_runner, json_serializable, riverpod_generator |

### 서버 (Spring Boot)

| 분류 | 기술 |
|---|---|
| 프레임워크 | Spring Boot 3.x |
| 언어 | Java 21 |
| 통신 | REST API, WebSocket |
| 인증 | JWT |
| 푸시 알림 | Firebase FCM |

## 시작하기

### 사전 요구사항

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41.5+
- Dart 3.11.3+
- Android Studio / Xcode

```bash
flutter --version
```

### 클론 및 패키지 설치

```bash
git clone https://github.com/chewbitdev/Capstone-Design.git
cd Capstone-Design
flutter pub get
```

### 실행

```bash
# Android 에뮬레이터 실행
flutter emulators --launch Pixel_9_Pro_XL

# iOS 시뮬레이터 실행 (Mac only)
flutter emulators --launch apple_ios_simulator

# 앱 실행
flutter run -d all
```

> 자세한 세팅 방법은 [SETUP.md](SETUP.md) 참고

## 기여하기

[CONTRIBUTING.ko.md](CONTRIBUTING.ko.md) 참고

- [Issues](https://github.com/chewbitdev/Capstone-Design/issues) — 버그 리포트 및 기능 제안
- [Pull Requests](https://github.com/chewbitdev/Capstone-Design/pulls) — 기능 개발, 문서 개선, 버그 수정

## 문서

| 문서 | 설명 |
|---|---|
| [SETUP.md](SETUP.md) | 개발환경 세팅 가이드 (Mac / Windows) |
| [COMMANDS.md](COMMANDS.md) | 자주 쓰는 명령어 모음 |
| [CONTRIBUTING.ko.md](CONTRIBUTING.ko.md) | 프로젝트 구조 및 개발 가이드라인 |

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE.ko.md](LICENSE.ko.md)를 참고하세요.
