# Road Master

Flutter app for **Swedish driving theory (license B)** and **taxi theory** prep: Firebase Auth, Firestore progress, taxi question bank, and bundled **B-license theory import** assets.

---

## For AI assistants and new contributors

**Read this file first** after `git clone`. It lists everything required so `flutter run` succeeds on a clean machine. If setup fails, use `flutter doctor -v` output and the error log.

---

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **Flutter SDK** (stable) | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| **Dart** | Ships with Flutter |
| **iOS** | Xcode + CocoaPods (`sudo gem install cocoapods` if needed) |
| **Android** (optional) | Android Studio / SDK, emulator or device |

---

## Clone and install

```bash
git clone https://github.com/waqas1013/road-master.git
cd road-master
flutter pub get
```

**First iOS build** (or after dependency changes):

```bash
cd ios && pod install && cd ..
```

---

## Firebase — Dart configuration (required)

The app imports **`lib/firebase_options.dart`** and calls **`DefaultFirebaseOptions.currentPlatform`** in `lib/main.dart`.

That file is **gitignored** (generated secrets / project-specific options). It is **not** in the repo.

### Option A — FlutterFire CLI (recommended on a new laptop)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select the Firebase project that matches the checked-in native configs:

- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

This generates **`lib/firebase_options.dart`** locally.

### Option B — Copy from an existing machine

Copy **`lib/firebase_options.dart`** from another checkout that already builds (same Firebase project).

### Fallback template

See **`lib/firebase_options.example.dart`** for the shape of `DefaultFirebaseOptions` if you must fill values manually (prefer FlutterFire).

---

## Run the app

```bash
flutter devices
flutter run -d <device_id>
```

Examples:

- iOS Simulator: pick the `ios` simulator line from `flutter devices`
- Android: `flutter run -d emulator-5554` (or your device id)

---

## Web (optional)

Firebase **App Check** on web may need reCAPTCHA. See `lib/main.dart`: production builds can use:

```bash
flutter run -d chrome --dart-define=RECAPTCHA_SITE_KEY=<your_site_key>
```

Debug builds fall back to a debug provider when the key is empty.

---

## Project layout (quick reference)

| Path | Purpose |
|------|---------|
| `lib/` | App code, routing (`go_router`), Riverpod |
| `assets/taxi/` | Taxi question bank JSON |
| `assets/b_license_import/` | **B-license** PDF extract (questions, images, maps). See **`assets/b_license_import/README.md`** |
| `firebase.json`, `firestore.rules` | Firebase project config / rules (deploy separately) |

---

## Sanity check

```bash
flutter doctor -v
dart analyze
```

Fix every **`[!]`** from `flutter doctor` before assuming the toolchain is wrong vs. the project.

---

## License / content

Theory content under `assets/b_license_import/` is derived from study materials; ensure your distribution complies with applicable copyright and terms.
