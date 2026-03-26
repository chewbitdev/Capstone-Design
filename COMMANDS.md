# iKong 개발 명령어 정리

## 에뮬레이터

```bash
# 사용 가능한 에뮬레이터 목록
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch apple_ios_simulator   # iOS
flutter emulators --launch Pixel_9_Pro_XL        # Android

# 연결된 디바이스 확인
flutter devices
```

---

## 앱 실행

```bash
# 특정 디바이스에서 실행
flutter run -d emulator-5554                     # Android 에뮬레이터
flutter run -d <iOS_DEVICE_ID>                   # iOS 시뮬레이터

# 모든 디바이스에서 동시 실행
flutter run -d all

# 릴리즈 모드로 실행
flutter run --release
```

---

## 실행 중 단축키 (터미널)

| 키 | 동작 |
|---|---|
| `r` | Hot Reload (코드 변경 즉시 반영) |
| `R` | Hot Restart (앱 전체 재시작) |
| `d` | 디바이스 연결 해제 (앱은 유지) |
| `q` | 앱 종료 |
| `p` | 위젯 경계선 표시 |
| `i` | Inspector 토글 |
| `o` | 렌더링 레이어 오버레이 |

---

## 빌드

```bash
# Android APK 빌드
flutter build apk
flutter build apk --release

# Android App Bundle (플레이스토어용)
flutter build appbundle

# iOS 빌드
flutter build ios
flutter build ios --release

# 빌드 캐시 삭제
flutter clean
```

---

## 패키지

```bash
# 패키지 설치 (pubspec.yaml 변경 후)
flutter pub get

# 패키지 업그레이드
flutter pub upgrade

# 코드 자동 생성 (riverpod, json_serializable 등)
dart run build_runner build
dart run build_runner watch          # 파일 변경 감지 자동 생성
dart run build_runner build --delete-conflicting-outputs
```

---

## 디버그

```bash
# Flutter 환경 진단
flutter doctor

# 로그 보기
flutter logs

# DevTools (브라우저 디버거)
flutter pub global activate devtools
flutter pub global run devtools

# 분석 (린트 오류 확인)
flutter analyze

# 테스트 실행
flutter test
```

---

## Git / GitHub

```bash
# 변경사항 확인
git status
git diff

# 커밋
git add .
git commit -m "커밋 메시지"

# 푸시 (토큰 필요)
git remote set-url origin https://<TOKEN>@github.com/chewbitdev/Capstone-Design.git
git push origin main
git remote set-url origin https://github.com/chewbitdev/Capstone-Design.git
```
