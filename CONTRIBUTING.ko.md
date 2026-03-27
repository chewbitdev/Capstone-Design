# iKong 개발 가이드라인

<p align="right"><a href="CONTRIBUTING.md">English</a></p>

## 프로젝트 구조

```
lib/
├── main.dart                   # 앱 진입점
├── app.dart                    # MaterialApp, 라우터 설정
│
├── core/                       # 전역 공통 모듈 (변경 최소화)
│   ├── constants/              # 앱 상수, API 주소, 키값
│   ├── errors/                 # 예외 / 실패 클래스
│   ├── network/                # Dio 클라이언트, 인터셉터, WebSocket
│   ├── services/               # 위치, 알림, 로컬저장소, 백그라운드
│   ├── router/                 # go_router 라우트 정의
│   └── utils/                  # 날짜 포맷, 유효성 검사 등 유틸
│
├── features/                   # 기능별 모듈 (주요 개발 영역)
│   ├── auth/                   # 로그인 / 회원가입
│   ├── profile/                # 프로필 / 내 정보
│   ├── biometric/              # 실시간 생체 정보 (심박수, 호흡수)
│   ├── health_record/          # 건강 기록 / 통계 그래프
│   ├── emergency/              # 긴급 호출 (119, 보호자)
│   ├── fall_detection/         # 낙상 감지
│   ├── guardian/               # 보호자 등록 / 관리
│   ├── activity/               # 활동량 모니터링
│   ├── report/                 # 건강 리포트 / AI 분석
│   ├── notification/           # 알림 목록
│   └── settings/               # 앱 설정
│
└── shared/                     # 공용 UI 컴포넌트
    ├── widgets/                # 재사용 위젯
    ├── theme/                  # 색상, 폰트, 테마
    └── extensions/             # Dart 확장 함수
```

---

## Clean Architecture 레이어 구조

각 feature는 반드시 아래 3개 레이어로 구성합니다.

```
feature/
├── data/               # 외부 데이터 (API, 로컬 DB)
│   ├── datasources/    # API 호출 / SharedPreferences 읽기
│   ├── models/         # JSON 직렬화 모델 (fromJson / toJson)
│   └── repositories/   # Repository 구현체
│
├── domain/             # 비즈니스 로직 (순수 Dart, 의존성 없음)
│   ├── entities/       # 순수 데이터 클래스
│   ├── repositories/   # Repository 추상 인터페이스
│   └── usecases/       # 단일 기능 비즈니스 로직
│
└── presentation/       # UI
    ├── pages/          # 화면 단위
    ├── widgets/        # 해당 feature 전용 위젯
    └── providers/      # Riverpod Provider / State
```

### 레이어 간 의존성 규칙

```
presentation → domain ← data
```

- `presentation`은 `domain`만 참조
- `data`는 `domain`만 참조
- `domain`은 외부 의존성 없음 (Flutter, Dio 등 import 금지)
- 레이어를 건너뛴 직접 참조 금지

---

## 네이티브 기능 개발 위치

Flutter `lib/`에서 처리할 수 없는 플랫폼별 설정은 아래 위치에서 수정합니다.

### Android — `android/`

| 작업 | 파일 위치 |
|---|---|
| 권한 추가 (카메라, 위치, 알림 등) | `android/app/src/main/AndroidManifest.xml` |
| 최소 SDK 버전 변경 | `android/app/build.gradle.kts` |
| Firebase 연동 | `android/app/google-services.json` (직접 추가) |
| 앱 아이콘 변경 | `android/app/src/main/res/mipmap-*/` |
| 백그라운드 서비스 | `android/app/src/main/kotlin/com/capstone/ikong/` |

### iOS — `ios/`

| 작업 | 파일 위치 |
|---|---|
| 권한 추가 (카메라, 위치, 알림 등) | `ios/Runner/Info.plist` |
| Firebase 연동 | `ios/Runner/GoogleService-Info.plist` (직접 추가) |
| 앱 아이콘 변경 | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| 배포 타겟 버전 변경 | `ios/Podfile` |
| 네이티브 코드 | `ios/Runner/` (Swift) |

### 공통 권한 추가 예시

**Android** `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**iOS** `Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>응급 상황 시 위치 정보를 전송합니다.</string>
<key>NSCameraUsageDescription</key>
<string>프로필 사진 등록에 사용됩니다.</string>
```

---

## 상태관리 — Riverpod

```dart
// Provider 정의 (providers/ 폴더)
@riverpod
class HeartRateNotifier extends _$HeartRateNotifier {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

// UI에서 사용
final heartRate = ref.watch(heartRateNotifierProvider);
```

- `@riverpod` 어노테이션 사용 (riverpod_generator)
- 코드 생성: `dart run build_runner build`

---

## 네트워크 — Dio

```dart
// core/network/api_client.dart 에서 싱글톤으로 관리
// datasource에서만 사용, presentation에서 직접 호출 금지

final response = await _apiClient.get('/health/heart-rate');
```

---

## 코딩 컨벤션

### 파일명
- 소문자 + 언더스코어: `heart_rate_widget.dart`

### 클래스명
- 파스칼케이스: `HeartRateWidget`

### 변수 / 함수명
- 카멜케이스: `heartRate`, `getHeartRate()`

### 상수
- 카멜케이스: `AppConstants.heartRateMax`

### 위젯 구조
```dart
class HeartRateWidget extends StatelessWidget {
  const HeartRateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

---

## Git 브랜치 전략

```
main                        # 배포 브랜치 (관리자 외 직접 push 금지)
├── develop                 # 개발 통합 브랜치
│   ├── feat/auth           # 기능 구현
│   ├── feat/biometric
│   ├── bug/login-crash     # 버그 수정
│   ├── ui/home-screen      # UI 작업
│   ├── enhance/chart       # 개선
│   ├── refactor/api        # 리팩토링
│   ├── test/biometric      # 테스트
│   └── docs/setup-guide    # 문서
```

### 브랜치 생성
```bash
git checkout develop
git pull origin develop
git checkout -b feat/기능명
```

### 라벨 & 브랜치 & 커밋 규칙

| 라벨 | 브랜치 prefix | 커밋 prefix | 설명 |
|---|---|---|---|
| `Feat` | `feat/` | `feat:` | 기능 구현 이슈 |
| `Bug` | `bug/` | `fix:` | 버그 발생/Fix 이슈 |
| `UI` | `ui/` | `style:` | UI 작업 이슈 |
| `Enhance` | `enhance/` | `enhance:` | 개선 이슈 |
| `Refactor` | `refactor/` | `refactor:` | 리팩토링 이슈 |
| `Test` | `test/` | `test:` | 테스트 이슈 |
| `Docs` | `docs/` | `docs:` | 문서 이슈 |

```bash
git commit -m "feat: 실시간 심박수 화면 구현"
git commit -m "fix: 로그인 토큰 저장 오류 수정"
git commit -m "style: 홈 화면 UI 개선"
git commit -m "docs: API 명세 문서 추가"
```

### 이슈 & PR 규칙
- 작업 시작 전 이슈 생성 후 라벨 부착
- 브랜치는 이슈 라벨에 맞는 prefix 사용
- `develop` 브랜치로 PR 생성
- 최소 1명 코드 리뷰 후 머지
- PR 제목은 커밋 메시지 규칙과 동일하게

---

## 패키지 추가 시

1. `pubspec.yaml`에 추가
2. `flutter pub get` 실행
3. 팀원에게 공유 (pubspec.yaml 커밋)

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: 패키지명 패키지 추가"
```
