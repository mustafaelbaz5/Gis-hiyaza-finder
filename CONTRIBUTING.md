# 🤝 Contributing Guide

This document covers everything a developer needs to set up,
run, test, and distribute this project.

---

## Requirements

| Tool         | Version              | Check                  |
| ------------ | -------------------- | ---------------------- |
| Flutter SDK  | 3.0+                 | `flutter --version`  |
| Dart SDK     | bundled with Flutter | `dart --version`     |
| Ruby         | 3.2.9+               | `ruby --version`     |
| Java         | JDK 17               | `java --version`     |
| Firebase CLI | latest               | `firebase --version` |
| Fastlane     | latest               | `fastlane --version` |
| make         | any                  | `make --version`     |

---

## First Time Setup

### 1. Clone and install

```bash
git clone https://github.com/mustafaelbaz5/App-Structure.git my_app
cd my_app
make install
```

### 2. Run code generation

```bash
make generate
```

### 3. Set up environment variables

Create a `.env` file in the project root — never commit this:

```
FIREBASE_CLI_TOKEN=your_token_here
```

### 4. Set up Fastlane

```bash
cd android
bundle install
```

---

## Running the App

```bash
make dev     # development flavor
make prod    # production flavor
```

---

## All Available Commands

### Setup

| Command           | Description                              |
| ----------------- | ---------------------------------------- |
| `make install`  | Install all dependencies                 |
| `make generate` | Run code generation once                 |
| `make watch`    | Run code generation in watch mode        |
| `make clean`    | Clean project and reinstall dependencies |

### Run

| Command       | Description            |
| ------------- | ---------------------- |
| `make dev`  | Run development flavor |
| `make prod` | Run production flavor  |

### Testing

| Command                      | Description                        |
| ---------------------------- | ---------------------------------- |
| `make test`                | Run all tests                      |
| `make test-verbose`        | Run all tests with each name shown |
| `make test-coverage`       | Run tests with coverage report     |
| `make test-core`           | Run core layer tests only          |
| `make test-features`       | Run features tests only            |
| `make test-file FILE=path` | Run a specific test file           |

### Code Quality

| Command               | Description                          |
| --------------------- | ------------------------------------ |
| `make analyze`      | Analyze code for warnings and errors |
| `make format`       | Auto-format all Dart files           |
| `make format-check` | Check formatting without applying    |

### Build

| Command                 | Description                      |
| ----------------------- | -------------------------------- |
| `make build-apk-dev`  | Build debug APK (development)    |
| `make build-apk-prod` | Build release APK (production)   |
| `make build-aab-prod` | Build release AAB for Play Store |
| `make build-ios-prod` | Build release IPA for App Store  |

### Packages

| Command                | Description                        |
| ---------------------- | ---------------------------------- |
| `make outdated`      | Check outdated packages            |
| `make upgrade`       | Upgrade packages safely            |
| `make upgrade-major` | Upgrade including breaking changes |

### Distribution

| Command                      | Description                           |
| ---------------------------- | ------------------------------------- |
| `make distribute-firebase` | Distribute production APK to Firebase |

---

## Project Structure

```
lib/
├── core/
│   ├── api/           # Dio setup, interceptors, API consumer
│   ├── config/        # App configuration per flavor
│   ├── di/            # Dependency injection (GetIt)
│   ├── errors/        # Exceptions and failure classes
│   ├── localization/  # EasyLocalization setup
│   ├── networking/    # Network connectivity checker
│   ├── router/        # App router and route names
│   ├── service/       # Secure storage service
│   ├── themes/        # Light/dark themes, colors, text styles
│   ├── utils/         # Extensions, validators, constants
│   └── widgets/       # Reusable shared widgets
│
└── features/
    └── your_feature/
        ├── data/      # Models, remote API, repository impl
        ├── logic/     # Cubit/Bloc, states
        └── ui/        # Screens and widgets

test/                  # mirrors lib/ structure exactly
integration_test/      # full app flow tests
```

---

## Adding a New Feature

Follow this structure for every new feature:

```
features/
  your_feature/
    data/
      models/           # request/response models
      remote/           # API calls
      repo/             # repository interface + implementation
    logic/
      cubit/            # cubit + states
    ui/
      screens/          # screen widgets
      widgets/          # feature-specific widgets
```

