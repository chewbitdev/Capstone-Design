# iKong 개발환경 세팅 가이드

## 공통 사전 준비

### 1. Flutter SDK 설치

**Mac**
```bash
brew install --cask flutter
```

**Windows**
1. https://docs.flutter.dev/get-started/install/windows 접속
2. Flutter SDK zip 다운로드 후 `C:\flutter` 에 압축 해제
3. 환경변수 PATH에 `C:\flutter\bin` 추가

**설치 확인**
```bash
flutter --version
```

---

### 2. Android Studio 설치 (공통)

1. https://developer.android.com/studio 에서 다운로드 후 설치
2. 실행 후 `SDK Manager` 열기
3. 아래 항목 설치:
   - Android SDK Platform 35
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
4. `AVD Manager`에서 에뮬레이터 생성 (Pixel 9 Pro XL 권장)

---

### 3. Xcode 설치 (Mac only - iOS 빌드용)

```bash
# App Store에서 Xcode 설치 후
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# CocoaPods 설치
brew install cocoapods
```

---

### 4. Java 설치

**Mac**
```bash
brew install --cask temurin   # OpenJDK 21
```

**Windows**
1. https://adoptium.net 에서 JDK 21 설치

---

## 프로젝트 세팅

### 1. 레포지토리 클론

```bash
git clone https://github.com/chewbitdev/Capstone-Design.git
cd Capstone-Design
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. Flutter 환경 진단

```bash
flutter doctor
```
> 모든 항목에 ✓ 표시 확인. 문제 있으면 출력 메시지 따라 해결.

---

## 에뮬레이터 실행

```bash
# 사용 가능한 에뮬레이터 목록 확인
flutter emulators

# iOS 시뮬레이터 실행 (Mac only)
flutter emulators --launch apple_ios_simulator

# Android 에뮬레이터 실행
flutter emulators --launch Pixel_9_Pro_XL
```

---

## 앱 실행

```bash
# 연결된 디바이스 확인
flutter devices

# 특정 디바이스 실행
flutter run -d emulator-5554       # Android
flutter run -d <iOS_DEVICE_ID>     # iOS

# 전체 동시 실행
flutter run -d all
```

---

## VS Code 세팅 (선택)

1. VS Code 설치: https://code.visualstudio.com
2. 확장 프로그램 설치:
   - `Flutter` (Dart 포함 자동 설치)
   - `Dart`

---

## 자주 발생하는 오류

### flutter doctor에서 Android toolchain 오류
```bash
flutter doctor --android-licenses   # 라이선스 동의
```

### CocoaPods 오류 (Mac)
```bash
brew install cocoapods
pod repo update
```

### Gradle 빌드 실패
```bash
flutter clean
flutter pub get
flutter run
```

### Windows에서 PATH 적용 안 될 때
- 시스템 속성 > 환경 변수 > Path에 `C:\flutter\bin` 추가 후 **터미널 재시작**
