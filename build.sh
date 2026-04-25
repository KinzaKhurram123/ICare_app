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

# Auto-detect the iris_web_rtc JS filename bundled by the agora package
IRIS_JS=$(find build/web/assets/packages/agora_rtc_engine/assets/ -name "iris_web_rtc*.js" 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "")

if [ -n "$IRIS_JS" ]; then
  echo "Found iris_web_rtc file: $IRIS_JS"
  # Patch index.html to use the correct iris_web_rtc filename
  sed -i "s|assets/packages/agora_rtc_engine/assets/iris_web_rtc[^\"]*\.js|assets/packages/agora_rtc_engine/assets/$IRIS_JS|g" build/web/index.html
  echo "Patched index.html with correct iris filename: $IRIS_JS"
else
  echo "WARNING: iris_web_rtc JS not found in agora package assets!"
  # List what's in the agora assets dir for debugging
  ls build/web/assets/packages/agora_rtc_engine/assets/ 2>/dev/null || echo "Agora assets dir not found"
fi

echo "Build complete!"
