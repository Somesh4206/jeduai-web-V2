#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Netlify build for Flutter web app..."

# Use FLUTTER_VERSION env var if set, otherwise default to "stable"
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="$HOME/flutter"

# Install Flutter if not already present
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "📦 Installing Flutter ($FLUTTER_VERSION)..."
  git clone -b "$FLUTTER_VERSION" --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  echo "✅ Flutter already installed at $FLUTTER_DIR"
fi

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

# Verify Flutter is available
echo "🔍 Verifying Flutter installation..."
flutter --version

# Enable web support
echo "🌐 Enabling Flutter web..."
flutter config --enable-web

# Download web artifacts
echo "📥 Downloading web artifacts..."
flutter precache --web

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release

echo "✅ Build complete! Output in build/web/"
