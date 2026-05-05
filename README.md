# Road Master

Flutter app for **Swedish driving theory (license B)** and **taxi theory**: Firebase Auth, Firestore, taxi question bank, and **B-license** data under **`assets/b_license_import/`**.

---

## Tell another AI (copy-paste)

```
Clone https://github.com/waqas1013/road-master.git.

1. Open README.md at the repo root and follow it to install Flutter, run flutter pub get,
   ios/pod install if needed, create lib/firebase_options.dart (FlutterFire or copy from a machine that builds),
   then flutter run.

2. Only if you change B-license theory files or wire them into the app: read
   assets/b_license_import/README.md — it explains the JSON, images, and how to handle data like the taxi bank.
```

---

## Setup (human or AI — read this file only)

**Goal:** `flutter run` works on a clean clone after **`firebase_options.dart`** exists.

### Prerequisites

- Flutter SDK (stable), Xcode + CocoaPods for iOS; Android SDK optional.

### Commands

```bash
git clone https://github.com/waqas1013/road-master.git
cd road-master
flutter pub get
cd ios && pod install && cd ..
```

### Firebase Dart options (**required — not in Git**)

`lib/main.dart` needs **`lib/firebase_options.dart`**. It is **gitignored**.

- **Recommended:** `dart pub global activate flutterfire_cli` then **`flutterfire configure`** (same project as `ios/Runner/GoogleService-Info.plist` and `android/app/google-services.json`).
- **Or** copy **`lib/firebase_options.dart`** from another checkout.

See **`lib/firebase_options.example.dart`** only if you must fill values by hand.

### Run

```bash
flutter doctor -v
flutter devices
flutter run -d <device_id>
```

### Web (optional)

```bash
flutter run -d chrome --dart-define=RECAPTCHA_SITE_KEY=<key>
```

(See comments in `lib/main.dart` for App Check / debug behaviour.)

---

## Where everything lives

| What | Where |
|------|--------|
| App code | `lib/` |
| Taxi theory JSON loader pattern | `lib/data/taxi_question_bank.dart`, `assets/taxi/bank/questions.json` |
| **B-license** PDF extract (JSON + PNGs + map) | **`assets/b_license_import/`** — **how it works:** **`assets/b_license_import/README.md`** |

---

## Content note

Theory material under `assets/b_license_import/` may be subject to copyright; comply with applicable rules when distributing.
