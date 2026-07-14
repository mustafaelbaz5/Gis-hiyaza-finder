# 🐛 Troubleshooting

Solutions for the most common issues you may encounter
in this project.

---

## Flutter & Dart

### `flutter: command not found`

```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Make it permanent — add to ~/.zshrc or ~/.bashrc
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Verify
flutter --version
```

### `dart: command not found`

```bash
# Add Dart pub cache to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Make it permanent
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

### `flutter doctor` shows issues

```bash
# Run with verbose output for more details
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses
```

### Packages not found after cloning

```bash
make install
# or
flutter pub get
```

### Build artifacts causing issues

```bash
make clean
# or
flutter clean && flutter pub get
```

---

## Code Generation

### Mocks not generated

```bash
# Run build_runner
make generate

# If conflicts occur
dart run build_runner build --delete-conflicting-outputs
```

### `build_runner` conflicts

```bash
# Delete conflicting outputs automatically
dart run build_runner build --delete-conflicting-outputs
```

### Changes not reflected after generation

```bash
# Clean generated files and regenerate
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## Android

### Gradle sync issues

```bash
# Clean Gradle cache
cd android && ./gradlew clean && cd ..
flutter pub get
```

### `SDK not found` error

1. Open Android Studio
2. Go to **Tools → SDK Manager**
3. Install missing SDK components
4. Run `flutter doctor` to verify

### `Execution failed for task ':app:processDebugGoogleServices'`

- Make sure `google-services.json` is in `android/app/`
- Verify the package name matches your Firebase app

### Flavor not found

Make sure flavor configurations exist in `android/app/build.gradle`:

```gradle
flavorDimensions "env"
productFlavors {
    development {
        dimension "env"
        applicationIdSuffix ".dev"
    }
    production {
        dimension "env"
    }
}
```

### APK path not found after build

Check your actual build output path:

```bash
find build/app/outputs -name "*.apk"
```

Update `android_artifact_path` in Fastfile to match.

---

## iOS

### `pod install` fails

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### CocoaPods not installed

```bash
sudo gem install cocoapods
pod setup
```

### iOS build fails with signing error

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Signing & Capabilities**
3. Select your team
4. Enable **Automatically manage signing**

---

## Firebase

### `App not found` error

```bash
# Verify your Firebase App ID
# Firebase Console → Project Settings → Your Apps → App ID
# Format: 1:123456789:android:abc123def456
```

Update `app:` field in Fastfile with correct ID.

### Invalid authentication token

```bash
# Generate a new token
firebase logout
firebase login:ci

# Update GitHub Secret with new token
# Settings → Secrets → FIREBASE_CLI_TOKEN
```

### Testers not receiving notifications

- Verify email addresses in Fastfile are correct
- Check tester spam/junk folders
- Ensure testers accepted the Firebase invitation
- Verify Firebase App Distribution is enabled for your project
- Check testers are added in **Firebase Console → App Distribution → Testers**

### `firebase: command not found`

```bash
npm install -g firebase-tools

# Verify
firebase --version
```

### APK uploads but testers can't install

- Check testers have enabled **Install unknown apps** on their device
- Verify the APK is signed correctly for the flavor

---

## Fastlane

### `fastlane: command not found`

```bash
sudo gem install fastlane

# Or with bundler
cd android
gem install bundler
bundle install
```

### `Could not find plugin` error

```bash
cd android
fastlane add_plugin firebase_app_distribution
```

### `Gemfile.lock` conflicts

```bash
cd android
rm Gemfile.lock
bundle install
```

### Ruby version errors

```bash
# Check Ruby version
ruby --version

# Install correct version (use rbenv)
rbenv install 3.2.9
rbenv local 3.2.9
```

### Build path mismatch

```bash
# Find actual APK path after building
find build/app/outputs -name "*.apk"

# Update Fastfile android_artifact_path to match
```

---

## GitHub Actions

### Workflow not triggering

- Verify the workflow file is in `.github/workflows/`
- Check the branch name matches (`main` vs `master`)
- Make sure the YAML indentation is correct

### `FIREBASE_CLI_TOKEN` secret not found

