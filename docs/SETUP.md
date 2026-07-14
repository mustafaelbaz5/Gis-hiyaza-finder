# 📦 Setup Guide

Everything you need to get this project running from scratch.

---

## 1. Prerequisites

Install these tools before starting:

| Tool                | How to install                                                                       |
| ------------------- | ------------------------------------------------------------------------------------ |
| Flutter SDK 3.0+    | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Git                 | [git-scm.com](https://git-scm.com/)                                                  |
| Android Studio      | [developer.android.com/studio](https://developer.android.com/studio)                 |
| VS Code (optional)  | [code.visualstudio.com](https://code.visualstudio.com/)                              |
| make (Windows only) | `choco install make` (run as admin)                                                  |

**Verify your Flutter installation:**

```bash
flutter doctor
```

All items should show ✅ before continuing.

---

## 2. Clone the Repository

```bash
git clone https://github.com/mustafaelbaz5/App-Structure.git my_app
cd my_app
```

---

## 3. Link to Your Own Repository

### Option A — Keep original commit history

```bash
# Remove original remote
git remote remove origin

# Add your new repository
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git

# Verify
git remote -v

# Push
git branch -M main
git push -u origin main
```

### Option B — Start fresh (recommended)

```bash
# Remove existing git history
rm -rf .git

# Initialize new repository
git init

# Stage all files
git add .

# First commit
git commit -m "Initial commit: Flutter starter template"

# Rename branch
git branch -M main

# Add your repository
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git

# Push
git push -u origin main
```

> **Why Option B?** Clean commit history, no references to the
> original template, smaller repository size.

> **Important:** Create an empty repository on GitHub first.
> Do NOT initialize it with README, .gitignore, or license.

---

## 4. Install Dependencies

```bash
flutter pub get
```

Or using make:

```bash
make install
```

---

## 5. Run Code Generation

This project uses `build_runner` for mock generation and other
code generation tasks. Run this once after cloning:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or using make:

```bash
make generate
```

> **Tip:** Use `make watch` during development to auto-regenerate
> on file changes.

---

## 6. Rename the Project

Use the Flutter rename package to update your app identity:

```bash
# Install rename tool
dart pub global activate rename

# Update app name (shown under app icon)
dart run rename setAppName --value "Your App Name"

# Update bundle ID
dart run rename setBundleId --value com.yourcompany.yourapp
```

This automatically updates:

- `AndroidManifest.xml`
- `build.gradle`
- `Info.plist` (iOS)
- `pubspec.yaml`

---

## 7. Configure App Flavors

This template has two flavors — open
`lib/core/config/app_config.dart` and update for each environment:

```dart
// Development
static const String baseUrl = 'https://dev-api.yourapp.com';

// Production
static const String baseUrl = 'https://api.yourapp.com';
```

---

## 8. Android SDK Configuration

### Option A — Android Studio (recommended)

1. Open Android Studio
2. Go to **Tools → SDK Manager → SDK Tools**
3. Install:
   - Android SDK Build-Tools (latest)
   - NDK (Side by side)
   - CMake

### Option B — Command line

```bash
sdkmanager --update
sdkmanager "build-tools;34.0.0"
sdkmanager "ndk;26.1.10909125"
sdkmanager "cmake;3.22.1"
```

---

## 9. Run the App

```bash
# Development
flutter run --flavor development --target lib/main_dev.dart

# Production
flutter run --flavor production --target lib/main_prod.dart
```

Or using make:

```bash
make dev    # development
make prod   # production
```

---

## 10. Update Dependencies

```bash
make outdated       # check what needs updating
make upgrade        # safe upgrade
make upgrade-major  # upgrade including breaking changes
```

> **Rule:** always run `make test` after upgrading to catch
> any breaking changes.

---

## 11. Clean Build

If you encounter build issues:

```bash
make clean
```

For Android Gradle issues specifically:

```bash
cd android && ./gradlew clean && cd ..
flutter pub get
```

For iOS pod issues:

```bash
cd ios && pod install && cd ..
```

---

## ✅ Setup Checklist

- [x] Flutter doctor shows no issues
- [ ] Repository linked to your own GitHub
- [ ] Project renamed (app name + bundle ID)
- [ ] Dependencies installed (`make install`)
- [ ] Code generation ran (`make generate`)
- [ ] App config updated with your API URLs
- [ ] App runs in development flavor
- [ ] App runs in production flavor

---

## Next Steps

| Guide                                  | What's next                      |
| -------------------------------------- | -------------------------------- |
| [Firebase &amp; Fastlane](FIREBASE.md) | Set up Firebase distribution     |
| [CI/CD Workflow](CICD.md)              | Set up automated pipeline        |
| [Testing Guide](TESTING.md)            | Learn how to write and run tests |
