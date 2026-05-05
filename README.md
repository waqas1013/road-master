# Road Master

Flutter app for **Swedish driving theory (license B)** and **taxi theory**: Firebase Auth, Firestore, taxi question bank, and **B-license** data under **`assets/b_license_import/`**.

---

## Tell another AI (copy-paste)

**New machine / first setup — root README only:**

```
Clone https://github.com/waqas1013/road-master.git, read README.md at the repo root only,
and follow it until flutter run works (Flutter, flutter pub get, ios/pod install if needed,
lib/firebase_options.dart via FlutterFire or copy).
```

**When the task involves `assets/b_license_import/`** (edit JSON/PNGs, wire B theory into UI, explain the extract):  
have the assistant **also** read **`assets/b_license_import/README.md`**. Skip that file for unrelated work.

---

## Setup (human or AI — start here on a new clone)

**Goal:** `flutter run` works after **`firebase_options.dart`** exists.  
You do **not** need the import-folder README for this step.

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
| **B-license** PDF extract | **`assets/b_license_import/`** — read **`assets/b_license_import/README.md`** only when your task touches this folder |

---

## Content note

Theory material under `assets/b_license_import/` may be subject to copyright; comply with applicable rules when distributing.