1. Go to **Settings → Secrets and variables → Actions**
2. Verify secret name is exactly `FIREBASE_CLI_TOKEN`
3. Regenerate token if expired:

```bash
firebase login:ci
```

### Tests failing in CI but passing locally

```bash
# Check Flutter version matches
# In workflow file:
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'   # match your local version

# Check local Flutter version
flutter --version
```

### Gradle build fails in CI

Add this to your workflow before building:

```yaml
- name: Grant execute permission for gradlew
  run: chmod +x android/gradlew
```

### Workflow times out

- Check if dependencies are being cached correctly
- Verify cache keys in the workflow file match your files
- First build without cache takes 8–12 minutes — this is normal

### APK artifact not uploaded

Check the artifact path in the workflow:

```yaml
- name: Upload APK artifact
  uses: actions/upload-artifact@v4
  with:
    name: app-production-release
    path: build/app/outputs/flutter-apk/*.apk  # verify this path
```

---

## Testing

### `LateInitializationError: Field '_data' has not been initialized`

This means `ScreenUtil` is not initialized in tests.

**Option A** — Add `ScreenUtilInit` to test helper:

```dart
Widget buildTestWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}
```

**Option B** — Refactor widget to not use `ScreenUtil` internally.
Pass values as parameters instead.

### `EasyLocalization` crash in widget tests

Do not use `context.isRTL` or any `EasyLocalization` calls
directly in widget `build` methods. Pass locale-dependent
values as parameters instead:

```dart
// ❌ bad — crashes in tests
final isRTL = context.isRTL;

// ✅ good — testable
const CustomTextForm(isRTL: false)
```

### Mock not generating

1. Make sure `@GenerateMocks([YourClass])` is above `main()`
2. Run `make generate`
3. Import the generated file:

```dart
import 'your_test_file.mocks.dart';
```

### `type 'Null' is not a subtype of type` in tests

You forgot to set up a `when()` for a mock method:

```dart
// Add this before calling the method
when(mockStorage.read(key: 'token'))
    .thenAnswer((_) async => 'value');
```

### Widget test finds 0 widgets

- Check you are using the correct finder
- Use `find.byType()` for widget types
- Use `find.byKey()` for keyed widgets
- Use `find.text()` for text content
- Add `await tester.pumpAndSettle()` after interactions

---

## make

### `make: command not found` on Windows

```bash
# Option A — with Chocolatey (run as admin)
choco install make

# Option B — with Scoop (no admin needed)
irm get.scoop.sh | iex
scoop install make
```

### `missing separator` error in Makefile

Makefile commands must use **tabs** not spaces.
Check your editor is not converting tabs to spaces.

In VS Code — add to `settings.json`:

```json
{
  "[makefile]": {
    "editor.insertSpaces": false
  }
}
```

---

## Getting More Help

If your issue is not listed here:

| Resource              | Link                                                                                          |
| --------------------- | --------------------------------------------------------------------------------------------- |
| Flutter docs          | [flutter.dev/docs](https://flutter.dev/docs)                                                     |
| Flutter GitHub issues | [github.com/flutter/flutter/issues](https://github.com/flutter/flutter/issues)                   |
| Stack Overflow        | [stackoverflow.com/questions/tagged/flutter](https://stackoverflow.com/questions/tagged/flutter) |
| Firebase docs         | [firebase.google.com/docs](https://firebase.google.com/docs)                                     |
| Fastlane docs         | [docs.fastlane.tools](https://docs.fastlane.tools)                                               |
| GitHub Actions docs   | [docs.github.com/en/actions](https://docs.github.com/en/actions)                                 |

---

## Reporting a New Issue

When opening an issue please include:

1. Flutter version (`flutter --version`)
2. Operating system and version
3. Full error message
4. Steps to reproduce
5. What you expected vs what happened

```

---

## All docs are done ✅

Here's the complete documentation structure:
```

docs/
  SETUP.md            ✅ project setup + first run
  FIREBASE.md         ✅ firebase + fastlane
  CICD.md             ✅ github actions workflow
  TESTING.md          ✅ testing guide
  TROUBLESHOOTING.md  ✅ common issues + fixes
README.md             ✅ overview + quick start
CONTRIBUTING.md       ✅ for contributors
