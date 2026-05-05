# Road Master

Flutter app for **Swedish driving theory (license B)** and **taxi theory** prep: Firebase Auth, Firestore progress, taxi question bank, and bundled **B-license theory import** assets.

---

## What to tell another AI (copy-paste)

```
Clone https://github.com/waqas1013/road-master.git, open README.md at the project root,
read it fully, then follow it to install prerequisites, restore lib/firebase_options.dart,
and run flutter run. Do not skip the B-license data section if you touch theory assets or UI.
```

You only need to point the assistant at **this README**; everything below is the source of truth.

---

## For AI assistants and new contributors

**Read this entire file first** after `git clone`. It lists everything required so `flutter run` succeeds on a clean machine. If setup fails, use `flutter doctor -v` output and the error log.

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

## B-license theory data (`assets/b_license_import/`)

### Why this folder is in Git

The PDF-derived **questions (JSON), markdown review dump, image map, and PNG snippets** are committed so a **`git clone`** always restores the full dataset — no manual USB copy, no silent loss when switching laptops. Treat the repo as the **backup of record** for this extract.

### Canonical documentation (read before changing anything)

**`assets/b_license_import/README.md`** describes:

- Field meanings in **`b_questions_extracted.json`**
- **`question_image_map.json`** (`by_question_id` → Flutter asset paths)
- Coverage limits (e.g. inferred answers not complete for every row)

**Do not duplicate schema lore only in chat** — update that README if the format changes.

### How this relates to taxi theory (pattern to follow)

Taxi content today:

- **Bank JSON:** `assets/taxi/bank/questions.json` (declared in **`pubspec.yaml`**)
- **Loader:** **`lib/data/taxi_question_bank.dart`** — loads via **`rootBundle.loadString`**, parses into **`TaxiPracticeQuestion`**
- **Images:** JSON fields such as **`imageAssetPath`**, **`imageNetworkUrl`**, explanation images; **`TaxiBankImage`** / storage upload scripts under **`scripts/`** when moving assets to Firebase Storage

**When you integrate B-license into the app**, mirror that approach unless there is a deliberate redesign:

1. **Keep** data under **`assets/b_license_import/`** with the **same filenames and layout** (`question_images/*.png`, JSON + map at repo root of that folder).
2. **Register assets** in **`pubspec.yaml`** under `flutter: assets:` — any new file or folder needs an entry (Flutter does not auto-include arbitrary paths).
3. **Load text** with **`rootBundle.loadString`** on **`b_questions_extracted.json`** (and optionally **`question_image_map.json`** for images).
4. **Show images** with **`Image.asset`** using paths from **`question_image_map.json`** or basenames derived per **`assets/b_license_import/README.md`**. Prefer the same widget patterns as taxi (**`TaxiBankImage`** / lightbox) where it reduces duplication, or a B-specific twin if names must stay separate.
5. **Optional Phase 2 (like taxi):** upload PNGs to **Firebase Storage**, store HTTPS URLs in app state or a slim JSON layer, and fall back to bundled **`Image.asset`** when offline — same idea as taxi bank images.

### What not to do

- Do **not** move PNGs or JSON to random folders without updating **`pubspec.yaml`** and **`question_image_map.json`** / regeneration steps.
- Do **not** assume every row has **`correct_option`** — scoring logic must match **`assets/b_license_import/README.md`**.
- Do **not** strip **`assets/b_license_import/`** from Git “to save space” without replacing it with another approved backup (LFS, private artifact, etc.).

### Regenerating `question_image_map.json`

If **`b_questions_extracted.json`** changes (new PDF run), rebuild **`question_image_map.json`** from it: parse JSON (skip any garbage before the first `{`), take **`image_files`** basenames, emit **`assets/b_license_import/question_images/<basename>`** per question **`id`**. Keep **`by_question_id`** semantics documented in the folder README.

---

## Project layout (quick reference)

| Path | Purpose |
|------|---------|
| `lib/` | App code, routing (`go_router`), Riverpod |
| `lib/data/taxi_question_bank.dart` | Reference loader pattern for asset-backed JSON + image paths |
| `assets/taxi/` | Taxi bank **`questions.json`** and related assets |
| `assets/b_license_import/` | **B-license** extract — **committed backup**; details in **`assets/b_license_import/README.md`** |
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
