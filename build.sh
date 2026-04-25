#!/bin/bash
set -e

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
    export PATH="$PATH:/tmp/flutter/bin"
    flutter config --no-analytics
    flutter precache --web
fi

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run analyzer to catch errors early
echo "Running Dart analyzer..."
flutter analyze --no-pub || true

# Build Flutter web
echo "Building Flutter web..."
flutter build web --release --verbose

# ─── Fix Agora iris_web_rtc script ──────────────────────────────────────────
echo ""
echo "=== Agora iris_web_rtc fix ==="

# Step 1: Search build output for iris file (any package)
IRIS_FILE=$(find build/web/ -name "iris_web_rtc*.js" 2>/dev/null | head -1)
echo "In build output: ${IRIS_FILE:-not found}"

# Step 2: If missing from build output, search Flutter pub cache
if [ -z "$IRIS_FILE" ]; then
  PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
  echo "Searching pub cache at: $PUB_CACHE"
  IRIS_SOURCE=$(find "$PUB_CACHE" -name "iris_web_rtc*.js" 2>/dev/null | head -1)
  echo "In pub cache: ${IRIS_SOURCE:-not found}"

  if [ -n "$IRIS_SOURCE" ]; then
    DEST_DIR="build/web/assets/packages/agora_rtc_engine/assets"
    mkdir -p "$DEST_DIR"
    cp "$IRIS_SOURCE" "$DEST_DIR/"
    IRIS_FILE="$DEST_DIR/$(basename "$IRIS_SOURCE")"
    echo "Copied to build: $IRIS_FILE"
  fi
fi

# Step 3: Patch index.html with found file (or warn)
if [ -n "$IRIS_FILE" ]; then
  IRIS_BASENAME=$(basename "$IRIS_FILE")
  # Path relative to build/web/
  IRIS_REL="${IRIS_FILE#build/web/}"
  # Extract version: iris_web_rtc_4.18.2.js -> 4.18.2
  IRIS_VER=$(echo "$IRIS_BASENAME" | sed 's/iris_web_rtc_//' | sed 's/\.js$//')

  echo "iris filename : $IRIS_BASENAME"
  echo "iris version  : $IRIS_VER"
  echo "iris html path: $IRIS_REL"

  # Patch the iris script src in index.html
  sed -i "s|assets/packages/agora_rtc_engine/assets/iris_web_rtc[^\"]*\.js|$IRIS_REL|g" build/web/index.html

  # Also sync the CDN agora-rtc-sdk-ng version to match iris version
  sed -i "s|agora-rtc-sdk-ng@[^/\"]*|agora-rtc-sdk-ng@$IRIS_VER|g" build/web/index.html

  echo "Patched index.html — agora scripts now:"
  grep -n "agora\|iris" build/web/index.html || true
else
  echo "ERROR: iris_web_rtc not found anywhere!"
  echo "All JS files under build/web/assets/packages/:"
  find build/web/assets/packages/ -name "*.js" 2>/dev/null || echo "(none)"
  echo ""
  echo "All package dirs:"
  ls build/web/assets/packages/ 2>/dev/null || echo "(none)"
fi

echo ""
echo "Build complete!"
