# 🚀 Flutter Starter Template

> A professional, production-ready Flutter template featuring clean
> architecture, multi-environment support, and automated CI/CD workflows.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## ✨ What's Included

| Feature               | Description                                      |
| --------------------- | ------------------------------------------------ |
| 🏗️ Clean Architecture | Scalable structure with separation of concerns   |
| 🎨 Theme System       | Light/dark mode with custom color system         |
| 🌍 Localization       | Arabic + English support via EasyLocalization    |
| 🔒 Secure Storage     | Encrypted local storage via FlutterSecureStorage |
| 🌐 Networking         | Dio with interceptors, auth token injection      |
| 🧭 Routing            | Centralized router with slide transitions        |
| 🎭 Multi-Flavor       | Separate development and production environments |
| 🔥 Firebase Ready     | Pre-configured for Firebase App Distribution     |
| 🚀 CI/CD              | GitHub Actions + Fastlane automated pipeline     |
| ✅ Testing            | Unit, widget tests with full core coverage       |

---

## 📋 Requirements

| Tool                     | Version                            |
| ------------------------ | ---------------------------------- |
| Flutter SDK              | 3.0+                               |
| Dart SDK                 | bundled with Flutter               |
| Android Studio / VS Code | latest                             |
| Git                      | any                                |
| Ruby                     | 3.0+ (for Fastlane)                |
| Firebase CLI             | latest                             |
| make                     | any (Windows:`choco install make`) |

---

## ⚡ Quick Start

```bash
# 1. Clone
git clone https://github.com/mustafaelbaz5/App-Structure.git my_app
cd my_app

# 2. Install dependencies
flutter pub get

# 3. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 4. Run development flavor
flutter run --flavor development --target lib/main_dev.dart
```

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── api/          # Dio setup, interceptors, API consumer
│   ├── config/       # App configuration per flavor
│   ├── di/           # Dependency injection (GetIt)
│   ├── errors/       # Exceptions and failure classes
│   ├── localization/ # EasyLocalization setup
│   ├── networking/   # Network connectivity checker
│   ├── router/       # App router and route names
│   ├── service/      # Secure storage service
│   ├── themes/       # Light/dark themes, colors, text styles
│   ├── utils/        # Extensions, validators, constants
│   └── widgets/      # Reusable shared widgets
│
└── features/
    └── your_feature/
        ├── data/     # Models, remote API, repository impl
        ├── logic/    # Cubit/Bloc, states
        └── ui/       # Screens and widgets
```

---

## 📚 Documentation

| Guide                                       | Description                              |
| ------------------------------------------- | ---------------------------------------- |
| [Setup Guide](docs/SETUP.md)                | Project setup, rename, and first run     |
| [Firebase &amp; Fastlane](docs/FIREBASE.md) | Firebase project + Fastlane distribution |
| [CI/CD Workflow](docs/CICD.md)              | GitHub Actions pipeline setup            |
| [Testing Guide](docs/TESTING.md)            | How to write and run tests               |
| [Troubleshooting](docs/TROUBLESHOOTING.md)  | Common issues and fixes                  |
| [Contributing](CONTRIBUTING.md)             | How to contribute to this project        |

---

## 🛠️ Common Commands

```bash
make install          # install dependencies
make dev              # run development flavor
make prod             # run production flavor
make test             # run all tests
make test-verbose     # run tests with names
make generate         # run code generation
make analyze          # analyze code
make format           # format dart files
make clean            # clean and reinstall
make outdated         # check outdated packages
make upgrade          # upgrade packages
make distribute-firebase  # distribute to Firebase
make help             # show all commands
```

---

## 👨‍💻 Author

**Mustafa Elbaz**

- GitHub: [@mustafaelbaz5](https://github.com/mustafaelbaz5)

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## ⭐ Support

If this template helped you, please give it a ⭐️ on GitHub!

---

_Made with ❤️ by Mustafa Elbaz_
