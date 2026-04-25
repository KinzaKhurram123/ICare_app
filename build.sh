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

# Step 1: Find iris in the build output (any location)
IRIS_FILE=$(find build/web/ -name "iris_web_rtc*.js" 2>/dev/null | head -1)
echo "build/web search: ${IRIS_FILE:-not found}"

# Step 2: Search all known pub cache locations on the build server
if [ -z "$IRIS_FILE" ]; then
  echo "Searching pub cache locations..."
  for PUB_DIR in \
      "/vercel/.pub-cache" \
      "$HOME/.pub-cache" \
      "/root/.pub-cache" \
      "/tmp/.pub-cache" \
      "$(flutter pub cache dir 2>/dev/null || true)"; do
    if [ -n "$PUB_DIR" ] && [ -d "$PUB_DIR" ]; then
      echo "  checking: $PUB_DIR"
      IRIS_SOURCE=$(find "$PUB_DIR" -name "iris_web_rtc*.js" 2>/dev/null | head -1)
      if [ -n "$IRIS_SOURCE" ]; then
        echo "  FOUND: $IRIS_SOURCE"
        break
      fi
    fi
  done

  # Step 3: Also check the agora_rtc_engine and iris_method_channel package dirs directly
  if [ -z "$IRIS_SOURCE" ]; then
    echo "Checking package dirs directly..."
    for PKG_DIR in \
        "/vercel/.pub-cache/hosted/pub.dev/agora_rtc_engine-6.5.3" \
        "/vercel/.pub-cache/hosted/pub.dev/iris_method_channel-2.2.4" \
        "$HOME/.pub-cache/hosted/pub.dev/agora_rtc_engine-6.5.3" \
        "$HOME/.pub-cache/hosted/pub.dev/iris_method_channel-2.2.4"; do
      if [ -d "$PKG_DIR" ]; then
        echo "  found dir: $PKG_DIR"
        echo "  contents:"
        ls "$PKG_DIR/" 2>/dev/null || true
        echo "  assets:"
        ls "$PKG_DIR/assets/" 2>/dev/null || echo "    (no assets/ dir)"
        JS_FILE=$(find "$PKG_DIR" -name "*.js" 2>/dev/null | head -5)
        echo "  js files: ${JS_FILE:-none}"
        IRIS_SOURCE=$(find "$PKG_DIR" -name "iris_web_rtc*.js" 2>/dev/null | head -1)
        if [ -n "$IRIS_SOURCE" ]; then
          echo "  IRIS FOUND: $IRIS_SOURCE"
          break
        fi
      fi
    done
  fi

  # Step 4: Copy to build output if found in pub cache
  if [ -n "$IRIS_SOURCE" ]; then
    DEST_DIR="build/web/assets/packages/agora_rtc_engine/assets"
    mkdir -p "$DEST_DIR"
    cp "$IRIS_SOURCE" "$DEST_DIR/"
    IRIS_FILE="$DEST_DIR/$(basename "$IRIS_SOURCE")"
    echo "Copied to build: $IRIS_FILE"
  fi
fi

# Step 5: Patch index.html
if [ -n "$IRIS_FILE" ]; then
  IRIS_BASENAME=$(basename "$IRIS_FILE")
  IRIS_REL="${IRIS_FILE#build/web/}"
  IRIS_VER=$(echo "$IRIS_BASENAME" | sed 's/iris_web_rtc_//' | sed 's/\.js$//')

  echo ""
  echo "iris filename : $IRIS_BASENAME"
  echo "iris version  : $IRIS_VER"
  echo "iris html path: $IRIS_REL"

  sed -i "s|assets/packages/agora_rtc_engine/assets/iris_web_rtc[^\"]*\.js|$IRIS_REL|g" build/web/index.html
  sed -i "s|agora-rtc-sdk-ng@[^/\"]*|agora-rtc-sdk-ng@$IRIS_VER|g" build/web/index.html

  echo "Patched index.html — agora lines:"
  grep -n "agora\|iris" build/web/index.html || true
else
  echo ""
  echo "=== iris_web_rtc STILL NOT FOUND — debug info ==="
  echo "build/web/ top-level:"
  ls build/web/ 2>/dev/null || true
  echo "build/web/packages/ (plugin web assets):"
  ls build/web/packages/ 2>/dev/null || echo "(no packages/ dir)"
  echo "All .js in build/web/:"
  find build/web/ -name "*.js" 2>/dev/null | head -20 || true
  echo "All pub cache .pub-cache dirs:"
  find /vercel -maxdepth 2 -name ".pub-cache" 2>/dev/null || true
  find / -maxdepth 4 -name "iris_method_channel*" -type d 2>/dev/null | head -5 || true
fi

echo ""
echo "Build complete!"
