# iKong

> 노인을 위한 실시간 건강 모니터링 및 응급 대응 앱

---

## 프로젝트 개요

iKong은 노인의 생체 정보를 실시간으로 모니터링하고, 낙상 감지 및 응급 상황 발생 시 보호자와 119에 자동으로 알림을 전송하는 스마트 헬스케어 앱입니다.

| 항목 | 내용 |
|---|---|
| 플랫폼 | Android, iOS |
| 프레임워크 | Flutter 3.41.5 |
| 백엔드 | Spring Boot (Java) |
| 아키텍처 | Clean Architecture + Feature-first |
| 상태관리 | Riverpod |

---

## 주요 기능

- **실시간 생체 정보** — 심박수 / 호흡수 실시간 표시
- **건강 기록** — 일 / 주 / 월 통계 그래프, 수면 중 데이터
- **낙상 감지** — 낙상 감지 후 무움직임 지속 시 자동 알림
- **긴급 호출** — 119 바로 신고, 보호자 즉시 호출
- **자동 알림** — 보호자에게 위치 + 생체 데이터 자동 전송
- **보호자 앱** — 부모님 상태 실시간 확인, 건강 데이터 조회
- **생활 모니터링** — 활동량 분석, 장시간 침대 감지
- **건강 리포트** — 주간 분석, AI 이상 패턴 감지

---

## 문서

| 문서 | 설명 |
|---|---|
| [SETUP.md](SETUP.md) | 개발환경 세팅 (Mac / Windows) |
| [COMMANDS.md](COMMANDS.md) | 자주 쓰는 명령어 모음 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 프로젝트 구조 및 개발 가이드라인 |

---

## 빠른 시작

```bash
# 1. 클론
git clone https://github.com/chewbitdev/Capstone-Design.git
cd Capstone-Design

# 2. 패키지 설치
flutter pub get

# 3. 에뮬레이터 실행
flutter emulators --launch Pixel_9_Pro_XL        # Android
flutter emulators --launch apple_ios_simulator   # iOS (Mac only)

# 4. 앱 실행
flutter run -d all
```

> 자세한 세팅 방법은 [SETUP.md](SETUP.md) 참고

---

## 기술 스택

| 분류 | 패키지 |
|---|---|
| 상태관리 | flutter_riverpod, riverpod_annotation |
| 라우팅 | go_router |
| 네트워크 | dio, web_socket_channel |
| 로컬저장소 | shared_preferences, flutter_secure_storage, hive |
| 위치 | geolocator, geocoding |
| 알림 | flutter_local_notifications |
| 차트 | fl_chart |
| 권한 | permission_handler |
| 코드생성 | build_runner, json_serializable, riverpod_generator |
