#!/usr/bin/env bash
# Upload local question-bank images to Firebase Storage (Phase 2).
#
# Prereqs:
#   - gcloud / gsutil installed and authenticated (`gcloud auth login`)
#   - Bucket exists for your Firebase project (Firebase Console → Storage)
#
# Default bucket id is usually PROJECT_ID.appspot.com (see Firebase Console).
# Override: GS_BUCKET=gs://your-bucket-id ./scripts/upload_taxi_bank_images_to_storage.sh

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SRC="${ROOT}/assets/taxi/bank/images"
if [[ ! -d "$SRC" ]]; then
  echo "Missing folder: $SRC" >&2
  exit 1
fi

# Default bucket (Firebase Console → Storage shows the gs:// name, e.g.
# gs://PROJECT_ID.firebasestorage.app for newer default buckets).
GS_BUCKET="${GS_BUCKET:-gs://road-master-se.firebasestorage.app}"
DEST="${GS_BUCKET%/}/taxi/bank/images"

echo "Syncing:"
echo "  $SRC"
echo "  → $DEST"
echo

if ! command -v gsutil >/dev/null 2>&1; then
  echo "gsutil not found. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install" >&2
  exit 1
fi

gsutil -m rsync -r "$SRC" "$DEST"

echo
echo "Done. Images are available at Storage path prefix: taxi/bank/images/"
echo "Set Storage rules (see storage.rules) to allow read access, then run the app."
