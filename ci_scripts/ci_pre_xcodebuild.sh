#!/bin/sh
set -e

# Xcode Cloud — pre-build script
# Populates Configs/Secrets.xcconfig from environment variables
# configured in App Store Connect → Xcode Cloud → Environment Variables.
#
# All variables must be marked as Secret in App Store Connect
# so their values are masked in build logs.

SECRETS_FILE="$CI_PRIMARY_REPOSITORY_PATH/Configs/Secrets.xcconfig"

# Test actions don't need Firebase — the app detects -RunningTests and
# uses NoOpAnalyticsService instead. Write an empty secrets file so the
# xcconfig reference in the project resolves without errors.
if [ "$CI_XCODEBUILD_ACTION" = "test" ]; then
    echo "Test action detected — writing empty Secrets.xcconfig."
    cat > "$SECRETS_FILE" << EOF
FIREBASE_API_KEY =
FIREBASE_APP_ID =
FIREBASE_GCM_SENDER_ID =
FIREBASE_PROJECT_ID =
FIREBASE_STORAGE_BUCKET =
EOF
    exit 0
fi

# For all other actions (archive, build, analyze) require real credentials.
MISSING=""
for VAR in \
    FIREBASE_API_KEY \
    FIREBASE_APP_ID \
    FIREBASE_GCM_SENDER_ID \
    FIREBASE_PROJECT_ID \
    FIREBASE_STORAGE_BUCKET
do
    eval "VALUE=\$$VAR"
    if [ -z "$VALUE" ]; then
        MISSING="$MISSING $VAR"
    fi
done

if [ -n "$MISSING" ]; then
    echo "error: Missing required environment variables:$MISSING"
    echo "       Set them in App Store Connect → Xcode Cloud → Environment Variables."
    exit 1
fi

cat > "$SECRETS_FILE" << EOF
FIREBASE_API_KEY = $FIREBASE_API_KEY
FIREBASE_APP_ID = $FIREBASE_APP_ID
FIREBASE_GCM_SENDER_ID = $FIREBASE_GCM_SENDER_ID
FIREBASE_PROJECT_ID = $FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET = $FIREBASE_STORAGE_BUCKET
EOF

echo "Secrets.xcconfig written successfully."
