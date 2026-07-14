# 🔥 Firebase & Fastlane Setup

This guide covers setting up Firebase App Distribution and Fastlane
for distributing builds to testers.

---

## 1. Install Required Tools

### Ruby

```bash
# macOS — comes pre-installed, verify with:
ruby --version

# Windows — download from:
# https://rubyinstaller.org/

# Linux
sudo apt-get install ruby-full
```

### Fastlane

```bash
sudo gem install fastlane

# Verify
fastlane --version
```

### Firebase CLI

```bash
npm install -g firebase-tools

# Verify
firebase --version
```

---

## 2. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Follow the setup wizard
4. Disable Google Analytics if not needed

---

## 3. Add Android App to Firebase

1. In your Firebase project click **Add app → Android icon**
2. Enter your package name (e.g. `com.yourcompany.yourapp`)
3. Click **Register app**
4. Download `google-services.json`
5. Place it in `android/app/` directory

> **Important:** The package name must exactly match your
> `android/app/build.gradle` applicationId.

---

## 4. Find Your Firebase App ID

You will need this for the Fastfile configuration:

1. In Firebase Console click the **gear icon → Project settings**
2. Scroll to **Your apps** section
3. Copy the **App ID**

Format: `1:123456789:android:abc123def456`

---

## 5. Enable Firebase App Distribution

1. In Firebase Console go to **App Distribution** in the left menu
2. Click **Get started**
3. Select your Android app
4. Click **Enable**

---

## 6. Initialize Fastlane

```bash
# Navigate to android directory
cd android

# Initialize Fastlane
fastlane init
```

When prompted:

- **Package name:** your app package name
- **Path to json secret file:** press Enter to skip
- **Download metadata:** `n`

This creates:

```
android/
  fastlane/
    Fastfile    ← automation configuration
    Appfile     ← app information
  Gemfile       ← Ruby dependencies
```

---

## 7. Install Firebase Plugin

```bash
# Still in android directory
fastlane add_plugin firebase_app_distribution
```

---

## 8. Configure Fastfile

Replace contents of `android/fastlane/Fastfile` with:

```ruby
default_platform(:android)

platform :android do

  # ─── Production Distribution ─────────────────────────────
  desc "Distribute production build to Firebase"
  lane :release_to_firebase do
    sh "flutter clean"
    sh "flutter build apk --release --flavor production \
        --target lib/main_prod.dart --no-tree-shake-icons"

    testers_list = [
      "dev@company.com",
      "qa@company.com",
      "tester@company.com",
    ]

    firebase_app_distribution(
      app: "YOUR_FIREBASE_APP_ID",
      firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"],
      android_artifact_type: "APK",
      android_artifact_path: "../build/app/outputs/flutter-apk/app-production-release.apk",
      testers: testers_list.join(", "),
      release_notes: "Version 1.0.0",
    )
  end

  # ─── Development Distribution ────────────────────────────
  desc "Distribute development build to Firebase"
  lane :dev_to_firebase do
    sh "flutter clean"
    sh "flutter build apk --flavor development \
        --target lib/main_dev.dart --no-tree-shake-icons"

    testers_list = [
      "dev@company.com",
    ]

    firebase_app_distribution(
      app: "YOUR_FIREBASE_APP_ID",
      firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"],
      android_artifact_type: "APK",
      android_artifact_path: "../build/app/outputs/flutter-apk/app-development-debug.apk",
      testers: testers_list.join(", "),
      release_notes: "Development build",
    )
  end

end
```

> **Replace** `YOUR_FIREBASE_APP_ID` with your actual App ID from Step 4.

---

## 9. Managing Testers

### Add or remove testers

Open `android/fastlane/Fastfile` and update the `testers_list`:

```ruby
testers_list = [
  "newdev@company.com",
  "tester@company.com",
]
```

### Using tester groups (recommended for large teams)

Instead of listing emails, create groups in Firebase Console:

1. Go to **App Distribution → Testers & Groups**
2. Create a group (e.g. `internal-testers`)
3. Add tester emails to the group
4. Update Fastfile:

```ruby
firebase_app_distribution(
  app: "YOUR_FIREBASE_APP_ID",
  firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"],
  android_artifact_type: "APK",
  android_artifact_path: "...",
  groups: "internal-testers",   # ← use group instead of testers
  release_notes: "Version 1.0.0",
)
```

---

## 10. Generate Firebase CLI Token

```bash
firebase login:ci
```

This opens a browser for authentication. After login, a token
appears in the terminal:

```
✔  Success! Use this token to login on a CI server:

1//0abcdefghijklmnopqrstuvwxyz...

Example: firebase deploy --token "$FIREBASE_TOKEN"
```

**Copy this token** — you will need it in the next step.

> **Security:** Never commit this token to your repository.
> Store it only in environment variables or GitHub Secrets.

---

## 11. Test Fastlane Locally

Before setting up CI/CD, test that everything works locally:

```bash
# Make sure you are in the android directory
cd android

# Install Ruby dependencies
bundle install

# Test production distribution
bundle exec fastlane release_to_firebase

# Or test development distribution
bundle exec fastlane dev_to_firebase
```

**Expected output:**

```
[✔] Flutter clean completed
[✔] APK built successfully
[✔] APK uploaded to Firebase
[✔] Testers notified via email
```

Or using make from project root:

```bash
make distribute-firebase
```

---

## 12. Update Release Notes

Update the `release_notes` field in Fastfile before each distribution:

```ruby
release_notes: "v1.0.4 — Fixed login screen, added dark mode",
```

> **Tip:** Keep release notes clear and meaningful so testers
> know what changed in each build.

---

## ✅ Firebase & Fastlane Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` placed in `android/app/`
- [ ] Firebase App Distribution enabled
- [ ] Firebase App ID copied
- [ ] Fastlane initialized (`fastlane init`)
- [ ] Firebase plugin installed
- [ ] `Fastfile` updated with your App ID
- [ ] Tester emails or groups configured
- [ ] Firebase CLI token generated
- [ ] Local distribution tested successfully

---

## Next Steps

| Guide                                 | What's next                               |
| ------------------------------------- | ----------------------------------------- |
| [CI/CD Workflow](CICD.md)             | Automate distribution with GitHub Actions |
| [Troubleshooting](TROUBLESHOOTING.md) | Common Firebase and Fastlane issues       |