And mirror it in tests:

```
test/features/your_feature/
  data/
    models/             # fromJson, toJson tests
    remote/             # API call tests with mocks
    repo/               # success + failure tests
  logic/
    cubit/              # state emission tests
  ui/
    widgets/            # interaction + validation tests
```

---

## Adding a New Route

**3 steps every time:**

### 1. Add route name in `routes.dart`

```dart
static const String home = '/home';
```

### 2. Add case in `app_router.dart`

```dart
case Routes.home:
  return _buildRoute(const HomeScreen(), settings);
```

### 3. Add test in `app_router_test.dart`

```dart
test('returns route with correct name for home', () {
  final route = AppRouter.generateRoute(
    const RouteSettings(name: Routes.home),
  );
  expect(route.settings.name, equals(Routes.home));
});
```

---

## Testing Rules

| Rule                  | Description                                   |
| --------------------- | --------------------------------------------- |
| One test — one thing | Each test checks exactly one behavior         |
| Independent tests     | Use `setUp` to reset state before each test |
| Descriptive names     | Name tests like sentences                     |
| Test behavior         | Test what code does, not how it does it       |
| Test alongside code   | Write tests as you build, never after         |

### What to test

| File type          | What to test                        |
| ------------------ | ----------------------------------- |
| Models             | `fromJson` and `toJson`         |
| Repository impl    | success, failure, error handling    |
| Cubit/Bloc         | all state emissions                 |
| Widgets with forms | validation, interactions, callbacks |
| Extensions/utils   | all logic branches                  |

### What to skip

| File type           | Why                            |
| ------------------- | ------------------------------ |
| Abstract classes    | no logic                       |
| State classes       | just data holders              |
| Screen compositors  | just compose other widgets     |
| Navigation wrappers | just wraps Flutter's Navigator |

---

## Git Workflow

```
main        ← production ready, triggers CI/CD
develop     ← integration branch
feature/*   ← new features
fix/*       ← bug fixes
```

### Branch naming

```bash
git checkout -b feature/auth-screen
git checkout -b fix/login-validation
```

### Commit message format

```
type: short description

feat: add login screen
fix: resolve password validation bug
test: add auth cubit tests
refactor: clean up dio factory
docs: update contributing guide
```

### Before every commit

```bash
make format     # format code
make analyze    # check for issues
make test       # run all tests
```

### Pull Request checklist

- [ ] Feature works in development flavor
- [ ] Tests written and passing
- [ ] `make analyze` passes with no issues
- [ ] `make format` applied
- [ ] PR description explains what changed and why

---

## CI/CD Pipeline

Every push to `main` automatically:

1. Runs all tests — stops if any fail
2. Runs `flutter analyze`
3. Builds production APK
4. Distributes to Firebase App Distribution
5. Notifies testers via email

> **Rule:** only merge to `main` when ready for testers.
> Every merge = a new build distributed.

For full CI/CD setup see [docs/CICD.md](docs/CICD.md).

---

## Documentation

| File                        | Purpose                          |
| --------------------------- | -------------------------------- |
| `README.md`               | Project overview and quick start |
| `docs/SETUP.md`           | Project setup and first run      |
| `docs/FIREBASE.md`        | Firebase and Fastlane setup      |
| `docs/CICD.md`            | GitHub Actions workflow          |
| `docs/TESTING.md`         | Testing guide                    |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes          |
| `CONTRIBUTING.md`         | This file                        |

---

## Getting Help

| Resource        | Link                                                      |
| --------------- | --------------------------------------------------------- |
| Flutter docs    | [flutter.dev/docs](https://flutter.dev/docs)                 |
| Firebase docs   | [firebase.google.com/docs](https://firebase.google.com/docs) |
| Fastlane docs   | [docs.fastlane.tools](https://docs.fastlane.tools)           |
| Troubleshooting | [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)           |

---

*Made with ❤️ by Mustafa Elbaz*

```

---

## Full documentation is now complete ✅
```

README.md              ← overview + quick start
CONTRIBUTING.md        ← this file
docs/
  SETUP.md             ← project setup
  FIREBASE.md          ← firebase + fastlane
  CICD.md              ← github actions
  TESTING.md           ← testing guide
  TROUBLESHOOTING.md   ← common issues
