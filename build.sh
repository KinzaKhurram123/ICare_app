#!/bin/bash

echo "=== Flutter Build Script ==="

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing..."

    # Clone Flutter
    if [ ! -d "/tmp/flutter" ]; then
        echo "Cloning Flutter repository..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to clone Flutter"
            exit 1
        fi
    fi

    # Add Flutter to PATH
    export PATH="$PATH:/tmp/flutter/bin"

    # Configure Flutter
    echo "Configuring Flutter..."
    flutter config --no-analytics

    # Precache web
    echo "Precaching Flutter web..."
    flutter precache --web
fi

# Verify Flutter is working
echo "Verifying Flutter installation..."
flutter --version
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter verification failed"
    exit 1
fi

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: flutter pub get failed"
    exit 1
fi

# Build for web
echo "Building Flutter web app..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "ERROR: flutter build web failed"
    exit 1
fi

echo "=== Build Complete Successfully ==="
exit 0
