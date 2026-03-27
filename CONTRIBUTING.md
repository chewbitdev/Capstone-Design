# Contributing to iKong

<p align="right"><a href="CONTRIBUTING.ko.md">한국어</a></p>

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── app.dart                    # MaterialApp, router setup
│
├── core/                       # Global shared modules (minimize changes)
│   ├── constants/              # App constants, API URLs, key values
│   ├── errors/                 # Exception / failure classes
│   ├── network/                # Dio client, interceptors, WebSocket
│   ├── services/               # Location, notification, local storage, background
│   ├── router/                 # go_router route definitions
│   └── utils/                  # Date formatter, validators, utilities
│
├── features/                   # Feature modules (main development area)
│   ├── auth/                   # Login / Sign up
│   ├── profile/                # Profile / My info
│   ├── biometric/              # Real-time biometric (heart rate, breathing)
│   ├── health_record/          # Health records / statistics charts
│   ├── emergency/              # Emergency call (119, guardian)
│   ├── fall_detection/         # Fall detection
│   ├── guardian/               # Guardian registration / management
│   ├── activity/               # Activity monitoring
│   ├── report/                 # Health report / AI analysis
│   ├── notification/           # Notification list
│   └── settings/               # App settings
│
└── shared/                     # Shared UI components
    ├── widgets/                # Reusable widgets
    ├── theme/                  # Colors, fonts, theme
    └── extensions/             # Dart extension functions
```

---

## Clean Architecture Layer Structure

Each feature must be composed of the following 3 layers.

```
feature/
├── data/               # External data (API, local DB)
│   ├── datasources/    # API calls / SharedPreferences
│   ├── models/         # JSON serialization models (fromJson / toJson)
│   └── repositories/   # Repository implementation
│
├── domain/             # Business logic (pure Dart, no external dependencies)
│   ├── entities/       # Pure data classes
│   ├── repositories/   # Repository abstract interfaces
│   └── usecases/       # Single-responsibility business logic
│
└── presentation/       # UI
    ├── pages/          # Screen units
    ├── widgets/        # Feature-specific widgets
    └── providers/      # Riverpod Provider / State
```

### Layer Dependency Rules

```
presentation → domain ← data
```

- `presentation` references only `domain`
- `data` references only `domain`
- `domain` has no external dependencies (no Flutter, Dio imports)
- Cross-layer direct references are prohibited

---

## Native Feature Development

Platform-specific settings that cannot be handled in Flutter `lib/` should be modified at the following locations.

### Android — `android/`

| Task | File Location |
|---|---|
| Add permissions (camera, location, notification, etc.) | `android/app/src/main/AndroidManifest.xml` |
| Change minimum SDK version | `android/app/build.gradle.kts` |
| Firebase integration | `android/app/google-services.json` (add manually) |
| Change app icon | `android/app/src/main/res/mipmap-*/` |
| Background service | `android/app/src/main/kotlin/com/capstone/ikong/` |

### iOS — `ios/`

| Task | File Location |
|---|---|
| Add permissions (camera, location, notification, etc.) | `ios/Runner/Info.plist` |
| Firebase integration | `ios/Runner/GoogleService-Info.plist` (add manually) |
| Change app icon | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Change deployment target version | `ios/Podfile` |
| Native code | `ios/Runner/` (Swift) |

---

## State Management — Riverpod

```dart
// Provider definition (providers/ folder)
@riverpod
class HeartRateNotifier extends _$HeartRateNotifier {
  @override
  int build() => 0;

  void update(int value) => state = value;
}

// Usage in UI
final heartRate = ref.watch(heartRateNotifierProvider);
```

- Use `@riverpod` annotation (riverpod_generator)
- Code generation: `dart run build_runner build`

---

## Network — Dio

```dart
// Managed as singleton in core/network/api_client.dart
// Use only in datasource, never call directly from presentation

final response = await _apiClient.get('/health/heart-rate');
```

---

## Coding Conventions

### File Names
- Lowercase + underscore: `heart_rate_widget.dart`

### Class Names
- PascalCase: `HeartRateWidget`

### Variable / Function Names
- camelCase: `heartRate`, `getHeartRate()`

### Constants
- camelCase: `AppConstants.heartRateMax`

### Widget Structure
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

## Git Branch Strategy

```
main                        # Production branch (direct push restricted)
├── develop                 # Development integration branch
│   ├── feat/auth           # Feature implementation
│   ├── feat/biometric
│   ├── bug/login-crash     # Bug fix
│   ├── ui/home-screen      # UI work
│   ├── enhance/chart       # Enhancement
│   ├── refactor/api        # Refactoring
│   ├── test/biometric      # Testing
│   └── docs/setup-guide    # Documentation
```

### Create a Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feat/feature-name
```

### Label & Branch & Commit Rules

| Label | Branch Prefix | Commit Prefix | Description |
|---|---|---|---|
| `Feat` | `feat/` | `feat:` | Feature implementation |
| `Bug` | `bug/` | `fix:` | Bug report / fix |
| `UI` | `ui/` | `style:` | UI work |
| `Enhance` | `enhance/` | `enhance:` | Enhancement |
| `Refactor` | `refactor/` | `refactor:` | Refactoring |
| `Test` | `test/` | `test:` | Testing |
| `Docs` | `docs/` | `docs:` | Documentation |

```bash
git commit -m "feat: implement real-time heart rate screen"
git commit -m "fix: resolve login token storage bug"
git commit -m "style: improve home screen UI"
git commit -m "docs: add API specification document"
```

### Issue & PR Rules
- Create an issue before starting work and attach the appropriate label
- Use the branch prefix matching the issue label
- Create PR targeting `develop` branch
- Merge after at least 1 code review approval
- PR title follows the same commit message convention

---

## Adding Packages

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Commit and share with the team

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add [package-name] package"
```
