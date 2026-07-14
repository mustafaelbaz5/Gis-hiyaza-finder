# 🚀 CI/CD Workflow

This guide covers setting up the automated GitHub Actions pipeline
that builds and distributes your app on every push to `main`.

---

## Overview

```
Push to main
     │
     ▼
GitHub Actions triggers
     │
     ├── Checkout code
     ├── Cache Flutter + Gradle dependencies
     ├── Setup JDK 17
     ├── Install Flutter
     ├── Install dependencies
     ├── Run all tests          ← stops here if tests fail
     ├── Setup Ruby + Fastlane
     └── Build + Distribute APK to Firebase
```

---

## 1. Prerequisites

Before setting up CI/CD make sure you have completed:

- [ ] [Firebase &amp; Fastlane Setup](FIREBASE.md) — fully working locally
- [ ] Firebase CLI token generated
- [ ] Fastlane `release_to_firebase` lane tested locally

---

## 2. Add GitHub Secret

The workflow needs your Firebase CLI token to distribute builds.

1. Go to your GitHub repository
2. Click **Settings → Secrets and variables → Actions**
3. Click **New repository secret**
4. Add the following secret:

| Name                   | Value                                 |
| ---------------------- | ------------------------------------- |
| `FIREBASE_CLI_TOKEN` | your token from `firebase login:ci` |

> **Never** hardcode this token in any file. Always use
> GitHub Secrets for sensitive values.

---

## 3. Create Workflow File

Create this folder structure in your project root:

```
.github/
  workflows/
    distribute.yml
```

Then add this content to `distribute.yml`:

```yaml
name: Android Firebase Distribution

on:
  push:
    branches:
      - main
  workflow_dispatch:  # allows manual trigger from GitHub Actions tab

jobs:
  distribute:
    runs-on: ubuntu-latest

    steps:
      # ─── Checkout ──────────────────────────────────────────
      - name: Checkout code
        uses: actions/checkout@v4

      # ─── Cache ─────────────────────────────────────────────
      - name: Cache Flutter dependencies
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            ${{ runner.os }}-gradle-

      # ─── Java ──────────────────────────────────────────────
      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      # ─── Flutter ───────────────────────────────────────────
      - name: Install Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # ─── Tests ─────────────────────────────────────────────
      - name: Run tests
        run: flutter test --reporter expanded

      # ─── Code Quality ──────────────────────────────────────
      - name: Analyze code
        run: flutter analyze

      # ─── Ruby + Fastlane ───────────────────────────────────
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2.9'
          bundler-cache: true
          working-directory: android

      # ─── Distribute ────────────────────────────────────────
      - name: Build and distribute to Firebase
        env:
          FIREBASE_CLI_TOKEN: ${{ secrets.FIREBASE_CLI_TOKEN }}
        run: |
          cd android
          bundle exec fastlane release_to_firebase

      # ─── Upload Artifact ───────────────────────────────────
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-production-release
          path: build/app/outputs/flutter-apk/*.apk
          retention-days: 7
```

---

## 4. Trigger the Workflow

### Automatic trigger

Every push to `main` triggers the workflow automatically:

```bash
git add .
git commit -m "your message"
git push origin main
```

### Manual trigger

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Android Firebase Distribution**
4. Click **Run workflow → Run workflow**

---

## 5. Monitor the Workflow

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Click the running workflow to see live logs
4. Each step shows ✅ or ❌ with detailed output

**Expected build times:**

| Build                      | Time          |
| -------------------------- | ------------- |
| First build (no cache)     | 8–12 minutes |
| Subsequent builds (cached) | 3–5 minutes  |

---

## 6. Workflow Stages Explained

### Cache stage

Caches Flutter packages and Gradle files between runs.
This is what makes subsequent builds 3–5 minutes instead of 10+.

### Test stage

Runs `flutter test --reporter expanded` before building.
**If any test fails, the workflow stops here** — no broken
builds get distributed to testers.

### Analyze stage

Runs `flutter analyze` to catch code issues before distribution.

### Distribute stage

Calls `bundle exec fastlane release_to_firebase` which:

1. Cleans the project
2. Builds the production APK
3. Uploads to Firebase App Distribution
4. Notifies all testers via email

### Upload artifact stage

Saves the APK as a GitHub artifact for 7 days.
Useful for downloading the exact APK that was distributed
without going to Firebase.

---

## 7. Branch Strategy

```
main          ← triggers CI/CD automatically
develop       ← integration branch (no CI/CD)
feature/*     ← new features
fix/*         ← bug fixes
```

**Rule:** only merge to `main` when the feature is
ready for testers. Every merge = a new build distributed.

---

## 8. Updating the Workflow

### Change Flutter version

```yaml
- name: Install Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'   # ← pin specific version
    channel: stable
```

### Add iOS distribution

Add a new job to the workflow:

```yaml
  distribute-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ipa --flavor production --target lib/main_prod.dart
```

### Trigger on pull requests too

```yaml
on:
  push:
    branches:
      - main
  pull_request:        # ← add this
    branches:
      - main
  workflow_dispatch:
```

> **Tip:** triggering on pull requests runs tests and analyze
> but you may want to skip distribution for PRs. Add a condition:
>
> ```yaml
> - name: Build and distribute to Firebase
>   if: github.event_name == 'push'   # ← only distribute on push
> ```

---

## 9. Adding New Secrets

If you add new environment variables (e.g. API keys):

1. Add to GitHub Secrets (Settings → Secrets → Actions)
2. Reference in workflow:

```yaml
env:
  FIREBASE_CLI_TOKEN: ${{ secrets.FIREBASE_CLI_TOKEN }}
  MY_API_KEY: ${{ secrets.MY_API_KEY }}          # ← add here
```

3. Use in Fastfile:

```ruby
ENV["MY_API_KEY"]
```

---

## ✅ CI/CD Checklist

- [ ] Firebase & Fastlane working locally
- [ ] `FIREBASE_CLI_TOKEN` added to GitHub Secrets
- [ ] `.github/workflows/distribute.yml` created
- [ ] Pushed to `main` branch
- [ ] Workflow shows green in Actions tab
- [ ] APK uploaded to Firebase App Distribution
- [ ] Testers received email notification
- [ ] APK artifact visible in GitHub Actions run

---

## Next Steps

| Guide                              | What's next                               |
| ---------------------------------- | ----------------------------------------- |
| [Testing Guide](TESTING.md)           | Write tests that protect your CI pipeline |
| [Troubleshooting](TROUBLESHOOTING.md) | Fix common CI/CD issues                   |
