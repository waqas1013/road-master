#!/usr/bin/env bash
# Build/install debug app on Android emulator + iOS simulator and bring each app to the foreground.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ANDROID_DEVICE="${ANDROID_DEVICE:-emulator-5554}"
IOS_DEVICE="${IOS_DEVICE:-1ECCB434-1310-4482-8E69-1FDC6E299FCB}"
ANDROID_PKG="com.roadmaster.road_master"
IOS_BUNDLE="com.roadmaster.roadMaster"

echo "==> Android ($ANDROID_DEVICE)"
adb -s "$ANDROID_DEVICE" shell pm trim-caches 500M 2>/dev/null || true
if flutter install --debug -d "$ANDROID_DEVICE"; then
  adb -s "$ANDROID_DEVICE" shell am start -n "${ANDROID_PKG}/.MainActivity"
else
  echo "Warning: Android install failed (e.g. emulator disk full). iOS will still run." >&2
fi

echo "==> iOS simulator ($IOS_DEVICE)"
xcrun simctl boot "$IOS_DEVICE" 2>/dev/null || true
if flutter install --debug -d "$IOS_DEVICE"; then
  xcrun simctl launch "$IOS_DEVICE" "$IOS_BUNDLE"
else
  echo "Warning: iOS install failed." >&2
  exit 1
fi

echo "Done."
