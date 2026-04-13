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

# Build Flutter web
echo "Building Flutter web..."
flutter build web --release

echo "Build complete!"
