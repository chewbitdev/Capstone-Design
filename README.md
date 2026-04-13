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
  Real-time health monitoring and emergency response app for the elderly
</p>

<p align="center">
  <a href="README.ko.md">한국어</a>
</p>

---

**iKong** is a smart healthcare app designed for elderly people living alone.
It receives real-time biometric data from wearable devices and automatically notifies guardians and emergency services when a fall or emergency is detected.

## Features

- **Real-time Biometric Monitoring** — Live heart rate / breathing rate measurement with anomaly alerts
- **Health Records** — Daily / weekly / monthly statistics charts and sleep biometric logging
- **Fall Detection** — Automatic fall detection with auto-report after prolonged inactivity
- **Emergency Call** — One-tap 119 emergency button and instant guardian notification
- **Auto Alerts** — Automatic message with current location and biometric data sent to guardians
- **Guardian Mode** — Real-time status check and health data dashboard for guardians
- **Activity Monitoring** — Activity analysis, daily pattern tracking, prolonged bed detection
- **Health Report** — Weekly health analysis and AI-based anomaly pattern detection
- **Multi-Guardian** — Register up to N guardians with configurable permissions

## Architecture

```
        APP                                        SERVER
┌─────────────────┐          REST API        ┌─────────────────┐
│   Flutter App   │ ◄──────────────────────► │  Spring Boot    │
│  (Android/iOS)  │                          │                 │
│                 │        WebSocket         │  · REST API     │
│  · UI / State   │ ◄──────────────────────► │  · WebSocket    │
│  · Biometric    │   (Real-time biometric)  │  · FCM Push     │
│  · Emergency    │                          │                 │
└─────────────────┘          FCM             └────────┬────────┘
         ▲                                            │
         └────────────────────────────────────────────┘
                         Push Notification
```

### App Internal Structure (Clean Architecture)

```
Presentation  →  Domain  ←  Data
(UI/Riverpod)    (UseCase)   (API/Local)
                              ↕
                       Spring Boot API
```

## Tech Stack

### App (Flutter)

| Category | Technology |
|---|---|
| Framework | Flutter 3.41.5 / Dart 3.11.3 |
| Architecture | Clean Architecture + Feature-first |
| State Management | Riverpod |
| Routing | go_router |
| Network | Dio, WebSocket |
| Local Storage | SharedPreferences, Hive, SecureStorage |
| Location | Geolocator |
| Notification | FCM, flutter_local_notifications |
| Chart | fl_chart |
| Code Generation | build_runner, json_serializable, riverpod_generator |

### Server (Spring Boot)

| Category | Technology |
|---|---|
| Framework | Spring Boot 3.x |
| Language | Java 21 |
| Communication | REST API, WebSocket |
| Authentication | JWT |
| Push Notification | Firebase FCM |

## Build & Run

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41.5+
- Dart 3.11.3+
- Android Studio / Xcode

```bash
flutter --version
```

### Clone & Install Dependencies

```bash
git clone https://github.com/chewbitdev/Capstone-Design.git
cd Capstone-Design
flutter pub get
```

### Run

```bash
# Launch Android emulator
flutter emulators --launch Pixel_9_Pro_XL

# Launch iOS simulator (Mac only)
flutter emulators --launch apple_ios_simulator

# Run app
flutter run -d all
```

> See [SETUP.md](SETUP.md) for detailed setup instructions.

## Contributing

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for details.

- [Issues](https://github.com/chewbitdev/Capstone-Design/issues) — Bug reports and feature requests
- [Pull Requests](https://github.com/chewbitdev/Capstone-Design/pulls) — New features, documentation improvements, and bug fixes

## Documentation

| Document | Description |
|---|---|
| [SETUP.md](SETUP.md) | Environment setup guide (Mac / Windows) |
| [COMMANDS.md](COMMANDS.md) | Frequently used commands |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Project structure and development guidelines |

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.
