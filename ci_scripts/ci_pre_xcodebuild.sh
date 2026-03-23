#!/bin/sh
set -e

# Xcode Cloud — pre-build script
# Populates Configs/Secrets.xcconfig from environment variables
# configured in App Store Connect → Xcode Cloud → Environment Variables.
#
# Variables must be marked as Secret in App Store Connect
# so their values are masked in build logs.
#
# Workflows that don't need Firebase (e.g. test-only) don't need these
# variables set at all — the script writes an empty secrets file and exits.
# The app detects test runs via -RunningTests / XCTestConfigurationFilePath
# and uses NoOpAnalyticsService, so Firebase is never initialised.

# Derive the repo root from the script's location — ci_scripts/ sits directly
# inside the repo root, so one level up is always correct regardless of which
# environment variables Xcode Cloud exposes in this context.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS_FILE="$REPO_ROOT/Configs/Secrets.xcconfig"
 
# Ensure the directory exists — Secrets.xcconfig is gitignored so git never
# creates the Configs/ folder on a fresh clone if no other file is committed there.
mkdir -p "$REPO_ROOT/Configs"

VARS="FIREBASE_API_KEY FIREBASE_APP_ID FIREBASE_GCM_SENDER_ID FIREBASE_PROJECT_ID FIREBASE_STORAGE_BUCKET"

# Count how many of the required variables are actually set.
SET_COUNT=0
for VAR in $VARS; do
    eval "VALUE=\$$VAR"
    [ -n "$VALUE" ] && SET_COUNT=$((SET_COUNT + 1))
done

TOTAL=5

# None set → test/build workflow without Firebase; write empty file and exit.
if [ "$SET_COUNT" -eq 0 ]; then
    echo "No Firebase variables set — writing empty Secrets.xcconfig."
    cat > "$SECRETS_FILE" << EOF
FIREBASE_API_KEY =
FIREBASE_APP_ID =
FIREBASE_GCM_SENDER_ID =
FIREBASE_PROJECT_ID =
FIREBASE_STORAGE_BUCKET =
EOF
    exit 0
fi

# Some but not all set → misconfiguration; fail loudly.
if [ "$SET_COUNT" -lt "$TOTAL" ]; then
    MISSING=""
    for VAR in $VARS; do
        eval "VALUE=\$$VAR"
        [ -z "$VALUE" ] && MISSING="$MISSING $VAR"
    done
    echo "error: Partial Firebase configuration — missing:$MISSING"
    echo "       Either set all variables or none in App Store Connect → Xcode Cloud → Environment Variables."
    exit 1
fi

# All set → write real secrets.
cat > "$SECRETS_FILE" << EOF
FIREBASE_API_KEY = $FIREBASE_API_KEY
FIREBASE_APP_ID = $FIREBASE_APP_ID
FIREBASE_GCM_SENDER_ID = $FIREBASE_GCM_SENDER_ID
FIREBASE_PROJECT_ID = $FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET = $FIREBASE_STORAGE_BUCKET
EOF

echo "Secrets.xcconfig written successfully."
