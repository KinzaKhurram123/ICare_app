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

# Build Flutter web (skip analyzer to speed up build)
echo "Building Flutter web..."
flutter build web --release --web-renderer html

echo "Build complete!"
