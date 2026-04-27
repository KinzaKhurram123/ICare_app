#!/bin/bash

echo "=== Starting Flutter Build ==="

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter || exit 1
    export PATH="$PATH:/tmp/flutter/bin"
    flutter config --no-analytics || exit 1
    flutter precache --web || exit 1
fi

# Get dependencies
echo "Getting dependencies..."
flutter pub get || exit 1

# Build Flutter web
echo "Building Flutter web..."
flutter build web --release --web-renderer html || exit 1

echo "=== Build Complete ==="
